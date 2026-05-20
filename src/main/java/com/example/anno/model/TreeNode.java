package com.example.anno.model;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class TreeNode {
    private String id;
    private String name;
    private List<TreeNode> children;
    private boolean isLeaf;

    public TreeNode(String id, String name, String folder) {
        this.id = id;
        this.name = name;
        this.children = new ArrayList<>();

        if("Y".equals(folder)){
            this.isLeaf = false;
        }else{
            this.isLeaf = true;
        }
    }

    // JSON 직렬화 시 null인 children 필드 제외
    @JsonInclude(JsonInclude.Include.NON_NULL)
    public List<TreeNode> getChildren() {
        return children;
    }
    // isLeaf가 false일 때 JSON에서 제거
    @JsonInclude(JsonInclude.Include.NON_DEFAULT)
    public boolean isLeaf() { return isLeaf; }

    public void addChild(TreeNode child) {
        this.children.add(child);
    }
}
