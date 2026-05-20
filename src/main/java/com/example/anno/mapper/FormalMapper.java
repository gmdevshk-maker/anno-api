package com.example.anno.mapper;

import com.example.anno.model.Formal;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface FormalMapper {

    // 양식정의 조회(리스트)
    List<Formal> selectFormal(Formal formal);

    // 양식정의 조회(개병)
    Formal selectFormalCheck(Formal formal);

    // 양식정의 등록
    int insertFormal(Formal formal);

    // 양식정의 수정
    int updateFormal(Formal formal);

    // 양식정의 삭제
    int deleteFormal(Formal formal);
}
