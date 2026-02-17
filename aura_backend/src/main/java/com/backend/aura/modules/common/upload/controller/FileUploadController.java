package com.backend.aura.modules.common.upload.controller;

import com.backend.aura.modules.common.upload.dto.response.UploadErrorResponse;
import com.backend.aura.modules.common.upload.dto.response.UploadResponse;
import com.backend.aura.modules.common.upload.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
public class FileUploadController {

    private static final Logger log = LoggerFactory.getLogger(FileUploadController.class);

    private final FileUploadService fileUploadService;

    @PostMapping("/profile-image")
    public ResponseEntity<?> uploadProfileImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") String userId) {

        log.debug("------------------------------------------------------------");
        log.debug("UPLOAD_CTRL - POST /profile-image | userId: {} | fileName: {} | size: {} bytes | contentType: {}",
                userId, file.getOriginalFilename(), file.getSize(), file.getContentType());

        try {
            if (file.isEmpty()) {
                log.debug("UPLOAD_CTRL - RESPONSE: 400 File is empty");
                log.debug("------------------------------------------------------------");
                return ResponseEntity.badRequest().body(UploadErrorResponse.of("File is empty"));
            }

            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                log.debug("UPLOAD_CTRL - RESPONSE: 400 Not an image | contentType: {}", contentType);
                log.debug("------------------------------------------------------------");
                return ResponseEntity.badRequest().body(UploadErrorResponse.of("Only image files are allowed"));
            }

            long maxSize = 5 * 1024 * 1024;
            if (file.getSize() > maxSize) {
                log.debug("UPLOAD_CTRL - RESPONSE: 400 File too large | size: {} bytes", file.getSize());
                log.debug("------------------------------------------------------------");
                return ResponseEntity.badRequest().body(UploadErrorResponse.of("File size exceeds 5MB limit"));
            }

            String imageUrl = fileUploadService.uploadProfileImage(file, userId);
            log.debug("UPLOAD_CTRL - RESPONSE: 200 OK | imageUrl: {}", imageUrl);
            log.debug("------------------------------------------------------------");
            return ResponseEntity.ok(UploadResponse.of(imageUrl));
        } catch (Exception e) {
            log.debug("UPLOAD_CTRL - RESPONSE: 500 Error | message: {}", e.getMessage(), e);
            log.debug("------------------------------------------------------------");
            return ResponseEntity.internalServerError().body(UploadErrorResponse.of("Failed to upload image"));
        }
    }
}
