package com.example.anno.comm;

import com.example.anno.model.TreeGroup;
import com.example.anno.model.TreeNode;

import java.util.*;

public class ConvertTree {
    // 트리 변환 메서드
    public static List<TreeNode> convertToTree(List<TreeGroup> flatList) {
        // 1. 모든 노드를 Map으로 저장 (빠른 검색을 위해)
        Map<String, TreeNode> nodeMap = new HashMap<>();

        // 2. idx를 기준으로 정렬
        flatList.sort(Comparator.comparing(item -> Integer.parseInt(item.getIdx())));

        // 3. 모든 TreeNode 생성
        for (TreeGroup item : flatList) {
            TreeNode node = new TreeNode(item.getId(), item.getText(), item.getFolder());
            nodeMap.put(item.getId(), node);
        }

        // 4. 부모-자식 관계 설정
        List<TreeNode> rootNodes = new ArrayList<>();

        for (TreeGroup item : flatList) {
            TreeNode currentNode = nodeMap.get(item.getId());

            if ("root".equals(item.getParent())) {
                // 루트 노드인 경우
                rootNodes.add(currentNode);
            } else {
                // 자식 노드인 경우 부모에 추가
                TreeNode parentNode = nodeMap.get(item.getParent());
                if (parentNode != null) {
                    parentNode.addChild(currentNode);
                }
            }
        }

        // 5. leaf 노드 설정 및 빈 children 처리
        for (TreeNode node : nodeMap.values()) {
            if (node.getChildren().isEmpty()) {
                node.setChildren(null); // 빈 children 배열을 null로 설정
            }
        }

        // 6. 각 레벨에서 idx 기준으로 정렬
        sortChildrenRecursively(rootNodes, flatList);

        return rootNodes;
    }

    // 재귀적으로 자식 노드들을 정렬하는 메서드
    public static void sortChildrenRecursively(List<TreeNode> nodes, List<TreeGroup> originalList) {
        // 원본 데이터에서 idx 정보를 가져오기 위한 맵 생성
        Map<String, Integer> idxMap = new HashMap<>();
        for (TreeGroup item : originalList) {
            idxMap.put(item.getId(), Integer.parseInt(item.getIdx()));
        }

        // 현재 레벨 정렬
        nodes.sort(Comparator.comparing(node -> idxMap.get(node.getId())));

        // 자식 노드들도 재귀적으로 정렬
        for (TreeNode node : nodes) {
            if (node.getChildren() != null) {
                sortChildrenRecursively(node.getChildren(), originalList);
            }
        }
    }
}
