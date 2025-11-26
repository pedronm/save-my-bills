package com.savemybills.graphql;

import com.savemybills.model.ReceiptData;
import com.savemybills.service.ReceiptService;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ReceiptResolver {
    
    private final ReceiptService receiptService;
    
    @QueryMapping
    public ReceiptData receipt(@Argument String receiptId) {
        return receiptService.getReceiptById(receiptId);
    }
    
    @QueryMapping
    public List<ReceiptData> receipts() {
        return receiptService.getAllReceipts();
    }
    
    @QueryMapping
    public List<ReceiptData> receiptsByUser(@Argument String userId) {
        return receiptService.getReceiptsByUserId(userId);
    }
    
    @QueryMapping
    public List<ReceiptData> receiptsByCategory(@Argument String category) {
        return receiptService.getReceiptsByCategory(category);
    }
    
    @QueryMapping
    public List<ReceiptData> receiptsByUserAndCategory(@Argument String userId, @Argument String category) {
        return receiptService.getReceiptsByUserAndCategory(userId, category);
    }
    
    @MutationMapping
    public Boolean deleteReceipt(@Argument String receiptId) {
        receiptService.deleteReceipt(receiptId);
        return true;
    }
}
