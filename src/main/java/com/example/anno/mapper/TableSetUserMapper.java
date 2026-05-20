package com.example.anno.mapper;

import com.example.anno.model.TableSet;
import com.example.anno.model.TableSetUser;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TableSetUserMapper {

    // 표 등록
    int insertTableSetUser(TableSetUser tableSetUser);

    // 표 수정
    int updateTableSetUser(TableSetUser tableSetUser);

    // 표 삭제
    int deleteTableSetUser(String formalId);
}
