# SKSE 플러그인 템플릿

CommonLibSSE-NG(CharmedBaryon 계열 3.7.0)로 SKSE 플러그인을 만드는 최소 틀입니다.
설치와 빌드 방법은 키트의 `갈래/05-SKSE.md`에 있습니다. 이 폴더만 따로 복사해 쓸 때도 키트 폴더는 지우지 말고 두세요.

라이선스: MIT(`LICENSE`). 빌드한 DLL에는 CommonLibSSE-NG, spdlog, fmt 등 다른 라이브러리가 함께 들어가며, `build.cmd zip`이 그 라이선스 고지를 zip에 넣습니다.

## 들어 있는 것

| 파일 | 역할 |
|---|---|
| `src/main.cpp` | 플러그인 코드. 로그를 남기고, 새 게임을 시작하거나 세이브를 불러오면 로딩 화면이 닫힌 뒤 왼쪽 위에 알림을 띄웁니다. |
| `src/PCH.h` | 미리 컴파일하는 헤더 |
| `CMakeLists.txt` | 플러그인 이름·버전, 빌드 결과를 `package\SKSE\Plugins`로 복사, 라이선스 고지 복사, MO2 폴더로 복사(선택), 배포용 zip |
| `CMakePresets.json` | 빌드 설정. 빌드 파일은 이 폴더 밖(`SKSE_BUILD_ROOT`, 기본 `C:\skse-build`)에 만듭니다. |
| `vcpkg.json`, `vcpkg-configuration.json` | 의존 라이브러리(CommonLibSSE-NG)와 그 버전 고정 |
| `cmake/triplets/` | 빌드 경로(사용자 이름이 든 경로)가 DLL에 남지 않게 하는 설정 |
| `build.cmd` | 빌드 실행 파일 |
| `LICENSE` | 이 템플릿의 라이선스(MIT) |

## 이름 바꾸기

1. 이 폴더를 작업할 곳에 복사합니다. 예: `C:\skse\MyCoolPlugin`. 한글 경로에서도 빌드되지만, 영문·숫자로 된 짧은 경로를 권합니다. 플러그인마다 다른 폴더 이름을 씁니다.
2. `CMakeLists.txt`의 `project(MyPlugin VERSION 1.0.0 ...)`에서 이름과 버전을 바꿉니다. 이름은 영문·숫자로 씁니다. 이 이름이 DLL과 로그 파일 이름이 됩니다.
3. `vcpkg.json`의 `"name"`과 `"version-string"`을 바꿉니다.
   - `"name"`에는 **소문자, 숫자, 하이픈(-)만** 쓸 수 있습니다. 밑줄(_)이나 공백은 쓸 수 없습니다. 예: `MyCoolPlugin` → `my-cool-plugin`, `Fire_Hurts` → `fire-hurts`
   - `"version-string"`은 2번의 버전과 같게 씁니다.
4. 이름을 바꾸기 전에 빌드한 적이 있으면 `C:\skse-build\<폴더 이름>\package`를 지우고 다시 빌드합니다. 옛 이름의 DLL이 남기 때문입니다.

## Visual Studio나 VS Code로 열 때

코드를 고치는 데는 어떤 편집기를 써도 됩니다. 다만 **빌드는 항상 `build.cmd`로 합니다.** 빌드 폴더와 vcpkg 위치를 `build.cmd`가 정해 주기 때문입니다.
편집기가 CMake 구성을 자동으로 시작해 `... is not set. Build this template by running build.cmd ...` 오류를 내면, 그 구성은 무시하고 `build.cmd`를 실행하세요. 그때 드라이브 맨 위에 생긴 빈 빌드 폴더는 지워도 됩니다.
