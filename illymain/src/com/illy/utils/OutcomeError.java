package com.illy.utils;

public class OutcomeError {
    private String errorMessage;
    private String errorCode;

    public OutcomeError(String errorCode, String errorMessage) {
        this.errorCode = errorCode;
        this.errorMessage = errorMessage;
    }

    public String getErrorMessage() {
        return errorMessage;
    }

    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }

    public String toString() {
        return "OutcomeError[" + this.errorMessage + " - " + this.errorCode + "]";
    }
}