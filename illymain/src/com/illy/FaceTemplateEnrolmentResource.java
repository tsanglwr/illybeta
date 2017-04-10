package com.illy;

public class FaceTemplateEnrolmentResource {
    private String faceTemplateUUID;
    private String faceTemplateUrl;

    public String getFaceTemplateUUID() {
        return this.faceTemplateUUID;
    }

    public String getFaceTemplateUrl() {
        return this.faceTemplateUrl;
    }

    @Override
    public String toString() {
        return faceTemplateUrl;
    }
}