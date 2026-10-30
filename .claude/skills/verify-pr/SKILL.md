---
name: verify-pr
description: Check a Clinkr pull request against the acceptance criteria of the issue it closes, tick the criteria that are met, and post the result on the PR. Use when asked to verify a PR, check it against its issue, or run /verify-pr <PR#>.
---

# Verify a pull request against its issue

`/code-review` checks the code for bugs. This skill checks the change does what the issue asked for. Run it on every PR that closes or is part of an issue, after `/code-review`.

The argument is the PR number. If none is given, use the PR for the current branch (`gh pr view --json number`).

## 1. Find the criteria

1. Read the PR:

   ```bash
   gh pr view <PR#> --json number,title,body,headRefName,headRefOid,closingIssuesReferences,files
   ```

2. The linked issues are those in `closingIssuesReferences`, plus any `Part of #N` in the body. If there are none, say the PR has no linked issue and stop. That's fine for chores.
3. Read each issue with `gh issue view <N> --json number,title,body,state`. The **acceptance criteria** are its checkbox items (`- [ ]` and `- [x]`), under every heading: "Done when", "Localization" and any others. The **Details** bullets are the spec. Check them too, but report them separately, since they don't decide whether the issue is done.

## 2. Check each criterion

Make sure you're looking at the PR's code: `git rev-parse HEAD` must match `headRefOid`. If it doesn't and the working tree is clean, run `gh pr checkout <PR#>`. Otherwise ask the user first.

Give each criterion one verdict, with evidence:

| Verdict | When |
|---|---|
| **Met** | A test asserts it (name the test), or you saw it working in the simulator (say what you did and saw) |
| **Deferred** | The PR says it's left to another issue. Check that issue exists, is open and lists the criterion |
| **Not met** | The diff doesn't do it, or it does something else |
| **Can't verify** | Neither a test nor the simulator can show it. Say what the user should check by hand |

How to gather the evidence:

- **Tests:** run `scripts/test.sh` once. Then look for a test that covers each criterion, in `SharedTests/`, `ClinkrTests/`, `ClinkrUITests/` and `Clinkr Watch AppTests/`. A test that only exists but doesn't assert the behaviour doesn't count.
- **Simulator:** for anything a user would see or tap, follow the `run` skill, then do what the criterion describes and take a screenshot. Use the smallest Watch (40 or 41mm) for size and fit criteria, and switch language for localization criteria.
- **Code:** reading the diff is enough only for criteria that aren't observable, like "no confirmation dialogs". Say that's what you relied on.

Don't mark something Met because the PR description says so. Check it yourself.

## 3. Report and record

1. Show the user a table: criterion, verdict, evidence. Put Not met and Can't verify first. List any Details bullets the diff contradicts after it.
2. Post the same table as a PR comment, with `gh pr comment <PR#> --body-file <file>`. Start it with `## Acceptance criteria check` and the commit it checked (`headRefOid`). Run again after new pushes: a later comment replaces the earlier one in meaning, so don't edit old comments.
3. In the issue, tick the boxes that are **Met**, and only those. Change `- [ ]` to `- [x]` on exactly those lines and leave the rest of the body as it is:

   ```bash
   gh issue view <N> --json body --jq .body > <scratch>/issue.md
   # edit the ticked lines in <scratch>/issue.md
   gh issue edit <N> --body-file <scratch>/issue.md
   ```

4. For each **Deferred** criterion whose target issue doesn't list it yet, add it there as a new checkbox under "Done when", with "(from #N)" at the end.
5. If the PR says `Closes #N` but any criterion of #N is Deferred or Not met, the issue would close with work left. Tell the user and suggest changing the PR body to `Part of #N`.

## Verdict

End with one line:

- **Ready**: every criterion is Met or Deferred to an open issue that lists it.
- **Not ready**: list what's Not met.
- **Needs a manual check**: list the Can't verify items.
