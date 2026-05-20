package com.example.anno;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.transaction.annotation.EnableTransactionManagement;

@SpringBootApplication
@EnableTransactionManagement
public class AnnoApplication {

    public static void main(String[] args) {
        SpringApplication.run(AnnoApplication.class, args);
    }

}
