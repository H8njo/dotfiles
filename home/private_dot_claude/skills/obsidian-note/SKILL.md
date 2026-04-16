---
name: obsidian-note
description: Create or update notes in Obsidian second-brain vault. Use when you need to document findings, save project insights, or create/update knowledge notes while working on any project.
argument-hint: "[folder/note-title] [optional: append]"
---

# Obsidian Note Manager

Create or update notes in the Obsidian second-brain vault.

## Vault

- Path: `/Users/hoonjo/obsidian/vaults/second-brain/`
- Conventions: Read `/Users/hoonjo/obsidian/vaults/second-brain/CLAUDE.md` FIRST before any operation.

## Usage

```
/obsidian-note 04 Zettelkasten/React Server Components
/obsidian-note 01 Projects/samra-mansang/features/숙제표 시스템
/obsidian-note 03 Resources/dev-tools/pnpm append
```

## 권한

- 파일 조회 (Read, Glob, Grep, ls 등) → 확인 없이 바로 진행
- 파일 수정/추가 → 확인 없이 바로 진행
- 파일 삭제만 유저 확인을 받는다

## Instructions

1. **Read CLAUDE.md** from the vault root. Follow ALL conventions (naming, linking, templates, folder structure, plugin usage, post-creation checklist).

2. **Determine the target path** from `$ARGUMENTS`.
   - If no folder prefix given, ask the user which folder it belongs to.
   - Add `.md` extension if not present.
   - Create parent directories if needed.

3. **If `append` mode**: Read the existing note, add new content under the appropriate heading. Do NOT remove existing content.

4. **If creating new note**: Apply the correct template based on the target folder.
   - `00 Inbox` → inbox template
   - `01 Projects` → project template
   - `02 Areas` → area template
   - `03 Resources` → resource template
   - `04 Zettelkasten` → zettelkasten template
   - `05 MOCs` → moc template

5. **Frontmatter**: Always include `created` (today's date) and `tags`. Add `aliases` if the concept has multiple names.

6. **Content rules**:
   - Korean by default, English for technical terms
   - Use `[[wiki links]]` for all related concepts (HIGHEST PRIORITY)
   - Use callouts (`[!note]`, `[!tip]`, `[!warning]`, `[!example]`)
   - Use Tasks plugin syntax for actionable items (`- [ ]` with priority emoji)
   - Specify language tags for all code blocks
   - Dataview queries ONLY in index/overview notes

7. **Post-creation checklist** (MANDATORY):
   - MOC check: Does a relevant MOC exist? Add the new note's link.
   - MOC creation: 3+ notes on same topic without MOC? Create one.
   - Project index update: If note belongs to a project, update the index note.
   - Inline link check: Add `[[links]]` for concepts referencing existing notes.
   - Cross-note enrichment: Update up to 3 directly related notes (small additions only).

8. **Folder organization**: If notes can be separated into 2+ distinct concerns, create subfolders. Apply consistent grouping logic.
