---
name: verify-pr
description: Check a Clinkr pull request against the acceptance criteria of the issue it closes, record the result on the PR, and tick the met criteria in the issue once it's merged. Use when asked to verify a PR, check it against its issue, or run /verify-pr <PR#>.
---

# Verify a pull request against its issue

`/code-review` checks the code for bugs. This skill checks the change does what the issue asked for. Run it on every PR that closes or is part of an issue, after `/code-review`, and once more after merging.

The argument is the PR number. If none is given, use the PR for the current branch (`gh pr view --json number`).

## 1. Find the criteria

1. Read the PR:

   ```bash
   gh pr view <PR#> --json number,title,body,state,headRefName,headRefOid,closingIssuesReferences,files
   ```

2. The linked issues are those in `closingIssuesReferences`, plus any `Part of #N` in the body. If there are none, say the PR has no linked issue and stop. That's fine for chores.
3. Read each issue with `gh issue view <N> --json number,title,body,state`. The **acceptance criteria** are its checkbox items (`- [ ]` and `- [x]`), under every heading: "Done when", "Localization" and any others. The **Details** bullets are the spec. Check them too, but report them separately, since they don't decide whether the issue is done.
4. If the PR is already merged (`state` is `MERGED`), go to [After merging](#after-merging).

## 2. Check each criterion

Work on the PR's exact commit, `headRefOid`:

- If `git rev-parse HEAD` already matches it, use the current checkout.
- Otherwise don't switch this checkout's branch: the PR branch is often open in another worktree, and git refuses to check it out twice. Add a temporary worktree at that commit instead, work there, and remove it at the end:

  ```bash
  git fetch origin "pull/<PR#>/head"
  git worktree add --detach <scratch>/verify-pr-<PR#> <headRefOid>
  # ... checks ...
  git worktree remove <scratch>/verify-pr-<PR#>
  ```

Give each criterion one verdict, with evidence:

| Verdict | When |
|---|---|
| **Met** | A test asserts it (name the test), or you saw it working in the simulator (say what you did and saw) |
| **Deferred** | The PR says it's left to another issue, and that issue exists and is open. If the issue doesn't list the criterion yet, step 3 adds it |
| **Not met** | The diff doesn't do it, or it does something else, or it's deferred to an issue that's closed or doesn't exist |
| **Can't verify** | Neither a test nor the simulator can show it. Say what the user should check by hand |

How to gather the evidence:

- **Tests:** CI already runs `scripts/test.sh` on the PR. Read its result with `gh pr checks <PR#> --json name,bucket`. If **Build and test** passed, rely on it. If it failed, report that and stop. Run `scripts/test.sh` locally only if CI hasn't finished. Then look for a test that covers each criterion, in `SharedTests/`, `ClinkrTests/`, `ClinkrUITests/` and `Clinkr Watch AppTests/`. A test that only exists but doesn't assert the behaviour doesn't count.
- **Simulator:** for anything a user would see or tap, follow the `run` skill, then do what the criterion describes and take a screenshot. Use the smallest Watch (40 or 41mm) for size and fit criteria. For localization criteria, launch the app in each language instead of changing the simulator's settings, for example in Spanish (Argentina):

  ```bash
  xcrun simctl launch --terminate-running-process <udid> <bundle-id> -AppleLanguages "(es-AR)" -AppleLocale es_AR
  ```

- **Code:** reading the diff is enough only for criteria that aren't observable, like "no confirmation dialogs". Say that's what you relied on.

Don't mark something Met because the PR description says so. Check it yourself.

## 3. Report and record

While the PR is open, record the result on the PR only. The issue's boxes change after merging, so they never claim work that isn't on `main`.

1. Show the user a table: criterion, verdict, evidence. Put Not met and Can't verify first. List any Details bullets the diff contradicts after it.
2. Keep one result comment on the PR. Start it with `## Acceptance criteria check` and the commit it checked (`headRefOid`). If an earlier one exists, replace its body rather than adding another:

   ```bash
   id=$(gh api "repos/{owner}/{repo}/issues/<PR#>/comments" \
     --jq '[.[] | select(.body | startswith("## Acceptance criteria check"))] | last | .id // empty')
   # no id: gh pr comment <PR#> --body-file <file>
   # id:    gh api "repos/{owner}/{repo}/issues/comments/$id" -X PATCH -F body=@<file>
   ```

3. In the PR body's **Acceptance criteria** section, set each box from this run's verdict: `- [x]` for Met, `- [ ]` for everything else, unticking any box an earlier run ticked. Change only those lines (`gh pr view <PR#> --json body --jq .body`, edit, then `gh pr edit <PR#> --body-file <file>`).
4. For each **Deferred** criterion whose target issue doesn't list it yet, add it there as a new checkbox under "Done when", with "(from #N)" at the end.
5. If the PR says `Closes #N` but any criterion of #N is Deferred or Not met, the issue would close with work left. Tell the user and suggest changing the PR body to `Part of #N`.

End with one line:

- **Ready**: every criterion is Met or Deferred.
- **Not ready**: list what's Not met.
- **Needs a manual check**: list the Can't verify items.

## After merging

Run `/verify-pr <PR#>` again once the PR is merged, to tick the issue's boxes. Don't re-check the criteria:

1. Find the PR's `## Acceptance criteria check` comment. If its commit isn't the merged `headRefOid`, the last pushes weren't checked: say so and stop, so the user can decide.
2. In each linked issue, tick the boxes that comment marks **Met**. Don't untick anything: another merged PR may have met it. Change `- [ ]` to `- [x]` on exactly those lines and leave the rest of the body as it is:

   ```bash
   gh issue view <N> --json body --jq .body > <scratch>/issue.md
   # edit the ticked lines in <scratch>/issue.md
   gh issue edit <N> --body-file <scratch>/issue.md
   ```

3. If the issue is still open and every box is now ticked, tell the user it can be closed.
