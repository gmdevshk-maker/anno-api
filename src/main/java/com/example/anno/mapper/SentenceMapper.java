package com.example.anno.mapper;

import com.example.anno.model.Sentence;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface SentenceMapper {

    // 문장 조회
    List<Sentence> selectSentence(Sentence sentence);

    // 문장 등록
    int insertSentence(Sentence sentence);

    // 문장 수정
    int updateSentence(Sentence sentence);

    // 문장 삭제
    int deleteSentence(Sentence sentence);

    // 문장 삭제(Tree 전체)
    int deleteSentenceTree(String sentence);
}
