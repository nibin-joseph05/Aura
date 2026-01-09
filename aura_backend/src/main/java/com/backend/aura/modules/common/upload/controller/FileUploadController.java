package com.backend.aura.modules.common.upload.controller;

import com.backend.aura.modules.common.upload.dto.response.UploadErrorResponse;
import com.backend.aura.modules.common.upload.dto.response.UploadResponse;
import com.backend.aura.modules.common.upload.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/upload")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileUploadService fileUploadService;

    @PostMapping("/profile-image")
    public ResponseEntity<?> uploadProfileImage(
            @RequestParam("file") MultipartFile file,
            @RequestParam("userId") String userId) {
        try {
            if (file.isEmpty()) {
                return ResponseEntity.badRequest().body(UploadErrorResponse.of("File is empty"));
            }

            String contentType = file.getContentType();
            if (contentType == null || !contentType.startsWith("image/")) {
                return ResponseEntity.badRequest().body(UploadErrorResponse.of("Only image files are allowed"));
            }

            long maxSize = 5 * 1024 * 1024;
            if (file.getSize() > maxSize) {
                return ResponseEntity.badRequest().body(UploadErrorResponse.of("File size exceeds 5MB limit"));
            }

            String imageUrl = fileUploadService.uploadProfileImage(file, userId);
            return ResponseEntity.ok(UploadResponse.of(imageUrl));
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body(UploadErrorResponse.of("Failed to upload image"));
        }
    }
}
