package com.illy.usecases;

import com.illy.utils.FileDownloader;
import com.illy.utils.Helpers;
import com.illy.utils.Outcome;
import com.illy.utils.S3Helper;
import com.neurotec.biometrics.*;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.biometrics.client.NClusterBiometricConnection;
import com.neurotec.io.NFile;
import com.neurotec.lang.NThrowable;
import com.neurotec.util.concurrent.AggregateExecutionException;

import java.io.File;
import java.math.BigInteger;
import java.net.URL;
import java.security.SecureRandom;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.io.IOException;
import java.util.Properties;
import java.util.EnumSet;
import java.lang.reflect.Field;
import com.neurotec.biometrics.NBiometricOperation;
import com.neurotec.biometrics.NBiometricStatus;
import com.neurotec.biometrics.NBiometricTask;
import com.neurotec.biometrics.NSubject;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.biometrics.client.NClusterBiometricConnection;
import com.neurotec.io.NFile;
import com.sun.jna.Platform;
import org.apache.logging.log4j.Logger;

/**
 * Interface to MegaMatcher 9 SDK Matching Server
 */
public final class CreateFaceTemplateEnrolmentUseCase implements UseCaseBase {

    public static final String INPUT_MEGAMATCHER_SERVER_HOST = "INPUT_MEGAMATCHER_SERVER_HOST";
    public static final String INPUT_MEGAMATCHER_SERVER_PORT = "INPUT_MEGAMATCHER_SERVER_PORT";
    public static final String INPUT_FACE_TEMPLATE_URL = "INPUT_FACE_TEMPLATE_URL";
    public static final String INPUT_FACE_TEMPLATE_UUID = "INPUT_FACE_TEMPLATE_UUID";
    public static final String INVALID_PARAMS = "INVALID_PARAMS";
    public static final String FATAL_ERROR = "FATAL_ERROR";
    public static final String ENROL_ERROR = "ENROL_ERROR";
    public static final String GENERAL_ERROR = "GENERAL_ERROR";
    final static Logger logger = org.apache.logging.log4j.LogManager.getLogger(CreateFaceTemplateEnrolmentUseCase.class);
    private Properties props = null;

    public CreateFaceTemplateEnrolmentUseCase() {
        this.props = new Properties();
    }

    public CreateFaceTemplateEnrolmentUseCase(Properties props) {
        this.props = props;
    }

    public Outcome run() {
        logger.info("CreateFaceTemplateEnrolmentUseCase.run");
        Helpers.initLibraryPath();

        String errorMessage = validateParameters();

        if (errorMessage != null) {
            return Outcome.createFailedOutcome(CreateFaceTemplateEnrolmentUseCase.INVALID_PARAMS, errorMessage);
        }

        try {
            Outcome outcome = CreateFaceTemplateEnrolmentUseCase.enrolFaceTemplate(
                    this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_HOST),
                    Integer.valueOf(this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_PORT)),
                    this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_URL),
                    this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID));
            return outcome;
        }  catch (Throwable throwable) {
            return Outcome.createFailedOutcome(CreateFaceTemplateEnrolmentUseCase.ENROL_ERROR, CreateFaceTemplateEnrolmentUseCase.GENERAL_ERROR);
        }
    }

    private String validateParameters() {

        if (null == this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_URL)) {
            return CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_URL.toString() + " is required";
        }

        if (null == this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID)) {
            return CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID.toString() + " is required";
        }

        //handle the case where string is not valid UUID
        try{
            UUID uuid = UUID.fromString(this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID));
        } catch (IllegalArgumentException exception){
            return CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID.toString() + " is invalid";
        }

        if (null == this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_HOST)) {
            return CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_HOST.toString() + " is required";
        }

        if (null == this.props.getProperty(CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_PORT)) {
            return CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_PORT.toString() + " is required";
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

    public static Outcome enrolFaceTemplate(String serverAddress, Integer serverPort, String faceTemplateUrlPath, String faceTemplateUUID) throws Throwable {

        URL faceTemplateUrl = new URL(faceTemplateUrlPath);
        String localFaceTemplatePath = FileDownloader.downloadFromUrl(faceTemplateUrl);

        NBiometricClient biometricClient = null;
        NSubject subject = null;
        NClusterBiometricConnection connection = null;
        NBiometricTask task = null;

        try {
            biometricClient = new NBiometricClient();
            subject = createSubject(localFaceTemplatePath, faceTemplateUUID);

            connection = new NClusterBiometricConnection();
            connection.setHost(serverAddress);
            connection.setAdminPort(serverPort);

            biometricClient.getRemoteConnections().add(connection);

            task = biometricClient.createTask(EnumSet.of(NBiometricOperation.ENROLL), subject);

            biometricClient.performTask(task);

            if (task.getStatus() != NBiometricStatus.OK) {
                if (task.getError() != null) throw task.getError();
                return Outcome.createFailedOutcome(CreateFaceTemplateEnrolmentUseCase.ENROL_ERROR, task.getStatus().toString());
            }
            CreateFaceTemplateEnrolmentUseCaseResult result = new CreateFaceTemplateEnrolmentUseCaseResult();
            result.setFaceTemplateUrl(faceTemplateUrlPath);
            result.setFaceTemplateUUID(faceTemplateUUID);
            return Outcome.createSuccessOutcome(result);
        } catch (Throwable th) {
            logger.error(th.getStackTrace());
        } finally {
            if (task != null) task.dispose();
            if (connection != null) connection.dispose();
            if (subject != null) subject.dispose();
            if (biometricClient != null) biometricClient.dispose();
        }

        return Outcome.createFailedOutcome(CreateFaceTemplateEnrolmentUseCase.GENERAL_ERROR, CreateFaceTemplateEnrolmentUseCase.GENERAL_ERROR);
    }

    private static NSubject createSubject(String fileName, String subjectId) throws IOException {
        NSubject subject = new NSubject();
        subject.setTemplateBuffer(NFile.readAllBytes(fileName));
        subject.setId(subjectId);

        return subject;
    }


}
