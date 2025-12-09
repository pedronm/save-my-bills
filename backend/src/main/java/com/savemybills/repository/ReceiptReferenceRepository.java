package com.savemybills.repository;

import com.savemybills.model.ReceiptReference;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ReceiptReferenceRepository extends JpaRepository<ReceiptReference, Long> {
    
    Optional<ReceiptReference> findByReceiptId(String receiptId);
    
    Optional<ReceiptReference> findByDriveFileId(String driveFileId);
    
    boolean existsByReceiptId(String receiptId);
}
