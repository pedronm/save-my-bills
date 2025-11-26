package com.savemybills.graphql;

import com.savemybills.model.ScreenshotData;
import com.savemybills.service.ScreenshotService;
import lombok.RequiredArgsConstructor;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.MutationMapping;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.stereotype.Controller;

import java.util.List;

@Controller
@RequiredArgsConstructor
public class ScreenshotResolver {
    
    private final ScreenshotService screenshotService;
    
    @QueryMapping
    public ScreenshotData screenshot(@Argument String screenshotId) {
        return screenshotService.getScreenshotById(screenshotId);
    }
    
    @QueryMapping
    public List<ScreenshotData> screenshots() {
        return screenshotService.getAllScreenshots();
    }
    
    @QueryMapping
    public List<ScreenshotData> screenshotsByUser(@Argument String userId) {
        return screenshotService.getScreenshotsByUserId(userId);
    }
    
    @QueryMapping
    public List<ScreenshotData> screenshotsByCategory(@Argument String category) {
        return screenshotService.getScreenshotsByCategory(category);
    }
    
    @QueryMapping
    public List<ScreenshotData> screenshotsByUserAndCategory(@Argument String userId, @Argument String category) {
        return screenshotService.getScreenshotsByUserAndCategory(userId, category);
    }
    
    @MutationMapping
    public Boolean deleteScreenshot(@Argument String screenshotId) {
        screenshotService.deleteScreenshot(screenshotId);
        return true;
    }
}
