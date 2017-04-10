package com.illy;

public class FaceTemplateResource {
    private String imageUrl;
    private String faceTemplateUrl;

    public String getImageUrl() {
        return this.imageUrl;
    }

    @Override
    public String toString() {
        return imageUrl + "-" + faceTemplateUrl;
    }
}