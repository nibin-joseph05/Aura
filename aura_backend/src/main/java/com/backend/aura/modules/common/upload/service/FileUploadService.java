package com.backend.aura.modules.common.upload.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class FileUploadService {

    @Value("${file.upload-dir:uploads}")
    private String uploadDir;

    public String uploadProfileImage(MultipartFile file, String userId) throws IOException {
        Path uploadPath = Paths.get(uploadDir, "profile-images");

        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        String originalFilename = file.getOriginalFilename();
        String extension = "";
        if (originalFilename != null && originalFilename.contains(".")) {
            extension = originalFilename.substring(originalFilename.lastIndexOf("."));
        }

        String filename = userId + "_" + UUID.randomUUID().toString().substring(0, 8) + extension;
        Path filePath = uploadPath.resolve(filename);

        Files.copy(file.getInputStream(), filePath, StandardCopyOption.REPLACE_EXISTING);

        return "/uploads/profile-images/" + filename;
    }

    public void deleteProfileImage(String relativePath) {
        if (relativePath == null || relativePath.isEmpty())
            return;

        try {
            Path filePath = Paths.get(uploadDir, relativePath);
            Files.deleteIfExists(filePath);
        } catch (IOException e) {
        }
    }
}
