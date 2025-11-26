package com.savemybills.controller;

import com.savemybills.model.ReceiptData;
import com.savemybills.service.ReceiptService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/receipts")
@RequiredArgsConstructor
@Slf4j
public class ReceiptController {
    
    private final ReceiptService receiptService;
    
    @PostMapping("/upload")
    public ResponseEntity<Map<String, Object>> uploadReceipt(
        @RequestParam("file") MultipartFile file,
        @RequestParam("title") String title,
        @RequestParam(value = "description", required = false) String description,
        @RequestParam(value = "userId", required = false) String userId,
        @RequestParam(value = "category", required = false) String category,
        @RequestParam(value = "amount", required = false) Double amount,
        @RequestParam(value = "currency", required = false, defaultValue = "USD") String currency,
        @RequestParam(value = "billDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime billDate,
        @RequestParam(value = "vendor", required = false) String vendor,
        @RequestParam(value = "tags", required = false) Map<String, String> tags
    ) {
        try {
            log.info("Uploading receipt: {}", file.getOriginalFilename());
            
            ReceiptData data = receiptService.uploadReceipt(
                file, title, description, userId, category, amount, currency, billDate, vendor, tags
            );
            
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("receiptId", data.getReceiptId());
            response.put("driveFileUrl", data.getDriveFileUrl());
            response.put("uploadedAt", data.getUploadedAt());
            
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
            
        } catch (Exception e) {
            log.error("Error uploading receipt", e);
            Map<String, Object> errorResponse = new HashMap<>();
            errorResponse.put("success", false);
            errorResponse.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }
}
