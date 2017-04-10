package com.illy.usecases;

public class CreateFaceTemplateEnrolmentUseCaseResult {
    private String faceTemplateUUID;
    private String faceTemplateUrl;

    public String getFaceTemplateUUID() {
        return faceTemplateUUID;
    }

    public void setFaceTemplateUUID(String faceTemplateUUID) {
        this.faceTemplateUUID = faceTemplateUUID;
    }
    public String getFaceTemplateUrl() {
        return faceTemplateUrl;
    }

    public void setFaceTemplateUrl(String faceTemplateUrl) {
        this.faceTemplateUrl = faceTemplateUrl;
    }
}