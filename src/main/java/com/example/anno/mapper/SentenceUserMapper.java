package com.example.anno.mapper;

import com.example.anno.model.Sentence;
import com.example.anno.model.SentenceUser;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface SentenceUserMapper {

    // 문장 등록
    int createSentenceUser(List<SentenceUser> sentenceUser);

    // 문장 삭제
    int deleteSentenceUser(String sentenceId);

    // 문장 삭제(Tree 전체)
    int deleteSentenceUserTree(String treeGroupId);
}
