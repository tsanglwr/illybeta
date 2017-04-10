package com.illy.usecases;

public class CreateFaceTemplateUseCaseResult {
    private String imageUrl;
    private String faceTemplateUrl;

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getFaceTemplateUrl() {
        return faceTemplateUrl;
    }

    public void setFaceTemplateUrl(String faceTemplateUrl) {
        this.faceTemplateUrl = faceTemplateUrl;
    }

    public String toString() {
        String s = "CreateFaceTemplateUseCaseResult [ " + this.imageUrl + ", " + this.faceTemplateUrl + " ]";
        return s;
    }
}