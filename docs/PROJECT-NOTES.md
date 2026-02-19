# Project Notes — Build Retrospective

This document captures lessons learned during the build process. Every project has rough edges in its commit history — what matters is whether you learned from them.

---

## February 5: Formatting Commit Burst

**What happened:** 14 commits in quick succession, all formatting fixes, pushed via the GitHub web editor.

**Why it happened:** I was editing README files directly on GitHub.com to fix markdown rendering issues. Each save created a new commit, and I couldn't preview how the markdown would render before committing. The result was a noisy commit history that obscures the real work happening that day.

**What I learned:** Always preview markdown locally before pushing. VS Code's built-in markdown preview (`Ctrl+Shift+V`) catches rendering issues without creating throwaway commits. For multi-file documentation changes, batch them into a single commit with a clear message like `docs: fix markdown formatting across phase READMEs`.

**What I do now:** All documentation edits happen locally in VS Code, previewed before commit. If I catch multiple formatting issues, I fix them all and commit once.

---

## February 15: Module File Recovery

**What happened:** A directory restructure in phase 03 (modules) resulted in files going missing from the repository. A recovery commit was needed to restore the module source files.

**Why it happened:** I restructured the directory layout (moving files into `modules/vpc/`) without verifying `git status` before committing. Git doesn't automatically track file moves — it sees a delete and a create. When the add was incomplete, the "delete" half got committed but the "create" half didn't, leaving the module files missing from the repo.

**What I learned:** Before any directory restructure, run `git status` and `git diff --staged` to verify that every moved file appears as both "deleted" and "new file" (or as "renamed" if git detects the move). The `git mv` command handles this atomically and is safer than manual `mv` + `git add`.

**What I do now:** Directory restructures use `git mv` exclusively. I verify with `git status` before committing, and I test with `terraform init && terraform validate` after the restructure to confirm nothing broke.

---

## Why This Document Exists

These aren't mistakes to hide — they're the kind of operational lessons that only come from building real projects. The formatting burst taught me to preview locally. The file recovery taught me to verify state before restructuring. Both habits carry directly into production infrastructure work where a bad commit can have real consequences.
