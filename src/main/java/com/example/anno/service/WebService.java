package com.example.anno.service;

import com.example.anno.mapper.*;
import com.example.anno.model.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class WebService {

    private final TreeGroupMapper treeGroupMapper;
    private final FormalMapper formalMapper;
    private final TreeGroupDetailMapper treeGroupDetailMapper;
    private final SentenceMapper sentenceMapper;
    private final SentenceUserMapper sentenceUserMapper;
    private final TableSetMapper tableSetMapper;
    private final TableSetUserMapper tableSetUserMapper;
    private final TreeDetailMapper treeDetailMapper;

    // Tree 조회
    public List<TreeGroup> getTreeGroup(TreeGroup treeGroup) {
        return treeGroupMapper.selectTreeGroup(treeGroup);
    }

    // Tree 등록
    @Transactional
    public int createTreeGroup(List<TreeGroup> tree) {
        return treeGroupMapper.insertTreeGroup(tree);
    }

    // Tree 삭제
    @Transactional
    public int deleteTreeGroup(List<TreeGroup> tree) {
        return treeGroupMapper.deleteTreeGroup(tree);
    }

    // 양식정의 조회
    public List<Formal> getFormal(Formal formal) {
        return formalMapper.selectFormal(formal);
    }

    // 양식정의 조회(중복체크)
    public Formal getFormalCheck(Formal formal) {
        return formalMapper.selectFormalCheck(formal);
    }

    // 양식정의 등록
    @Transactional
    public int createFormal(Formal formal) {
        return formalMapper.insertFormal(formal);
    }

    // 양식정의 수정
    @Transactional
    public int updateFormal(Formal formal) {
        return formalMapper.updateFormal(formal);
    }

    // 양식정의 삭제
    @Transactional
    public int deleteFormal(Formal formal) {
        return formalMapper.deleteFormal(formal);
    }

    // 목차 상세조회
    public List<TreeGroupDetail> getTreeGroupDetail(TreeGroupDetail treeGroupDetail) {
        return treeGroupDetailMapper.selectTreeGroupDetail(treeGroupDetail);
    }

    // 목차 상세등록
    @Transactional
    public int createTreeGroupDetailFormal(List<TreeGroupDetail> treeGroupDetail) {
        return treeGroupDetailMapper.insertTreeGroupDetailFormal(treeGroupDetail);
    }

    // 목차 상세등록
    @Transactional
    public int createTreeGroupDetailSentence(TreeGroupDetail treeGroupDetail) {
        return treeGroupDetailMapper.insertTreeGroupDetailSentence(treeGroupDetail);
    }

    // 목차 상세삭제(전체)
    @Transactional
    public int deleteTreeGroupDetail(String treeGroupDetail) {
        return treeGroupDetailMapper.deleteTreeGroupDetail(treeGroupDetail);
    }

    // 목차 상세삭제(개별)
    @Transactional
    public int deleteTreeGroupDetailRow(TreeGroupDetail treeGroupDetail) {
        return treeGroupDetailMapper.deleteTreeGroupDetailRow(treeGroupDetail);
    }

    // 목차 상세삭제(표)
    @Transactional
    public int deleteTreeGroupDetailFormal(String id) {
        return treeGroupDetailMapper.deleteTreeGroupDetailFormal(id);
    }

    // 목차 상세삭제(양식ID)
    @Transactional
    public int deleteTreeGroupDetailFormalId(String formalId) {
        return treeGroupDetailMapper.deleteTreeGroupDetailFormalId(formalId);
    }

    // 목차 상세삭제(문장)
    @Transactional
    public int deleteTreeGroupDetailSentence(String id) {
        return treeGroupDetailMapper.deleteTreeGroupDetailSentence(id);
    }

    // 문장 조회
    public List<Sentence> getSentence(Sentence sentence) {
        return sentenceMapper.selectSentence(sentence);
    }

    // 문장 등록(관리자)
    @Transactional
    public int createSentence(Sentence sentence) {
        return sentenceMapper.insertSentence(sentence);
    }

    // 문장 등록(사용자)
    @Transactional
    public int createSentenceUser(List<SentenceUser> sentenceUser) {
        return sentenceUserMapper.createSentenceUser(sentenceUser);
    }

    // 문장 수정
    @Transactional
    public int updateSentence(Sentence sentence) {
        return sentenceMapper.updateSentence(sentence);
    }

    // 문장 삭제(관리자)
    @Transactional
    public int deleteSentence(Sentence sentence) {
        return sentenceMapper.deleteSentence(sentence);
    }

    // 문장 삭제(사용자)
    @Transactional
    public int deleteSentenceUser(String sentenceId) {
        return sentenceUserMapper.deleteSentenceUser(sentenceId);
    }

    // 문장 삭제(관리자, Tree 전체)
    @Transactional
    public int deleteSentenceTree(String id) {
        return sentenceMapper.deleteSentenceTree(id);
    }

    // 문장 삭제(사용자, Tree 전체)
    @Transactional
    public int deleteSentenceUserTree(String treeGroupId) {
        return sentenceUserMapper.deleteSentenceUserTree(treeGroupId);
    }

    // 표 조회
    public TableSet getTableSet(TableSet tableSet) {
        return tableSetMapper.selectTableSet(tableSet);
    }

    // 표 등록(관리자)
    @Transactional
    public int createTableSet(TableSet tableSet) {
        return tableSetMapper.insertTableSet(tableSet);
    }

    // 표 등록(사용자)
    @Transactional
    public int createTableSetUser(TableSetUser tableSetUser) {
        return tableSetUserMapper.insertTableSetUser(tableSetUser);
    }

    // 표 수정(관리자)
    @Transactional
    public int updateTableSet(TableSet tableSet) {
        return tableSetMapper.updateTableSet(tableSet);
    }

    // 표 수정(사용자)
    @Transactional
    public int updateTableSetUser(TableSetUser tableSetUser) {
        return tableSetUserMapper.updateTableSetUser(tableSetUser);
    }

    // 표 삭제(관리자)
    @Transactional
    public int deleteTableSet(String formalId) {
        return tableSetMapper.deleteTableSet(formalId);
    }

    // 표 삭제(사용자)
    @Transactional
    public int deleteTableSetUser(String formalId) {
        return tableSetUserMapper.deleteTableSetUser(formalId);
    }

    // Tree 상세조회(관리자)
    public List<TreeDetail> getTreeDetail(TreeDetail treeDetail) {
        return treeDetailMapper.selectTreeDetail(treeDetail);
    }

    // Tree 상세조회(사용자)
    public List<TreeDetailUser> getTreeDetailUser(TreeDetailUser treeDetailUser) {
        return treeDetailMapper.selectTreeDetailUser(treeDetailUser);
    }

    // Tree 상세조회(사용자 저체)
    public List<TreeDetailUser> getTreeDetailUserAll(TreeDetailUser treeDetailUser) {
        return treeDetailMapper.selectTreeDetailUserAll(treeDetailUser);
    }
}
