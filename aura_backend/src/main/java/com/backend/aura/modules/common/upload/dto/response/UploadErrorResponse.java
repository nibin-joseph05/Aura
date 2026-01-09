package com.backend.aura.modules.common.upload.dto.response;

public class UploadErrorResponse {
    private String error;

    public UploadErrorResponse() {
    }

    public UploadErrorResponse(String error) {
        this.error = error;
    }

    public static UploadErrorResponse of(String error) {
        return new UploadErrorResponse(error);
    }

    public String getError() {
        return error;
    }

    public void setError(String error) {
        this.error = error;
    }
}
