---
name: my-page-flow
description: >
  코드베이스의 실제 로직을 분석하여 페이지/화면의 UI 플로우를 정적 HTML로 자동 생성하는 스킬.
  모바일 프레임, 상태별 필드/버튼 조건, 바텀시트/모달, 화면 전환 흐름을 시각화한다.
  다음 요청에 반드시 이 스킬을 사용할 것:
  "{페이지명} 화면 플로우를 만들어줘", "{페이지명} screen flow 만들어줘",
  "{페이지명} UI flow 만들어줘", "{페이지명} 화면 플로우 HTML 만들어줘",
  "화면 플로우 만들어줘", "{페이지명} 화면 흐름 보여줘".
  사용자가 특정 페이지나 컴포넌트의 화면 전환/상태 흐름을 시각화하고 싶다고 언급하면 이 스킬을 적극 활용할 것.
---

# 페이지 화면 플로우 생성기

코드베이스 분석 → 상태/로직 추출 → 정적 HTML 화면 플로우 생성.
테스트 섹션 없이 화면 플로우만 출력한다.

## Step 1: 페이지명 추출 및 파일 탐색

사용자 요청에서 페이지명을 추출한다 (예: "NiceAuthPage" → `niceAuth`).

```bash
# 디렉토리 탐색 (camelCase 변환 후 검색)
find src -type d -iname "*{pageName}*" 2>/dev/null
find src/pages src/screens -maxdepth 2 -name "index.tsx" | xargs grep -l "{PageName}" 2>/dev/null
```

찾은 디렉토리에서 다음 파일을 읽는다:
- `index.tsx` — 메인 컴포넌트 (필수)
- `*.reducer.ts` / `*Reducer.ts` — 상태 머신 (있으면)
- `*Type.ts` / `*.types.ts` — 타입 정의 (있으면)
- `*BottomSheet.tsx`, `*Modal.tsx` — 바텀시트/모달 (같은 디렉토리)

## Step 2: 로직 추출

코드를 읽으며 다음을 파악한다.

**화면 단계 (Steps)**
- 리듀서 액션 타입 → 단계 흐름 도출
- 예: `Init → IdentityVerify → VerificationCode → Complete`

**각 단계별 화면 상태 변형**
- 빈 폼 vs 채워진 폼
- 로딩 중 / 에러 상태
- 입력 완료 후 상태 변화

**버튼/필드 조건**
- `isValid*` 함수, `disabled` 조건, `state: "normal"|"disabled"` 패턴
- 어떤 조건에서 버튼이 활성화/비활성화되는지

**바텀시트/모달 트리거**
- `isVisible*`, `open*` 상태 변수와 그 표시 조건
- 닫힘 조건 및 닫힐 때 동작

**화면 전환**
- `navigation.navigate`, `navigation.replace`, `navigation.pop` 호출 조건

## Step 3: HTML 생성

아래 CSS 시스템을 그대로 사용하여 HTML 파일을 작성한다.

### CSS 템플릿

```css
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
  font-family: 'Pretendard', -apple-system, system-ui, sans-serif;
  background: #f0f4f8; padding: 40px 32px; color: #1e293b;
}

/* 헤더 */
.page-title { text-align: center; font-size: 26px; font-weight: 800; margin-bottom: 6px; }
.page-subtitle { text-align: center; font-size: 13px; color: #64748b; margin-bottom: 48px; }

/* 상단 플로우 라인 */
.flow-line {
  display: flex; align-items: center; justify-content: center;
  gap: 10px; margin-bottom: 52px; flex-wrap: wrap;
}
.flow-step { display: flex; flex-direction: column; align-items: center; gap: 5px; }
.step-num {
  width: 28px; height: 28px; border-radius: 50%;
  background: #3b82f6; color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 700;
}
.step-num.done { background: #22c55e; font-size: 14px; }
.step-label { font-size: 11px; color: #64748b; text-align: center; max-width: 64px; line-height: 1.3; }
.flow-arrow { font-size: 16px; color: #3b82f6; padding-bottom: 14px; }

/* 섹션 */
.flow-section { margin-bottom: 52px; }
.section-title {
  font-size: 11px; font-weight: 700; color: #94a3b8;
  text-transform: uppercase; letter-spacing: 0.1em;
  margin-bottom: 20px; padding-left: 2px;
}
.page-wrap { max-width: 1200px; margin: 0 auto; }
.flow-row { display: flex; align-items: flex-start; justify-content: center; gap: 20px; flex-wrap: wrap; }
.group { display: flex; flex-direction: column; align-items: center; gap: 7px; }
.screen-label { font-size: 11px; font-weight: 700; color: #3b82f6; text-transform: uppercase; letter-spacing: 0.06em; }
.badge {
  font-size: 11px; padding: 2px 8px; border-radius: 99px;
  background: #dbeafe; color: #1d4ed8; font-weight: 600;
}
.badge.green { background: #dcfce7; color: #15803d; }
.badge.red { background: #fee2e2; color: #b91c1c; }
.badge.gray { background: #f1f5f9; color: #64748b; }
.arrow { font-size: 24px; color: #3b82f6; padding-top: 110px; }
.condition-note { font-size: 11px; color: #94a3b8; font-style: italic; text-align: center; max-width: 200px; margin-top: 2px; line-height: 1.5; }

/* 모바일 프레임 */
.phone {
  width: 210px; border: 2.5px solid #1e293b; border-radius: 28px;
  background: #fff; overflow: hidden;
  box-shadow: 0 8px 28px rgba(0,0,0,0.13);
}
.status-bar {
  height: 34px; background: #fff; border-bottom: 1px solid #f0f0f0;
  display: flex; justify-content: space-between; align-items: center;
  padding: 0 14px; font-size: 11px; font-weight: 600;
}
.nav-bar {
  height: 44px; background: #fff; border-bottom: 1px solid #f0f0f0;
  display: flex; justify-content: space-between; align-items: center; padding: 0 12px;
}
.nav-title { font-size: 14px; font-weight: 700; }
.nav-btn { font-size: 18px; color: #64748b; }
.screen-body { padding: 14px 12px; min-height: 280px; }
.cta-area { padding: 8px 12px 14px; }

/* 인포 박스 */
.info-box {
  background: #eff6ff; border-radius: 8px; padding: 9px 11px;
  font-size: 11px; color: #3b82f6; margin-bottom: 10px; line-height: 1.5;
}

/* 입력 필드 */
.field {
  height: 40px; border: 1.5px solid #e5e7eb; border-radius: 10px;
  display: flex; align-items: center; padding: 0 11px;
  font-size: 12px; color: #1e293b; margin-bottom: 7px;
}
.field.active { border-color: #3b82f6; }
.field.disabled { background: #f5f5f5; color: #aaa; }
.field.error { border-color: #ef4444; }
.field-placeholder { color: #cbd5e1; }
.field-row { display: flex; gap: 6px; margin-bottom: 7px; }
.field-row .field { flex: 1; margin-bottom: 0; }

/* 버튼 */
.cta-btn {
  height: 44px; border-radius: 12px;
  display: flex; align-items: center; justify-content: center;
  font-size: 13px; font-weight: 700;
}
.cta-btn.active { background: #3b82f6; color: #fff; }
.cta-btn.disabled { background: #e5e7eb; color: #aaa; }
.sub-btn {
  height: 36px; border-radius: 8px; border: 1px solid #e5e7eb;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; color: #64748b; margin-top: 6px;
}

/* 타이머 */
.timer { font-size: 11px; color: #ef4444; font-weight: 600; text-align: right; margin-bottom: 6px; }

/* 바텀시트 */
.bs-group { display: flex; flex-direction: column; align-items: center; gap: 7px; }
.bs-trigger { font-size: 11px; color: #64748b; font-style: italic; text-align: center; max-width: 220px; }
.bottomsheet {
  background: #fff; border-radius: 20px 20px 0 0;
  box-shadow: 0 -4px 24px rgba(0,0,0,0.13);
  padding: 18px 14px; width: 210px;
}
.bs-handle { width: 32px; height: 4px; background: #e5e7eb; border-radius: 2px; margin: 0 auto 14px; }
.bs-title { font-size: 14px; font-weight: 700; margin-bottom: 10px; }
.bs-item {
  height: 44px; display: flex; align-items: center; justify-content: space-between;
  padding: 0 4px; font-size: 13px; border-bottom: 1px solid #f0f0f0;
}
.bs-item.selected { color: #3b82f6; font-weight: 700; }
.bs-item.disabled { color: #cbd5e1; }

/* 팝업 */
.popup-wrapper { display: flex; flex-direction: column; align-items: center; gap: 7px; }
.popup-trigger { font-size: 11px; color: #64748b; font-style: italic; text-align: center; max-width: 220px; }
.popup {
  background: #fff; border-radius: 16px;
  box-shadow: 0 8px 32px rgba(0,0,0,0.16);
  padding: 20px 16px; width: 210px;
}
.popup-title { font-size: 14px; font-weight: 700; margin-bottom: 8px; }
.popup-body { font-size: 12px; color: #64748b; line-height: 1.6; margin-bottom: 14px; }
.popup-actions { display: flex; gap: 8px; }
.popup-btn {
  flex: 1; height: 38px; border-radius: 8px;
  display: flex; align-items: center; justify-content: center;
  font-size: 12px; font-weight: 600;
}
.popup-btn.cancel { background: #f1f5f9; color: #64748b; }
.popup-btn.confirm { background: #3b82f6; color: #fff; }

/* 구분선 */
.divider { border: none; border-top: 2px dashed #e5e7eb; margin: 44px 0; }
```

### HTML 구조 패턴

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{PageName} 화면 플로우</title>
  <style>/* 위 CSS 전체 삽입 */</style>
</head>
<body>
<div class="page-wrap">

<!-- 헤더 -->
<h1 class="page-title">{PageName} 화면 플로우</h1>
<p class="page-subtitle">코드베이스 기반 실제 화면 재현 · {PageName} ({현재 브랜치명})</p>

<!-- 상단 플로우 라인: 리듀서 액션 타입 기반 -->
<div class="flow-line">
  <div class="flow-step">
    <div class="step-num">1</div>
    <div class="step-label">단계명</div>
  </div>
  <div class="flow-arrow">→</div>
  <!-- ... -->
  <div class="flow-step">
    <div class="step-num done">✓</div>
    <div class="step-label">완료</div>
  </div>
</div>

<!-- STEP 1: 같은 단계의 다양한 상태를 한 row에 -->
<div class="flow-section">
  <div class="section-title">STEP 1 — {단계명}</div>
  <div class="flow-row">

    <!-- 상태 A: 초기/빈 폼 -->
    <div class="group">
      <div class="screen-label">STEP 1 — 초기 진입</div>
      <div class="badge">빈 폼 · 버튼 비활성</div>
      <div class="phone">
        <div class="status-bar"><span>9:41</span><span>▶ II ■</span></div>
        <div class="nav-bar">
          <span class="nav-btn">‹</span>
          <span class="nav-title">화면 타이틀</span>
          <span class="nav-btn">✕</span>
        </div>
        <div class="screen-body">
          <div class="info-box">안내 메시지 텍스트</div>
          <div class="field"><span class="field-placeholder">필드명</span></div>
          <div class="field"><span class="field-placeholder">필드명</span></div>
        </div>
        <div class="cta-area">
          <div class="cta-btn disabled">버튼 텍스트</div>
        </div>
      </div>
      <p class="condition-note">조건 설명 텍스트</p>
    </div>

    <div class="arrow">→</div>

    <!-- 상태 B: 입력 완료 -->
    <div class="group">
      <div class="screen-label">STEP 1 — 입력 완료</div>
      <div class="badge green">필드 완료 · 버튼 활성</div>
      <div class="phone">
        <!-- ... -->
        <div class="cta-area">
          <div class="cta-btn active">버튼 텍스트</div>
        </div>
      </div>
    </div>

    <div class="arrow">→</div>

  </div>
</div>

<!-- 바텀시트 섹션: 트리거 조건 + UI -->
<div class="flow-section">
  <div class="section-title">{바텀시트명}</div>
  <div class="flow-row">
    <div class="bs-group">
      <div class="bs-trigger">{트리거 설명} 클릭 시</div>
      <div class="bottomsheet">
        <div class="bs-handle"></div>
        <div class="bs-title">바텀시트 타이틀</div>
        <div class="bs-item selected">선택된 항목 <span>✓</span></div>
        <div class="bs-item">항목</div>
        <div class="bs-item disabled">비활성 항목</div>
      </div>
      <p class="condition-note">닫힘 조건: {조건}</p>
    </div>
  </div>
</div>

<!-- 팝업/Alert 섹션 (있을 경우) -->
<div class="flow-section">
  <div class="section-title">팝업 / Alert</div>
  <div class="flow-row">
    <div class="popup-wrapper">
      <div class="popup-trigger">{트리거 조건}</div>
      <div class="popup">
        <div class="popup-title">팝업 제목</div>
        <div class="popup-body">팝업 본문 내용</div>
        <div class="popup-actions">
          <div class="popup-btn cancel">취소</div>
          <div class="popup-btn confirm">확인</div>
        </div>
      </div>
    </div>
  </div>
</div>

</body>
</html>
```

### 생성 원칙

- **한 `flow-row` = 같은 단계의 상태 변형들** (초기 → 입력 중 → 완료 등)
- **바텀시트/모달은 별도 섹션**으로 분리하고 트리거 조건을 `.bs-trigger`에 명시
- **`condition-note`에 코드 조건 표시**: `isValid*()` 함수명, `state === "X"` 조건 등
- 실제 코드에서 읽은 **placeholder 텍스트, 버튼 라벨, 필드명을 그대로** 사용
- 현재 git 브랜치명을 `git branch --show-current`로 가져와 subtitle에 표시

## Step 4: 파일 저장 및 열기

```bash
# docs 디렉토리 생성 (없으면)
mkdir -p docs

# 파일 저장 경로
docs/{PageName}_flow.html
```

저장 후 `open docs/{PageName}_flow.html` 로 브라우저에서 바로 열기.
