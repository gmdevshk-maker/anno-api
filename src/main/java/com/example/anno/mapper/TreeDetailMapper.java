package com.example.anno.mapper;

import com.example.anno.model.TableSet;
import com.example.anno.model.TreeDetail;
import com.example.anno.model.TreeDetailUser;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface TreeDetailMapper {

    // Tree 상세조회(관리자)
    List<TreeDetail> selectTreeDetail(TreeDetail treeDetail);
    // Tree 상세조회(사용자)
    List<TreeDetailUser> selectTreeDetailUser(TreeDetailUser treeDetailUser);
    // Tree 상세조회(사용자 전체)
    List<TreeDetailUser> selectTreeDetailUserAll(TreeDetailUser treeDetailUser);
}
