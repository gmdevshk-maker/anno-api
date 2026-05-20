package com.example.anno.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class Formal {
    private String id;
    private String standard;
    private String style;
    private String styleText;
    private String version;
    private String mergeWay;
    private String sumWay;
    private String quarter;
    private String endTerm;
    private String startDt;
    private String endDt;
    private String tableSetId;
    private String updateDt;
}
