# dev.md — Pre‑production Checklist

- Remove any debugging logs and verbose prints in release builds
- Ensure `.env` contains only non-sensitive placeholders if repo is public
- Confirm camera/storage permission prompts have clear copy
- Verify iOS/Android build settings: release signing, versioning, icons/splash
- Recheck asset list in `pubspec.yaml` for unused images/files
- Optimize video handling for storage constraints (old clip cleanup policy)
- Validate Hive boxes migrations if models change
- Audit third‑party packages are up‑to‑date and safe
