package com.example.anno.mapper;

import com.example.anno.model.TreeGroupDetail;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TreeGroupDetailMapper {

    // 목차 상세조회
    List<TreeGroupDetail> selectTreeGroupDetail(TreeGroupDetail treeGroupDetail);

    // 목차 상세등록(양식)
    int insertTreeGroupDetailFormal(List<TreeGroupDetail> treeGroupDetail);

    // 목차 상세등록(문장)
    int insertTreeGroupDetailSentence(TreeGroupDetail treeGroupDetail);

    // 목차 상세삭제(전체)
    int deleteTreeGroupDetail(String treeGroupDetail);

    // 목차 상세삭제(개별)
    int deleteTreeGroupDetailRow(TreeGroupDetail treeGroupDetail);

    // 목차 상세삭제(테이블)
    int deleteTreeGroupDetailFormal(String id);

    // 목차 상세삭제(양식ID)
    int deleteTreeGroupDetailFormalId(String formalId);

    // 목차 상세삭제(문장)
    int deleteTreeGroupDetailSentence(String id);
}
