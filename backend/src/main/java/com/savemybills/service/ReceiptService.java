package com.savemybills.service;

import com.savemybills.model.ReceiptData;
import com.savemybills.model.ReceiptReference;
import com.savemybills.repository.ReceiptDataRepository;
import com.savemybills.repository.ReceiptReferenceRepository;
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
public class ReceiptService {
    
    private final GoogleDriveService googleDriveService;
    private final ReceiptReferenceRepository referenceRepository;
    private final ReceiptDataRepository dataRepository;
    
    @Transactional
    public ReceiptData uploadReceipt(
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
            // Generate unique receipt ID
            String receiptId = UUID.randomUUID().toString();
            String fileName = receiptId + "_" + file.getOriginalFilename();
            
            // Upload to Google Drive
            String driveFileId = googleDriveService.uploadFile(file, fileName);
            String driveFileUrl = googleDriveService.getFileUrl(driveFileId);
            
            // Save reference in PostgreSQL
            ReceiptReference reference = ReceiptReference.builder()
                .receiptId(receiptId)
                .title(title)
                .description(description)
                .driveFileId(driveFileId)
                .build();
            
            referenceRepository.save(reference);
            
            // Save full data in MongoDB
            ReceiptData data = ReceiptData.builder()
                .receiptId(receiptId)
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
            log.error("Error uploading receipt", e);
            throw new RuntimeException("Failed to upload receipt: " + e.getMessage(), e);
        }
    }
    
    public ReceiptData getReceiptById(String receiptId) {
        return dataRepository.findByReceiptId(receiptId)
            .orElseThrow(() -> new RuntimeException("Receipt not found: " + receiptId));
    }
    
    public List<ReceiptData> getReceiptsByUserId(String userId) {
        return dataRepository.findByUserId(userId);
    }
    
    public List<ReceiptData> getReceiptsByCategory(String category) {
        return dataRepository.findByCategory(category);
    }
    
    public List<ReceiptData> getReceiptsByUserAndCategory(String userId, String category) {
        return dataRepository.findByUserIdAndCategory(userId, category);
    }
    
    public List<ReceiptData> getAllReceipts() {
        return dataRepository.findAll();
    }
    
    @Transactional
    public void deleteReceipt(String receiptId) {
        try {
            ReceiptData data = getReceiptById(receiptId);
            
            // Delete from Google Drive
            googleDriveService.deleteFile(data.getDriveFileId());
            
            // Delete from MongoDB
            dataRepository.delete(data);
            
            // Delete from PostgreSQL
            ReceiptReference reference = referenceRepository.findByReceiptId(receiptId)
                .orElseThrow(() -> new RuntimeException("Reference not found"));
            referenceRepository.delete(reference);
            
            log.info("Receipt deleted: {}", receiptId);
            
        } catch (Exception e) {
            log.error("Error deleting receipt", e);
            throw new RuntimeException("Failed to delete receipt: " + e.getMessage(), e);
        }
    }
}
