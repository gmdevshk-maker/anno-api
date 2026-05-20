<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1" name="viewport"/>
    <title>테이블 에디터</title>
    <style>
        :root { --border:black; --accent:#4f46e5; --bg:#f8fafc; --text:#111827; --muted:#6b7280; }
        * { box-sizing: border-box; }
        body { margin:0; padding:16px; font-family: system-ui, -apple-system, Segoe UI, Roboto, Noto Sans KR, Arial, "맑은 고딕", sans-serif; color:var(--text); background:#fff; }
        h1 { font-size:18px; margin:0 0 12px; }
        .hint { color:var(--muted); font-size:12px; margin:8px 2px 1px; }
        .kbd { font-family:ui-monospace, SFMono-Regular, Menlo, monospace; border:1px solid var(--border); border-bottom-width:2px; padding:1px 6px; border-radius:6px; background:#fff; }
        .edit-table-wrap { overflow:auto; }
        table { border-collapse:collapse; width:auto; table-layout:fixed; }
        thead th { background:var(--bg); font-weight:700; text-align:center; }
        tr { height:40px; }
        td, th { border:1px solid var(--border); padding:0; position:relative; vertical-align:middle; }
        td:focus-within, th:focus-within { outline:2px solid rgba(79,70,229,.25); outline-offset:-2px; }
        td.selected, th.selected { outline:2px solid var(--accent); outline-offset:-2px; background:#eef2ff; }
        td input, th input { width:100%; height:100%; border:0; padding:8px 10px; font-size:14px; background:transparent; color:var(--text); box-sizing: border-box; }
        td input[readonly], th input[readonly] { color:#6b7280; background:#f3f4f6; }
        .ctx-menu { position:fixed; z-index:9999; min-width:110px; padding:6px 0; margin:0; list-style:none; background:#fff; border:1px solid var(--border); border-radius:10px; box-shadow:0 10px 30px rgba(0,0,0,.12); display:none; }
        .ctx-menu .item { padding:8px 12px; cursor:pointer; font-size:13px; white-space:nowrap; }
        .ctx-menu .item:hover { background:#f4f4ff; }
        .ctx-menu .has-sub { position:relative; }
        .ctx-menu .has-sub > .item::after { content:'▶'; float:right; opacity:.6; }
        .ctx-menu .submenu { position:fixed; display:none; background:#fff; border:1px solid var(--border); border-radius:10px; padding:6px 0; list-style:none; box-shadow:0 10px 30px rgba(0,0,0,.12); }
        #previewTable .pv-text { display:block; margin:0 8px; }
        td.cell-readonly, th.cell-readonly { background:#f3f4f6; }
        td.cell-readonly input, th.cell-readonly input { background:transparent; }
        #table-edit-modal #table-edit-content { overflow-x: auto; overflow-y: auto; }
        #table-edit-modal #table-edit-content .edit-table-wrap { overflow-x: auto; }
        #table-edit-modal #table-edit-content table { width: max-content; table-layout: fixed; /* white-space: nowrap;  // 셀 줄바꿈 방지 원할 시 주석 해제 */ }
        #table-edit-modal #previewWrap { overflow-x: auto; }
        #table-edit-modal #previewWrap #previewTable { width: max-content; table-layout: fixed; }
        thead th { background:#eef2ff !important; }
        /* 셀 우측 플로팅 메뉴 */
        .cell-toolbar {
            position: absolute; z-index: 9998; display: none;
            background:#fff; border:1px solid #111; border-radius:10px;
            padding:20px; box-shadow:0 10px 30px rgba(0,0,0,.12); width:150px;
            user-select:none;
        }
        .cell-toolbar .sec-title { font-size:12px; text-align:center; margin:2px 0 6px; color:#374151; }
        .cell-toolbar .grid {
            display:grid; grid-template-columns:repeat(3, 1fr); gap:6px; place-items:center;
            margin-bottom:8px;
        }
        .cell-toolbar .row {
            display:flex; gap:8px; justify-content:center;
        }
        .cell-toolbar button {
            width:32px; height:32px; border:1px solid #111; border-radius:6px;
            background:#fff; cursor:pointer; font-size:14px; line-height:1;
        }
        .cell-toolbar button:hover { background:#f4f4ff; }
        .cell-toolbar .btn-wide { width:42px; }
        /* 메뉴 토글 표시용 */
        .ctx-menu .item[role="menuitemradio"]{ padding-left:22px; position:relative; }
        .ctx-menu .item[role="menuitemradio"]::before{
            content:'☐'; position:absolute; left:8px; top:50%; transform:translateY(-50%); opacity:.8;
        }
        .ctx-menu .item[role="menuitemradio"].checked::before{ content:'✔'; }
    </style>
</head>
<body>
<div class="hint">
    셀을 <b>오른쪽 클릭</b>하면 컨텍스트 메뉴가 열립니다. (범위 선택: 첫 셀 클릭 → <b><span class="kbd">Shift</span>+클릭</b>, 다중 선택: <b><span class="kbd">Ctrl</span>+클릭</b>)
</div>
<ul class="ctx-menu" id="ctxMenu">
    <li class="has-sub">
        <div class="item">행/열 툴바</div>
        <ul class="submenu">
            <li class="item" data-act="toolbar-use">사용</li>
            <li class="item" data-act="toolbar-unused">사용안함</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">헤더</div>
        <ul class="submenu">
            <li class="item" data-act="make-header">헤더 설정</li>
            <li class="item" data-act="unset-header">헤더 해제</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">병합</div>
        <ul class="submenu">
            <li class="item" data-act="merge-rect">병합 설정</li>
            <li class="item" data-act="split-cell">병합 해제</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">행</div>
        <ul class="submenu">
            <li class="item" data-act="add-row-above">행 추가(위)</li>
            <li class="item" data-act="add-row-below">행 추가(아래)</li>
            <li class="item" data-act="delete-rows">행 삭제</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">열</div>
        <ul class="submenu">
            <li class="item" data-act="add-col-left">열 추가(왼쪽)</li>
            <li class="item" data-act="add-col-right">열 추가(오른쪽)</li>
            <li class="item" data-act="delete-cols">열 삭제</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">열 너비</div>
        <ul class="submenu">
            <li class="item" data-act="colwidth-100">100px</li>
            <li class="item" data-act="colwidth-200">200px</li>
            <li class="item" data-act="colwidth-300">300px</li>
            <li class="item" data-act="colwidth-custom">직접 입력…</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">정렬</div>
        <ul class="submenu">
            <li class="item" data-act="align-left">왼쪽 정렬</li>
            <li class="item" data-act="align-center">가운데 정렬</li>
            <li class="item" data-act="align-right">오른쪽 정렬</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">입력 타입</div>
        <ul class="submenu">
            <li class="item" data-act="input-type-text">문자 입력</li>
            <li class="item" data-act="input-type-number">숫자 입력</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">읽기전용</div>
        <ul class="submenu">
            <li class="item" data-act="set-readonly">읽기전용 설정</li>
            <li class="item" data-act="unset-readonly">읽기전용 해제</li>
        </ul>
    </li>
    <li class="has-sub">
        <div class="item">수식</div>
        <ul class="submenu">
            <li class="item" data-act="formula-set">수식 설정</li>
            <li class="item" data-act="formula-unset">수식 해제</li>
        </ul>
    </li>
</ul>
<div class="edit-table-wrap">
    <table id="grid">
        <colgroup class="colgroup"></colgroup>
        <thead></thead>
        <tbody></tbody>
    </table>
</div>
<div style="margin:12px 0 6px;">
    <button id="btnReset" onclick="resetTable();" type="button">초기화</button>
    <button id="btnPreview" onclick="previewTable();" type="button">미리보기</button>
</div>
<div class="edit-table-wrap" id="previewWrap"></div>
<!-- 셀 우측 플로팅 메뉴 -->
<div id="cellToolbar" class="cell-toolbar" role="toolbar" aria-hidden="true">
    <div class="sec-title">행/열 추가</div>
    <div class="grid" aria-label="행/열 추가">
        <span></span>
        <button type="button" data-act="up" aria-label="위로 추가">↑</button>
        <span></span>
        <button type="button" data-act="left" aria-label="왼쪽으로 추가">←</button>
        <span></span>
        <button type="button" data-act="right" aria-label="오른쪽으로 추가">→</button>
        <span></span>
        <button type="button" data-act="down" aria-label="아래로 추가">↓</button>
        <span></span>
    </div>
    <div class="sec-title" style="border-top:1px solid #e5e7eb; padding-top:6px;">행/열 삭제</div>
    <div class="row" aria-label="행/열 삭제">
        <button type="button" class="btn-wide" data-act="del-row" aria-label="행 삭제">━</button>
        <button type="button" class="btn-wide" data-act="del-col" aria-label="열 삭제">┃</button>
    </div>
</div>
<script>
    window.$table = $('#grid');
    window.$ctx = $('#ctxMenu');

    window.MATRIX = { rows: [], rowMeta: [], totalCols: 0 };
    window.anchor = null;
    window.lastRect = null;

    window.toolbarEnabled = true;

    $(document).ready(function() {
        const $ctx = $('#ctxMenu');
        const $tb  = $('#cellToolbar');
        if ($ctx.length) $ctx.detach().appendTo(document.body);
        if ($tb.length)  $tb.detach().appendTo(document.body);

        updateToolbarMenuChecks();
        initToolbarMenu();
        setEditTableHtml();
    });

    // 저장된 테이블을 가져와서 수정
    function setEditTableHtml() {
        let tableDataEdit = window.tableDataEdit;

        if (tableDataEdit) {
            // 저장된 테이블이 있을 경우
            resetTable();
        }else{
            // 저장된 테이블이 없을 경우 기본테이블로 설정
            refreshDataCell();
        }

        rebuildMatrix();
        resetDataCell();
    }

    function resetTable(){
        $table.empty();
        $('#previewWrap').empty();
        $table.html(tableDataEdit);

        rebuildMatrix();
        resetDataCell();
    }

    // 기본테이블 설정
    function refreshDataCell(){
        if ($table[0].tBodies.length === 0) $table.append('<tbody></tbody>');
        if (!$table[0].tHead) $table.append('<thead></thead>');

        const thead = $table[0].tHead;
        const tbody = $table[0].tBodies[0];

        $(thead).empty();
        $(tbody).empty();

        // 첫 줄은 헤더
        $(thead).append(createRow(6, 'th'));

        // 나머지 4줄은 일반 행
        for (let i = 0; i < 4; i++) {
            $(tbody).append(createRow(6, 'td'));
        }
    }

    // 새로운 셀(td/th)을 생성하고 input을 포함시킴
    function createCell(tag = 'td', value = '') {
        const $cell = $(document.createElement(tag));
        const $inp = $('<input>', { type: 'text', val: value, spellcheck: false });
        $cell.append($inp);

        if (tag === 'td') {
            $cell.css({
                width: '200px',
                minWidth: '200px',
                maxWidth: '200px'
            });
        }

        return $cell[0];
    }

    // 지정된 열 개수(cols)만큼 셀이 포함된 행(tr)을 생성
    function createRow(cols, tag = 'td') {
        const $tr = $('<tr>');
        for (let i = 0; i < cols; i++) {
            $tr.append(createCell(tag));
        }
        return $tr[0];
    }

    // <colgroup>을 열 개수에 맞게 조정
    function ensureColgroup(n) {
        const $cg = $('.colgroup');
        while ($cg.children().length < n) { $cg.append('<col>'); }
        while ($cg.children().length > n) { $cg.children().last().remove(); }
    }

    // 테이블 구조를 MATRIX(행렬) 데이터로 다시 구성
    function rebuildMatrix() {
        const rows = [];
        const rowMeta = [];
        let totalCols = 0;
        const carriers = [];

        function pushSection(secEl, secName) {
            if (!secEl) return;
            for (const tr of secEl.rows) {
                const arr = [];
                for (const c of carriers) {
                    for (let k = 0; k < (c.colSpan || 1); k++) { arr.push(c.cell); }
                    c.remaining -= 1;
                }
                for (let i = carriers.length - 1; i >= 0; i--) {
                    if (carriers[i].remaining <= 0) carriers.splice(i, 1);
                }
                for (const cell of tr.cells) {
                    const cspan = Math.max(1, cell.colSpan || 1);
                    const rspan = Math.max(1, cell.rowSpan || 1);
                    for (let k = 0; k < cspan; k++) { arr.push(cell); }
                    if (rspan > 1) carriers.push({ cell, colSpan: cspan, remaining: rspan - 1 });
                }
                rows.push(arr);
                rowMeta.push({ tr, section: secName });
                totalCols = Math.max(totalCols, arr.length);
            }
        }

        pushSection($table[0].tHead, 'thead');
        pushSection($table[0].tBodies[0], 'tbody');
        MATRIX = { rows, rowMeta, totalCols };
        ensureColgroup(totalCols || 1);
    }

    // 특정 셀의 좌표(r,c)를 MATRIX 기준으로 반환
    function coordsOf(cell) {
        for (let r = 0; r < MATRIX.rows.length; r++) {
            const row = MATRIX.rows[r];
            for (let c = 0; c < row.length; c++) {
                if (row[c] === cell) return { r, c };
            }
        }
        return null;
    }

    // 선택된 셀(td, th)들을 Set으로 반환
    function selectedCells() {
        return new Set($table.find('td.selected, th.selected').toArray());
    }

    // 현재 선택 상태를 초기화
    function clearSelection() {
        $table.find('.selected').removeClass('selected');
    }

    // 직사각형 범위(r1,c1~r2,c2)의 셀들을 선택
    function selectRect(r1, c1, r2, c2) {
        clearSelection();
        const rmin = Math.min(r1, r2);
        const rmax = Math.max(r1, r2);
        const cmin = Math.min(c1, c2);
        const cmax = Math.max(c1, c2);
        const seen = new Set();
        for (let r = rmin; r <= rmax; r++) {
            const row = MATRIX.rows[r] || [];
            for (let c = cmin; c <= cmax; c++) {
                const cell = row[c];
                if (!cell) continue;
                if (seen.has(cell)) continue;
                seen.add(cell);
                $(cell).addClass('selected');
            }
        }
        lastRect = { r1: rmin, c1: cmin, r2: rmax, c2: cmax };
    }

    // 현재 선택된 셀들의 최소/최대 행열 범위 반환
    function selectionBounds() {
        const sel = selectedCells();
        if (!sel.size) return null;
        let rmin = Infinity, rmax = -1, cmin = Infinity, cmax = -1;
        for (let r = 0; r < MATRIX.rows.length; r++) {
            const row = MATRIX.rows[r];
            for (let c = 0; c < row.length; c++) {
                const cell = row[c];
                if (sel.has(cell)) {
                    rmin = Math.min(rmin, r);
                    rmax = Math.max(rmax, r);
                    cmin = Math.min(cmin, c);
                    cmax = Math.max(cmax, c);
                }
            }
        }
        return { rmin, rmax, cmin, cmax };
    }

    // 선택된 셀이 포함된 행 정보를 반환 (tr, 인덱스, 구역명)
    function selectedRows() {
        const sel = selectedCells();
        if (!sel.size) return [];
        const rows = [];
        const seen = new Set();
        for (let r = 0; r < MATRIX.rows.length; r++) {
            const row = MATRIX.rows[r];
            for (let c = 0; c < row.length; c++) {
                const cell = row[c];
                if (sel.has(cell)) {
                    const tr = cell.parentElement;
                    if (!seen.has(tr)) { seen.add(tr); rows.push({ tr, index: r, section: MATRIX.rowMeta[r].section }); }
                }
            }
        }
        rows.sort((a, b) => a.index - b.index);
        return rows;
    }

    $table.on('contextmenu', 'td, th', function (e) {
        e.preventDefault();
        rebuildMatrix();
        const pos = coordsOf(this);
        if (!pos) return;
        if (!$(this).hasClass('selected')) { clearSelection(); $(this).addClass('selected'); }
        showCtxMenu(e.clientX, e.clientY);
    });

    $table.on('click', 'td, th', function (e) {
        rebuildMatrix();
        const pos = coordsOf(this);
        if (!pos) return;
        if (e.shiftKey && anchor) {
            selectRect(anchor.r, anchor.c, pos.r, pos.c);
            hideCtxMenu();
            return;
        }
        if (e.ctrlKey || e.metaKey) {
            $(this).toggleClass('selected');
            anchor = pos;
            hideCtxMenu();
            return;
        }
        clearSelection();
        $(this).addClass('selected');
        anchor = pos;
        hideCtxMenu();
    });

    // 뷰포트 안에 메뉴 위치를 조정
    function clampToViewport(x, y, w, h) {
        const vw = window.innerWidth;
        const vh = window.innerHeight;
        let left = x, top = y;
        if (left + w > vw - 8) left = Math.max(8, x - w);
        if (top + h > vh - 8) top = Math.max(8, y - h);
        if (left < 8) left = 8;
        if (top < 8) top = 8;
        return { left, top };
    }

    // 컨텍스트 메뉴 표시
    function showCtxMenu(clientX, clientY) {
        $ctx.css({ left: -9999, top: -9999, display: 'block' });
        const menuW = $ctx.outerWidth();
        const menuH = $ctx.outerHeight();
        const pos = clampToViewport(clientX, clientY, menuW, menuH);
        $ctx.css({ left: pos.left + 'px', top: pos.top + 'px' });
    }

    // 컨텍스트 메뉴 숨김
    function hideCtxMenu() {
        $ctx.hide();
        hideAllSubmenus();
    }

    // 모든 서브메뉴 숨김
    function hideAllSubmenus() {
        $ctx.find('.submenu').hide();
    }

    $ctx.on('mouseenter', '.has-sub', function () {
        const $parent = $(this);
        const $sub = $parent.children('.submenu');
        if (!$sub.length) return;
        $sub.css({ display: 'block', visibility: 'hidden' });
        const pr = this.getBoundingClientRect();
        const srW = $sub.outerWidth();
        const srH = $sub.outerHeight();
        let left = pr.right;
        let top = pr.top;
        if (left + srW > window.innerWidth - 8) left = pr.left - srW;
        if (top + srH > window.innerHeight - 8) top = Math.max(8, window.innerHeight - 8 - srH);
        if (left < 8) left = 8;
        $sub.css({ left: left + 'px', top: top + 'px', visibility: 'visible' });
    }).on('mouseleave', '.has-sub', function () {
        $(this).children('.submenu').hide();
    });

    $(document).on('click scroll keydown resize', function (e) {
        if (e.type === 'keydown' && e.key !== 'Escape') return;
        hideCtxMenu();
    });

    $ctx.on('click', '[data-act]', function () {
        const act = $(this).data('act');
        hideCtxMenu();
        runCtxAction(act);
    });

    // 선택된 메뉴 항목 실행
    function runCtxAction(act) {
        rebuildMatrix();
        const map = {
            'add-row-above': () => addRow('above'),
            'add-row-below': () => addRow('below'),
            'delete-rows': () => deleteRows(),
            'add-col-left': () => addCol('left'),
            'add-col-right': () => addCol('right'),
            'delete-cols': () => deleteCols(),
            'merge-rect': () => mergeRect(),
            'split-cell': () => splitCells(),
            'align-left': () => alignCells('left'),
            'align-center': () => alignCells('center'),
            'align-right': () => alignCells('right'),
            'make-header': () => makeHeaderMulti(),
            'unset-header': () => unsetHeaderMulti(),
            'set-readonly': () => setReadonly(true),
            'unset-readonly': () => setReadonly(false),
            'input-type-text': () => applyInputTypeFixed('text'),
            'input-type-number': () => applyInputTypeFixed('number'),
            'colwidth-100': () => applyColWidthFixed(100),
            'colwidth-200': () => applyColWidthFixed(200),
            'colwidth-300': () => applyColWidthFixed(300),
            'colwidth-custom': () => applyColWidthPrompt(),
            'formula-set': () => toggleFormula(true),
            'formula-unset': () => toggleFormula(false),
            'toolbar-use': () => {
                window.toolbarEnabled = true;
                updateToolbarMenuChecks();
                showToolbarAtSelectedCell();
            },
            'toolbar-unused': () => {
                window.toolbarEnabled = false;
                updateToolbarMenuChecks();
                $('#cellToolbar').hide().attr('aria-hidden','true')}
        };
        if (map[act]) map[act]();
        rebuildMatrix();
    }

    // 행 추가 (위/아래)
    function addRow(where = 'below') {
        const rows = selectedRows();
        const $tbody = $($table[0].tBodies[0]);
        if (where === 'above') {
            if (!rows.length) return;
            const first = rows[0];
            const secName = first.section === 'thead' ? 'thead' : 'tbody';
            const cols = MATRIX.totalCols || ($table[0].tBodies[0].rows[0]?.cells.length || 1);
            const tr = createRow(cols, secName === 'thead' ? 'th' : 'td');
            $(tr).insertBefore(first.tr);
            //clearSelection();
            //$(tr.cells[0]).addClass('selected');
            return;
        }
        if (rows.length) {
            const last = rows[rows.length - 1];
            const secName = last.section === 'thead' ? 'thead' : 'tbody';
            const cols = MATRIX.totalCols || ($table[0].tBodies[0].rows[0]?.cells.length || 1);
            const tr = createRow(cols, secName === 'thead' ? 'th' : 'td');
            $(tr).insertAfter(last.tr);
            //clearSelection();
            //$(tr.cells[0]).addClass('selected');
        } else {
            const cols = MATRIX.totalCols || ($table[0].tBodies[0].rows[0]?.cells.length || 1);
            const tr = createRow(cols, 'td');
            if ($tbody[0].rows.length) $(tr).insertAfter($tbody[0].rows[$tbody[0].rows.length - 1]);
            else $tbody.append(tr);
            //clearSelection();
            //$(tr.cells[0]).addClass('selected');
        }
    }

    // 선택된 행 삭제
    function deleteRows() {
        rebuildMatrix();
        const b = selectionBounds();
        if (!b) return;
        // 전체 행 개수 확인 (thead + tbody 합산)
        const totalRowCount = ($table[0].tHead?.rows.length || 0) + ($table[0].tBodies[0]?.rows.length || 0);
        if (totalRowCount <= 1) {
            return;
        }
        // 기준 좌표: anchor가 범위 안이면 anchor.r/anchor.c, 아니면 범위 좌상단
        const tgtR = (anchor && b.rmin <= anchor.r && anchor.r <= b.rmax) ? anchor.r : b.rmin;
        const tgtC = (anchor && b.cmin <= anchor.c && anchor.c <= b.cmax) ? anchor.c : b.cmin;

        const rows = selectedRows(); if (!rows.length) return;
        for (let i = rows.length - 1; i >= 0; i--) {
            // 헤더가 1개뿐인데 그걸 지우려고 하면 막기
            if (rows[i].section === "thead" && $table[0].tHead.rows.length <= 1) {
                continue;
            }
            // 일반 행이 1개뿐인데 그걸 지우려고 하면 막기
            if (rows[i].section === "tbody" && $table[0].tBodies[0].rows.length <= 1) {
                continue;
            }
            $(rows[i].tr).remove();
        }

        rebuildMatrix();

        // 삭제 후, 원래 tgtR 위치로 내려온 행을 선택(아래 행이 당겨져 옴)
        let r = Math.min(tgtR, MATRIX.rows.length - 1);
        if (r < 0) { clearSelection(); return; }
        let c = Math.min(tgtC, (MATRIX.rows[r] || []).length - 1);
        clearSelection();
        const cell = MATRIX.rows[r]?.[c];
        if (cell) $(cell).addClass('selected');
    }

    // 특정 인덱스 위치에 열 삽입
    function insertColAt(index) {
        for (let r = 0; r < MATRIX.rows.length; r++) {
            const arr = MATRIX.rows[r];
            const { tr, section } = MATRIX.rowMeta[r];
            const tag = section === 'thead' ? 'th' : 'td';
            if (index >= arr.length) { $(tr).append(createCell(tag)); continue; }
            const ref = arr[index];
            if (!ref) { $(tr).append(createCell(tag)); continue; }
            if (index > 0 && arr[index - 1] === ref) ref.colSpan = (ref.colSpan || 1) + 1;
            else $(createCell(tag)).insertBefore(ref);
        }
    }

    // 열 추가 (왼쪽/오른쪽)
    function addCol(side = 'right') {
        const b = selectionBounds();
        if (!b) return;
        const index = side === 'left' ? b.cmin : (b.cmax + 1);
        insertColAt(index);
        //clearSelection();
    }

    // 선택된 열 삭제
    function deleteCols() {
        rebuildMatrix();
        const b = selectionBounds();
        if (!b) return;
        // 전체 열 개수 확인
        if (MATRIX.totalCols <= 1) {
            return;
        }
        const tgtR = (anchor && b.rmin <= anchor.r && anchor.r <= b.rmax) ? anchor.r : b.rmin;
        const tgtC = b.cmin; // 삭제 후 이 인덱스에 오른쪽 열이 당겨져 옴
        if (!b) return;
        for (let r = 0; r < MATRIX.rows.length; r++) {
            const arr = MATRIX.rows[r];
            const visited = new Set();
            for (let c = b.cmin; c <= b.cmax; c++) {
                const cell = arr[c];
                if (!cell || visited.has(cell)) continue;
                let count = 0; for (let k = c; k <= b.cmax; k++) if (arr[k] === cell) count++;
                if ((cell.colSpan || 1) > count) cell.colSpan = (cell.colSpan || 1) - count; else $(cell).remove();
                visited.add(cell);
            }
        }
        rebuildMatrix();
        let r = Math.min(tgtR, MATRIX.rows.length - 1);
        if (r < 0) { clearSelection(); return; }
        let c = Math.min(tgtC, (MATRIX.rows[r] || []).length - 1);
        clearSelection();
        const cell = MATRIX.rows[r]?.[c];
        if (cell) $(cell).addClass('selected');
    }

    // 선택 영역의 셀 병합
    function mergeRect() {
        const b = selectionBounds();
        if (!b) return;
        const topRow = MATRIX.rows[b.rmin] || [];
        if (!topRow.length) return;
        const firstCell = topRow[b.cmin];
        if (!firstCell) return;
        const uniq = new Set();
        const values = [];
        for (let r = b.rmin; r <= b.rmax; r++) {
            const row = MATRIX.rows[r] || [];
            for (let c = b.cmin; c <= b.cmax; c++) {
                const cell = row[c];
                if (!cell) continue;
                if (uniq.has(cell)) continue;
                uniq.add(cell);
                const inp = $(cell).find('input')[0];
                if (inp && inp.value) values.push(inp.value);
            }
        }
        const a = $(firstCell).find('input')[0];
        if (a) a.value = values.join(' ');
        for (const cell of uniq) {
            if (cell === firstCell) continue;
            $(cell).remove();
        }
        firstCell.colSpan = (b.cmax - b.cmin + 1);
        firstCell.rowSpan = (b.rmax - b.rmin + 1);
        clearSelection();
    }

    // 병합된 셀 해제 (rowSpan, colSpan 원복)
    function splitCells() {
        const sel = Array.from(selectedCells());

        // 병합 해제할 셀들을 먼저 수집 (중복 제거)
        const toSplit = new Set();
        for (const cell of sel) {
            if ((cell.rowSpan || 1) > 1 || (cell.colSpan || 1) > 1) {
                toSplit.add(cell);
            }
        }

        for (const cell of toSplit) {
            const rspan = cell.rowSpan || 1;
            const cspan = cell.colSpan || 1;

            // 병합된 셀이 아니면 건너뛰기
            if (rspan === 1 && cspan === 1) continue;

            const tag = cell.tagName.toLowerCase();

            // rowSpan이 있는 경우: 아래 행들에 빈 셀 추가
            if (rspan > 1) {
                const tr = cell.parentElement;
                const parentEl = tr.parentElement; // thead or tbody
                const allRows = Array.from(parentEl.rows);
                const rowIndex = allRows.indexOf(tr);

                // 현재 셀의 DOM 인덱스 찾기
                const cellIndex = Array.from(tr.cells).indexOf(cell);

                // 아래 행들에 셀 추가
                for (let i = 1; i < rspan; i++) {
                    const targetRow = allRows[rowIndex + i];
                    if (!targetRow) continue;

                    // 삽입 위치 계산: 같은 cellIndex 위치에 삽입
                    let insertPos = 0;
                    let currentPos = 0;

                    for (let j = 0; j < targetRow.cells.length; j++) {
                        if (currentPos >= cellIndex) {
                            insertPos = j;
                            break;
                        }
                        currentPos++;
                        insertPos = j + 1;
                    }

                    // cspan 개수만큼 새 셀 생성 및 삽입
                    for (let k = 0; k < cspan; k++) {
                        const newTag = targetRow.parentElement.tagName === 'THEAD' ? 'th' : 'td';
                        const newCell = createCell(newTag);

                        if (insertPos < targetRow.cells.length) {
                            targetRow.insertBefore(newCell, targetRow.cells[insertPos]);
                        } else {
                            targetRow.appendChild(newCell);
                        }
                    }
                }

                // 원본 셀의 rowSpan 제거
                cell.rowSpan = 1;
            }

            // colSpan이 있는 경우: 같은 행에 빈 셀 추가
            if (cspan > 1) {
                // 원본 셀 뒤에 새 셀들 추가
                for (let i = 1; i < cspan; i++) {
                    const newCell = createCell(tag);
                    cell.parentElement.insertBefore(newCell, cell.nextSibling);
                }

                // 원본 셀의 colSpan 제거
                cell.colSpan = 1;
            }
        }

        // 구조 재구성
        rebuildMatrix();
    }

    // 선택된 셀의 정렬 변경 (left, center, right)
    function alignCells(mode = 'left') {
        const sel = selectedCells();
        if (!sel.size) return;
        for (const cell of sel) {
            $(cell).css('text-align', mode);
            $(cell).find('input').css('text-align', mode);
        }
    }

    // 선택된 행을 헤더(th)로 변환
    function makeHeaderMulti() {
        const rows = selectedRows();
        if (!rows.length) return;
        if (!$table[0].tHead) $table[0].createTHead();
        const thead = $table[0].tHead;
        for (const { tr } of rows) {
            const cells = Array.from(tr.children);
            for (const td of cells) {
                if (td.tagName.toLowerCase() === 'th') continue;
                const inp = td.querySelector('input');
                if (inp) {
                    inp.type = 'text';
                    inp.removeAttribute('readonly');
                    inp.removeAttribute('data-formula');
                    inp.removeAttribute('step');
                    $(td).css('background-color', '');
                }
                const th = document.createElement('th');
                th.colSpan = td.colSpan || 1;
                th.rowSpan = td.rowSpan || 1;
                th.style.cssText = td.style.cssText;
                while (td.firstChild) th.appendChild(td.firstChild);
                td.replaceWith(th);
            }
            thead.appendChild(tr);
        }
        clearSelection();
        rebuildMatrix();
    }

    function unsetHeaderMulti() {
        const rows = selectedRows();
        if (!rows.length) return;

        const theadRows = rows.filter(r => r.section === 'thead');
        if (!theadRows.length) return;

        if (!$table[0].tBodies.length) $table[0].appendChild(document.createElement('tbody'));
        const tbody = $table[0].tBodies[0];
        const toMove = theadRows.map(r => r.tr);
        const refFirst = tbody.rows[0] || null;

        // th → td 변환 함수
        function thToTd(tr) {
            const cells = Array.from(tr.children);
            for (const th of cells) {
                if (th.tagName.toLowerCase() !== 'th') continue;
                const td = document.createElement('td');
                td.colSpan = th.colSpan || 1;
                td.rowSpan = th.rowSpan || 1;
                td.style.cssText = th.style.cssText;
                while (th.firstChild) td.appendChild(th.firstChild);
                th.replaceWith(td);
            }
        }

        // 원래 순서 유지한 채 tbody 맨 앞으로 이동
        for (let i = toMove.length - 1; i >= 0; i--) {
            const tr = toMove[i];
            thToTd(tr);
            if (refFirst) tbody.insertBefore(tr, tbody.firstChild);
            else tbody.appendChild(tr);
        }

        // thead가 비었으면 제거
        if ($table[0].tHead && !$table[0].tHead.rows.length) $table[0].deleteTHead();

        clearSelection();
        rebuildMatrix();
    }

    // 선택된 셀 input 타입 변경(text/number)
    function applyInputTypeFixed(type) {
        const sel = selectedCells();
        if (!sel.size) return;
        for (const cell of sel) {
            let inp = cell.querySelector('input');
            if (!inp) { inp = document.createElement('input'); cell.appendChild(inp); }
            inp.type = type;
            if (type === 'number') inp.step = 'any';
            else inp.removeAttribute('step');
        }
    }

    // 선택된 열의 너비를 고정값으로 변경
    function applyColWidthFixed(val) {
        const b = selectionBounds();
        if (!b) return;

        // 2) MATRIX를 이용해 선택 구간의 모든 행에 대해 컬럼 위치 셀에 width 지정
        const mergeCnt = getMergedCellCount();
        const seen = new WeakSet();
        for (let r = 0; r < MATRIX.rows.length; r++) {
            const row = MATRIX.rows[r] || [];
            for (let c = b.cmin; c <= b.cmax; c++) {
                const cell = row[c];
                let newVal = val;

                if (!cell || seen.has(cell)) continue;

                // merge 갯수에 따라 width 분배
                if (mergeCnt > 1) {
                    newVal = (Number(val) / mergeCnt);
                }

                cell.style.width = newVal + 'px';
                cell.style.minWidth = newVal + 'px';
                cell.style.maxWidth = newVal + 'px';

                seen.add(cell);
            }
        }

        // 3) 셀 안 input은 꽉 차게
        //$table.find('th input, td input').css('width', '100%');
    }

    // 사용자 입력을 받아 열 너비 변경
    function applyColWidthPrompt() {
        const v = window.prompt('열 너비(px)를 입력하세요', '120');
        const val = parseInt(v, 10);
        if (!val || val < 40) return;
        applyColWidthFixed(val);
    }

    // 셀을 읽기전용/해제 처리
    function setReadonly(isReadonly) {
        const sel = selectedCells();
        if (!sel.size) return;

        for (const cell of sel) {
            const $cell = $(cell);
            const $inp  = $cell.find('input');

            $inp.prop('readonly', isReadonly);

            if (isReadonly) {
                $cell.addClass('cell-readonly').css('background-color', '#f3f4f6');
                $inp.css('background-color', 'transparent');
            } else {
                $cell.removeClass('cell-readonly').css('background-color', '');
                $inp.css('background-color', '');
            }
        }
    }

    // 셀을 수식 모드로 설정/해제
    function toggleFormula(enable) {
        const sel = selectedCells();
        if (!sel.size) return;
        for (const cell of sel) {
            const $cell = $(cell);
            const inp = cell.querySelector('input');
            if (!inp) continue;
            if (enable) {
                inp.setAttribute('data-formula', '');
                $cell.css('background-color', 'navajowhite');
                if (inp.type === 'number') { inp.type = 'text'; inp.removeAttribute('step'); }
                $(inp).prop('readonly', false);
            } else {
                inp.removeAttribute('data-formula');
                $cell.css('background-color', '');
            }
        }
        try { if ($table && $table.data('_calx_inited')) { $table.calx('update'); } } catch (_e) {}
    }

    // 열 인덱스를 Excel처럼 A, B, C... 문자열로 변환
    function indexToColumnName(index) {
        let s = ''; let n = index;
        while (n >= 0) { s = String.fromCharCode((n % 26) + 65) + s; n = Math.floor(n / 26) - 1; }
        return s;
    };

    // 셀에 data-cell, placeholder 속성을 갱신
    function refreshGridIdsAndCalx(type) {
        try { rebuildMatrix(); } catch(_e) {}
        const rows = MATRIX.rows, meta = MATRIX.rowMeta;
        let bodyRowNum = 0;
        const visited = new WeakSet(); // ← 전역 방문 체크(한 번만 라벨링)

        for (let r = 0; r < rows.length; r++) {
            if (!meta[r] || meta[r].section !== 'tbody') continue;
            bodyRowNum++;
            const tr = meta[r].tr;

            // 현재 행(tr) 기준의 "DOM 열 오프셋" 계산(캐리어 무시, 실제 열 위치 기준)
            const domCells = Array.from(tr.children);
            const domOffset = new Map();
            let off = 0;
            for (const el of domCells) { domOffset.set(el, off); off += (el.colSpan || 1); }

            const row = rows[r] || [];
            for (let c = 0; c < row.length; c++) {
                const cell = row[c];
                if (!cell || visited.has(cell)) continue;
                if (cell.parentElement !== tr) continue; // ← 캐리어(윗행에 실제로 속한 셀)는 스킵
                const inp = cell.querySelector('input'); if (!inp) continue;
                const colIndex = domOffset.get(cell) ?? c; // DOM 기준 열 인덱스 사용
                const label = indexToColumnName(colIndex) + String(bodyRowNum);

                inp.setAttribute('data-cell', label);
                inp.setAttribute('placeholder', label);

                visited.add(cell);
            }
        }
    };

    function resetDataCell() {
        if (typeof runCtxAction === 'function') {
            let __old = runCtxAction;
            window.runCtxAction = function () {
                let ret = __old.apply(this, arguments);
                try {
                    if(arguments[0] != "merge-rect"){
                        refreshGridIdsAndCalx();
                    }
                } catch (_e) {

                }
                return ret;
            };
        }
        if (typeof $ !== 'undefined') {
            $(function () {
                setTimeout(function () {
                    try {
                        refreshGridIdsAndCalx();
                    } catch (_e) {

                    }
                }, 0);
            });
        }
    };

    // 테이블 미리보기(Preview) 렌더링
    window.previewTable = function() {
        let $src = $('#grid');
        if (!$src.length) { console.warn('grid 테이블이 없습니다.'); return; }
        $src.find('.selected, .cell-selected, .current').removeClass('selected cell-selected current');
        function getColumnWidths($table) {
            let ws = [];
            let $cg = $table.children('colgroup').first();
            if ($cg.length && $cg.find('col').length) {
                $cg.find('col').each(function () {
                    let w = parseFloat($(this).css('width')) || parseFloat($(this).attr('width')) || null;
                    ws.push(w);
                });
            } else {
                let $row = $table.find('thead tr:first, tbody tr:first').first();
                $row.children('th,td').each(function () { ws.push($(this).outerWidth()); });
            }
            return ws;
        }
        let colWidths = getColumnWidths($src);
        let $pv = $('<table id="previewTable">').css('table-layout', 'fixed');
        $pv.html($src.html());
        let $srcInputs = $src.find('thead th input, tbody td input');
        let $pvInputs = $pv.find('thead th input, tbody td input');
        $pvInputs.each(function (i) {
            let $s = $($srcInputs[i]);
            let $t = $(this);
            if (!$s.length) return;
            $t.val($s.val() || $s.attr('value') || '');
            if ($s.prop('readonly')) $t.prop('readonly', true);
            let f = $s.attr('data-formula'); if (typeof f !== 'undefined') $t.attr('data-formula', f);
            let dc = $s.attr('data-cell'); if (typeof dc !== 'undefined') $t.attr('data-cell', dc);
        });
        let $newColgroup = $('<colgroup/>');
        let $oldColgroup = $pv.children('colgroup').first();
        if ($oldColgroup.length) $oldColgroup.replaceWith($newColgroup);
        else $pv.prepend($newColgroup);
        $pv.find('thead th').each(function () {
            let $th = $(this), $inp = $th.find('input');
            if ($inp.length) {
                let txt = $inp.val() || $inp.attr('value') || '';
                $inp.remove();
                $th.text(txt);
            }
        });
        $pv.find('tbody td').each(function () {
            let $td = $(this);
            let $inputs = $td.find('input');
            let bg = $td.css('background-color');
            if (!$inputs.length) return;
            let $fi = $inputs.filter('[data-formula]');
            if ($fi.length) {
                let items = [];
                $fi.each(function () {
                    let $f = $(this);
                    items.push({
                        cellName: $f.attr('data-cell') || $f.attr('name') || '',
                        formulaStr: $f.attr('data-formula') || $f.val() || ''
                    });
                });
                $td.empty();
                items.forEach(function (it) {
                    let $span = $('<span/>')
                        .attr('data-cell', it.cellName)
                        .attr('data-formula', it.formulaStr)
                        .css({ display: 'block', marginLeft: '8px', marginRight: '8px' });
                    $td.append($span);
                });
                $td.css('background-color', bg);
                return;
            }
            let $ro = $inputs.filter('[readonly]');
            if ($ro.length) {
                let v = $ro.first().val() || $ro.first().attr('value') || '';
                let $span = $('<span/>').text(v).attr('data-pv', '1')
                    .css({ display: 'block', marginLeft: '8px', marginRight: '8px' });
                $td.empty().append($span);
                $td.css('background-color', bg);
                return;
            }
            $inputs.removeAttr('placeholder');
        });
        function wrapWithInlineMargin($cell) {
            if ($cell.find('input').length) return;
            if ($cell.children('[data-pv]').length) return;
            if ($cell.find('[data-formula]').length) return;
            let hasContent = $.trim($cell.text()).length || $cell.children().length;
            if (!hasContent) return;
            let kids = $cell.contents();
            let $wrap = $('<span/>').attr('data-pv', '1')
                .css({ display: 'block', marginLeft: '8px', marginRight: '8px' });
            $wrap.append(kids);
            $cell.empty().append($wrap);
        }
        $pv.find('thead th').each(function () { wrapWithInlineMargin($(this)); });
        $pv.find('tbody td').each(function () { wrapWithInlineMargin($(this)); });
        $('#previewWrap').empty().append($pv);
        $pv.calx();
    }

    window.getTableEdit = function() {
        const $src = $('#grid');
        if (!$src.length) { console.warn('grid 테이블이 없습니다.'); return ''; }

        // 원본은 손대지 않고 복제본에서 작업
        const $clone = $src.clone();

        // 선택/포커스 등 편집용 클래스 제거
        $clone.find('.selected, .cell-selected, .current').removeClass('selected cell-selected current');

        // input 현재 값 -> value 속성 동기화 (readonly, data-formula/data-cell 등은 그대로 보존됨)
        $clone.find('thead th input, tbody td input').each(function () {
            this.setAttribute('value', this.value ?? '');
        });

        return $clone.html();
    }

    function getMergedCellCount() {
        if (!window.anchor || !MATRIX || !MATRIX.rows.length) return 1;

        const r = anchor.r;
        const c = anchor.c;
        const row = MATRIX.rows[r] || [];
        const cell = row[c];
        if (!cell) return 1;

        return Number(Math.max(1, cell.colSpan || 1));
    }

    function initToolbarMenu(){
        const $toolbar = $('#cellToolbar');

        // 위치 지정 + 표시
        function showCellToolbarFor(cell) {
            // 먼저 치수 계산을 위해 잠시 표시
            $toolbar.css({ left: -9999, top: -9999, display: 'block' });

            const rect = cell.getBoundingClientRect();
            const w = $toolbar.outerWidth();
            const h = $toolbar.outerHeight();

            // 셀 우측에 정렬(세로는 가운데)
            const x = rect.right + 8;
            const y = rect.top + (rect.height - h) / 2;

            const pos = clampToViewport(x, y, w, h);
            $toolbar
                .css({ left: pos.left + 'px', top: pos.top + 'px', display: 'block' })
                .attr('aria-hidden', 'false');
        }

        function hideCellToolbar() {
            $toolbar.hide().attr('aria-hidden', 'true');
        }

        // 버튼 -> 동작 매핑 (←, →, ↑, ↓, 행, 열)
        $toolbar.off('click.toolbar').on('click.toolbar', 'button[data-act]', function (e) {
            e.stopPropagation();
            const act = $(this).data('act');
            if (act === 'left') addCol('left');        // ←
            else if (act === 'right') addCol('right'); // →
            else if (act === 'up') addRow('above');    // ↑
            else if (act === 'down') addRow('below');  // ↓
            else if (act === 'del-row') deleteRows();  // 행
            else if (act === 'del-col') deleteCols();  // 열
            rebuildMatrix();
            refreshGridIdsAndCalx();
        });

        // 셀 클릭 시 툴바 표시 (기존 선택 로직 뒤에 실행되도록 네임스페이스로 별도 바인딩)
        $table.off('click.toolbar').on('click.toolbar', 'td, th', function () {
            if (!window.toolbarEnabled) return;
            if (window.toolbarEnabled) showToolbarAtSelectedCell();
            showCellToolbarFor(this);
        });

        // 바깥 클릭/ESC/스크롤/리사이즈 시 숨김
        $(document)
            .off('click.toolbar keydown.toolbar')
            .on('click.toolbar', function (e) {
                if (!$(e.target).closest('#grid, #cellToolbar').length) hideCellToolbar();
            })
            .on('keydown.toolbar', function (e) {
                if (e.key === 'Escape') hideCellToolbar();
            });

        $(window).off('scroll.toolbar resize.toolbar')
            .on('scroll.toolbar resize.toolbar', hideCellToolbar);
    }

    // 현재 선택 셀 기준으로 툴바 위치/표시
    function showToolbarAtSelectedCell() {
        const $toolbar = $('#cellToolbar');
        const el = $('#grid').find('td.selected, th.selected').first()[0];
        if (!el) { $toolbar.show().attr('aria-hidden','false'); return; }
        // 위치 계산
        $toolbar.css({ left:-9999, top:-9999, display:'block' });
        const rect = el.getBoundingClientRect();
        const w = $toolbar.outerWidth(), h = $toolbar.outerHeight();
        const pos = clampToViewport(rect.right + 8, rect.top + (rect.height - h)/2, w, h);
        $toolbar.css({ left:pos.left+'px', top:pos.top+'px', display:'block' }).attr('aria-hidden','false');
    }

    // 메뉴 체크표시 갱신
    function updateToolbarMenuChecks(){
        const on = !!window.toolbarEnabled, $ctx = $('#ctxMenu');
        const $use = $ctx.find('[data-act="toolbar-use"]');
        const $off = $ctx.find('[data-act="toolbar-unused"]');
        $use.attr('role','menuitemradio').toggleClass('checked', on).attr('aria-checked', on);
        $off.attr('role','menuitemradio').toggleClass('checked', !on).attr('aria-checked', !on);
    }
</script>
</body>
</html>
