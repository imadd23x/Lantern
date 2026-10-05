import Foundation

public enum HookNormalizer {
    public static func normalize(_ data: Data, provider: AgentProvider) throws -> AgentEvent? {
        guard data.count <= 200_000,
              let input = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let session = input["session_id"] as? String, !session.isEmpty,
              let name = input["hook_event_name"] as? String else { throw EventError.invalidPayload }
        let kind: EventKind
        switch name {
        case "SessionStart": kind = .idle
        case "UserPromptSubmit": kind = .thinking
        case "PreToolUse", "PostToolUse", "SubagentStart", "SubagentStop": kind = .working
        case "PostToolUseFailure": kind = .attention
        case "PermissionRequest": kind = .approval
        case "Notification": kind = .attention
        case "Stop": kind = .finished
        case "StopFailure": kind = .failed
        case "SessionEnd", "Interrupt": kind = .ended
        default: return nil
        }
        let tool = input["tool_name"] as? String ?? ""
        let args = input["tool_input"] as? [String: Any] ?? [:]
        let detail: String
        if let rawArgs = input["tool_input"], JSONSerialization.isValidJSONObject(rawArgs) {
            detail = String(decoding: try JSONSerialization.data(withJSONObject: rawArgs, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]), as: UTF8.self)
        } else { detail = "" }
        let summary: String
        switch kind {
        case .approval: summary = tool.isEmpty ? "Permission requested" : tool
        case .thinking: summary = "Thinking"
        case .working: summary = tool.isEmpty ? "Working" : tool
        case .finished: summary = "Turn complete"
        case .failed: summary = "Agent reported an error"
        case .attention: summary = name == "PostToolUseFailure" ? "Tool failed" : String((input["message"] as? String ?? "Needs your attention").prefix(512))
        case .idle: summary = "Ready"
        case .ended: summary = "Session ended"
        }
        // Prompts, transcripts, tool responses, and permission suggestions are deliberately omitted.
        let event = AgentEvent(provider: provider, sessionID: session, kind: kind,
            cwd: input["cwd"] as? String ?? "", summary: summary, detail: detail,
            reason: input["reason"] as? String ?? args["description"] as? String ?? "",
            turnID: input["turn_id"] as? String)
        try event.validate()
        return event
    }
}
