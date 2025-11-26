package com.savemybills.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.Map;

@Document(collection = "screenshots")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScreenshotData {
    
    @Id
    private String id;
    
    private String screenshotId;
    
    private String filename;
    
    private String contentType;
    
    private Long fileSize;
    
    private String driveFileId;
    
    private String driveFileUrl;
    
    private Map<String, Object> metadata;
    
    private LocalDateTime uploadedAt;
    
    private LocalDateTime lastAccessedAt;
    
    private String userId;
    
    private String category;
    
    private Double amount;
    
    private String currency;
    
    private LocalDateTime billDate;
    
    private String vendor;
    
    private Map<String, String> tags;
}
