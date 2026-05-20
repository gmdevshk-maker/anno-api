package com.example.anno.controller;

import com.example.anno.comm.ConvertTree;
import com.example.anno.comm.DataAggregator;
import com.example.anno.model.*;
import com.example.anno.service.WebService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;

@Controller
@RequiredArgsConstructor
public class WebController {

    private final WebService webService;

    // 메인화면
    @GetMapping("/")
    public String indexPage() {
        return "index";
    }

    // Tree 조회
    @PostMapping("/selectTreeGroup")
    @ResponseBody
    public HashMap<String, Object> selectTreeGroup(@RequestBody TreeGroup treeGroup) {

        HashMap<String, Object> hashmap = new HashMap<String, Object>();
        List<TreeGroup> list = webService.getTreeGroup(treeGroup);

        // 트리 구조로 변환
        List<TreeNode> treeList = ConvertTree.convertToTree(list);

        hashmap.put("list", treeList);

        return hashmap;
    }

    // Tree 등록
    @PostMapping("/saveTreeGroup")
    @ResponseBody
    public int saveTreeGroup(@RequestBody List<TreeGroup> treeGroup) {

        int res = webService.createTreeGroup(treeGroup);

        return res;
    }

    // Tree 삭제
    @PostMapping("/deleteTreeGroup")
    @ResponseBody
    public int deleteTreeGroup(@RequestBody List<TreeGroup> treeGroup) {

        int res = webService.deleteTreeGroup(treeGroup);

        if(res > 0){
            for(TreeGroup tg : treeGroup){
                webService.deleteTreeGroupDetail(tg.getId());
                webService.deleteSentenceTree(tg.getId());
                webService.deleteSentenceUserTree(tg.getId());
            }
        }

        return res;
    }

    // Tree 상세삭제
    @PostMapping("/deleteTreeGroupDetail")
    @ResponseBody
    public int deleteTreeGroupDetail(@RequestBody TreeGroup treeGroup) {

        int res = webService.deleteTreeGroupDetail(treeGroup.getId());

        return res;
    }

    // Tree 상세조회(관리자)
    @PostMapping("/selectTreeDetail")
    @ResponseBody
    public HashMap<String, Object> selectTreeDetail(@RequestBody TreeDetail treeDetail) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        List<TreeDetail> list = webService.getTreeDetail(treeDetail);

        map.put("list", list);

        return map;
    }

    // Tree 상세조회(사용자)
    @PostMapping("/selectTreeDetailUser")
    @ResponseBody
    public HashMap<String, Object> selectTreeDetailUser(@RequestBody TreeDetailUser treeDetailUser) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        List<TreeDetailUser> list = webService.getTreeDetailUser(treeDetailUser);

        map.put("list", list);

        return map;
    }

    // Tree 상세조회(사용자 전체)
    @PostMapping("/selectTreeDetailUserAll")
    @ResponseBody
    public HashMap<String, Object> selectTreeDetailUserAll(@RequestBody TreeDetailUser treeDetailUser) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        List<TreeDetailUser> detailList = webService.getTreeDetailUserAll(treeDetailUser);
        // formalId별로 데이터 합산
        List<TreeDetailUser> totalList = DataAggregator.aggregateDataByFormalId(detailList);

        map.put("list", totalList);
        map.put("detailList", detailList);

        return map;
    }

    // 양식정의 조회
    @PostMapping("/selectFormal")
    @ResponseBody
    public HashMap<String, Object> selectFormal(@RequestBody Formal formal) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        List<Formal> list = webService.getFormal(formal);

        map.put("list", list);

        return map;
    }

    // 양식정의 중복값 조회
    @PostMapping("/selectFormalCheck")
    @ResponseBody
    public HashMap<String, Object> selectFormalCheck(@RequestBody Formal formal) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        Formal data = webService.getFormalCheck(formal);

        map.put("data", data);

        return map;
    }

    // 양식정의 등록
    @PostMapping("/saveFormal")
    @ResponseBody
    public HashMap<String, Object> saveFormal(@RequestBody Formal formal) {

        int res;

        if(formal.getId().isEmpty()){
            res = webService.createFormal(formal);
        }else{
            res = webService.updateFormal(formal);
        }

        HashMap<String, Object> map = new HashMap<String, Object>();
        map.put("response", res);
        map.put("formal", formal);

        return map;
    }

    // 양식정의 삭제
    @PostMapping("/deleteFormal")
    @ResponseBody
    public int deleteFormal(@RequestBody Formal formal) {

        int res = 0;

        webService.deleteTableSet(formal.getId());
        webService.deleteTableSetUser(formal.getId());
        webService.deleteTreeGroupDetailFormalId(formal.getId());
        res = webService.deleteFormal(formal);

        return res;
    }

    // 테이블 생성
    @GetMapping("/tableEdit")
    public String tableEditModal() {
        return "tableEdit";
    }

    // 목록 상세조회
    @PostMapping("/selectTreeGroupDetail")
    @ResponseBody
    public HashMap<String, Object> selectTreeGroupDetail(@RequestBody TreeGroupDetail treeGroupDetail) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        List<TreeGroupDetail> list = webService.getTreeGroupDetail(treeGroupDetail);

        map.put("list", list);

        return map;
    }

    // 문장 조회
    @PostMapping("/selectSentence")
    @ResponseBody
    public HashMap<String, Object> selectSentence(@RequestBody Sentence sentence) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        List<Sentence> list = webService.getSentence(sentence);

        map.put("list", list);

        return map;
    }

    // 문장 등록(관리자)
    @PostMapping("/saveSentence")
    @ResponseBody
    public int saveSentence(HttpSession session, @RequestBody List<Sentence> sentence) {

        int res = 0;

        webService.deleteTreeGroupDetailSentence(sentence.get(0).getTreeGroupId());

        for(Sentence data : sentence){
            if(data.getId().isEmpty()){
                res = webService.createSentence(data);
            }else{
                res = webService.updateSentence(data);
            }

            if(!data.getId().isEmpty()){
                TreeGroupDetail tgd = new TreeGroupDetail();
                tgd.setTreeGroupId(data.getTreeGroupId());
                tgd.setSentenceId(data.getId());
                tgd.setIdx(data.getIdx());

                webService.createTreeGroupDetailSentence(tgd);
            }
        }

        return res;
    }

    // 문장 등록(사용자)
    @PostMapping("/saveSentenceUser")
    @ResponseBody
    public int saveSentenceUser(@RequestBody List<SentenceUser> sentenceUser) {

        int res = 0;
        
        try {
            res = webService.createSentenceUser(sentenceUser);
        } catch (DataIntegrityViolationException e) {
            // ORA-02291: 외래 키 제약 조건 위반 (부모 키가 없는 경우)
            Throwable cause = e.getRootCause();
            if (cause != null && cause.getMessage() != null && cause.getMessage().contains("ORA-02291")) {
                res = 0;
            } else {
                throw e;
            }
        }

        return res;
    }

    // 문장 삭제
    @PostMapping("/deleteSentence")
    @ResponseBody
    public int deleteSentence(@RequestBody Sentence sentence) {
        int res = 0;

        webService.deleteSentenceUser(sentence.getId());

        res = webService.deleteSentence(sentence);

        if(res > 0){
            TreeGroupDetail tgd = new TreeGroupDetail();
            tgd.setTreeGroupId(sentence.getTreeGroupId());
            tgd.setIdx(sentence.getIdx());

            webService.deleteTreeGroupDetailRow(tgd);

        }

        return res;
    }

    // 양식정의 ID등록
    @PostMapping("/saveFormalId")
    @ResponseBody
    public int saveFormalId(@RequestBody List<TreeGroupDetail> treeGroupDetail) {

        int res = 0;

        webService.deleteTreeGroupDetailFormal(treeGroupDetail.get(0).getTreeGroupId());

        res = webService.createTreeGroupDetailFormal(treeGroupDetail);

        return res;
    }

    // 표 조회
    @PostMapping("/selectTableSet")
    @ResponseBody
    public HashMap<String, Object> selectTableSet(@RequestBody TableSet tableSet) {

        HashMap<String, Object> map = new HashMap<String, Object>();
        TableSet data = webService.getTableSet(tableSet);

        map.put("data", data);

        return map;
    }

    // 표 등록(관리자)
    @PostMapping("/saveTableSet")
    @ResponseBody
    public int saveTableSet(@RequestBody List<TableSet> tableSet) {

        int res = 0;
        // CLOB 저장시 ORA-03146 오류 방지를 위해 분리
        for(TableSet ts : tableSet){
            if(ts.getId().isEmpty()){
                res = webService.createTableSet(ts);
            }

            if(!ts.getId().isEmpty()){
                res = webService.updateTableSet(ts);
            }
        }

        return res;
    }

    // 표 등록(사용자)
    @PostMapping("/saveTableSetUser")
    @ResponseBody
    public int saveTableSetUser(@RequestBody List<TableSetUser> tableSetUser) {

        int res = 0;

        for(TableSetUser ts : tableSetUser){
            try {
                // CLOB 저장시 ORA-03146 오류 방지를 위해 분리
                if (ts.getId().isEmpty()) {
                    res = webService.createTableSetUser(ts);
                }
                if(!ts.getId().isEmpty()){
                    res = webService.updateTableSetUser(ts);
                }
            } catch (DataIntegrityViolationException e) {
                Throwable cause = e.getRootCause();
                // ORA-02291: 외래 키 제약 조건 위반 (부모 키가 없는 경우)
                if (cause != null && cause.getMessage() != null && cause.getMessage().contains("ORA-02291")) {
                    res = 0;
                } else {
                    throw e;
                }
            }
        }

        return res;
    }

    // 문장/표 삭제
    @PostMapping("/deleteTableRow")
    @ResponseBody
    public int deleteTableRow(@RequestBody TreeGroupDetail treeGroupDetail) {

        int res = webService.deleteTreeGroupDetailRow(treeGroupDetail);

        if(res > 0){
            webService.deleteTableSetUser(treeGroupDetail.getFormalId());
        }

        return res;
    }
}
