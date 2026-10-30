# Decisions

Choices about how Clinkr works and how it's built, with the reason behind each one, newest first. The aim is to remember *why* something is the way it is before changing it.

Add an entry in the same pull request that makes the decision. Keep it to a few lines. To change a past decision, add a new entry and mark the old one **Replaced by** the new one, instead of rewriting it.

What changed in each release is in the [GitHub releases](https://github.com/pablocolaiacovo/clinkr/releases), so there's no separate changelog.

## 2026-10-30 · Record decisions in this file

- **Decision:** One decision log in `docs/DECISIONS.md`, with short dated entries.
- **Why:** Reasons were scattered across pull request descriptions and got lost once the code moved on.
- **Instead of:** A changelog, which GitHub releases already cover, or a folder with one file per decision, which is more than a one-person project needs.
- **PR:** [#64](https://github.com/pablocolaiacovo/clinkr/pull/64)

## 2026-10-30 · Update docs and diagrams in every pull request

- **Decision:** Updating the docs a change affects is the first step of every pull request, with a diagram or screenshot when it explains something faster than text.
- **Why:** The docs fell behind after a few pull requests that didn't update them.
- **PR:** [#64](https://github.com/pablocolaiacovo/clinkr/pull/64)

## 2026-10-30 · Comments only where code can't explain itself

- **Decision:** Comments are only for complex blocks that stay complex after simplifying, and for legally required headers. Changes delete unnecessary comments in the files they touch.
- **Why:** Clear names and small pieces explain code better than comments, which go stale.
- **PR:** [#62](https://github.com/pablocolaiacovo/clinkr/pull/62)

## 2026-10-29 · Save tonight on the Watch, in a file

- **Decision:** The Watch keeps tonight's night and the finished nights waiting for the iPhone in `nights.json`, written atomically after every change. A drink 12 hours or more after the last one ends the forgotten night and starts a new one.
- **Why:** Force-quitting the app, a restart or a dead battery must never lose tonight's drinks.
- **PR:** [#60](https://github.com/pablocolaiacovo/clinkr/pull/60)

## 2026-10-29 · `/code-review` on every pull request

- **Decision:** Every pull request gets a `/code-review` in Claude Code before merging, however small.
- **Why:** Every change gets a second look before it reaches `main`. GitHub doesn't enforce it, so it's part of the checklist in `CONTRIBUTING.md`.
- **PR:** [#61](https://github.com/pablocolaiacovo/clinkr/pull/61)

## 2026-10-29 · Screens use design tokens by name

- **Decision:** Colors, text styles, spacing, radii and drink glyphs live in `Shared/` and come from the [design system](https://claude.ai/artifact/MUR9q8zqsWysfgui8mdNsh). Screens use them by name, never raw values or emoji.
- **Why:** Both apps stay consistent with the design system, and a change to a token changes every screen at once.
- **PR:** [#59](https://github.com/pablocolaiacovo/clinkr/pull/59)

## 2026-10-29 · One data model in `Shared/`

- **Decision:** `DrinkType`, `DrinkEntry` and `Night` live in `Shared/`, compiled into both apps, and are `Codable`. Pace is left out for nights under 15 minutes.
- **Why:** Both apps work with the same nights, which need to travel between the Watch and the iPhone. A one-hour floor on pace would understate short nights.
- **PR:** [#47](https://github.com/pablocolaiacovo/clinkr/pull/47)

## 2026-10-28 · Name the app Clinkr

- **Decision:** The app is called Clinkr, with bundle IDs under `com.colaiacovo.clinkr`.
- **Why:** Other apps on the App Store already use the name Clink.
- **PR:** [#45](https://github.com/pablocolaiacovo/clinkr/pull/45)

## 2026-10-27 · One test script for local runs and CI

- **Decision:** `scripts/test.sh` runs lint and the iPhone and Watch tests, and GitHub Actions runs the same script.
- **Why:** What passes locally passes in CI, with one place to change.
- **PR:** [#2](https://github.com/pablocolaiacovo/clinkr/pull/2)

## 2026-10-27 · A light workflow

- **Decision:** `main` plus short-lived branches, squash-merged. Semantic versioning, staying on `0.x` until the first public release.
- **Why:** Keep `main` working without adding paperwork to a one-person project.
- **PR:** [#1](https://github.com/pablocolaiacovo/clinkr/pull/1)

## From the start · Self-care, never drink counts

- **Decision:** Clinkr is playful, but it's about taking care of yourself and remembering the night. Fun features reward the night, friends, water and getting home, never the number of drinks, and copy never judges amounts.
- **Why:** It's the app's founding idea, and App Store Review Guideline 1.4.3 rejects apps that encourage excessive drinking.
