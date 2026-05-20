package com.example.anno.comm;

import com.example.anno.model.TreeDetailUser;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;

import java.math.BigDecimal;
import java.util.*;
import java.util.regex.Pattern;

public class DataAggregator {
    
    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final Pattern NUMBER_PATTERN = Pattern.compile("^-?\\d{1,3}(,\\d{3})*(\\.\\d+)?$|^-?\\d+(\\.\\d+)?$");
    
    /**
     * TreeDetailUser 리스트를 formalId별로 그룹화하고 데이터를 합산합니다.
     */
    public static List<TreeDetailUser> aggregateDataByFormalId(List<TreeDetailUser> detailList) {
        Map<String, List<TreeDetailUser>> groupedData = new HashMap<>();
        
        // formalId별로 그룹화
        for (TreeDetailUser item : detailList) {
            String formalId = item.getFormalId();
            groupedData.computeIfAbsent(formalId, k -> new ArrayList<>()).add(item);
        }
        
        List<TreeDetailUser> totalList = new ArrayList<>();
        
        // 각 그룹별로 데이터 합산
        for (Map.Entry<String, List<TreeDetailUser>> entry : groupedData.entrySet()) {
            List<TreeDetailUser> groupItems = entry.getValue();
            
            // 그룹 내 유효한 userId 개수 계산
            int userCount = countValidUserIds(groupItems);
            
            if (groupItems.size() == 1) {
                // 데이터가 하나만 있는 경우 그대로 추가
                TreeDetailUser singleItem = groupItems.get(0);
                TreeDetailUser result = createResultItem(singleItem);
                result.setData(singleItem.getData()); // data 필드를 그대로 사용
                result.setUserCount(String.valueOf(userCount));
                totalList.add(result);
            } else {
                // 여러 데이터가 있는 경우 합산
                TreeDetailUser aggregatedItem = aggregateGroupData(groupItems);
                aggregatedItem.setUserCount(String.valueOf(userCount));
                totalList.add(aggregatedItem);
            }
        }
        
        // idx 값 기준으로 오름차순 정렬
        totalList.sort(Comparator.comparingInt(DataAggregator::parseIdxToInt));
        
        return totalList;
    }
    
    /**
     * 그룹 내 데이터들을 합산합니다.
     */
    private static TreeDetailUser aggregateGroupData(List<TreeDetailUser> groupItems) {
        TreeDetailUser baseItem = groupItems.get(0);
        TreeDetailUser result = createResultItem(baseItem);
        
        try {
            // defaultData를 기준으로 합산된 데이터 생성
            JsonNode defaultDataNode = objectMapper.readTree(baseItem.getDefaultData());
            JsonNode aggregatedDataNode = aggregateJsonData(groupItems, defaultDataNode);
            
            result.setData(objectMapper.writeValueAsString(aggregatedDataNode));
        } catch (Exception e) {
            // JSON 파싱 오류 시 첫 번째 아이템의 data 사용
            result.setData(baseItem.getData());
        }
        
        return result;
    }
    
    /**
     * JSON 데이터를 합산합니다.
     */
    private static JsonNode aggregateJsonData(List<TreeDetailUser> groupItems, JsonNode defaultDataNode) {
        try {
            // defaultData의 구조를 복사
            JsonNode resultNode = defaultDataNode.deepCopy();
            
            // data 배열 추출
            JsonNode dataArray = resultNode.path("options").path("data");
            if (dataArray.isArray()) {
                ArrayNode aggregatedArray = (ArrayNode) dataArray;
                
                // 각 행별로 합산
                for (int rowIndex = 0; rowIndex < aggregatedArray.size(); rowIndex++) {
                    JsonNode row = aggregatedArray.get(rowIndex);
                    if (row.isArray()) {
                        ArrayNode aggregatedRow = (ArrayNode) row;
                        
                        // 각 열별로 합산
                        for (int colIndex = 0; colIndex < aggregatedRow.size(); colIndex++) {
                            BigDecimal sum = BigDecimal.ZERO;
                            boolean hasNumericData = false;
                            
                            // 모든 그룹 아이템에서 해당 위치의 값들을 합산
                            for (TreeDetailUser item : groupItems) {
                                try {
                                    JsonNode itemDataNode = objectMapper.readTree(item.getData());
                                    JsonNode itemDataArray = itemDataNode.path("options").path("data");
                                    
                                    if (itemDataArray.isArray() && rowIndex < itemDataArray.size()) {
                                        JsonNode itemRow = itemDataArray.get(rowIndex);
                                        if (itemRow.isArray() && colIndex < itemRow.size()) {
                                            String cellValue = itemRow.get(colIndex).asText();
                                            
                                            if (isNumeric(cellValue)) {
                                                BigDecimal cellNumber = parseNumericValue(cellValue);
                                                sum = sum.add(cellNumber);
                                                hasNumericData = true;
                                            }
                                        }
                                    }
                                } catch (Exception e) {
                                    // 개별 아이템 파싱 오류는 무시하고 계속 진행
                                }
                            }
                            
                            // 합산된 값이 있으면 업데이트
                            if (hasNumericData) {
                                aggregatedRow.set(colIndex, objectMapper.valueToTree(formatNumericValue(sum)));
                            }
                        }
                    }
                }
            }
            
            return resultNode;
            
        } catch (Exception e) {
            // 오류 발생 시 기본 데이터 반환
            return defaultDataNode;
        }
    }
    
    /**
     * 결과 아이템을 생성합니다.
     */
    private static TreeDetailUser createResultItem(TreeDetailUser baseItem) {
        TreeDetailUser result = new TreeDetailUser();
        result.setTreeGroupId(baseItem.getTreeGroupId());
        result.setTableSetId(baseItem.getTableSetId());
        result.setFormalId(baseItem.getFormalId());
        result.setStandard(baseItem.getStandard());
        result.setStyle(baseItem.getStyle());
        result.setStyleText(baseItem.getStyleText());
        result.setVersion(baseItem.getVersion());
        result.setMergeWay(baseItem.getMergeWay());
        result.setSumWay(baseItem.getSumWay());
        result.setQuarter(baseItem.getQuarter());
        result.setEndTerm(baseItem.getEndTerm());
        result.setStartDt(baseItem.getStartDt());
        result.setEndDt(baseItem.getEndDt());
        result.setSentenceId(baseItem.getSentenceId());
        result.setText(baseItem.getText());
        result.setIdx(baseItem.getIdx());
        return result;
    }
    
    /**
     * 문자열이 숫자인지 확인합니다.
     */
    private static boolean isNumeric(String value) {
        if (value == null || value.trim().isEmpty()) {
            return false;
        }
        
        // 공백 제거
        String trimmedValue = value.trim();
        
        // 공식(SUM 등)은 제외
        if (trimmedValue.startsWith("=")) {
            return false;
        }
        
        return NUMBER_PATTERN.matcher(trimmedValue).matches();
    }
    
    /**
     * 숫자 문자열을 BigDecimal로 변환합니다.
     */
    private static BigDecimal parseNumericValue(String value) {
        if (value == null || value.trim().isEmpty()) {
            return BigDecimal.ZERO;
        }
        
        // 쉼표 제거
        String cleanValue = value.trim().replace(",", "");
        
        try {
            return new BigDecimal(cleanValue);
        } catch (NumberFormatException e) {
            return BigDecimal.ZERO;
        }
    }
    
    /**
     * BigDecimal 값을 적절한 형식의 문자열로 변환합니다.
     */
    private static String formatNumericValue(BigDecimal value) {
        if (value == null) {
            return "0";
        }
        
        // 정수인 경우 소수점 제거
        if (value.scale() <= 0) {
            return value.toBigInteger().toString();
        } else {
            return value.toString();
        }
    }
    
    /**
     * 그룹 내 유효한 userId의 개수를 계산합니다.
     * null이 아니고 빈 문자열이 아닌 userId만 카운트합니다.
     */
    private static int countValidUserIds(List<TreeDetailUser> groupItems) {
        int count = 0;
        for (TreeDetailUser item : groupItems) {
            String userId = item.getUserId();
            if (userId != null && !userId.trim().isEmpty()) {
                count++;
            }
        }
        return count;
    }
    
    /**
     * idx 문자열을 안전하게 정수로 변환합니다.
     * 파싱 실패 시 큰 값(Integer.MAX_VALUE)을 반환하여 정렬 시 뒤로 이동시킵니다.
     */
    private static int parseIdxToInt(TreeDetailUser item) {
        try {
            String idx = item.getIdx();
            if (idx == null || idx.trim().isEmpty()) {
                return Integer.MAX_VALUE;
            }
            return Integer.parseInt(idx.trim());
        } catch (NumberFormatException e) {
            return Integer.MAX_VALUE;
        }
    }
}
