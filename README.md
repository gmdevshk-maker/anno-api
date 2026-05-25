# anno-api

회계·주석 문서용 **주석 양식 정의·편집** 백엔드. 트리(목차) 구조로 양식·문장·표를 관리하고 Oracle에 저장한다.

## 기술 스택

| 구분 | 기술 |
|------|------|
| Runtime | Java 17 |
| Framework | Spring Boot 3.5.4 |
| Build | Maven (`packaging: war`) |
| Frontend | jQuery, jsTree |
| DB | Oracle (ojdbc11) |
| ORM | MyBatis 3.0.5 |

## 아키텍처

```
WebController → WebService → MyBatis Mapper → Oracle
```

## 주요 기능

| 영역 | 테이블(예) | 설명 |
|------|------------|------|
| 트리 | `TREE_GROUP` | 목차 CRUD, jsTree 변환 (`ConvertTree`) |
| 양식 | `FORMAL` | 주석 양식 메타 정의 |
| 목차 상세 | `TREE_GROUP_DETAIL` | 트리 ↔ 양식·문장 연결 |
| 문장 | `SENTENCE`, `SENTENCE_USER` | 관리자 / 사용자 입력 |
| 표 | `TABLE_SET`, `TABLE_SET_USER` | 표 정의(CLOB), 관리자 / 사용자 |
| 집계 | `TreeDetail` 등 | formalId별 합산 (`DataAggregator`) |

## API 개요

| 경로 | 용도 |
|------|------|
| `/selectTreeGroup`, `/saveTreeGroup`, `/deleteTreeGroup` | 트리 |
| `/selectFormal`, `/saveFormal`, `/deleteFormal` | 양식 |
| `/selectSentence`, `/saveSentence`, `/saveSentenceUser` | 문장 |
| `/selectTableSet`, `/saveTableSet`, `/saveTableSetUser` | 표 |
| `/selectTreeDetail`, `/selectTreeDetailUser` | 상세·집계 |