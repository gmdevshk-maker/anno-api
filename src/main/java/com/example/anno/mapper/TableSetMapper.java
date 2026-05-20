package com.example.anno.mapper;

import com.example.anno.model.TableSet;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TableSetMapper {

    // 표 조회
    TableSet selectTableSet(TableSet tableSet);

    // 표 등록
    int insertTableSet(TableSet tableSet);

    // 표 수정
    int updateTableSet(TableSet tableSet);

    // 표 삭제
    int deleteTableSet(String formalId);
}
