package com.illy;

public class FaceTemplateMatchQueryRequestResource {
    private String requestId;
    private String faceTemplateUrl;

    public String getRequestId() {
        return this.requestId;
    }

    public String getFaceTemplateUrl() {
        return this.faceTemplateUrl;
    }

    @Override
    public String toString() {
        return faceTemplateUrl;
    }
}