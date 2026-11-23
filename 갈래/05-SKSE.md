# SKSE 플러그인 (C++)

가장 무거운 방법입니다. `00-도구-고르기.md`에서 INI, ESP 패치, Papyrus로 안 된다는 것을 확인한 뒤에 씁니다.

## 이럴 때

- 엔진 동작 자체를 바꿔야 할 때(게임 함수 후킹, 성능 개선)
- Papyrus로는 너무 느리거나 접근할 수 없는 정보가 필요할 때
- 스크립트로 만들 수 없는 새 시스템

SKSE는 Steam판과 GOG판용이 따로 있습니다. 지원하는 판은 [SKSE 공식 사이트](https://skse.silverlock.org/)에서 확인하세요. Microsoft Store·Game Pass판은 SKSE를 쓸 수 없습니다.

## 1. 준비물 설치 (처음 한 번)

1. **Visual Studio 2022** (Community 무료판 또는 Build Tools)
   - 설치 프로그램에서 **"C++를 사용한 데스크톱 개발"** 워크로드를 고릅니다. 이 워크로드에 들어 있는 "Windows용 C++ CMake 도구"(CMake와 Ninja)를 빼지 마세요.
   - 템플릿은 CMake 3.28 이상이 필요합니다. 오래된 VS 2022라면 Visual Studio Installer에서 최신으로 업데이트합니다.
   - 템플릿은 VS 2022의 v143 도구(MSVC 14.44)로 시험했습니다. 2022가 없으면 `build.cmd`가 더 새 버전을 쓰지만, 그 조합은 시험하지 않았습니다.
2. **Git for Windows**: [git-scm.com](https://git-scm.com/download/win)
3. **vcpkg**: C++ 라이브러리 관리 도구입니다. PowerShell에서 아래 두 줄을 실행합니다.
   ```powershell
   git clone https://github.com/microsoft/vcpkg C:\vcpkg
   ```
   ```powershell
   C:\vcpkg\bootstrap-vcpkg.bat
   ```
   - `C:\vcpkg`에 두면 `build.cmd`가 알아서 찾습니다. 다른 곳에 뒀다면 환경 변수 `VCPKG_ROOT`에 그 경로를 넣습니다. **경로에 공백이 없어야 합니다**(`build.cmd`가 확인합니다).
   - 템플릿이 쓰는 라이브러리 버전은 템플릿의 `vcpkg-configuration.json`이 고정하므로, vcpkg 자체는 최신이어도 됩니다.

## 2. 새 플러그인 만들기

1. 키트의 `skse-template` 폴더를 작업할 곳에 복사합니다. 예: `C:\skse\MyCoolPlugin`
   - **폴더 이름이 빌드 폴더 이름이 됩니다**(`C:\skse-build\<폴더 이름>`). 플러그인마다 다른 폴더 이름을 쓰세요. 같은 이름의 폴더 두 개를 빌드하면 빌드 파일이 섞입니다.
   - 한글과 공백이 든 경로에서도 빌드되는 것을 확인했습니다(2026-11-23). 그래도 다른 개발 도구와 함께 쓸 때 문제를 줄이려면 영문·숫자로 된 짧은 경로를 권합니다.
   - 템플릿 폴더에는 `LICENSE`(MIT)가 함께 들어 있습니다. 이 안내 문서는 키트에 있으니, 키트 폴더도 지우지 말고 두세요.
2. `skse-template/README.md`의 "이름 바꾸기"대로 이름과 버전을 바꿉니다.
   - 이름을 바꾸기 전에 한 번 빌드했다면 `C:\skse-build\<폴더 이름>\package`에 옛 이름의 DLL이 남습니다. 그 폴더를 지우고 다시 빌드하세요.
3. 복사한 폴더의 `build.cmd`를 실행합니다. 처음에는 CommonLibSSE-NG를 받아서 빌드하느라 몇 분 걸립니다(시험한 PC에서 약 3분 반, PC와 인터넷 속도에 따라 더 걸릴 수 있음). 그다음부터는 vcpkg가 만들어 둔 것을 다시 써서 수십 초면 끝납니다.
4. `BUILD OK`가 나오면 DLL은 `C:\skse-build\<폴더 이름>\package\SKSE\Plugins`에 있습니다. (`C:`는 시스템 드라이브입니다. `SKSE_BUILD_ROOT`로 바꿀 수 있습니다.)

**빌드는 항상 `build.cmd`로 합니다.** Visual Studio의 "폴더 열기"나 VS Code가 CMake 구성을 자동으로 시작하면 `... is not set` 오류로 멈춥니다. 이때 드라이브 맨 위에 `<폴더 이름>\build` 같은 빈 빌드 폴더가 생길 수 있으니 지워도 됩니다. 편집은 편집기로 하고 빌드는 `build.cmd`로 하세요.

### 빌드하자마자 MO2에 넣기

MO2에 빈 모드 폴더(예: `mods\MyCoolPlugin`)를 만들고, 같은 창에서 경로를 지정한 뒤 빌드합니다.

```powershell
$env:DEPLOY_DIR = "G:\MO2\mods\MyCoolPlugin"; .\build.cmd
```

- 빌드할 때마다 DLL이 그 모드 폴더의 `SKSE\Plugins`로 복사됩니다(같은 이름의 DLL은 덮어씀). MO2에서 그 모드를 켜 두면 바로 게임에서 시험할 수 있습니다.
- `build.cmd`는 드라이브 맨 위, `Data` 폴더, `Stock Game`·`steamapps\common` 아래로의 복사를 거부합니다. `mods` 바로 아래가 아닌 폴더면 경고를 냅니다.
- 이 설정은 그 PowerShell 창을 닫을 때까지 남습니다. 다른 플러그인을 빌드하기 전에 `$env:DEPLOY_DIR = $null`로 지우세요. 안 그러면 다른 플러그인 DLL도 그 폴더로 복사됩니다.

### 배포용 zip

```powershell
.\build.cmd zip
```

`C:\skse-build\<폴더 이름>\<플러그인 이름>-<버전>.zip`이 생깁니다. 안에는 `SKSE\Plugins\<이름>.dll`과, DLL에 함께 들어간 라이브러리의 라이선스 고지(`<이름>-licenses\`)가 들어 있습니다.

## 3. 게임에서 확인하기

1. MO2에서 시험용 프로필을 고르고, DLL을 넣은 모드를 켭니다(왼쪽 목록). DLL만 든 모드는 오른쪽 플러그인 목록에 나오지 않습니다.
2. MO2의 실행 목록에서 **SKSE(`skse64_loader.exe`)** 를 골라 실행합니다. 게임을 그냥 실행하면 SKSE 플러그인이 로드되지 않습니다.
3. 새 게임을 시작하거나 세이브를 불러옵니다.

템플릿 그대로 빌드했다면 다음이 보여야 합니다. 2026-11-23에 AE 1.6.1170에서 세이브를 불러와 1~3을 확인했습니다(새 게임 시작은 시험하지 않았습니다).

1. `문서\My Games\Skyrim Special Edition\SKSE\skse64.log`에 `plugin MyPlugin.dll (...) loaded correctly`가 있습니다. SKSE가 플러그인을 불러왔다는 뜻입니다.
2. `MyPlugin.log`에 `starting`, `Game data loaded`, `Game loaded ...`(새 게임이면 `New game ...`), `Notification requested` 줄이 있습니다.
   - **이 로그는 `skse64.log`와 다른 폴더에 생길 수 있습니다.** CommonLibSSE-NG는 로그 폴더 이름을 게임 메모리에서 읽는데, 2026-11-23에 AE 1.6.1170 환경에서 시험했을 때는 `문서\My Games\Skyrim.INI\SKSE\`에 생겼습니다. 같은 PC의 다른 CommonLib 기반 플러그인 로그도 그 폴더에 있었습니다.
   - 못 찾으면 `문서\My Games` 아래에서 `MyPlugin.log`를 검색하세요. 그래도 없으면 로그 파일을 만들지 못한 것입니다(플러그인은 로그 없이 계속 동작합니다). 1번으로 로드 여부를 확인하세요.
   - 로그는 게임을 켤 때마다 새로 씁니다. 이전 실행의 로그가 필요하면 게임을 다시 켜기 전에 복사해 두세요.
3. 로딩 화면이 닫힌 뒤 왼쪽 위에 `MyPlugin 1.0.0.0 loaded` 알림이 뜹니다. 2번 로그의 `Notification requested`는 알림을 **요청**한 시점입니다. 화면에 실제로 보였는지는 직접 확인해야 합니다.
   - 로딩 화면이 떠 있는 동안 띄운 알림은 보이기 전에 사라집니다. 그래서 템플릿은 로딩 화면이 닫힐 때까지 기다렸다가 알림을 띄웁니다. 직접 알림을 넣을 때도 같은 방식을 쓰세요.
4. `skse64.log`에 플러그인이 없거나 오류가 있으면, 그 줄을 AI에게 보여 주세요.

## AI가 지킬 것

- CommonLibSSE-NG의 클래스·함수 이름은 **빌드에 쓰는 설치된 헤더**(`C:\skse-build\<폴더 이름>\vcpkg_installed\...\include`)로 확인한 뒤 씁니다. 없는 API를 지어내지 않습니다.
  - houseCARL `skse-plugin-authoring` 스킬은 다른 계열(alandtse `ng` 4.x)의 CommonLibSSE-NG를 기준으로 쓰였습니다. 이 템플릿은 CharmedBaryon 계열 3.7.0입니다(2026-11-23 확인). 스킬의 예시가 헤더와 다르면 헤더를 따릅니다.
- 빌드가 성공했다는 것과 게임에서 동작한다는 것은 다릅니다. 빌드 결과와 "게임에서 확인할 것"을 나눠 보고합니다.
- 게임 함수 주소는 게임 버전마다 다릅니다. 주소를 직접 쓰지 말고 Address Library ID(`REL::RelocationID`)를 씁니다. 어떤 버전에서 확인했는지 적습니다.
- 템플릿 DLL은 "Address Library를 쓰는 버전 독립 플러그인"으로 선언되어, SKSE가 모든 게임 버전에서 불러옵니다. 특정 버전의 구조에 기대는 코드를 넣었다면, 시험한 버전을 사용자에게 알리고 배포 설명에 적게 합니다.
- 게임 함수를 후킹하는 코드는 크래시 위험이 큽니다. 무엇을 왜 후킹하는지, 원래 동작을 어떻게 보존하는지를 사용자에게 설명합니다.
- `kNewGame` 메시지는 새 게임이 **로드되기 전**에 옵니다. 그 시점에는 플레이어나 월드를 건드리지 않습니다.

## 배포할 때

- 사용자는 **SKSE**, **Address Library for SKSE Plugins**, **Microsoft Visual C++ 재배포 가능 패키지(x64)** 가 필요합니다. 설명 페이지에 적습니다.
- 시험한 게임 버전을 적고, 시험하지 않은 버전은 "미확인"으로 적습니다.
- `서식/배포-점검표.md`를 확인합니다.
