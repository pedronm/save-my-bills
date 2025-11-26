package com.savemybills.repository;

import com.savemybills.model.ReceiptData;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public interface ReceiptDataRepository extends MongoRepository<ReceiptData, String> {
    
    Optional<ReceiptData> findByReceiptId(String receiptId);
    
    List<ReceiptData> findByUserId(String userId);
    
    List<ReceiptData> findByCategory(String category);
    
    List<ReceiptData> findByUploadedAtBetween(LocalDateTime start, LocalDateTime end);
    
    List<ReceiptData> findByUserIdAndCategory(String userId, String category);
}
