// 공통 JavaScript 함수들

// 페이지 로드 시 실행
$(document).ready(function() {
    console.log('Common JavaScript loaded');
    
    // 전역 설정
    $.ajaxSetup({
        timeout: 10000,
        error: function(xhr, status, error) {
            console.error('AJAX Error:', status, error);
        }
    });
});

// 공통 유틸리티 함수들
const CommonUtils = {
    // 성공 메시지 표시
    showSuccess: function(message) {
        alert(message);
    },
    
    // 에러 메시지 표시
    showError: function(message) {
        alert('오류: ' + message);
    },
    
    // 확인 다이얼로그
    confirm: function(message, callback) {
        if (confirm(message)) {
            callback();
        }
    },
    
    // 로딩 표시
    showLoading: function(button) {
        $(button).prop('disabled', true).text('처리 중...');
    },
    
    // 로딩 숨김
    hideLoading: function(button, originalText) {
        $(button).prop('disabled', false).text(originalText || '확인');
    },
    
    // 폼 데이터를 JSON으로 변환
    formToJson: function(formSelector) {
        const formData = {};
        $(formSelector + ' input, ' + formSelector + ' select, ' + formSelector + ' textarea').each(function() {
            const name = $(this).attr('name');
            const value = $(this).val();
            if (name && value !== undefined) {
                formData[name] = value;
            }
        });
        return formData;
    },

    // UUID v4 생성
    UUID: function() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
};

