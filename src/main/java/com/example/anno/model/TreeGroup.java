package com.example.anno.model;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
public class TreeGroup {
    private String id;
    private String parent;
    private String text;
    private String idx;
    private String accountDate;
    private String folder;
}
