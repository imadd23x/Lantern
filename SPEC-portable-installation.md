# Spec: private portable installation

Inherits code style and safety rules from `SPEC.md`. The user reversed the public
release decision: retain supplied assets and keep GitHub private. Do not rewrite
history or change the existing application identifier.

## Outcome

The repository owner can download a versioned native app on another Mac without
copying account settings, credentials, hook trust, session contents or this Mac's
absolute build paths. macOS 15+ remains required. Package both Apple Silicon and
Intel slices; Intel execution must be reported unverified without Intel hardware.

## Implementation plan

1. Build each architecture into a separate unsynced temporary directory, remapping
   source paths at compilation. Merge executables, render the icon on the host,
   then sign and verify the complete bundle.
2. Audit packaged binaries and archive contents. Never package local configuration,
   outputs, hooks, backups or Git history. Keep the explicitly requested assets.
3. Provide a short install guide: extract, place Lantern.app in ~/Applications or
   /Applications, launch, and configure each agent locally through its existing
   preview/backup flow. No installation-time config writes or automatic trust.
4. Attach the checked app and checksums to a private versioned GitHub release. A
   release points to an exact reviewed commit; it does not require merging the
   currently open UI branch into main or changing repository visibility.

## Limits and checks

Ad-hoc signing does not provide notarization. macOS may require explicit opening
approval on a new Mac; do not disable Gatekeeper or strip quarantine to bypass it.
Test both Mach-O slices, signature, archive extraction and resources. Validate
that no home/source path or local account/config files entered the release.

Existing settings are generated locally from the installed executable's location.
Changing a user's installed app requires a verified rollback and no pending real
approval. Release changes are reversible; no paid signing account is provisioned.
