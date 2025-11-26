package com.savemybills.service;

import com.savemybills.model.ScreenshotData;
import com.savemybills.model.ScreenshotReference;
import com.savemybills.repository.ScreenshotDataRepository;
import com.savemybills.repository.ScreenshotReferenceRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class ScreenshotService {
    
    private final GoogleDriveService googleDriveService;
    private final ScreenshotReferenceRepository referenceRepository;
    private final ScreenshotDataRepository dataRepository;
    
    @Transactional
    public ScreenshotData uploadScreenshot(
        MultipartFile file,
        String title,
        String description,
        String userId,
        String category,
        Double amount,
        String currency,
        LocalDateTime billDate,
        String vendor,
        Map<String, String> tags
    ) {
        try {
            // Generate unique screenshot ID
            String screenshotId = UUID.randomUUID().toString();
            String fileName = screenshotId + "_" + file.getOriginalFilename();
            
            // Upload to Google Drive
            String driveFileId = googleDriveService.uploadFile(file, fileName);
            String driveFileUrl = googleDriveService.getFileUrl(driveFileId);
            
            // Save reference in PostgreSQL
            ScreenshotReference reference = ScreenshotReference.builder()
                .screenshotId(screenshotId)
                .title(title)
                .description(description)
                .driveFileId(driveFileId)
                .build();
            
            referenceRepository.save(reference);
            
            // Save full data in MongoDB
            ScreenshotData data = ScreenshotData.builder()
                .screenshotId(screenshotId)
                .filename(file.getOriginalFilename())
                .contentType(file.getContentType())
                .fileSize(file.getSize())
                .driveFileId(driveFileId)
                .driveFileUrl(driveFileUrl)
                .uploadedAt(LocalDateTime.now())
                .lastAccessedAt(LocalDateTime.now())
                .userId(userId)
                .category(category)
                .amount(amount)
                .currency(currency)
                .billDate(billDate)
                .vendor(vendor)
                .tags(tags)
                .build();
            
            return dataRepository.save(data);
            
        } catch (Exception e) {
            log.error("Error uploading screenshot", e);
            throw new RuntimeException("Failed to upload screenshot: " + e.getMessage(), e);
        }
    }
    
    public ScreenshotData getScreenshotById(String screenshotId) {
        return dataRepository.findByScreenshotId(screenshotId)
            .orElseThrow(() -> new RuntimeException("Screenshot not found: " + screenshotId));
    }
    
    public List<ScreenshotData> getScreenshotsByUserId(String userId) {
        return dataRepository.findByUserId(userId);
    }
    
    public List<ScreenshotData> getScreenshotsByCategory(String category) {
        return dataRepository.findByCategory(category);
    }
    
    public List<ScreenshotData> getScreenshotsByUserAndCategory(String userId, String category) {
        return dataRepository.findByUserIdAndCategory(userId, category);
    }
    
    public List<ScreenshotData> getAllScreenshots() {
        return dataRepository.findAll();
    }
    
    @Transactional
    public void deleteScreenshot(String screenshotId) {
        try {
            ScreenshotData data = getScreenshotById(screenshotId);
            
            // Delete from Google Drive
            googleDriveService.deleteFile(data.getDriveFileId());
            
            // Delete from MongoDB
            dataRepository.delete(data);
            
            // Delete from PostgreSQL
            ScreenshotReference reference = referenceRepository.findByScreenshotId(screenshotId)
                .orElseThrow(() -> new RuntimeException("Reference not found"));
            referenceRepository.delete(reference);
            
            log.info("Screenshot deleted: {}", screenshotId);
            
        } catch (Exception e) {
            log.error("Error deleting screenshot", e);
            throw new RuntimeException("Failed to delete screenshot: " + e.getMessage(), e);
        }
    }
}
