<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<!DOCTYPE html>
<html>
<head>
    <link rel="stylesheet" href="/css/common.css">
    <jsp:include page="common/header.jsp" />
    <meta charset="UTF-8">
    <title>주석양식정의</title>
    <style>
        table { border-collapse:collapse; width:auto; table-layout:fixed; }
        body { margin:0; padding:0; font-family:Arial; }
        #top-bar {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px;
            border-bottom:1px solid #ccc;
            background: #f6f8fa;
        }
        #container {
            display: flex;
            height: 800px;
        }
        #tree-panel {
            width: 300px;
            height: 800px;
            border-right: 1px solid #ccc;
            overflow-y: auto;
            background: #fcfcfc;
            padding: 8px 0 8px 8px;
        }
        #right-panel {
            flex:1;
            height: 800px;
            padding: 16px;
            overflow-y: auto;
            background: #fff;
            min-width:500px;
            box-sizing: border-box;
        }
        .panel-header {
            font-size:18px;
            font-weight: bold;
            margin-bottom:14px;
            background: #e2e7f1;
            padding:8px;
            border-radius:5px;
            display: flex;
            justify-content: space-between;  /* 좌, 우 끝 정렬 */
            align-items: center;
            width: 100%;  /* 부모의 전체 너비 사용 */
            box-sizing: border-box;
        }
        .textarea-row {
            width: 100%; height: 70px; resize:vertical; margin-top:10px;
        }
        /* 버튼 스타일 샘플 */
        button, select, input[type="text"] {
            padding:5px 12px;
            font-size:14px;
        }
        button {cursor:pointer; background:#e2e7f1; border: 1px solid #a5b4ce; border-radius:3px;}
        #formal-list-table thead th {
            text-align: center;
        }
        input[readonly] {
            background-color: #e9ecef;
            cursor: not-allowed;
            pointer-events: none;
        }
        #formal-list-table {
            border-collapse: collapse; /* 테두리 겹침 방지 */
        }

        #formal-list-table th,
        #formal-list-table td {
            border: 1px solid #ccc; /* 위, 아래, 왼쪽, 오른쪽 테두리 */
        }

        #container {
            display: flex;
            /*height: 800px;*/
        }
        #tree-panel {
            width: 300px;
            /*height: 800px;*/
            border-right: 1px solid #ccc;
            background: #fcfcfc;
        }
        #divider {
            width: 3px;
            cursor: col-resize;
            background: #dbe3f5;
            /*height: 100%;*/
            z-index: 2;
        }
        #divider.dragging {
            background: #93b0ec;
        }
        #right-panel {
            flex: 1;
            min-width: 500px;
            /*height: 800px;*/
            background: #fff;
        }
        #style-modal table tr:hover,
        #style-modal table td:hover {
            background-color: transparent !important;
        }
        /* ===== previewTable  ===== */
        .formal-table-div .previewTable { border-collapse: collapse; table-layout: fixed; }
        .formal-table-div .previewTable th,
        .formal-table-div .previewTable td { height:40px; border:1px solid #000; padding:0; vertical-align: middle; }
        .formal-table-div .previewTable thead th { background:#eef2ff; text-align:center; font-weight:700; }
        .formal-table-div .previewTable td input,
        .formal-table-div .previewTable th input { width:100%; height:100%; border:0; padding:8px 10px; box-sizing:border-box; }
        .formal-table-div .previewTable [data-pv]{ display:block; margin-left:8px; margin-right:8px; }
        /* ===== end previewTable ===== */
        /* 모달 높이 고정 + 내부를 세로 플렉스 */
        #formal-list-modal{
            max-height:600px;
            display:flex;
            flex-direction:column;
        }

        /* 스크롤 영역(본문 표 래퍼) */
        #formal-list-scroll{
            flex:1;
            overflow-y: scroll;
            scrollbar-gutter: stable;
            margin:0;
            padding:0;
            border-top:0;
            margin-top:-1px; /* 헤더 하단선과 겹치게 */
        }

        /* 표 공통 */
        .formal-table{
            width:100%;
            margin:0;
            border-collapse:collapse;
            table-layout:fixed;
            font-size:15px;
        }

        /* 헤더 스타일 */
        .formal-table thead tr{ background:#e9ebf2; }
        .formal-table thead th{
            text-align:center;
            vertical-align:middle;
            border:1px solid #e5e7eb;
        }

        /* 바디 셀 정렬(필요 시 유지) */
        .formal-table td{
            text-align:center;
            vertical-align:middle;
        }
    </style>
</head>
<body>
<div id="top-bar">
    <label>회계연월</label>
    <input type="month" id="month" style="width:100px;">
    <label>목차</label>
    <input type="text" style="width:200px;">
    <button onclick="ajaxSelectTreeGroup();">Q</button>
    <button style="margin-left:auto;">목차복사</button>
</div>
<div id="container">
    <div id="tree-panel">
        <div id="tree"></div>
    </div>
    <div id="divider"></div>
    <div id="right-panel">
        <div class="panel-header" id="panel-title">
            <span>목차</span>
        </div>
        <button id="save-btn" onclick="ajaxSaveData();" hidden>저장</button>
        <div id="table-wrapper" style="padding-top: 10px;"></div>
    </div>
</div>

<div id="style-modal" style=" display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);
background:#fff;border:2px solid #5a7bcf;border-radius:8px;box-shadow:0 2px 10px #0002;min-width:700px;z-index:1000;padding:30px 32px;">
    <div style="font-size:19px; font-weight:bold; margin-bottom:16px;">양식정의</div>
    <input type="hidden" id="formal_id">
    <table style="width:100%; border-spacing:0; font-size:15px;">
        <!-- 1행 -->
        <tr>
            <td style="width:95px;"><label>표준</label></td>
            <td style="width:80px;">
                <select id="standard" style="width:100%;">
                    <option>Y</option>
                    <option>N</option>
                </select>
            </td>
            <td style="width:95px;"><label>버전 *</label></td>
            <td style="width:80px;">
                <input type="text" id="version" style="width:100%;" required>
            </td>
        </tr>
        <!-- 2행 -->
        <tr>
            <td><label>양식 *</label></td>
            <td>
                <input type="text" id="style" style="width:99%;" required>
            </td>
            <td colspan="2">
                <input type="text" id="styleText" style="width:100%;" required>
            </td>
        </tr>
        <!-- 3행 -->
        <tr>
            <td><label>취합방식</label></td>
            <td>
                <select id="mergeWay" style="width:100%;">
                    <option>합산</option>
                    <option>리스트</option>
                </select>
            </td>
            <td><label>합계방식</label></td>
            <td>
                <select id="sumWay" style="width:100%;">
                    <option>총계</option>
                    <option>법인별</option>
                    <option>법인별/총계</option>
                    <option>사용안함</option>
                </select>
            </td>
        </tr>
        <!-- 4행 -->
        <tr>
            <td><label>분기</label></td>
            <td>
                <select id="quarter" style="width:100%;">
                    <option>Y</option>
                    <option>N</option>
                </select>
            </td>
            <td><label>기말</label></td>
            <td>
                <select id="endTerm" style="width:100%;">
                    <option>Y</option>
                    <option>N</option>
                </select>
            </td>
        </tr>
        <!-- 5행 -->
        <tr>
            <td><label>유효기간</label></td>
            <td colspan="3">
                <input type="month" id="startDt" style="width:100px;" value="1900-01">
                &emsp;~&emsp;
                <input type="month" id="endDt" style="width:100px;" value="9999-12">
            </td>
        </tr>
    </table>
    <div style="margin-top:28px; text-align:right;">
        <button onclick="ajaxSaveStyleCheck();" style="min-width:80px; margin-right:8px;">저장</button>
        <button onclick="closeStyleModal();" style="min-width:80px;">취소</button>
    </div>
</div>

<!-- 양식 리스트 모달창 -->
<div id="formal-list-modal" style="display:none;position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);
max-height:90%;background:#fff;border:2px solid #5a7bcf;border-radius:8px;box-shadow:0 2px 10px #0002;z-index:1001;padding:20px;">
    <div style="font-size:17px; font-weight:bold; margin-bottom:12px;">양식 목록</div>
    <div style="margin-bottom:8px;">
        <input type="text" id="schFormal" placeholder="양식,버전 검색" style="width:300px;">
        <button type="button" onclick="ajaxSelectFormal('','');">Q</button>
    </div>
    <table class="formal-table">
        <colgroup>
            <col style="width:150px;">
            <col style="width:400px;">
            <col style="width:100px;">
            <col style="width:60px;">
            <col style="width:60px;">
            <col style="width:185px;">
        </colgroup>
        <thead>
        <tr>
            <th>양식</th>
            <th>양식명</th>
            <th>버전</th>
            <th>분기</th>
            <th>기말</th>
            <th>유효기간</th>
        </tr>
        </thead>
    </table>
    <div id="formal-list-scroll">
        <table id="formal-list-table" class="formal-table">
            <colgroup>
                <col style="width:150px;">
                <col style="width:400px;">
                <col style="width:100px;">
                <col style="width:60px;">
                <col style="width:60px;">
                <col style="width:85px;">
                <col style="width:85px;">
            </colgroup>
            <tbody>
            </tbody>
        </table>
    </div>
    <div style="margin-top:12px; text-align:right;">
        <button id="formal-select-btn" style="min-width:80px; margin-right:8px;">선택</button>
        <button onclick="closeFormalListModal();" style="min-width:80px;">취소</button>
    </div>
</div>

<!-- tableEdit.jsp를 로드할 모달 -->
<div id="table-edit-modal" style="display:none; position:fixed; top:50%; left:50%; transform:translate(-50%, -50%);
     width:auto; max-width:90%; height:auto; max-height:90%; background:#fff; border-radius:8px; box-shadow:0 4px 15px rgba(0,0,0,0.3); z-index:1500; overflow:auto; padding:20px;">
    <div style="margin-bottom:10px; font-size:17px; font-weight:bold;">양식정의</div>
    <div id="table-edit-content" style="width:100%; height:100%; overflow:auto;"></div>
    <div style="margin-top:10px; text-align:right;">
        <button id="table-select-btn" onclick="ajaxSaveTable();" style="min-width:80px; margin-right:8px;">저장</button>
        <button onclick="closeTableEditModal();" style="min-width:80px;">닫기</button>
    </div>
</div>

<!-- 모달 뒷배경(반투명) -->
<div id="modal-bg" style="display:none;position:fixed;left:0;top:0;width:100vw;height:100vh;background:#1a1a22cc;z-index:990;"></div>


<script>
    let accountDate;
    let maxTreeDepth = 10;
    let defaultData = [{"id": "root", "parent": "#", "text": "목차", "idx": 1}];
    let treeData;
    let treeGroupId;
    let rowIdx;
    let defaultList = {"list": [{"id": "","formalId": "","style": "","styleText": "","version": "", "sentenceId": "", "text": "","idx": "","tableDataEdit": "","saveIdx": ""}]};

    $(document).ready(function() {
        accountDate = moment().clone().subtract(1,'year').format('YYYY')+"-12";
        $('#month').val(accountDate);

        ajaxSelectTreeGroup();

        let isDragging = false;
        let containerOffset, minWidth = 150, maxWidth = 500;

        // 창 조절
        $('#divider').on('mousedown', function(e) {
            isDragging = true;
            containerOffset = $('#container').offset().left;
            $('body').css('user-select', 'none');
            $('#divider').addClass('dragging');
        });

        $(document).on('mousemove', function(e) {
            if (!isDragging) return;
            let newWidth = e.pageX - containerOffset;
            if (newWidth < minWidth) newWidth = minWidth;
            if (newWidth > maxWidth) newWidth = maxWidth;
            $('#tree-panel').css('width', newWidth + 'px');
        });

        $(document).on('mouseup', function(e) {
            if (isDragging) {
                isDragging = false;
                $('body').css('user-select', '');
                $('#divider').removeClass('dragging');
            }
        });

        $("#schFormal").on("keyup",function(key){
            if(key.keyCode==13) {
                ajaxSelectFormal('','');
            }
        });
    });

    // 양식정의 모달 유효기간 초기화
    function initStyleModalDate(){
        $('#startDt').val(moment().format('YYYY')+"-01");
        $('#endDt').val(moment().format('YYYY')+"-12");
    }

    // 스크롤 제어 함수
    function lockBodyScroll() {
        document.body.style.overflow = 'hidden';
    }

    function unlockBodyScroll() {
        document.body.style.overflow = 'auto';
    }

    // Tree 조회
    function ajaxSelectTreeGroup(){
        accountDate = $("#month").val();
        console.log("accountDate >>> "+accountDate);

        $.ajax({
            url: "/selectTreeGroup",
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({accountDate: accountDate}),
            success: function(response) {
                treeData = defaultData.concat(response.list);
                console.log("response >>> " + JSON.stringify(treeData));
                initTree();
            },
            error: function(xhr) {
                CommonUtils.showError("조회 실패: " + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // Tree 초기화
    function initTree(){
        $('#tree').jstree("destroy");
        $('#tree').jstree({
            'core': {
                'check_callback': true, // ← 수정
                'data': treeData
            },
            'plugins': ["contextmenu", "dnd", "wholerow", "types"],
            'types' : {
                "#" : {
                    "max_depth" : maxTreeDepth // 최대 깊이 제한
                }
            },
            'contextmenu': {
                'items': function ($node) {
                    let tree = $('#tree').jstree(true);
                    let node = tree.get_node($node);
                    let items = {};

                    // 현재 노드의 깊이(depth)를 구함
                    // root는 depth 0, 그 하위는 1, 2, ... 식으로 카운트
                    let depth = 0;
                    let parent = node;
                    while (parent.parent && parent.parent !== '#') {
                        parent = tree.get_node(parent.parent);
                        depth++;
                    }

                    // max_depth 도달 시 추가 메뉴 숨김
                    if (depth + 1 < maxTreeDepth) {
                        // depth + 1 은 새로 생성될 자식 노드의 깊이이므로 최대값 미만이어야 추가 가능
                        items['create'] = {
                            'label': '항목 추가',
                            'action': function () {
                                // id를 crypto.randomUUID()로 지정
                                let uuid = CommonUtils.UUID();
                                let newNode = tree.create_node(node, {id: uuid, text: '새 항목'});
                                tree.edit(newNode);
                            }
                        };
                    }

                    // ---- root 노드일 경우 ----
                    if (node.id === "root") {
                        return items; // root일 때 반환
                    }

                    // 기본 메뉴 항상 표시 (이름 변경, 삭제)
                    items['rename'] = {
                        'label': '이름 변경',
                        'action': function () {
                            tree.edit(node);
                        }
                    };
                    items['remove'] = {
                        'label': '항목 삭제',
                        'action': function () {
                            if (confirm("[삭제] 하시겠습니까?")){
                                tree.delete_node(node);
                            };
                        }
                    };

                    return items;
                }
            }
        })
            .on('ready.jstree', function() {
                // 트리 로드 완료 후 모든 노드 펼치기
                $('#tree').jstree('open_all');
            })
            .on('select_node.jstree', function(e, data) {
                // 선택
                let selectedText = data.node.text;
                let selectedId = data.node.id;

                if(selectedId == "root") {
                    // root 선택 시 우측 패널 빈화면 처리
                    $("#save-btn").hide();
                    clearRightPanel();
                    treeGroupId = null;
                } else {
                    // root가 아닌 실제 노드 선택 시 우측 패널 내용 표시
                    $("#save-btn").show();
                    $('#panel-title').text(data.node.text);
                    treeGroupId = selectedId;

                    ajaxSelectTreeDetail();
                }
            })
            .on('create_node.jstree', function(e, data) {
                // 추가
                //ajaxSaveTreeGroup();
            })
            .on('rename_node.jstree', function(e, data) {
                // 변경
                console.log("변경============");
                ajaxSaveTreeGroup();
            })
            .on('delete_node.jstree', function(e, data) {
                // 삭제
                console.log("삭제============");
                ajaxDeleteTreeGroup();
            })
            .on('move_node.jstree', function(e, data) {
                // 이동
                console.log("이동============");
                ajaxSaveTreeGroup();
            });
    }

    function clearRightPanel() {
        $('#panel-title').text('목차');
        $('#table-wrapper').empty();
    }

    // idx를 부여하는 함수 수정: 첫번째 배열값 (root 노드) 삭제 후 반환
    function getTreeWithIdx(treeInstance) {
        let counter = 1;
        // 모든 노드 id 목록 가져오기 (루트부터 순서대로)
        let allNodes = treeInstance.get_json('#', { 'flat': true });
        // 각 노드에 idx 부여
        let result = allNodes.map(function(node) {
            return {
                id: node.id,
                parent: node.parent,
                text: node.text,
                idx: counter++,
                accountDate: accountDate
            };
        });
        // 첫번째 배열값 삭제 (첫번째 요소 제외)
        result.shift();
        return result;
    }

    // 트리구조 저장
    function ajaxSaveTreeGroup(){
        let treeInstance = $('#tree').jstree(true);
        let result = getTreeWithIdx(treeInstance);
        console.log('Tree Data: ', JSON.stringify(result, null, 2));

        $.ajax({
            url: "/saveTreeGroup",
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify(result),
            success: function(response) {
                //CommonUtils.showSuccess("성공적으로 등록되었습니다!");
            },
            error: function(xhr) {
                CommonUtils.showError("등록 실패: " + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // 트리 삭제
    function ajaxDeleteTreeGroup(){
        $.ajax({
            url: "/deleteTreeGroup",
            type: "POST",
            contentType: "application/json; charset=utf-8",
            data: JSON.stringify({id: treeGroupId}),
            success: function(response) {
                ajaxSaveTreeGroup();
            },
            error: function(xhr) {
                CommonUtils.showError("삭제 실패: " + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // ----- 우측 동적 테이블 부분 -----
    let rows = [];

    // 테이블 최초 생성 시(초기화)
    function initTable() {
        rows = [{ type: '표' }];
        $('#table-wrapper').empty();
        $('#table-wrapper').append(makeRow(0));
        refreshRowIds(); // ★ 순서 새로 부여
        generateRowsFromJson(defaultList);
    }

    // Row 추가
    function makeRow(idx) {
        let row = rows[idx];
        let wrapper = $('<div>').css({
            marginBottom: '12px',
            display: 'flex',
            flexDirection: 'column'
        });

        let topRow = $('<div>').css({
            display: 'flex',
            alignItems: 'center',
            gap: '8px'
        });

        // +- 버튼
        topRow.append(
            $('<button type="button">+</button>').click(() => plusRow(idx)),
            $('<button type="button">-</button>').click(() => minusRow(idx)),
            $('<select>')
                .append('<option>표</option>', '<option>문장</option>')
                .val(row.type)
                .on('focus', function() {
                    // 변경 전 값 저장
                    $(this).data('prev', this.value);
                })
                .change(function () {
                    let rowDiv = $(this).closest('div[row-idx]');
                    let textareaId = rowDiv.find('input[name="textareaId"]').val();
                    let formalId = rowDiv.find('input[name="formalId"]').val();
                    let saveIdx = rowDiv.find('input[name="saveIdx"]').val();
                    let prev = $(this).data('prev');
                    let id;

                    if (textareaId) id = textareaId;
                    if(formalId) id = formalId;

                    if(id){
                        if (confirm("[변경] 하시겠습니까?\n(이전 데이터는 삭제됩니다)")){
                            ajaxDeleteData(prev, saveIdx, id);
                            changeRowType(idx, $(this).val());
                        } else {
                            $(this).val(prev);
                        }
                    }else{
                        changeRowType(idx, $(this).val());
                    }
                })
        );

        if (row.type === '문장') {
            topRow.append(
                $('<input type="hidden" name="textareaId" value="">'),
                $('<input type="hidden" name="saveIdx" value="">'));
            wrapper.append(topRow);

            let $textarea = $('<textarea class="textarea-row" textarea-id=""></textarea>')
                .css({
                    marginTop: '6px',
                    width: '100%',
                    height: '70px',
                    resize: 'vertical'
                });
            wrapper.append($textarea);
            return wrapper;
        }

        if (row.type === '표') {
            topRow.append(
                $('<input type="text" placeholder="양식,버전 검색" name="version" value="" onKeypress="javascript:if(event.keyCode==13) {ajaxSelectFormal(this,\'\');}">').css('width', '150px'),
                $('<input type="hidden" name="formalId" value="">'),
                $('<input type="hidden" name="tableId" value="">'),
                $('<input type="hidden" name="tableDataEdit" value="">'),
                $('<input type="hidden" name="saveIdx" value="">'),
                $('<button type="button" onclick="ajaxSelectFormal(this,\'\');">Q</button>'),
                $('<label>').text(row.labelText || ''),
                $('<button type="button" onclick="modalStyle(this);">양식등록</button>').css('margin-left', 'auto'),
                $('<button type="button" onclick="modalTable(this);">양식정의</button>')
            );
            wrapper.append(topRow);
            return wrapper;
        }
    }

    // 행 추가 시
    function plusRow(afterIdx) {
        rows.splice(afterIdx + 1, 0, { type: '표' });
        let newRow = makeRow(afterIdx + 1);
        const $wrapper = $('#table-wrapper');
        const $children = $wrapper.children();
        if ($children.length > afterIdx) {
            newRow.insertAfter($children.eq(afterIdx));
        } else {
            $wrapper.append(newRow);
        }
        refreshRowIds(); // ★ 순서 새로 부여
    }

    // 행 삭제 시
    function minusRow(idx) {
        //if (rows.length === 1) return; // 최소 1줄

        let targetRow = $('#table-wrapper').children().eq(idx);
        let selectValue = targetRow.find('select').val();

        if (selectValue === '문장') {
            let textareaId = targetRow.find('input[name="textareaId"]').val();
            let saveIdx = targetRow.find('input[name="saveIdx"]').val();
            console.log('삭제될 문장 idx 값:', saveIdx);
            if(saveIdx){
                if(confirm("저장된 문장을 삭제겠습니까?")){
                    ajaxDeleteData("문장", saveIdx, textareaId);
                }else{
                    return;
                }
            }
        }

        if (selectValue === '표') {
            let saveIdx = targetRow.find('input[name="saveIdx"]').val();
            console.log('삭제될 표 idx 값:', saveIdx);
            if(saveIdx){
                if(confirm("저장된 표를 삭제겠습니까?")){
                    ajaxDeleteData("표", saveIdx, "");
                }else{
                    return;
                }
            }
        }

        if(rows.length === 1){
            initTable();
            return;
        }

        rows.splice(idx, 1);
        $('#table-wrapper').children().eq(idx).remove();
        refreshRowIds();
    }

    // 문장/표 Select 변경 시
    function changeRowType(idx, val) {
        rows[idx].type = val;
        rows[idx].inputVal = rows[idx].inputVal || '';
        rows[idx].textareaVal = rows[idx].textareaVal || '';
        rows[idx].labelText = rows[idx].labelText || '';
        let newRow = makeRow(idx);
        $('#table-wrapper').children().eq(idx).replaceWith(newRow);
        refreshRowIds(); // ★ 순서 새로 부여
    }

    // 양식정의
    function modalStyle(element) {
        let formalId = $(element).closest('div[row-idx]').find('input[name="formalId"]').val();
        let rowDiv = $(element).closest('div[row-idx]');
        rowIdx = rowDiv.attr('row-idx');

        if(formalId){
            ajaxSelectFormal(element, formalId);
        }else{
            resetStyleModal();
            lockBodyScroll();
            $('#style-modal').show();
            $('#modal-bg').show();
        }
    }

    // 표 등록
    function modalTable(element) {
        let value = $(element).siblings('input').val();
        let rowDiv = $(element).closest('div[row-idx]');
        rowIdx = rowDiv.attr('row-idx');
        let formalId = $('div[row-idx="'+rowIdx+'"]').find('input[name="formalId"]').val();
        let tableDataEdit = $('div[row-idx="'+rowIdx+'"]').find('input[name="tableDataEdit"]').val();

        window.tableDataEdit = tableDataEdit;

        if(!formalId){
            alert("양식정의를 먼저 선택하세요.");
            return;
        }

        openTableEditModal();
        lockBodyScroll();
        $('#modal-bg').show();
    }

    function closeStyleModal() {
        unlockBodyScroll();
        $('#style-modal').hide();
        $('#modal-bg').hide();
    }

    // 양식정의 저장 유효성 체크
    function ajaxSaveStyleCheck() {
        if (confirm("[저장] 하시겠습니까?")){
            // 1. 값 읽기
            let data = {
                id: $('#formal_id').val(),
                standard: $('#standard').val(),
                version: $('#version').val(),
                style: $('#style').val(),
                styleText: $('#styleText').val(),
                mergeWay: $('#mergeWay').val(),
                sumWay: $('#sumWay').val(),
                quarter: $('#quarter').val(),
                endTerm: $('#endTerm').val(),
                startDt: $('#startDt').val(),
                endDt: $('#endDt').val()
            };

            // 2. 필수값 체크 (required 표시된 필드)
            let requiredFields = [
                {key: 'version', label: '버전'},
                {key: 'style', label: '양식ID'},
                {key: 'styleText', label: '양식명'}
            ];
            let missing = [];
            requiredFields.forEach(function(f){
                if(!data[f.key] || $.trim(data[f.key]) === '') {
                    missing.push(f.label);
                }
            });
            if(missing.length > 0) {
                alert('필수 입력 항목이 누락되었습니다.\n(' + missing.join(', ') + ')');
                return;
            }

            // 중복값 검증
            $.ajax({
                url: '/selectFormalCheck',  // 실제 저장 url로 변경
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(data),
                success: function(response){
                    console.log("data >>>>> "+JSON.stringify(data));
                    console.log("selectFormalCheck >>>>> "+JSON.stringify(response.data));
                    if(response.data == null){
                        ajaxSaveStyle(data);
                    }else{
                        alert('아래와 중복된 데이터가 존재합니다.' +
                            '\n-----------------------------------------' +
                            '\n버전: ' + response.data.version +
                            '\n양식ID: ' + response.data.style +
                            '\n유효기간: ' + response.data.startDt + ' ~ ' + response.data.endDt +
                            '\n등록일자: ' + response.data.updateDt);
                    }
                },
                error: function(xhr){
                    alert('중복조회 실패: ' + (xhr.responseText || xhr.statusText));
                }
            });
        }
    }

    // 양식정의 모달 저장
    function ajaxSaveStyle(data) {
        $.ajax({
            url: '/saveFormal',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(data),
            success: function(response){
                console.log("ajaxSaveStyle formalId >>> "+response.formal.id);
                let formalId = $('div[row-idx="'+rowIdx+'"]').find('input[name="formalId"]');
                let styleLabel = $('div[row-idx="'+rowIdx+'"]').find('label').first();

                formalId.val(response.formal.id);
                styleLabel.text(response.formal.style + ": " + response.formal.styleText + " (" + response.formal.version + ")");

                closeStyleModal();
            },
            error: function(xhr){
                alert('저장 실패: ' + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // 양식정의 리스트 조회
    function ajaxSelectFormal(element, id){
        let rowDiv;
        let value = $("#schFormal").val();

        if(element){
            rowDiv = $(element).closest('div[row-idx]');
            rowIdx = rowDiv.attr('row-idx');
            value = $('div[row-idx="'+rowIdx+'"]').find('input[name="version"]').val();
        }

        $("#schFormal").val(value);

        $.ajax({
            url: '/selectFormal',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({version: value, id: id}),
            success: function (response) {
                if(id && response.list.length > 0){
                    resetStyleModal();
                    fillStyleModal(response.list[0])
                    lockBodyScroll();
                    $('#style-modal').show();
                    $('#modal-bg').show();
                }else{
                    initFormal(response);
                }
            },
            error: function(xhr){
                alert('목록 조회 실패: ' + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // 양식정의 모달창 입력값 설정
    function fillStyleModal(data) {
        $('#formal_id').val(data.id);
        $('#standard').val(data.standard );
        $('#style').val(data.style);
        $('#styleText').val(data.styleText);
        $('#version').val(data.version);
        $('#mergeWay').val(data.mergeWay);
        $('#sumWay').val(data.sumWay);
        $('#quarter').val(data.quarter);
        $('#endTerm').val(data.endTerm);
        $('#startDt').val(data.startDt);
        $('#endDt').val(data.endDt);

        $('#style').prop('readonly', true);
        $('#version').prop('readonly', true);
    }

    // 양식테이블 초기화
    function initFormal(response){
        // 테이블 tbody 초기화
        let $tbody = $('#formal-list-table tbody');
        $tbody.empty();

        $.each(response.list, function (i, item) {
            $tbody.append(
                '<tr>' +
                '<td style="text-align: center">'+item.style+'</td>' +
                '<td style="text-align:left;">'+item.styleText+'</td>' +
                '<td style="text-align: center">'+item.version+'</td>' +
                '<td style="text-align: center">'+(item.quarter == 'Y' ? '■' : '□')+'</td>' +
                '<td style="text-align: center">'+(item.endTerm == 'Y' ? '■' : '□')+'</td>' +
                '<td style="text-align: center">'+item.startDt+'</td>' +
                '<td style="text-align: center">'+item.endDt+'</td>' +
                '<td style="display: none;">'+item.id+'</td>' +
                '</tr>'
            );
        });
        // 한 행 클릭시 배경 표시
        $('#formal-list-table tbody tr').on('click', function(){
            $(this).siblings().css('background','');
            $(this).css('background','#dbe4f3');
            $(this).addClass('selected').siblings().removeClass('selected');
        });
        lockBodyScroll();
        $('#formal-list-modal').show();
        $('#modal-bg').show();
    }

    // 취소버튼
    function closeFormalListModal() {
        unlockBodyScroll();
        $('#formal-list-modal').hide();
        $('#modal-bg').hide();
        $('#formal-list-table tbody tr').removeClass('selected');
    }

    // 양식목록 선택
    $('#formal-select-btn').on('click', function() {
        let $selected = $('#formal-list-table tbody tr.selected');
        if ($selected.length === 0) {
            alert('선택된 항목이 없습니다.');
            return;
        }

        // 선택된 행의 데이터 읽기
        // 예: version은 3번째 <td>, styleText는 2번째 <td>
        let style = $selected.find('td').eq(0).text();
        let version = $selected.find('td').eq(2).text();
        let styleText = $selected.find('td').eq(1).text();
        let formalId = $selected.find('td').eq(7).text();

        // "Q" 버튼 왼쪽 input과 오른쪽 label 선택
        // topRow 요소가 동적으로 생성되니 jQuery 선택자를 상황에 맞게 수정 필요
        // 예를 들어 첫 번째 topRow 내 input 과 label
        let $topRow = $('#right-panel > div > div').first(); // 적절히 변경 필요

        //let versionInput = $topRow.find('input[type="text"]').first();
        let paramInput = $('div[row-idx="'+rowIdx+'"]').find('input[name="version"]');
        let formalIdInput = $('div[row-idx="'+rowIdx+'"]').find('input[name="formalId"]');
        //let styleLabel = $topRow.find('label').first();
        let styleLabel = $('div[row-idx="'+rowIdx+'"]').find('label').first();

        paramInput.val(style);
        formalIdInput.val(formalId);
        styleLabel.text(style + ": " + styleText + " (" + version + ")");

        ajaxSelectTableSet(formalId);

        closeFormalListModal();
    });

    // 양식정의모달(테이블) 띄우기
    function openTableEditModal() {
        // 모달 내용 초기화(load할 수 있어서 비워두거나 로딩 표시 가능)
        $('#table-edit-content').html('로딩 중...');

        // 모달 및 배경 보여주기
        lockBodyScroll();
        $('#table-edit-modal').show();
        $('#modal-bg').show();

        // tableEdit.jsp 페이지를 Ajax로 로드해서 모달 내용에 삽입
        $('#table-edit-content').empty().load('/tableEdit', function(response, status, xhr) {
            if (status === "error") {
                $('#table-edit-content').html('<p>오류 발생: 페이지를 불러올 수 없습니다.</p>');
            }
        });
    }

    function closeTableEditModal() {
        // 기존 이벤트 리스너 제거
        $('#table-edit-content').off();
        // 컨텍스트 메뉴 제거
        if ($('#ctxMenu').length) {
            $('#ctxMenu').remove();
        }
        // 툴바 제거
        if ($('#cellToolbar').length) {
            $('#cellToolbar').remove();
        }
        // 모달 내용 완전히 비우기
        $('#table-edit-content').empty();

        unlockBodyScroll();
        $('#table-edit-modal').hide();
        $('#modal-bg').hide();
    }

    // 표 저장
    function ajaxSaveTable(){

        if (confirm("[저장] 하시겠습니까?")){
            let tableDataEdit = window.getTableEdit();

            if(tableDataEdit == null){
                return
            }

            let formalIdInput = $('div[row-idx="'+rowIdx+'"]').find('input[name="formalId"]').val();

            $.ajax({
                url: '/saveTableSet',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({
                    formalId: formalIdInput,
                    tableDataEdit: tableDataEdit,
                    treeGroupId: treeGroupId
                }),
                success: function(response) {
                    renderTableBox(tableDataEdit);
                },
                error: function(xhr, status, error) {
                    alert('표 저장 실패: ' + (xhr.responseText || xhr.statusText));
                }
            });
        }
    }

    // 상세내역 저장
    function ajaxSaveData(){
        if(!treeGroupId){
            alert("목차를 선택하세요.");
            return;
        }

        if (confirm("[저장] 하시겠습니까?")){
            $.ajax({
                url: '/deleteTreeGroupDetail',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({id: treeGroupId}),
                success: function(response) {
                    ajaxSaveTextarea();
                },
                error: function(xhr, status, error) {
                    alert('텍스트 저장 실패: ' + (xhr.responseText || xhr.statusText));
                }
            });
        }
    }

    // 문장 저장
    function ajaxSaveTextarea(){
        let dataArray = [];
        // textarea
        $('#table-wrapper textarea').each(function() {
            let idx = $(this).closest('div[row-idx]').attr('row-idx');
            let textareId = $(this).prev('div').find('input[name="textareaId"]').val();

            dataArray.push({
                id: textareId,
                treeGroupId: treeGroupId,
                text: $(this).val(),
                idx: idx
            });
        });
        console.log("textarea Data >>>>> "+JSON.stringify(dataArray));

        if(dataArray.length > 0){
            $.ajax({
                url: '/saveSentence',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify(dataArray),
                success: function(response) {
                    ajaxSaveFormalId();
                },
                error: function(xhr, status, error) {
                    alert('문장 저장 실패: ' + (xhr.responseText || xhr.statusText));
                }
            });
        }else{
            ajaxSaveFormalId();
        }
    }

    // 양식ID 저장
    function ajaxSaveFormalId(){
        let dataArray = [];

        $('#table-wrapper [name="formalId"]').each(function() {
            let formalId = $(this).val();
            if(formalId) {
                let idx = $(this).closest('div[row-idx]').attr('row-idx');

                dataArray.push({
                    treeGroupId: treeGroupId,
                    formalId: formalId,
                    idx: idx
                });
            }
        });

        console.log("ajaxSaveFormalId Data >>>>> "+JSON.stringify(dataArray));
        if(dataArray.length > 0){
            $.ajax({
                url: '/saveFormalId',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify(dataArray),
                success: function(response) {
                    ajaxSelectTreeDetail();
                },
                error: function(xhr, status, error) {
                    alert('표 저장 실패: ' + (xhr.responseText || xhr.statusText));
                }
            });
        }else{
            ajaxSelectTreeDetail();
        }
    }

    function refreshRowIds() {
        $('#table-wrapper > div').each(function(idx) {
            $(this).attr('row-idx', idx + 1); // 각 행에 row-idx="1", "2", ...
        });
    }

    // 테이블 렌더링
    function renderTableBox(tableDataEdit) {
        //unlockBodyScroll();
        //$('#table-edit-modal').hide();
        //$('#modal-bg').hide();

        $('div[row-idx="'+rowIdx+'"]').find('input[name="tableDataEdit"]').val(tableDataEdit);

        // (1) 양식정의 버튼 바로 아래에 div 추가
        let formalDiv = $('div[row-idx="'+rowIdx+'"]').find('.formal-table-div');

        if (!tableDataEdit) {
            formalDiv.empty();
            return;
        }

        if(formalDiv.length) {
            formalDiv.remove(); // 기존 div 있으면 삭제 및 재생성
        }

        // 새 div 생성 및 삽입
        let targetDiv = $('<div class="formal-table-div"></div>');
        $('div[row-idx="'+rowIdx+'"]').first().append(targetDiv);

        // id 제거, class만 사용
        const $pv = $('<table>')
            .addClass('previewTable')
            .css('table-layout', 'fixed')
            .html(tableDataEdit);

        // 편집용 강조 제거
        $pv.find('.selected, .cell-selected, .current')
            .removeClass('selected cell-selected current');

        // 헤더 input → 텍스트
        $pv.find('thead th').each(function () {
            const $th = $(this), $inp = $th.find('input');
            if ($inp.length) {
                const txt = $inp.val() || $inp.attr('value') || '';
                $inp.remove();
                $th.text(txt);
            }
        });

        // 바디 변환 (formula/readonly/placeholder)
        $pv.find('tbody td').each(function () {
            const $td = $(this);
            const $inputs = $td.find('input');
            const bg = $td.css('background-color');
            if (!$inputs.length) return;

            const $fi = $inputs.filter('[data-formula]');
            if ($fi.length) {
                const items = [];
                $fi.each(function () {
                    const $f = $(this);
                    items.push({
                        cellName: $f.attr('data-cell') || $f.attr('name') || '',
                        formulaStr: $f.attr('data-formula') || $f.val() || ''
                    });
                });
                $td.empty();
                items.forEach(function (it) {
                    $('<span/>')
                        .attr('data-cell', it.cellName)
                        .attr('data-formula', it.formulaStr)
                        .css({ display:'block', marginLeft:'8px', marginRight:'8px' })
                        .appendTo($td);
                });
                $td.css('background-color', bg);
                return;
            }

            const $ro = $inputs.filter('[readonly]');
            if ($ro.length) {
                const v = $ro.first().val() || $ro.first().attr('value') || '';
                $td.empty().append(
                    $('<span/>').text(v).attr('data-pv','1')
                        .css({ display:'block', marginLeft:'8px', marginRight:'8px' })
                );
                $td.css('background-color', bg);
                return;
            }

            $inputs.removeAttr('placeholder');
        });

        // 내용 여백 래핑
        function wrapWithInlineMargin($cell) {
            if ($cell.find('input').length) return;
            if ($cell.children('[data-pv]').length) return;
            if ($cell.find('[data-formula]').length) return;
            const hasContent = $.trim($cell.text()).length || $cell.children().length;
            if (!hasContent) return;
            const kids = $cell.contents();
            const $wrap = $('<span/>').attr('data-pv','1')
                .css({ display:'block', marginLeft:'8px', marginRight:'8px' });
            $wrap.append(kids);
            $cell.empty().append($wrap);
        }
        $pv.find('thead th').each(function(){ wrapWithInlineMargin($(this)); });
        $pv.find('tbody td').each(function(){ wrapWithInlineMargin($(this)); });

        targetDiv.empty().append($pv);

        // === preview-like colgroup width fix (no id required) ===
        (function applyColgroupWidths(){
            function getColumnWidths($table){
                const ws = [];
                const $cg = $table.children('colgroup').first();
                if (!($cg.length && $cg.find('col').length)){
                    const $row = $table.find('thead tr:first, tbody tr:first').first();
                    $row.children('th,td').each(function(){ ws.push($(this).outerWidth()); });
                }
                return ws;
            }
            // ensure attached to DOM before measuring
            const widths = getColumnWidths($pv);
            const $newColgroup = $('<colgroup/>');
            const $oldColgroup = $pv.children('colgroup').first();
            if ($oldColgroup.length) $oldColgroup.replaceWith($newColgroup);
            else $pv.prepend($newColgroup);
        })();
        // === end colgroup width fix ===

        $pv.calx();
    }

    // Tree 상세조회
    function ajaxSelectTreeDetail(){
        $.ajax({
            url: '/selectTreeDetail',
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({treeGroupId: treeGroupId}),
            success: function(response) {
                console.log("Tree 상세조회 >>>>> "+JSON.stringify(response));
                if(response.list.length == 0){
                    response = defaultList;
                }

                generateRowsFromJson(response);
            },
            error: function(xhr, status, error) {
                alert('상세조회 실패: ' + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // JSON 데이터를 기반으로 자동으로 Row를 생성하는 함수
    function generateRowsFromJson(jsonData) {
        // 기존 rows 배열 초기화
        rows = [];
        $('#table-wrapper').empty();
        console.log("jsonData >>>>> "+JSON.stringify(jsonData));
        // JSON 데이터의 list 배열을 순회하며 rows 생성
        jsonData.list.forEach(function(item, index) {
            let rowData = {};

            if (item.sentenceId) {
                // 문장 타입
                rowData.type = '문장';
                rowData.textareaVal = item.text;
                rowData.textareaId = item.sentenceId;
                rowData.saveIdx = item.idx;
            } else {
                // 표 타입
                rowData.type = '표';
                rowData.version = item.version;
                rowData.formalId = item.formalId;
                rowData.style = item.style;
                rowData.styleText = item.styleText;
                rowData.tableDataEdit = item.tableDataEdit;
                rowData.tableId = item.tableSetId;
                rowData.saveIdx = item.idx;
            }

            rows.push(rowData);
        });

        // 생성된 rows 배열을 기반으로 실제 DOM 요소들 생성
        rows.forEach(function(row, index) {
            $('#table-wrapper').append(makeRowFromData(index));
        });

        // Row ID 재정렬
        refreshRowIds();

        // 표 타입인 경우 테이블 렌더링
        rows.forEach(function(row, index) {
            if (row.type === '표' && row.tableDataEdit) {
                setTimeout(function() {
                    renderTableForRow(index, row.tableDataEdit);
                }, 100); // DOM이 완전히 생성된 후 실행
            }
        });
    }

    // JSON 데이터를 기반으로 개별 Row를 생성하는 함수 (기존 makeRow 함수 수정)
    function makeRowFromData(idx) {
        let row = rows[idx];
        let wrapper = $('<div>').css({
            marginBottom: '12px',
            display: 'flex',
            flexDirection: 'column'
        });

        let topRow = $('<div>').css({
            display: 'flex',
            alignItems: 'center',
            gap: '8px'
        });

        // + 버튼, - 버튼, select 추가
        console.log("row.saveIdx >>>>> "+row.saveIdx);
        topRow.append(
            $('<button type="button">+</button>').click(() => plusRow(idx)),
            $('<button type="button">-</button>').click(() => minusRow(idx)),
            $('<input type="hidden" name="saveIdx">').val(row.saveIdx),
            $('<select>')
                .append('<option>표</option>', '<option>문장</option>')
                .val(row.type)
                //.prop('disabled', (row.textareaId || row.formalId) ? true : false)
                .on('focus', function() {
                    // 변경 전 값 저장
                    $(this).data('prev', this.value);
                })
                .change(function () {
                    let rowDiv = $(this).closest('div[row-idx]');
                    let textareaId = rowDiv.find('input[name="textareaId"]').val();
                    let formalId = rowDiv.find('input[name="formalId"]').val();
                    let saveIdx = rowDiv.find('input[name="saveIdx"]').val();
                    let prev = $(this).data('prev');
                    let id;

                    if (textareaId) id = textareaId;
                    if(formalId) id = formalId;

                    if(id){
                        if (confirm("[변경] 하시겠습니까?\n(기존 데이터는 삭제됩니다)")){
                            ajaxDeleteData(prev, saveIdx, id);
                            changeRowType(idx, $(this).val());
                        } else {
                            $(this).val(prev);
                        }
                    }else{
                        changeRowType(idx, $(this).val());
                    }
                })
        );

        if (row.type === '표') {
            // 표 타입인 경우의 UI 구성
            let versionInput = $('<input type="text" name="version" placeholder="양식,버전 검색" onKeypress="javascript:if(event.keyCode==13) {ajaxSelectFormal(this,\'\');}">').css('width', '150px').val(row.style);
            let formalIdInput = $('<input type="hidden" name="formalId">').val(row.formalId);
            let tableIdInput = $('<input type="hidden" name="tableId">').val(row.tableId);
            let tableDataEdit = $('<input type="hidden" name="tableDataEdit">').val(row.tableDataEdit);
            let qButton = $('<button type="button" onclick="ajaxSelectFormal(this,\'\');">Q</button>');
            let styleDefButton = $('<button type="button" onclick="modalStyle(this);">양식등록</button>').css('margin-left', 'auto');
            let tableButton = $('<button type="button" onclick="modalTable(this);">양식정의</button>');
            let styleLabel = $('<label>').text((row.formalId ? row.style + ": " + row.styleText + " (" + row.version + ")" : ""));

            topRow.append(versionInput, formalIdInput, tableIdInput, tableDataEdit, qButton, styleLabel, styleDefButton, tableButton);
            wrapper.append(topRow);

            return wrapper;
        } else {
            // 문장 타입인 경우의 UI 구성
            let textareaId = $('<input type="hidden" name="textareaId">').val(row.textareaId);
            topRow.append(textareaId);
            wrapper.append(topRow);

            let textarea = $('<textarea class="textarea-row"></textarea>')
                .css({
                    marginTop: '6px',
                    width: '100%',
                    height: '70px',
                    resize: 'vertical'
                })
                .val(row.textareaVal || '')
                .attr('textarea-id', row.textareaId || '')
                .on('input', function () {
                    rows[idx].textareaVal = $(this).val();
                });

            wrapper.append(textarea);
            return wrapper;
        }
    }

    // 특정 Row에 대해 테이블을 렌더링하는 함수
    function renderTableForRow(rowIndex, tableDataEdit) {
        if (!tableDataEdit) return;

        // 해당 row의 wrapper div 찾기
        let rowDiv = $('div[row-idx="' + (rowIndex + 1) + '"]');

        // formal-table-div가 이미 있는지 확인
        let formalDiv = rowDiv.find('.formal-table-div');
        if (formalDiv.length) {
            formalDiv.remove();
        }

        // 새 div 생성 및 추가
        let targetDiv = $('<div class="formal-table-div"></div>');
        rowDiv.append(targetDiv);

        // id 제거, class만 사용
        const $pv = $('<table>')
            .addClass('previewTable')
            .css('table-layout', 'fixed')
            .html(tableDataEdit);

        // 편집용 강조 제거
        $pv.find('.selected, .cell-selected, .current')
            .removeClass('selected cell-selected current');

        // 헤더 input → 텍스트
        $pv.find('thead th').each(function () {
            const $th = $(this), $inp = $th.find('input');
            if ($inp.length) {
                const txt = $inp.val() || $inp.attr('value') || '';
                $inp.remove();
                $th.text(txt);
            }
        });

        // 바디 변환 (formula/readonly/placeholder)
        $pv.find('tbody td').each(function () {
            const $td = $(this);
            const $inputs = $td.find('input');
            const bg = $td.css('background-color');
            if (!$inputs.length) return;

            const $fi = $inputs.filter('[data-formula]');
            if ($fi.length) {
                const items = [];
                $fi.each(function () {
                    const $f = $(this);
                    items.push({
                        cellName: $f.attr('data-cell') || $f.attr('name') || '',
                        formulaStr: $f.attr('data-formula') || $f.val() || ''
                    });
                });
                $td.empty();
                items.forEach(function (it) {
                    $('<span/>')
                        .attr('data-cell', it.cellName)
                        .attr('data-formula', it.formulaStr)
                        .css({ display:'block', marginLeft:'8px', marginRight:'8px' })
                        .appendTo($td);
                });
                $td.css('background-color', bg);
                return;
            }

            const $ro = $inputs.filter('[readonly]');
            if ($ro.length) {
                const v = $ro.first().val() || $ro.first().attr('value') || '';
                $td.empty().append(
                    $('<span/>').text(v).attr('data-pv','1')
                        .css({ display:'block', marginLeft:'8px', marginRight:'8px' })
                );
                $td.css('background-color', bg);
                return;
            }

            $inputs.removeAttr('placeholder');
        });

        // 내용 여백 래핑
        function wrapWithInlineMargin($cell) {
            if ($cell.find('input').length) return;
            if ($cell.children('[data-pv]').length) return;
            if ($cell.find('[data-formula]').length) return;
            const hasContent = $.trim($cell.text()).length || $cell.children().length;
            if (!hasContent) return;
            const kids = $cell.contents();
            const $wrap = $('<span/>').attr('data-pv','1')
                .css({ display:'block', marginLeft:'8px', marginRight:'8px' });
            $wrap.append(kids);
            $cell.empty().append($wrap);
        }
        $pv.find('thead th').each(function(){ wrapWithInlineMargin($(this)); });
        $pv.find('tbody td').each(function(){ wrapWithInlineMargin($(this)); });

        targetDiv.empty().append($pv);
        $pv.calx();
    }

    // ID 정보를 포함한 테이블 렌더링 함수 (기존 renderTableBox 함수 수정)
    function renderTableBoxWithIds(targetDiv, tableId, formalId, tableDataEdit) {
        let html = "<table border='1' table-data-edit='" + (tableDataEdit ? tableDataEdit : "") + "'><thead><tr>";

        function colIdxToLetter(idx) {
            let str = "";
            idx += 1;
            while (idx > 0) {
                let mod = (idx - 1) % 26;
                str = String.fromCharCode(65 + mod) + str;
                idx = Math.floor((idx - mod) / 26);
            }
            return str;
        }

        // 헤더 생성
        tableJson.headers.forEach(function(h, colIdx) {
            html += '<th style="border-color:black; text-align:center; width:' + (h.width ? h.width : "80") + 'px; ' + (h.hidden ? 'display:none;' : '') + '">';
            html += h.value;
            html += '</th>';
        });

        html += "</tr></thead><tbody>";

        // Body 생성
        tableJson.rows.forEach(function(row, rowIdx) {
            html += "<tr>";
            row.forEach(function(cell, colIdx) {
                let border = "";
                let backgroundColor = "";

                if(cell.readonly) backgroundColor = "gainsboro;";
                if(cell.excelCalc) {
                    backgroundColor = "navajowhite !important;";
                    cell.readonly = true;
                }

                if(cell.readonly) border = "none;";

                let visStyle = (tableJson.headers[colIdx].hidden ? 'display:none;' : 'visibility:hidden;');

                if(!cell.hidden) visStyle = "";
                const cellName = colIdxToLetter(colIdx) + (rowIdx + 1);

                html += '<td style="border-color: black; text-align:'+cell.align+'; width:'+(cell.width ? cell.width : '80')+'px; '+visStyle+' background-color:'+backgroundColor+'">';
                html += '<input type="'+cell.type+'" value="'+cell.value+'" ' +
                    'style="border:'+border+'; text-align:'+cell.align+'; width:'+(cell.width ? cell.width : '80')+'px; background-color:'+backgroundColor+'" ' +
                    'data-cell="'+cellName+'" ' +
                    (cell.readonly ? 'readonly ' : ' ') +
                    (cell.excelCalc ? 'data-formula="' + cell.value + '" ' : '') +
                    (cell.excelCalc ? 'placeholder="' + cell.value + '"' : '');
                html += '</td>';
            });
            html += '</tr>';
        });

        html += '</tbody></table>';

        targetDiv.empty().html(html);
        targetDiv.find('table').calx();
    }

    // 상세내역 삭제
    function ajaxDeleteData(type, idx, textareaId){
        let url;

        switch (type) {
            case "문장":
                url = "deleteSentence";
                break;
            case "표":
                url = "deleteTableRow";
                break;
        }

        $.ajax({
            url: url,
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({treeGroupId: treeGroupId, idx: idx, id: textareaId}),
            success: function(response) {

            },
            error: function(xhr, status, error) {
                alert('삭제 실패: ' + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // 테이블 조회
    function ajaxSelectTableSet(formalId){

        $.ajax({
            url: "/selectTableSet",
            type: 'POST',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            data: JSON.stringify({formalId: formalId}),
            success: function(response) {
                console.log("selectTableSet response >>>> "+JSON.stringify(response.data));
                let tableDataEdit = null;

                if(response.data != null){
                    tableDataEdit = response.data.tableDataEdit;
                    //$('div[row-idx="'+rowIdx+'"]').find('input[name="tableId"]').val(response.data.id);
                }

                renderTableBox(tableDataEdit);
            },
            error: function(xhr, status, error) {
                alert('조회 실패: ' + (xhr.responseText || xhr.statusText));
            }
        });
    }

    // 양식정의 모달 초기화
    function resetStyleModal() {
        $('#style-modal').find('input').val('');
        $('#style-modal').find('select').each(function() {
            $(this).prop('selectedIndex', 0);
        });

        $('#style').prop('readonly', false);
        $('#version').prop('readonly', false);

        initStyleModalDate();
    }
</script>
</body>
</html>
