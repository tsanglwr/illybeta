package com.illy.usecases;

import java.util.List;

public class CreateFaceTemplateMatchQueryRequestUseCaseResult {
    private List<FaceTemplateMatchResult> matchingFaceTemplateUUIDs;
    private String faceTemplateUrl;

    public List<FaceTemplateMatchResult> getMatchingFaceTemplateUUIDs() {
        return this.matchingFaceTemplateUUIDs;
    }

    public void setMatchingFaceTemplateUUIDs(List<FaceTemplateMatchResult> matchingFaceTemplateUUIDs) {
        this.matchingFaceTemplateUUIDs = matchingFaceTemplateUUIDs;
    }

    public String getFaceTemplateUrl() {
        return faceTemplateUrl;
    }

    public void setFaceTemplateUrl(String faceTemplateUrl) {
        this.faceTemplateUrl = faceTemplateUrl;
    }
}