package com.illy;

import java.io.IOException;
import java.io.PrintWriter;

import java.util.EnumSet;
import java.lang.reflect.Field;
import com.neurotec.biometrics.NBiometricOperation;
import com.neurotec.biometrics.NBiometricStatus;
import com.neurotec.biometrics.NFace;
import com.neurotec.biometrics.NSubject;
import com.neurotec.biometrics.NTemplateSize;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.biometrics.client.NClusterBiometricConnection;
import com.neurotec.io.NFile;
import com.sun.jna.Platform;
import com.neurotec.lang.NThrowable;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.Closeable;
import java.io.File;
import java.io.FileFilter;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Reader;
import java.io.Writer;
import java.util.List;
import java.util.Map;
import java.util.HashMap;

import com.neurotec.lang.NThrowable;
import com.neurotec.util.concurrent.AggregateExecutionException;

/**
 * Interface to MegaMatcher 9 SDK Matching Server
 */
public final class CreateFaceTemplateUseCase {

    public static final String DEFAULT_ADDRESS = "127.0.0.1";
    public static final int DEFAULT_PORT = 24932;

    public static final String INPUT_IMAGE_FILE_PATH = "INPUT_IMAGE_FILE_PATH";
    public static final String INPUT_TEMPLATE_FILE_PATH = "INPUT_TEMPLATE_FILE_PATH";

    private Map<String, String> params = null;

    public CreateFaceTemplateUseCase() {
        this.params = new HashMap<String, String>();
    }
    public CreateFaceTemplateUseCase(Map<String, String> params) {
        this.params = params;
    }

    public Outcome run() throws Throwable {
        Helpers.initLibraryPath();

        if (!validateParameters()) {
            return new Outcome(false, "Bad params");
        }

        Outcome outcome = CreateFaceTemplateUseCase.createFaceTemplate(Helpers.DEFAULT_HOST, Helpers.DEFAULT_PORT, CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH, CreateFaceTemplateUseCase.INPUT_TEMPLATE_FILE_PATH);

        return outcome;
    }

    private boolean validateParameters() {

        if (null == this.params.get(CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH)) {
            return false;
        }

        if (null == this.params.get(CreateFaceTemplateUseCase.INPUT_TEMPLATE_FILE_PATH)) {
            return false;
        }

        return true;
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

    public static Outcome createFaceTemplate(String serverAddress, Integer serverPort, String imageFile, String templateFile) throws Throwable {
        NBiometricClient biometricClient = new NBiometricClient();
        NSubject subject = new NSubject();
        NFace face = new NFace();

        // perform all biometric operations on remote server only
        biometricClient.setLocalOperations(EnumSet.noneOf(NBiometricOperation.class));
        NClusterBiometricConnection connection = new NClusterBiometricConnection();
        connection.setHost(serverAddress);
        connection.setAdminPort(serverPort);
        biometricClient.getRemoteConnections().add(connection);

        face.setFileName(imageFile);
        subject.getFaces().add(face);
        biometricClient.setFacesTemplateSize(NTemplateSize.LARGE);

        NBiometricStatus status = biometricClient.createTemplate(subject);

        if (status == NBiometricStatus.OK) {
            System.out.println("Template extracted");
            NFile.writeAllBytes(templateFile, subject.getTemplateBuffer());
            return new Outcome(true);
        } else {
            return new Outcome(false, "Error" + status.toString(), -1);
        }
    }

}
