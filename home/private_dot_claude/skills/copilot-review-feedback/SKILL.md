---
name: copilot-review-feedback
description: Review Copilot comments on a GitHub PR, validate each suggestion, apply valid fixes, commit, reply with commit links, and resolve threads.
argument-hint: "<PR number>"
---

# Copilot Review Feedback

GitHub PR에 달린 Copilot 리뷰 코멘트를 가져와서, 각 제안이 유효한 수정인지 검증하고, 유효한 것만 수정 → 커밋 → 코멘트 답글(커밋 링크) → resolve 하는 자동화 스킬.

## 사용법

```
/copilot-review-feedback 219
```

## 작업 방식

- 먼저 할 일 목록을 정리해서 보여준다
- 유저가 승인하면 해당 작업 범위 내에서는 확인 없이 쭉 진행
- 중간에 일일이 물어보지 않는다

## 전체 흐름

```
1. PR 코멘트 수집 (Copilot 리뷰만 필터)
2. 각 코멘트별 검증 (코드 읽기 → 유효성 판단)
3. 유효한 수정 적용 + 커밋
4. Push (커밋 링크가 유효하려면 리모트에 먼저 올라가야 함)
5. 각 코멘트에 답글 + 커밋 링크 달기
6. 모든 Copilot 스레드 resolve
```

## 실행 절차

### Step 1: PR 정보 수집 및 브랜치 이동

```bash
REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner')
PR_NUMBER={argument}

# PR 기본 정보 및 브랜치명 가져오기
PR_BRANCH=$(gh pr view $PR_NUMBER --json headRefName -q '.headRefName')
gh pr view $PR_NUMBER --json title,state,headRefName
```

**해당 PR의 브랜치로 checkout한다.** 수정 및 커밋은 PR 브랜치에서 이루어져야 한다.

```bash
git checkout $PR_BRANCH
git pull origin $PR_BRANCH
```

현재 브랜치가 이미 PR 브랜치와 동일하면 checkout을 건너뛴다.

### Step 2: Copilot 코멘트 수집

```bash
# Copilot 리뷰 코멘트만 필터링
gh api repos/$REPO/pulls/$PR_NUMBER/comments \
  --jq '.[] | select(.user.login == "Copilot" or .user.login == "copilot" or (.user.type == "Bot" and (.user.login | test("copilot"; "i")))) | {id, path, line: (.line // .original_line), body}'
```

Copilot 코멘트가 없으면: "Copilot 리뷰 코멘트가 없습니다." 출력 후 종료.

### Step 3: 각 코멘트 검증

각 Copilot 코멘트에 대해:

1. **해당 파일의 관련 코드를 읽는다** (코멘트의 `path`와 `line` 기준, 전후 20줄)
2. **Copilot 제안의 유효성을 판단한다:**
   - ✅ **유효**: 실제 버그, 누락된 에러 핸들링, 잘못된 연산자, 누락된 의존성 등
   - ⚠️ **부분 유효**: 방향은 맞지만 제안된 코드가 부정확 (예: 무한 루프 위험, 타입 불일치)
   - ❌ **불필요**: 이미 처리됨, 의도된 동작, false positive, 스타일 취향 차이

3. **검증 결과를 테이블로 정리하여 사용자에게 보여준다:**

```
| # | 파일 | 라인 | 요약 | 판정 | 이유 |
|---|------|------|------|------|------|
| 1 | RightSection.tsx | 64 | ?? → || | ✅ 유효 | false가 nullish가 아니라 통과됨 |
| 2 | edit-question.tsx | 523 | 에러 핸들링 | ✅ 유효 | API 실패 시 무처리 |
| 3 | analysis.tsx | 153 | useEffect deps | ⚠️ 부분 | passageGroupIdParam만 추가 필요 |
```

4. **사용자에게 확인을 요청한다:**
   - "위 검증 결과대로 수정을 진행할까요? (❌ 판정은 스킵, ⚠️는 수정된 방향으로)"
   - 사용자가 특정 항목을 제외/포함 변경할 수 있음

### Step 4: 수정 적용 및 커밋

유효(✅) 및 부분 유효(⚠️)로 판정된 항목을 **관심사별로 묶어** 커밋한다:

- 같은 패턴의 수정은 하나의 커밋으로 (예: 에러 핸들링 3건 → 1커밋)
- 서로 다른 관심사는 별도 커밋 (예: 연산자 수정, 에러 핸들링, deps 수정 → 3커밋)
- 각 커밋 메시지 형식: `fix: {변경 요약}`
- 커밋 메시지 끝에 `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` 포함
- 매 커밋 전 `pnpm type-check` 실행. 실패하면 수정 후 재시도.

### Step 5: Push + 코멘트 답글 + 커밋 링크

모든 커밋이 완료된 후, **반드시 push를 먼저 실행한다.** push가 완료되어야 커밋 링크가 GitHub에서 유효하다.

```bash
git push
```

push 완료 후 각 Copilot 코멘트에 답글을 단다:

**✅ 유효 / ⚠️ 부분 유효 항목:**
```
수정 완료했습니다.
https://github.com/{repo}/commit/{hash}
```

부분 유효의 경우 Copilot 제안과 다르게 수정한 이유를 간단히 추가:
```
수정 완료했습니다. selectedPassages.length는 guard 조건과 충돌하여 passageGroupIdParam만 추가했습니다.
https://github.com/{repo}/commit/{hash}
```

**❌ 불필요 항목:**
```
검토 결과 수정이 불필요합니다. {이유}
```

답글 API:
```bash
gh api repos/$REPO/pulls/$PR_NUMBER/comments/{comment_id}/replies \
  -X POST -f body="{message}"
```

### Step 6: Resolve

모든 답글이 완료된 후, unresolved Copilot 스레드를 resolve한다:

```bash
# unresolved thread ID 조회
gh api graphql -f query='
query {
  repository(owner: "{owner}", name: "{name}") {
    pullRequest(number: {pr_number}) {
      reviewThreads(first: 50) {
        nodes {
          id
          isResolved
          comments(first: 1) {
            nodes {
              author { login }
            }
          }
        }
      }
    }
  }
}'
```

Copilot이 작성한 unresolved 스레드만 필터하여 resolve:
```bash
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "{thread_id}"}) {
    thread { isResolved }
  }
}'
```

**팀원 리뷰 스레드는 절대 resolve하지 않는다.** Copilot(봇) 코멘트만 대상.

### Step 7: 완료 요약

```
## Copilot Review Feedback 완료

PR: #{pr_number}
처리: {n}건 수정, {m}건 스킵
커밋: {k}개

| # | 파일 | 판정 | 커밋 |
|---|------|------|------|
| 1 | RightSection.tsx:64 | ✅ 수정 | abc1234 |
| 2 | edit-question.tsx:523 | ✅ 수정 | def5678 |
| 3 | ... | ❌ 스킵 | — |
```

## 주의사항

- **팀원 리뷰는 건드리지 않는다.** Copilot(봇) 코멘트만 대상.
- **코드를 읽지 않고 판단하지 않는다.** 반드시 해당 파일/라인을 읽고 검증.
- **부분 유효(⚠️)는 Copilot 제안을 그대로 적용하지 않고, 올바른 방향으로 수정한다.**
  - 예: Copilot이 `selectedPassages.length` deps 추가를 제안했지만 무한 루프 위험 → `passageGroupIdParam`만 추가
- **수정 후 반드시 type-check를 통과해야 한다.**
- **커밋은 관심사별로 묶되, 하나의 커밋에 너무 많은 변경을 넣지 않는다.**
