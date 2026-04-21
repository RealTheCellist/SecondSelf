# Second Self 이벤트 스키마

## 목적

이 문서는 정적 프로토타입 단계에서 수집하는 최소 이벤트 로그 정의서다.

현재 이벤트는 `localStorage`의 `second-self-events-v1` 키에 저장된다.

## 공통 구조

각 이벤트는 아래 구조를 가진다.

```json
{
  "id": "string",
  "name": "string",
  "payload": {},
  "createdAt": "ISO datetime"
}
```

## 이벤트 목록

### `app_loaded`

- 의미: 앱 진입
- payload: 없음

### `question_selected`

- 의미: 질문 카드 선택
- payload:
  - `promptId`

### `question_continue_clicked`

- 의미: 질문 선택 후 다음 단계 진입
- payload:
  - `promptId`

### `emotion_limit_reached`

- 의미: 감정 태그 2개 초과 선택 시도
- payload: 없음

### `checkin_submitted`

- 의미: 체크인 제출 완료
- payload:
  - `promptId`
  - `emotionCount`
  - `keywordCount`
  - `totalCheckins`

### `reflection_viewed`

- 의미: 결과 화면 렌더링
- payload:
  - `totalCheckins`

### `next_checkin_clicked`

- 의미: 다음 체크인 CTA 클릭
- payload: 없음

### `sample_data_seeded`

- 의미: QA용 샘플 데이터 주입
- payload:
  - `totalCheckins`

## 활용 목적

- 질문 선택 비율 확인
- 체크인 제출 수 확인
- 결과 화면 진입 수 확인
- 다음 체크인 의도 확인
- QA 시 샘플 데이터 주입 여부 확인

## 주의 사항

- 현재는 로컬 프로토타입 기준이라 분석 도구로 전송하지 않는다
- 정식 실험 단계로 넘어가면 이 스키마를 기반으로 외부 analytics 이벤트로 옮기면 된다
