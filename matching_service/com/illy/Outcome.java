package com.illy;

/**
 * Stores the outcome of a Use Case run
 */
public class Outcome {

    public Outcome(boolean isValid, String errorMessage, int errorCode) {
        this.isValid = isValid;
        this.errorMessage = errorMessage;
        this.errorCode = errorCode;
    }

    public Outcome(boolean isValid, String errorMessage) {
        this.isValid = isValid;
        this.errorMessage = errorMessage;
    }

    public Outcome(boolean isValid) {
        this.isValid = isValid;
    }

    public boolean isValid = false;
    public int errorCode = 0;
    public String errorMessage = "";
}