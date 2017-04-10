package com.illy.utils;

import java.util.List;
import java.util.LinkedList;

/**
 * Stores the outcome of a Use Case run
 */
public class Outcome {

    private boolean isValid = false;
    public Object result = null;
    private List<OutcomeError> outcomeErrorList;

    /**
     *  Create an outcome
     *
     * @param isValid Whether the result is good or bad
     * @param result The resulting data returned (set on isValid=true only)
     * @param errorMessage Error message (set on isValid=false only)
     * @param errorCode Error code (set on isValid=false only)
     */
    private Outcome(boolean isValid, Object result, String errorMessage, String errorCode) {
        this.result = result;
        this.isValid = isValid;

        if (errorMessage != null && errorCode != null) {
            this.addOutcomeError(new OutcomeError(errorCode, errorMessage));
        }
    }

    public void addOutcomeError(OutcomeError outcomeError) {

        if (this.outcomeErrorList == null) {
            this.outcomeErrorList = new LinkedList<OutcomeError>();
        }
        this.outcomeErrorList.add(outcomeError);
        this.isValid = false;
    }

    public List<OutcomeError> getOutcomeErrorList() {
        return this.outcomeErrorList;
    }

    public boolean isValid() {
        return this.isValid && (this.outcomeErrorList == null || this.outcomeErrorList.isEmpty());
    }
    /**
     * Create valid outcome
     *
     * @param result Resulting data to be returned with outcome
     * @return Outcome - The valid outcome
     */
    public static Outcome createSuccessOutcome(Object result) {
        return new Outcome(true, result, null, null);
    }
    /**
     * Create invalid/failed outcome
     *
     * @param errorMessage Error message
     * @param errorCode Error code
     * @return Outcome - Failed outcome
     */
    public static Outcome createFailedOutcome(String errorMessage, String errorCode) {
        return new Outcome(false, null, errorMessage, errorCode);
    }

}