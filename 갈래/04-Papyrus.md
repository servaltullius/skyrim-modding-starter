# Papyrus 스크립트

게임 중 일어나는 일에 반응해야 할 때 씁니다. 예: 퀘스트 단계가 바뀌면 무언가 하기, 아이템을 집으면 효과 주기, MCM 설정 메뉴.

## 먼저 알아 둘 것

- **스크립트는 세이브에 남습니다.** 플러그인 레코드에 붙은 스크립트와 그 변수 값은 세이브에 저장됩니다. 플레이 도중에 스크립트 모드를 빼면 세이브에 고아 데이터가 남고, 문제가 생길 수 있습니다. 반드시 시험용 프로필과 새 세이브로 시험합니다.
- 소스(`.psc`)를 컴파일하면 게임이 읽는 `.pex`가 됩니다. 배포에는 `.pex`가 필요하고, 소스도 함께 넣는 것이 관례입니다.
- 남의 모드 스크립트를 고칠 때 `.psc`가 없으면 houseCARL `housecarl_decompile_script`로 디컴파일해 볼 수 있습니다. 디컴파일 결과는 원본과 다를 수 있으니, 고친 뒤에는 원본과 동작을 비교합니다.

## 컴파일 준비

컴파일하려면 Papyrus 컴파일러와 바닐라 스크립트 소스가 필요합니다. SKSE 함수(또는 다른 SKSE 플러그인 함수)를 쓰는 스크립트라면 그 소스도 필요합니다.

1. **컴파일러와 바닐라 소스:** Steam에서 Creation Kit을 설치하면 게임 폴더에 `Papyrus Compiler\PapyrusCompiler.exe`와 `Data\Scripts.zip`이 생깁니다.
   - `Scripts.zip`을 풀면 `Source\Scripts` 폴더에 `.psc` 파일들과 플래그 파일 `TESV_Papyrus_Flags.flg`가 있습니다(2026-11-23 확인). MO2를 쓴다면 이 내용을 별도 모드(예: `mods\Vanilla Script Source`)로 만들어 두는 것이 깔끔합니다.
   - MO2의 Stock Game처럼 게임을 다른 폴더로 복사해 쓰면, 컴파일러가 원래 Steam 설치 폴더에만 있을 수 있습니다. houseCARL이 컴파일러를 못 찾으면 그 경로를 알려 줍니다(`housecarl_set_tool_path`).
2. **SKSE 소스:** SKSE 배포 압축 파일에는 스크립트 소스가 `Data\Scripts\Source\`에 들어 있습니다(SKSE 설명서에 적힌 위치, 바닐라와 다름). SKSE가 고친 `Actor.psc` 같은 파일은 바닐라와 이름이 같습니다.
3. **컴파일:** houseCARL `housecarl_compile_script`를 씁니다.
   - 소스 위치를 자동으로 못 찾아 "플래그 파일이 없다", "○○ is not a function" 같은 오류가 줄줄이 나오면, 소스 폴더를 `import_dirs`로 직접 넘깁니다.
   - **순서가 중요합니다.** 앞에 적은 폴더부터 찾고, 같은 이름의 파일은 먼저 찾은 것을 씁니다. SKSE 소스를 바닐라보다 **앞에** 적어야 SKSE가 추가한 함수가 보입니다. 예: `import_dirs="<MO2>/mods/SKSE64/Scripts/Source;<MO2>/mods/Vanilla Script Source/Source/Scripts"`
   - 다른 SKSE 플러그인(PapyrusUtil 등)의 함수를 쓰면 그 모드의 소스 폴더도 앞쪽에 추가합니다.

## 절차

1. 어떤 이벤트에 무엇을 할지 한 문장으로 정합니다.
2. 스크립트를 붙일 레코드(퀘스트, 마법 효과, 아이템 등)를 정합니다. 필요하면 `03-ESP-패치.md` 방식으로 새 플러그인을 만듭니다.
3. 스크립트를 씁니다. 함수와 이벤트 이름은 houseCARL `papyrus-reference` 스킬로 확인합니다. 없는 함수를 지어내지 않습니다.
4. 컴파일하고, 오류가 없을 때까지 고칩니다.
5. `.pex`는 새 MO2 모드 폴더의 `Scripts\`에, 내 `.psc`는 `Source\Scripts\`에 둡니다. SE/AE 바닐라 소스와 같은 구조입니다.
6. **스크립트를 레코드에 붙이고 속성(Property)을 채웁니다.** 새 스크립트는 `.pex`만 만들어서는 실행되지 않습니다. 2번의 레코드(퀘스트, 별칭, 마법 효과 등)에 스크립트를 연결하고, 스크립트가 쓰는 속성 값을 채워야 합니다. houseCARL 쓰기 도구로 새 패치에 넣습니다. 이미 붙어 있는 스크립트의 내용만 고친 경우에는 이 단계가 필요 없습니다.

## 게임에서 확인하기

1. Papyrus 로그를 켭니다. MO2의 INI 편집기(도구 메뉴)에서 `Skyrim.ini`의 `[Papyrus]` 항목에 아래를 넣습니다.
   - 시험용 프로필에서 "프로필별 게임 INI 사용"이 켜져 있는지 먼저 확인합니다. 꺼져 있으면 모든 프로필이 같은 INI를 써서 본 프로필 설정도 바뀝니다.
   - 바꾸기 전에 세 값의 원래 값을 적어 둡니다. 원래 켜져 있던 값이 있을 수 있습니다.
   ```ini
   [Papyrus]
   bEnableLogging=1
   bEnableTrace=1
   bLoadDebugInformation=1
   ```
2. 스크립트 안에 `Debug.Trace("내 모드: ○○ 실행됨")` 같은 줄을 넣어 두면 로그에서 찾기 쉽습니다.
3. 로그 위치: `문서\My Games\Skyrim Special Edition\Logs\Script\Papyrus.0.log`
4. 확인이 끝나면 세 값을 적어 둔 원래 값으로 되돌립니다. 켜 두면 디스크를 계속 씁니다.

## 자주 하는 실수

- `OnUpdate`를 짧은 간격으로 계속 등록하면 스크립트 엔진에 부하가 쌓입니다. 이벤트로 해결되는지 먼저 봅니다.
- 이미 시작된 퀘스트에 붙은 스크립트의 속성(Property) 값은 세이브에 남은 값이 쓰입니다. 플러그인에서 값을 바꿔도 기존 세이브에는 반영되지 않을 수 있습니다.
