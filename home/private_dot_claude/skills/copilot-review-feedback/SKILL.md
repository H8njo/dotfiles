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

## 전체 흐름

```
1. PR 코멘트 수집 (Copilot 리뷰만 필터)
2. 각 코멘트별 검증 (코드 읽기 → 유효성 판단)
3. 유효한 코멘트별로 수정 적용 (1코멘트 = 1커밋)
4. Push (커밋 링크가 유효하려면 리모트에 먼저 올라가야 함)
5. 각 코멘트에 답글 + 자기 커밋 링크 달기 (1:1 매핑)
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

### Step 3: 각 코멘트 검증 + 위험도/중요도 분석 + 사용자 승인

각 Copilot 코멘트에 대해:

1. **해당 파일의 관련 코드를 읽는다** (코멘트의 `path`와 `line` 기준, 전후 20줄. 필요 시 호출 컨텍스트, 사용처, 디자인 의도까지 확장 조사)

2. **Copilot 제안의 유효성을 엄밀하게 판단한다.** "Copilot이 말하니까 맞을 것"이라는 가정 금지. 다음을 적극적으로 의심한다:
   - 원래 코드가 의도된 동작일 가능성 (디자인/UX 의도)
   - Copilot의 진단이 과장되거나 false positive일 가능성 (특히 React 패턴, "render 중 setState" 등 Copilot이 자주 오버리액팅하는 항목)
   - 제안한 수정이 오히려 regression을 일으킬 가능성 (예: 즉시 동기 리셋이 의도였는데 useEffect 전환 시 한 프레임 stale)
   - 디자인 의도를 코드만 보고 단정 가능한지 (불가능하면 ❌ 또는 ⚠️로 분류하고 사용자에게 확인 요청)

3. **유효성 판정:**
   - ✅ **유효**: 실제 버그, 누락된 에러 핸들링, 잘못된 연산자, 누락된 의존성 등 객관적 결함
   - ⚠️ **부분 유효**: 방향은 맞지만 제안 코드가 부정확 (무한 루프, 타입 불일치, regression 위험)
   - ❓ **불확실**: 디자인 의도/사용자 의도 확인 필요 — 사용자에게 물어야 함
   - ❌ **불필요**: 이미 처리됨, 의도된 동작, false positive, 스타일 취향, Copilot 과잉 진단

4. **각 항목에 위험도(Risk)와 중요도(Importance)를 매긴다:**
   - **위험도 (수정 시 부작용 가능성):** 낮음 / 중간 / 높음
     - 높음: 동작 변경, 시각적 변경, 다른 컴포넌트 영향, 동기→비동기 전환 등
     - 중간: 로직 보강, 조건 강화
     - 낮음: 주석/타입/포맷 정리
   - **중요도 (수정 안 했을 때의 영향):** 낮음 / 중간 / 높음
     - 높음: 명백한 버그, 사용자 영향
     - 중간: 엣지 케이스, 가독성
     - 낮음: 문서, 컨벤션

5. **검증 결과를 테이블로 정리하여 사용자에게 보고한다:**

```
| # | 파일:라인 | 요약 | 판정 | 위험도 | 중요도 | 이유 |
|---|----------|------|------|--------|--------|------|
| 1 | Foo.tsx:64 | ?? → || | ✅ 유효 | 낮음 | 높음 | false가 nullish가 아니라 통과됨 |
| 2 | Bar.tsx:194 | render 중 setState → useEffect | ❌ 불필요 | 높음 | 낮음 | React가 허용하는 정식 패턴, useEffect 전환 시 한 프레임 stale UI 발생 |
| 3 | Baz.tsx:297 | 매칭 0건일 때 dim 비활성화 | ❓ 불확실 | 중간 | 중간 | 전체 dim이 의도된 UX인지 디자인 확인 필요 |
| 4 | Qux.tsx:76 | word 모드 hover 동기화 | ✅ 유효 | 낮음 | 중간 | WordModeWithStyleIdx 스토리에서 사용되는 조합 |
```

6. **사용자에게 명시적 승인을 받는다. 승인 없이는 절대 수정 진행 금지.**
   - "위 분석대로 진행할까요? 어떤 항목을 수정/스킵하시겠습니까?"
   - ❓ 항목은 사용자가 디자인 의도를 확인해줘야 ✅ 또는 ❌로 확정됨
   - 위험도 높음 항목은 사용자가 신중하게 결정하도록 강조
   - 사용자가 "다 진행해" 같이 명시적으로 승인하기 전까지 Step 4로 넘어가지 않는다
   - 사용자가 항목별로 다른 결정(예: "1, 4만 수정")을 줄 수 있으므로 그대로 따른다

**중요: Step 3에서 "분석 결과 보고"와 "사용자 승인" 사이를 절대 건너뛰지 마라.** 검증 후 자동 진행하지 않는다.

### Step 4: 수정 적용 및 커밋 (1코멘트 = 1커밋)

유효(✅) 또는 부분 유효(⚠️)로 판정된 **코멘트별로 순차 사이클을 반복한다.** 같은 패턴/관심사여도 절대 묶지 않는다 — 답글에서 코멘트 ↔ 커밋을 1:1로 링크 걸기 위함이다.

각 코멘트마다 다음 사이클을 반복:

```
1. 해당 코멘트의 변경만 적용
2. pnpm type-check (또는 프로젝트 표준) — 실패하면 수정 후 재시도
3. git commit (해당 변경만 stage)
4. comment_id ↔ commit hash 매핑에 추가
```

규칙:
- 코멘트 N개 수정 → 커밋 정확히 N개 (5개 코멘트 중 3개 수정이면 정확히 3개 커밋)
- 다음 코멘트로 넘어가기 전 현재 코멘트의 커밋이 완료되어야 함 — 두 코멘트 변경을 한 번에 stage 금지
- 커밋 메시지 형식: `fix: {해당 코멘트의 변경 요약}` (한 코멘트 단위로 작성)
- 커밋 메시지 끝에 `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` 포함

매핑 테이블 예시:
```
comment_id 3199261004 → commit abc1234
comment_id 3199261051 → commit def5678
comment_id 3199260928 → commit fed4321
```

이 매핑은 Step 5의 답글 링크에서 필수로 사용된다.

### Step 5: Push + 코멘트 답글 + 커밋 링크 (1:1 매핑 필수)

모든 커밋이 완료된 후, **반드시 push를 먼저 실행한다.** push가 완료되어야 커밋 링크가 GitHub에서 유효하다.

```bash
git push
```

push 완료 후 각 Copilot 코멘트에 **상세한** 답글을 단다.

**핵심 원칙: 답글의 커밋 링크는 그 코멘트에 대응하는 커밋의 해시여야 한다.** Step 4에서 만든 `comment_id → commit hash` 매핑 테이블을 그대로 사용한다. 절대로 모든 답글에 같은 커밋 링크를 박지 않는다 — 그러면 코멘트 ↔ 변경의 추적이 깨진다.

검증 방법: 답글 작성 직전 매핑 테이블을 다시 출력해 본인 눈으로 확인한 뒤 진행. 매핑이 없는 코멘트(❌ 불필요)는 커밋 링크 자체를 넣지 않는다.

**원칙: "수정 완료했습니다 + 커밋 링크"만 다는 것은 금지.** 어떤 문제를, 어떻게, 왜 그렇게 처리했는지가 답글 본문만 봐도 이해되어야 한다. 미래에 코드 히스토리를 보는 사람이 PR 리뷰만으로 의사결정 맥락을 재구성할 수 있어야 한다.

**답글에 반드시 포함할 항목:**

1. **진단(원인)**: Copilot이 지적한 게 어떤 문제였는지 한 줄로 재진술 (Copilot 본문을 그대로 베끼지 말고 검증한 결과를 본인 언어로)
2. **처리 방식**: 무엇을 어떻게 바꿨는지 구체적으로 (코드 변경 요점 1~2줄)
3. **선택 근거**: 왜 그 방향으로 갔는지 — 다른 옵션이 있었다면 왜 이 옵션을 선택했는지 (특히 ⚠️ 부분 유효 항목)
4. **영향 범위/주의점** (있을 때만): regression 가능성, 추가 검증 필요한 케이스, 후속 작업
5. **커밋 링크**: 마지막 줄에 `https://github.com/{repo}/commit/{hash}` — **반드시 그 코멘트에 대응하는 자기 커밋의 해시. 다른 코멘트의 커밋이나 통합 커밋 링크 금지.**

**✅ 유효 항목 답글 템플릿:**
```
{진단 한 줄}

처리: {무엇을 어떻게 바꿨는지}
근거: {왜 이 방향인지}

https://github.com/{repo}/commit/{hash}
```

예시:
```
`??`(nullish)는 `false`를 통과시켜 disabled prop이 false일 때도 `text-muted`가 적용되지 않던 문제였습니다.

처리: `disabled !== false ?? ...` → `disabled ? ... : ''` 로 명시적 분기로 전환.
근거: `??`로는 boolean 분기 의도가 보이지 않아 가독성도 함께 개선됨.

https://github.com/{repo}/commit/{hash}
```

**⚠️ 부분 유효 항목 답글 템플릿 (Copilot 제안과 다르게 처리한 이유 명시):**
```
{진단 한 줄}

처리: {실제로 바꾼 내용}
Copilot 제안과 다른 이유: {제안 그대로면 발생할 문제 — 무한 루프, 타입 불일치, regression 등}

https://github.com/{repo}/commit/{hash}
```

예시:
```
useEffect deps에 selectedPassages가 빠진 부분 지적.

처리: passageGroupIdParam만 deps에 추가.
Copilot 제안과 다른 이유: selectedPassages.length를 deps에 넣으면 effect 내부의 setSelectedPassages 호출과 충돌해 무한 루프가 발생합니다. guard 조건(`selectedPassages.length > 0` 체크)이 이미 있으므로 passageGroupIdParam 추가만으로 충분합니다.

https://github.com/{repo}/commit/{hash}
```

**❌ 불필요 항목 답글 템플릿 (왜 수정 안 했는지 명확히):**
```
{진단 한 줄 — Copilot이 본 것}

검토 결과 수정 불필요로 판단했습니다.
이유: {원래 코드가 의도된 동작인 근거 / Copilot 진단의 부정확한 부분 / regression 위험 등}
```

예시:
```
"render 중 setState 호출이 경고/무한 루프를 유발할 수 있다"는 지적.

검토 결과 수정 불필요로 판단했습니다.
이유: 이 패턴은 React 공식 문서가 인정하는 "store info from previous renders" 패턴(조건부 setState)이며 무한 루프가 발생하지 않습니다. useEffect로 옮길 경우 모드 전환 후 한 프레임 동안 stale state가 자식 컴포넌트에 전달되는 시각적 regression 위험이 있어 현재 패턴을 유지합니다.
```

**작성 시 주의:**
- 막연한 표현 금지: "개선했습니다", "정리했습니다" 같은 모호한 표현 대신 구체적인 변경 내용 적기
- Copilot 본문 복붙 금지: 본인이 검증한 결과를 본인 언어로 재진술
- 코드 스니펫은 1~2줄 핵심만, 길어지면 커밋 본문에서 보도록 유도
- ❓(불확실)였다가 사용자 확인으로 ❌가 된 항목은 답글에 사용자 확인 결과를 반영 (예: "디자인 의도 확인 결과 현재 동작이 의도된 것으로 확인됨")

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

- **사용자 명시 승인 없이 수정하지 않는다.** Step 3의 검증 결과 보고 이후, 사용자가 "진행해" 류의 명시적 승인을 줄 때까지 Step 4 이상으로 절대 진행하지 않는다. 자동 적용 금지.
- **Copilot을 무조건 신뢰하지 않는다.** Copilot은 React 패턴(특히 "render 중 setState"), 의도된 디자인 결정, 보수적 가드 코드 등에서 false positive를 자주 낸다. 원래 코드가 의도된 동작일 가능성을 항상 의심한다.
- **디자인 의도를 코드만으로 단정하지 않는다.** UX/디자인이 얽힌 코멘트는 ❓(불확실)로 분류하고 사용자에게 확인 요청한다.
- **위험도가 높은 수정은 더 신중하게 보고한다.** 동기→비동기 전환, 시각적 동작 변경, 다른 컴포넌트 영향 등은 명시적으로 위험도를 표시하고 사용자 판단을 요청한다.
- **팀원 리뷰는 건드리지 않는다.** Copilot(봇) 코멘트만 대상.
- **코드를 읽지 않고 판단하지 않는다.** 반드시 해당 파일/라인을 읽고 검증. 필요 시 사용처/호출자/스토리도 확인.
- **부분 유효(⚠️)는 Copilot 제안을 그대로 적용하지 않고, 올바른 방향으로 수정한다.**
  - 예: Copilot이 `selectedPassages.length` deps 추가를 제안했지만 무한 루프 위험 → `passageGroupIdParam`만 추가
- **수정 후 반드시 type-check를 통과해야 한다.**
- **1코멘트 = 1커밋. 같은 패턴이라도 절대 묶지 않는다.** 답글의 커밋 링크가 그 코멘트에 대응하는 자기 커밋이어야 추적이 깨지지 않는다.
- **답글의 커밋 링크는 매핑 테이블 기준으로 1:1.** 모든 답글에 통합 커밋 하나의 링크를 다는 것은 금지.
