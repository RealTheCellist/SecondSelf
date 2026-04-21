# Second Self 프론트엔드 컴포넌트 명세

## 문서 목적

이 문서는 `Second Self` 7일 체크인 실험용 MVP를 구현하기 위한 프론트엔드 컴포넌트 단위 명세다.

목표는 디자이너 문서를 코드 구조로 옮기는 기준을 만드는 것이다.

## 구현 기준

- 모바일 우선
- 화면 3개 기준
- 초기 구현은 단순한 클라이언트 상태와 서버 저장 흐름 기준

## 화면 단위 구성

- `QuestionSelectScreen`
- `CheckInComposeScreen`
- `ReflectionFeedScreen`

## 공통 레이아웃 컴포넌트

### `MobilePage`

책임:

- 모바일 세로 화면 컨테이너 제공
- 상단/본문/하단 CTA 레이아웃 구성

props:

- `title?`
- `children`
- `footer?`

### `BottomActionBar`

책임:

- 하단 고정 CTA 표시

props:

- `label`
- `disabled?`
- `loading?`
- `onClick`

## 화면 1 컴포넌트

### `QuestionSelectScreen`

책임:

- 질문 목록 표시
- 질문 1개 선택
- 다음 화면 이동

state:

- `selectedPromptId: string | null`

children:

- `QuestionCardList`
- `BottomActionBar`

events:

- `onSelectPrompt(promptId)`
- `onNext()`

### `QuestionCardList`

책임:

- 질문 카드 3개 렌더링

props:

- `items`
- `selectedId`
- `onSelect`

### `QuestionCard`

책임:

- 질문 카드 1개 렌더링
- 선택 상태 표시

props:

- `label`
- `selected`
- `onClick`

## 화면 2 컴포넌트

### `CheckInComposeScreen`

책임:

- 선택한 질문 표시
- 자유 텍스트 입력
- 감정 태그 선택
- 제출 가능 여부 계산

state:

- `text: string`
- `selectedEmotions: string[]`
- `submitting: boolean`
- `errors: { text?: string; emotions?: string; submit?: string }`

children:

- `PromptSummary`
- `CheckInTextArea`
- `EmotionTagSelector`
- `BottomActionBar`

events:

- `onTextChange(value)`
- `onToggleEmotion(tag)`
- `onSubmit()`

derived state:

- `canSubmit = text.trim().length > 0 && selectedEmotions.length > 0`

### `PromptSummary`

책임:

- 선택한 질문 한 줄 표시

props:

- `label`

### `CheckInTextArea`

책임:

- 멀티라인 텍스트 입력 처리

props:

- `value`
- `placeholder`
- `error?`
- `onChange`

### `EmotionTagSelector`

책임:

- 감정 태그 목록 렌더링
- 최대 2개 선택 제어

props:

- `items`
- `selectedItems`
- `maxSelection`
- `error?`
- `onToggle`

rules:

- 같은 태그 재탭 시 해제
- 2개 선택 상태에서 다른 태그 탭 시 무시 또는 교체 정책 필요

권장 정책:

- 2개 선택 상태에서 다른 태그 탭 시 가장 먼저 선택한 태그를 유지하고 새 선택은 막는다

## 화면 3 컴포넌트

### `ReflectionFeedScreen`

책임:

- 오늘의 해석 결과 표시
- 데이터 누적 상태에 따라 빈 상태 또는 패턴 카드 노출

props:

- `reflectionLine`
- `keywords`
- `summaryState`
- `summaryCards`

children:

- `ReflectionHero`
- `EmptyPatternState` or `PatternCardList`
- `BottomActionBar`

### `ReflectionHero`

책임:

- 해석 1줄과 키워드, 보조 문구 렌더링

props:

- `headline`
- `reflectionLine`
- `keywords`
- `helperText`

### `EmptyPatternState`

책임:

- 데이터 부족 상태 문구 렌더링

props:

- `title`
- `description`

### `PatternCardList`

책임:

- 패턴 카드 3개 렌더링

props:

- `cards`

### `PatternCard`

책임:

- 제목과 내용을 가진 카드 1개 렌더링

props:

- `title`
- `body`

## 상태 모델

### `PromptOption`

```ts
type PromptOption = {
  id: string;
  label: string;
};
```

### `CheckInDraft`

```ts
type CheckInDraft = {
  promptId: string;
  text: string;
  emotions: string[];
};
```

### `SummaryCard`

```ts
type SummaryCard = {
  id: "topics" | "emotions" | "reflection";
  title: string;
  body: string;
};
```

### `SummaryState`

```ts
type SummaryState = "empty" | "preview" | "full";
```

## 페이지 상태 전이

1. `QuestionSelectScreen`
2. `CheckInComposeScreen`
3. 제출 성공
4. `ReflectionFeedScreen`

예외 전이:

- 저장 실패 시 `CheckInComposeScreen` 유지
- 입력 검증 실패 시 같은 화면에서 오류 표시

## 데이터 흐름

### 입력 시

1. 질문 선택
2. 텍스트 입력
3. 감정 태그 선택
4. 제출

### 제출 시

1. `CheckInDraft` 생성
2. API 또는 저장 함수 호출
3. 저장 성공 시 요약 데이터 fetch 또는 compute
4. `ReflectionFeedScreen`으로 이동

### 결과 표시 시

1. 오늘의 해석 1줄 표시
2. 키워드 2개 표시
3. 누적 체크인 수에 따라 empty/preview/full 결정
4. 카드 렌더링

## API 추상 인터페이스

```ts
type SubmitCheckInInput = {
  promptId: string;
  text: string;
  emotions: string[];
};

type SubmitCheckInResult = {
  checkInId: string;
};

type ReflectionPayload = {
  reflectionLine: string;
  keywords: string[];
  summaryState: "empty" | "preview" | "full";
  summaryCards: SummaryCard[];
};
```

필요 함수:

- `submitCheckIn(input): Promise<SubmitCheckInResult>`
- `getReflectionFeed(userId): Promise<ReflectionPayload>`

## 검증 규칙

- 질문은 반드시 1개 선택
- 텍스트는 공백 제거 후 1자 이상
- 감정 태그는 1개 이상 2개 이하

## 에러 처리

### 입력 에러

- 질문 미선택: 화면 1에서 CTA 비활성
- 텍스트 미입력: 인라인 오류
- 태그 미선택: 인라인 오류

### 네트워크 에러

- 제출 실패 시 CTA 아래 인라인 메시지 표시
- 사용자가 다시 제출 가능해야 함

## 분석 이벤트

권장 이벤트:

- `question_select_viewed`
- `question_selected`
- `checkin_composer_viewed`
- `checkin_submitted`
- `reflection_viewed`
- `pattern_card_viewed`
- `next_checkin_clicked`

## 구현 우선순위

### P0

- 질문 선택 화면
- 체크인 작성 화면
- 제출 검증
- 결과 해석 1줄 화면

### P1

- 키워드 2개 노출
- 빈 상태 박스
- 패턴 카드 3장

### P2

- preview 상태 분기
- 분석 이벤트 정교화
- 시각 polish
