# Decisions

Choices about how Clinkr works and how it's built, with the reason behind each one, newest first. The aim is to remember *why* something is the way it is before changing it.

Add an entry in the same pull request that makes the decision. Keep it to a few lines. To change a past decision, add a new entry and mark the old one **Replaced by** the new one, instead of rewriting it.

What changed in each release is in the [GitHub releases](https://github.com/pablocolaiacovo/clinkr/releases), so there's no separate changelog.

## 2026-10-30 · Watch screens are vertical pages, Tonight first

- **Decision:** The Watch's screens are vertical pages in the order Tonight, Add, Night. Tonight's ring grows 8 slots at a time and is never shown as full or over. When space runs out, as on small Watches or at large text sizes, the count shrinks before the caption and waters do. The Undo toast covers the lower part of the ring on Tonight, but pushes Add's list up so its buttons can scroll clear of it.
- **Why:** Vertical pages are how watchOS apps move between screens now, and the Digital Crown scrolls them. The count is the one thing on Tonight that stays readable at a smaller size. An inset would shrink the ring every time the toast shows.
- **PR:** [#67](https://github.com/pablocolaiacovo/clinkr/pull/67)

## 2026-10-30 · Undo after every add, never a confirmation

- **Decision:** After any add on the Watch, a toast offers Undo for 5 seconds. It pushes the screen's content up rather than covering it, so every drink button can still be reached. With VoiceOver on, it's read out and stays until the next add or an undo. Its strings live in a Watch-only `Localizable.xcstrings`.
- **Why:** Mistaps happen in the dark, and one tap should take them back. An overlay hid the bottom drink buttons on the 40mm Watch, and 5 seconds isn't enough to reach a button with VoiceOver.
- **Instead of:** Confirmation dialogs, which slow down every add, or putting Watch-only strings in `Shared.xcstrings`, which both apps include.
- **PR:** [#65](https://github.com/pablocolaiacovo/clinkr/pull/65)

## 2026-10-30 · Check pull requests against their issue's acceptance criteria

- **Decision:** Each PR lists its issue's acceptance criteria with evidence, using the PR template, and `/verify-pr` checks each one with tests and the simulators. Results are recorded on the PR while it's open; the issue's boxes are ticked only after merging. A PR that leaves criteria for later says `Part of #N`, not `Closes #N`.
- **Why:** CI and `/code-review` check the code, not the requirements. #8 was closed by #63 with its boxes unticked, and a deferred criterion never reached #7.
- **Instead of:** A CI check that blocks merging on unticked boxes, which is stricter than a light workflow needs.
- **PR:** [#66](https://github.com/pablocolaiacovo/clinkr/pull/66)

## 2026-10-30 · Record decisions in this file

- **Decision:** One decision log in `docs/DECISIONS.md`, with short dated entries.
- **Why:** Reasons were scattered across pull request descriptions and got lost once the code moved on.
- **Instead of:** A changelog, which GitHub releases already cover, or a folder with one file per decision, which is more than a one-person project needs.
- **PR:** [#64](https://github.com/pablocolaiacovo/clinkr/pull/64)

## 2026-10-30 · Update docs and diagrams in every pull request

- **Decision:** Updating the docs a change affects is the first step of every pull request, with a diagram or screenshot when it explains something faster than text.
- **Why:** The docs fell behind after a few pull requests that didn't update them.
- **PR:** [#64](https://github.com/pablocolaiacovo/clinkr/pull/64)

## 2026-10-30 · Spanish first, in the local slang

- **Decision:** Clinkr launches in Spanish, and its words follow the slang of the launch region instead of formal Spanish, like Birra and Trago for beer and cocktail.
- **Why:** Spanish is the owner's first language and the first launch language, and the slang fits the app's playful tone better than the formal words.
- **Instead of:** Formal Spanish, like Cerveza and Cóctel.
- **PR:** [#63](https://github.com/pablocolaiacovo/clinkr/pull/63)

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

## 2026-10-27 · Require iOS 26 and watchOS 26

- **Decision:** Both apps need the newest iOS and watchOS, 26, and the code uses the newest Swift and SwiftUI, including Swift 6 strict concurrency.
- **Why:** The app's code should be state of the art.
- **Commit:** [3d6eeee](https://github.com/pablocolaiacovo/clinkr/commit/3d6eeee)

## From the start · Self-care, never drink counts

- **Decision:** Clinkr is playful, but it's about taking care of yourself and remembering the night. Fun features reward the night, friends, water and getting home, never the number of drinks, and copy never judges amounts.
- **Why:** It's the app's founding idea, and App Store Review Guideline 1.4.3 rejects apps that encourage excessive drinking.
