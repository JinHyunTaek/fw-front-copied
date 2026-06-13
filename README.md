# FightWeek

UFC 팬을 위한 격투 이벤트 트래킹 모바일 앱입니다. 다가오는 이벤트와 매치 카드를 확인하고, 선수 프로필을 살펴보며, 퀴즈로 포인트를 모으고 그 포인트로 경기 결과를 예측(베팅)할 수 있습니다.

Flutter 기반의 iOS / Android 앱이며, 백엔드는 Spring Boot REST API와 통신합니다.

## 주요 기능

- **이벤트 / 경기 일정** — 다가오는 이벤트 목록과 상세, 파이트 카드 시각화 (메인 / 언더 / 파이트 패스 언더)
- **선수 프로필** — 선수 검색, 상세 스탯, 선수 평점(rating) 및 랭킹
- **게임(퀴즈)** — 선수 이름 맞히기, 선수 이미지 맞히기, 경기 결과(A vs B + 승리 방법) 예측 퀴즈
- **예측(베팅)** — 퀴즈로 모은 포인트로 경기 결과를 예측하고 점수 획득, 포인트에 따른 벨트 등급
- **랭킹** — 유저 랭킹 / 선수 랭킹 / 선수 평점 랭킹, 최근 베팅 내역
- **실시간 스트림 / 채팅** — 진행 중인 이벤트의 실시간 스트림과 WebSocket 기반 채팅
- **알림** — Firebase Cloud Messaging 푸시 알림 및 알림 환경설정
- **소셜 로그인** — Google, Apple, Kakao, Naver 로그인 지원
- **설정** — 계정 관리(비밀번호 변경, 회원 탈퇴), 알림 설정, 다크/라이트 테마

## 기술 스택

| 영역 | 사용 기술 |
| --- | --- |
| 상태 관리 | `flutter_riverpod`, `riverpod_generator` |
| 라우팅 | `go_router` |
| 네트워크 | `dio`, `retrofit` (코드 생성) |
| 직렬화 | `json_serializable`, `json_annotation` |
| 인증 저장소 | `flutter_secure_storage` |
| 푸시 알림 | `firebase_core`, `firebase_messaging`, `flutter_local_notifications` |
| 광고 | `google_mobile_ads`, `app_tracking_transparency` |
| 소셜 로그인 | `google_sign_in`, `sign_in_with_apple`, `kakao_flutter_sdk`, `naver_login_sdk` |
| 반응형 UI | `flutter_screenutil` (디자인 기준 402×874) |
| 기타 | `cached_network_image`, `flutter_svg`, `table_calendar`, `web_socket_channel`, `image_picker`/`image_cropper`, `gpt_markdown` |

## 프로젝트 구조

기능(feature) 단위로 디렉토리를 나누고, 각 기능 내부는 레이어로 구분합니다.

```
lib/
├── main.dart                 # 앱 진입점 (테마, 환경 분기, SDK 초기화)
├── firebase_options.dart
├── common/                   # 공통 모듈
│   ├── component/            # 재사용 위젯 (페이지네이션 리스트, 다이얼로그 등)
│   ├── const/                # 색상, 스타일, 상수, data.dart(토큰 키·baseUrl)
│   ├── layout/               # 기본 레이아웃
│   ├── model/                # 페이지네이션·베이스 모델
│   ├── notification/         # FCM 초기화
│   ├── provider/             # dio, route(go_router), secure storage, 광고 등
│   ├── screen/               # 스플래시, 루트 탭, 웹뷰
│   ├── service/              # AdMob 등
│   └── utils/                # 날짜·경기 유틸
├── home/                     # 홈
├── fight_event/              # 이벤트 / 파이트 카드
├── fighter/                  # 선수 프로필 / 평점
├── game/                     # 퀴즈 게임
├── ranking/                  # 유저·선수·평점 랭킹
├── stream/                   # 실시간 스트림 + 채팅
├── user/                     # 인증 / 회원 / 소셜 로그인
├── alert/                    # 알림 환경설정
├── app_status/               # 서버 점검 / 상태 체크
├── report/                   # 신고
├── search/                   # 검색
└── setting/                  # 설정 (계정, 알림)
```

각 기능 디렉토리는 일반적으로 다음 레이어를 가집니다.

- `model/` — 데이터 모델 (`*.g.dart`는 build_runner 생성물)
- `repository/` — Retrofit 기반 API 호출 (데이터 계층)
- `provider/` — Riverpod 상태/비즈니스 로직
- `screen/`, `component/` — 화면과 UI 위젯

> 개발 규칙: UI 로직은 단순하고 선언적으로 유지하고, 비즈니스 로직은 위젯에 두지 않으며, API 호출은 데이터 계층(repository)에 격리합니다.

## 시작하기

### 요구 사항

- Flutter SDK `3.41.7` 이상 (Dart SDK `^3.7.0`)
- Xcode (iOS) / Android Studio (Android)

### 환경 설정

이 앱은 환경 변수와 시크릿을 두 가지 방식으로 주입받습니다.

1. **`asset/config/.env`** — 소셜 로그인 키를 담은 dotenv 파일 (`pubspec.yaml` 에셋으로 등록됨)

   ```env
   NAVER_CLIENT_NAME=...
   NAVER_CLIENT_ID=...
   NAVER_CLIENT_SECRET=...
   NAVER_URL_SCHEME=...
   KAKAO_NATIVE_APP_KEY=...
   KAKAO_JS_KEY=...
   ```

2. **`--dart-define`** — 빌드 시 환경/서버 주소 지정
   - `ENV` : `dev`(기본) 또는 `prod`
   - `BASE_URL` : `prod` 빌드 시 **필수** (REST 백엔드 주소)
   - `DEV_HOST` : dev 빌드에서 실기기 접속용 호스트 (기본값 존재, `http://<DEV_HOST>:8080` 사용)

### 실행

```bash
# 의존성 설치
flutter pub get

# 코드 생성 (retrofit / json / riverpod)
dart run build_runner build --delete-conflicting-outputs

# 개발 실행 (dev)
flutter run --dart-define=DEV_HOST=<로컬 백엔드 IP>

# 프로덕션 실행/빌드
flutter run --dart-define=ENV=prod --dart-define=BASE_URL=<백엔드 URL>
```

### 테스트

```bash
flutter test
```

모델·프로바이더 단위 테스트가 `test/`에 있으며, 테스트 픽스처는 `test/fixture/`에 위치합니다.

## 백엔드

이벤트·선수 등 모든 데이터는 Spring Boot REST 백엔드에서 제공됩니다. 인증은 access/refresh 토큰을 `flutter_secure_storage`에 저장하여 관리합니다.

## 라이선스 / 개인정보 처리방침

개인정보 처리방침: https://jinhyuntaek.github.io/fightweek-privacy/
