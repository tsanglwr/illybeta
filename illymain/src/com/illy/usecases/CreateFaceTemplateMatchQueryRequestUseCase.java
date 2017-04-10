package com.illy.usecases;

import com.illy.utils.FileDownloader;
import com.illy.utils.Helpers;
import com.illy.utils.Outcome;
import com.neurotec.biometrics.NBiometricOperation;
import com.neurotec.biometrics.NBiometricStatus;
import com.neurotec.biometrics.NBiometricTask;
import com.neurotec.biometrics.NSubject;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.biometrics.client.NClusterBiometricConnection;
import com.neurotec.io.NFile;
import com.neurotec.lang.NThrowable;
import com.neurotec.util.concurrent.AggregateExecutionException;
import com.neurotec.biometrics.NMatchingResult;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.net.URL;
import java.util.*;

/**
 * Interface to MegaMatcher 9 SDK Matching Server
 */
public final class CreateFaceTemplateMatchQueryRequestUseCase implements UseCaseBase {

    public static final String INPUT_MEGAMATCHER_SERVER_HOST = "INPUT_MEGAMATCHER_SERVER_HOST";
    public static final String INPUT_MEGAMATCHER_SERVER_PORT = "INPUT_MEGAMATCHER_SERVER_PORT";
    public static final String INPUT_FACE_TEMPLATE_URL = "INPUT_FACE_TEMPLATE_URL";
    public static final String INVALID_props = "INVALID_props";
    public static final String FATAL_ERROR = "FATAL_ERROR";
    public static final String SUBMIT_TASK_ERROR = "SUBMIT_TASK_ERROR";
    public static final String GENERAL_ERROR = "GENERAL_ERROR";
    final static Logger logger = org.apache.logging.log4j.LogManager.getLogger(CreateFaceTemplateMatchQueryRequestUseCase.class);

    private Properties props = null;

    public CreateFaceTemplateMatchQueryRequestUseCase() {
        this.props = new Properties();
    }

    public CreateFaceTemplateMatchQueryRequestUseCase(Properties props) {
        this.props = props;
    }

    public Outcome run() {
        logger.info("CreateFaceTemplateMatchQueryRequestUseCase.run");
        Helpers.initLibraryPath();

        String errorMessage = validateParameters();

        if (errorMessage != null) {
            return Outcome.createFailedOutcome(CreateFaceTemplateMatchQueryRequestUseCase.INVALID_props, errorMessage);
        }

        try {
            Outcome outcome = CreateFaceTemplateMatchQueryRequestUseCase.submitFaceTemplateMatchQueryRequest(
                    this.props.getProperty(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_HOST),
                    Integer.valueOf(this.props.getProperty(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_PORT)),
                    this.props.getProperty(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_FACE_TEMPLATE_URL));
            return outcome;
        }  catch (Throwable throwable) {
            return Outcome.createFailedOutcome(CreateFaceTemplateMatchQueryRequestUseCase.SUBMIT_TASK_ERROR, CreateFaceTemplateMatchQueryRequestUseCase.GENERAL_ERROR);
        }
    }

    private String validateParameters() {

        if (null == this.props.getProperty(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_FACE_TEMPLATE_URL)) {
            return CreateFaceTemplateMatchQueryRequestUseCase.INPUT_FACE_TEMPLATE_URL.toString() + " is required";
        }

        if (null == this.props.getProperty(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_HOST)) {
            return CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_HOST.toString() + " is required";
        }

        if (null == this.props.getProperty(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_PORT)) {
            return CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_PORT.toString() + " is required";
        }

        return null;
    }

    private static int handleNThrowable(NThrowable th) {
        int errorCode = -1;
        if (th instanceof AggregateExecutionException) {
            List<Throwable> causes = ((AggregateExecutionException) th).getCauses();
            for (Throwable cause : causes) {
                if (cause instanceof NThrowable) {
                    if (cause.getCause() instanceof NThrowable) {
                        errorCode = handleNThrowable((NThrowable) cause.getCause());
                    } else {
                        errorCode = ((NThrowable) cause).getCode();
                    }
                    break;
                }
            }
        } else {
            errorCode = ((NThrowable) th).getCode();
        }
        return errorCode;
    }

    public static Outcome submitFaceTemplateMatchQueryRequest(String serverAddress, Integer serverPort, String faceTemplateUrlPath) throws Throwable {

        URL faceTemplateUrl = new URL(faceTemplateUrlPath);
        String localFaceTemplatePath = FileDownloader.downloadFromUrl(faceTemplateUrl);

        NBiometricClient biometricClient = null;
        NSubject subject = null;
        NClusterBiometricConnection connection = null;
        NBiometricTask task = null;

        try {
            biometricClient = new NBiometricClient();
            subject = createSubject(localFaceTemplatePath, localFaceTemplatePath);

            connection = new NClusterBiometricConnection();
            connection.setHost(serverAddress);
            connection.setAdminPort(serverPort);

            biometricClient.getRemoteConnections().add(connection);

            task = biometricClient.createTask(EnumSet.of(NBiometricOperation.IDENTIFY), subject);

            biometricClient.performTask(task);

            if (task.getStatus() != NBiometricStatus.OK) {
                logger.info("Identification was unsuccessful. Status: %s.\n", task.getStatus());
                if (task.getError() != null) throw task.getError();
                return Outcome.createFailedOutcome(CreateFaceTemplateMatchQueryRequestUseCase.SUBMIT_TASK_ERROR, task.getStatus().toString());
            }

            CreateFaceTemplateMatchQueryRequestUseCaseResult result = new CreateFaceTemplateMatchQueryRequestUseCaseResult();
            result.setFaceTemplateUrl(faceTemplateUrlPath);

            LinkedList<FaceTemplateMatchResult> matchingResults = new LinkedList<FaceTemplateMatchResult>();

            for (NMatchingResult matchingResult : subject.getMatchingResults()) {
                matchingResults.add(new FaceTemplateMatchResult(matchingResult.getId(), matchingResult.getScore()));
                logger.info("Matched with ID: '%s' with score %d", matchingResult.getId(), matchingResult.getScore());
            }
            result.setMatchingFaceTemplateUUIDs(matchingResults);
            return Outcome.createSuccessOutcome(result);

        } catch (Throwable th) {
            return Outcome.createFailedOutcome(CreateFaceTemplateMatchQueryRequestUseCase.GENERAL_ERROR, task.getStatus().toString());
        } finally {
            if (task != null) task.dispose();
            if (connection != null) connection.dispose();
            if (subject != null) subject.dispose();
            if (biometricClient != null) biometricClient.dispose();
        }

    }

    private static NSubject createSubject(String fileName, String subjectId) throws IOException {
        NSubject subject = new NSubject();
        subject.setTemplateBuffer(NFile.readAllBytes(fileName));
        subject.setId(subjectId);

        return subject;
    }

}
