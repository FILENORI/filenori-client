# filenori-client
```shell
lib/
│
├── core/                     # 공통 및 핵심 코드
│   ├── error/                # 에러 정의 (e.g., Exceptions, Failures)
│   ├── network/              # 네트워크 관련 설정 및 유틸리티
│   ├── usecase/              # UseCase 정의
│   ├── utils/                # 공통 유틸리티 (e.g., Validators, Formatters)
│   └── constants.dart        # 상수 정의
│
├── features/                 # 기능별 모듈
│   ├── authentication/       # 로그인/회원가입 관련 모듈
│   │   ├── data/             # 데이터 계층
│   │   │   ├── models/       # 모델 정의
│   │   │   ├── datasources/  # 로컬/원격 데이터 소스
│   │   │   └── repositories/ # 구현된 Repository
│   │   ├── domain/           # 도메인 계층
│   │   │   ├── entities/     # 엔티티 정의
│   │   │   ├── usecases/     # UseCase 정의
│   │   │   └── repositories/ # Repository 인터페이스
│   │   └── presentation/     # 프레젠테이션 계층
│   │       ├── pages/        # 화면 페이지
│   │       ├── widgets/      # 위젯
│   │       ├── state/        # 상태 관리
│   │       └── controllers/  # 컨트롤러/뷰모델
│   │
│   ├── file_management/      # 파일 업로드/다운로드, 목록 보기 관련 모듈
│   │   ├── data/             # 데이터 계층
│   │   │   ├── models/       # 모델 정의
│   │   │   ├── datasources/  # 로컬/원격 데이터 소스
│   │   │   └── repositories/ # 구현된 Repository
│   │   ├── domain/           # 도메인 계층
│   │   │   ├── entities/     # 엔티티 정의
│   │   │   ├── usecases/     # UseCase 정의
│   │   │   └── repositories/ # Repository 인터페이스
│   │   └── presentation/     # 프레젠테이션 계층
│   │       ├── pages/        # 화면 페이지
│   │       ├── widgets/      # 위젯
│   │       ├── state/        # 상태 관리
│   │       └── controllers/  # 컨트롤러/뷰모델
│   │
│   └── p2p_transfer/         # P2P 파일 전송 모듈
│       ├── data/             # 데이터 계층
│       │   ├── models/       # 모델 정의
│       │   ├── datasources/  # 로컬/원격 데이터 소스
│       │   └── repositories/ # 구현된 Repository
│       ├── domain/           # 도메인 계층
│       │   ├── entities/     # 엔티티 정의
│       │   ├── usecases/     # UseCase 정의
│       │   └── repositories/ # Repository 인터페이스
│       └── presentation/     # 프레젠테이션 계층
│           ├── pages/        # 화면 페이지
│           ├── widgets/      # 위젯
│           ├── state/        # 상태 관리
│           └── controllers/  # 컨트롤러/뷰모델
│
├── app.dart                  # 앱의 최상위 엔트리 포인트 (Routes, Providers 설정)
├── main.dart                 # main() 함수, 앱 실행
└── injection.dart            # DI (Dependency Injection) 설정
```