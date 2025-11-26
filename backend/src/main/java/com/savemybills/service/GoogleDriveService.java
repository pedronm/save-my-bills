package com.savemybills.service;

import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.InputStreamContent;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.gson.GsonFactory;
import com.google.api.services.drive.Drive;
import com.google.api.services.drive.model.File;
import com.google.auth.http.HttpCredentialsAdapter;
import com.google.auth.oauth2.GoogleCredentials;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.security.GeneralSecurityException;
import java.util.Collections;

@Service
@Slf4j
public class GoogleDriveService {
    
    private static final JsonFactory JSON_FACTORY = GsonFactory.getDefaultInstance();
    private static final String APPLICATION_NAME = "Save My Bills";
    
    @Value("${google.drive.folder.id:root}")
    private String folderId;
    
    @Value("${google.credentials.path:}")
    private String credentialsPath;
    
    private Drive driveService;
    
    public String uploadFile(MultipartFile file, String fileName) throws IOException, GeneralSecurityException {
        Drive service = getDriveService();
        
        File fileMetadata = new File();
        fileMetadata.setName(fileName);
        fileMetadata.setParents(Collections.singletonList(folderId));
        
        InputStreamContent mediaContent = new InputStreamContent(
            file.getContentType(),
            file.getInputStream()
        );
        
        File uploadedFile = service.files().create(fileMetadata, mediaContent)
            .setFields("id, webViewLink, webContentLink")
            .execute();
        
        log.info("File uploaded to Google Drive with ID: {}", uploadedFile.getId());
        
        return uploadedFile.getId();
    }
    
    public String getFileUrl(String fileId) throws IOException, GeneralSecurityException {
        Drive service = getDriveService();
        
        File file = service.files().get(fileId)
            .setFields("webViewLink")
            .execute();
        
        return file.getWebViewLink();
    }
    
    public void deleteFile(String fileId) throws IOException, GeneralSecurityException {
        Drive service = getDriveService();
        service.files().delete(fileId).execute();
        log.info("File deleted from Google Drive: {}", fileId);
    }
    
    private Drive getDriveService() throws IOException, GeneralSecurityException {
        if (driveService != null) {
            return driveService;
        }
        
        GoogleCredentials credentials;
        
        if (credentialsPath != null && !credentialsPath.isEmpty()) {
            try (InputStream in = new java.io.FileInputStream(credentialsPath)) {
                credentials = GoogleCredentials.fromStream(in)
                    .createScoped(Collections.singletonList("https://www.googleapis.com/auth/drive.file"));
            }
        } else {
            log.warn("Google credentials not configured. Using application default credentials.");
            credentials = GoogleCredentials.getApplicationDefault()
                .createScoped(Collections.singletonList("https://www.googleapis.com/auth/drive.file"));
        }
        
        driveService = new Drive.Builder(
            GoogleNetHttpTransport.newTrustedTransport(),
            JSON_FACTORY,
            new HttpCredentialsAdapter(credentials))
            .setApplicationName(APPLICATION_NAME)
            .build();
        
        return driveService;
    }
}
