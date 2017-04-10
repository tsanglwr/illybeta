package com.illy.usecases;

import com.amazonaws.services.rekognition.model.Face;

import java.util.List;

public class FaceTemplateMatchResult {
    private String faceTemplateUUID;
    private Integer matchScore;

    public FaceTemplateMatchResult(String faceTemplateUUID, Integer matchScore) {
        this.faceTemplateUUID = faceTemplateUUID;
        this.matchScore = matchScore;
    }

    public String getFaceTemplateUUID() {
        return faceTemplateUUID;
    }

    public void setFaceTemplateUUID(String faceTemplateUUID) {
        this.faceTemplateUUID = faceTemplateUUID;
    }
    public Integer getMatchScore() {
        return this.matchScore;
    }

    public void setMatchScore(Integer matchScore) {
        this.matchScore = matchScore;
    }
}