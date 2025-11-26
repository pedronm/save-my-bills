package com.savemybills.repository;

import com.savemybills.model.ScreenshotData;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ScreenshotDataRepository extends MongoRepository<ScreenshotData, String> {
    
    Optional<ScreenshotData> findByScreenshotId(String screenshotId);
    
    List<ScreenshotData> findByUserId(String userId);
    
    List<ScreenshotData> findByCategory(String category);
    
    List<ScreenshotData> findByUploadedAtBetween(LocalDateTime start, LocalDateTime end);
    
    List<ScreenshotData> findByUserIdAndCategory(String userId, String category);
}
