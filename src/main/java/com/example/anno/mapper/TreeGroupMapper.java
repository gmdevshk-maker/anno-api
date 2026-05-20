package com.example.anno.mapper;

import com.example.anno.model.TreeGroup;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TreeGroupMapper {

    // Tree 조회
    List<TreeGroup> selectTreeGroup(TreeGroup treeGroup);

    // Tree 등록
    int insertTreeGroup(List<TreeGroup> tree);

    // Tree 삭제
    int deleteTreeGroup(List<TreeGroup> tree);
}
