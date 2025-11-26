package com.savemybills.repository;

import com.savemybills.model.ScreenshotReference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ScreenshotReferenceRepository extends JpaRepository<ScreenshotReference, Long> {
    
    Optional<ScreenshotReference> findByScreenshotId(String screenshotId);
    
    Optional<ScreenshotReference> findByDriveFileId(String driveFileId);
    
    boolean existsByScreenshotId(String screenshotId);
}
