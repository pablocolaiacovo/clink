---
name: release
description: Cut a new Clink release - bump the version and build number, commit, tag, and create the GitHub release. Use when asked to release, ship, tag, or bump the version.
---

# Release Clink

This follows the Releases section of `CONTRIBUTING.md`.

## 1. Decide the new version

Read the current values from `Clink.xcodeproj/project.pbxproj`:

```bash
grep -E "MARKETING_VERSION|CURRENT_PROJECT_VERSION" Clink.xcodeproj/project.pbxproj | sort -u
```

List the changes since the last tag with `git log --oneline $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD`. Propose the next version using the rules in CONTRIBUTING.md (patch for fixes, minor for features, stay on `0.x` before the first public release). The build number goes up by one. **Confirm both numbers with the user before changing anything.**

## 2. Check the release is ready

- You're on `main`, it's up to date with `origin/main`, and the working tree is clean.
- `scripts/test.sh` passes.

Stop and report if either check fails.

## 3. Bump and commit

Update every `MARKETING_VERSION` and `CURRENT_PROJECT_VERSION` line in `project.pbxproj`. There's one for Debug and one for Release, and both apps use them. Confirm with the grep above that every line changed. Then:

```bash
git commit -am "Release <version>"
```

## 4. Tag, push and publish

These steps are public, so **ask the user before running them**:

```bash
git push origin main
git tag -a v<version> -m "Release <version>"
git push origin v<version>
gh release create v<version> --title "<version>" --generate-notes
```

## 5. Report

Give the release URL. Remind the user that uploading to TestFlight or the App Store is a separate step in Xcode: Product → Archive, then Distribute App.
