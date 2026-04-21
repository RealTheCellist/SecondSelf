# Second Self Mobile

Flutter 기준으로 다시 잡은 `Second Self` 앱 구조입니다.

현재 이 폴더에는 아래가 들어 있습니다.

- `pubspec.yaml`
- `lib/` 앱 구조
- 질문 선택 -> 체크인 작성 -> 결과/패턴 피드 흐름
- 샘플 데이터 기반 preview/full 상태 확인 로직

## 현재 상태

이 환경에서는 `flutter create`가 완료되지 않아, 플랫폼 폴더(`android`, `ios`, `web` 등)는 아직 없습니다.

대신 실제 앱 로직은 Flutter 구조로 옮겨두었습니다. Flutter SDK가 정상 동작하는 환경에서 아래 순서로 이어가면 됩니다.

1. 새 Flutter 앱 생성 또는 이 폴더 기준으로 플랫폼 폴더 생성
2. `lib/` 코드 유지
3. `flutter pub get`
4. `flutter run`

## 주요 파일

- `lib/main.dart`
- `lib/app/app_shell.dart`
- `lib/models/checkin.dart`
- `lib/screens/question_select_screen.dart`
- `lib/screens/checkin_compose_screen.dart`
- `lib/screens/reflection_feed_screen.dart`
