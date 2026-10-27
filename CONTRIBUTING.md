# Working on Clink

A light workflow for a one-person hobby project. The aim is to keep `main` working without adding paperwork.

## Branches

`main` is the only long-lived branch. It should always build and run.

| Change | Where it goes |
|---|---|
| Typo, README edit, one-line fix | Commit straight to `main` |
| Anything bigger (a feature, a refactor, a risky fix) | A short-lived branch, merged with a pull request |

Branch names start with what kind of change it is:

- `feature/<short-name>`, e.g. `feature/watch-complication`
- `fix/<short-name>`, e.g. `fix/crash-on-launch`
- `chore/<short-name>` for tooling, dependencies and docs, e.g. `chore/ci-build`

Keep branches small and merge them within a few days. Merge with **Squash and merge**, so each pull request becomes one commit on `main`. GitHub deletes the branch after the merge.

`main` is protected against force-pushes and deletion. Pull requests can only be merged once the CI check (**Build and test**) passes. As the repo admin, you can still push small changes straight to `main`, and CI runs on them after the push.

## Commit messages

Use a short summary line in the imperative ("Add heart rate screen", not "Added..."), under about 70 characters. Add a blank line and more detail if the change needs explaining.

## Versions

Apple apps have two numbers. Both are set at the project level in Xcode, so the iPhone and Watch apps always match. Apple requires them to.

| Setting in Xcode | Example | Rule |
|---|---|---|
| **Version** (`MARKETING_VERSION`) | `0.1.0` | What users see. Uses [semantic versioning](https://semver.org): `MAJOR.MINOR.PATCH`. |
| **Build** (`CURRENT_PROJECT_VERSION`) | `7` | A whole number that goes up by one for every build you upload to TestFlight or the App Store. Never reused. |

For the version number:

- Stay on `0.x` until the first public release. Then go to `1.0.0`.
- Bump **PATCH** (`1.0.1`) for bug fixes only.
- Bump **MINOR** (`1.1.0`) for new features.
- Bump **MAJOR** (`2.0.0`) for big redesigns or breaking changes, e.g. dropping support for an iOS version.

## Releases

When a build goes to TestFlight or the App Store:

1. On `main`, bump the version and build number in Xcode (target → General → Identity). Commit as `Release 0.2.0`.
2. Tag that commit and push the tag:

   ```bash
   git tag -a v0.2.0 -m "Release 0.2.0"
   git push origin v0.2.0
   ```

3. Create a GitHub release from the tag with a few lines on what changed:

   ```bash
   gh release create v0.2.0 --generate-notes
   ```

4. Archive in Xcode (Product → Archive) and upload.

If you need a fix for a released version while `main` has moved on, branch from its tag (`git switch -c fix/0.2.1 v0.2.0`), fix it there, then release `v0.2.1` from that branch and merge the fix back into `main`.
