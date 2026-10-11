---
name: figma-cards
description: "카드뉴스 문안(slides.md)을 Figma에서 1080×1350 캐러셀 프레임으로 만들고 JPG로 내보내는 방법과 technow.archive 템플릿 만드는 방법. card-designer가 사용한다. Figma 카드 디자인, 템플릿 제작, 슬라이드 이미지 출력, 디자인 수정, 특정 장만 다시 그리기 요청에 사용한다. 문안 작성(card-copy)과 사실 검수(fact-check)에는 쓰지 않는다."
---

# Figma 카드 디자인

카드 이미지는 문안과 디자인이 **한 쌍**으로 검수된다. 디자이너는 문안을 그대로 옮기고, 모양만 책임진다. 글자가 안 들어가면 문안을 줄이지 않고 되돌려 보낸다.

## 준비 (매번)

1. `mcp__Figma__get_figma_skill`로 `skill://figma/figma-use/SKILL.md`를 읽는다. `use_figma` 전에 필수다.
2. `accounts/tech/planning/figma.md`에 파일 키가 있으면 그 파일을 쓴다. 없으면 「템플릿 만들기」로 간다.
3. `<섹터 폴더>/card/slides.md`를 읽는다. 총 장 수와 장별 시각 지시를 확인한다.

## 템플릿 만들기 (첫 섹터에서 한 번)

1. `whoami`로 플랜을 확인한다. 플랜이 여럿이면 고르지 말고 지휘자에게 묻는다.
2. `create_new_file`(editorType `design`)로 `technow.archive cards` 파일을 만든다. 파일 키·URL을 지휘자에게 보고하면 지휘자가 `figma.md`에 기록한다.
3. `Template` 페이지에 1080×1350 프레임으로 장 유형별 기본형을 만든다: 표지 / 본문 / 큰 수치 / 인용 / 한계 / 출처.
4. 공통 요소는 변수(색·글자)와 컴포넌트로 만든다: 상단 워드마크, `01 / 09` 형식 장 번호, 출처 줄.
5. 스타일은 `accounts/trendnow.archive/README.md`의 규격을 출발점으로 삼되 tech 계정답게 정한다. 글자 크기, 여백, 색을 정한 값은 `design-notes.md`에 적고, 지휘자가 `accounts/tech/README.md`의 "슬라이드 디자인 규칙"(T07)에 옮긴다.
6. 한글 폰트는 Figma에서 실제로 쓸 수 있는 것만 쓴다. 쓸 수 없으면 지휘자에게 묻는다.

## 섹터 캐러셀 만들기

1. 파일에 `<NN>-<slug>` 페이지를 만든다.
2. 장마다 템플릿 프레임을 복제해 문안을 채운다. 프레임 이름은 `01`, `02`처럼 장 번호로 짓는다.
3. 한 번에 한 장 또는 몇 장씩 `use_figma`로 만들고, 그때마다 `get_screenshot`으로 본다. 한꺼번에 만들고 마지막에 한 번 보면 같은 실수가 전 장에 퍼진다.
4. 확인할 것: 글자 잘림·넘침, 장 번호 정확성, 숫자·단위가 `slides.md`와 같은지, 여백, 가독성(작은 글자 대비).

## JPG 내보내기

- 장마다 `download_assets`(`defaultFormat: "jpg"`, 프레임 크기 1080×1350 그대로, `defaultScale`은 지정하지 않는다)로 받는다.
- 응답의 URL은 임시라서 바로 `curl`로 `<섹터 폴더>/card/NN.jpg`에 저장한다.
- 저장 후 `file`로 크기가 1080×1350인지 확인한다.

## design-notes.md

Figma 링크와 페이지, 장별 프레임 id, 글자 넘침 등으로 `card-writer`에게 요청한 수정, 막힌 것을 적는다.

## 하지 말 것

- 문안을 고치지 않는다.
- `createImageAsync`, `setPluginData`, `loadAllPagesAsync`는 지원되지 않으니 쓰지 않는다.
- 다른 섹터 페이지의 프레임을 건드리지 않는다.
