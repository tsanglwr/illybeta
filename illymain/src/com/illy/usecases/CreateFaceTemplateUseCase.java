package com.illy.usecases;

import java.util.EnumSet;
import java.math.BigInteger;
import java.util.UUID;
import java.security.SecureRandom;

import com.illy.utils.FileDownloader;
import com.illy.utils.Helpers;
import com.illy.utils.Outcome;
import com.illy.utils.OutcomeError;

import com.illy.utils.S3Helper;
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

import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

import java.net.*;
import java.io.*;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
import java.util.Properties;

import com.neurotec.lang.NThrowable;
import com.neurotec.util.concurrent.AggregateExecutionException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.UUID;

import com.amazonaws.AmazonClientException;
import com.amazonaws.AmazonServiceException;
import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.profile.ProfileCredentialsProvider;
import com.amazonaws.regions.Region;
import com.amazonaws.regions.Regions;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.Bucket;
import com.amazonaws.services.s3.model.GetObjectRequest;
import com.amazonaws.services.s3.model.ListObjectsRequest;
import com.amazonaws.services.s3.model.ObjectListing;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectSummary;
import org.apache.logging.log4j.Logger;
import javax.servlet.http.HttpServletResponse;

/**
 * Interface to MegaMatcher 9 SDK Matching Server
 */
public final class CreateFaceTemplateUseCase implements UseCaseBase {

    public static final String INPUT_MEGAMATCHER_SERVER_HOST = "INPUT_MEGAMATCHER_SERVER_HOST";
    public static final String INPUT_MEGAMATCHER_SERVER_PORT = "INPUT_MEGAMATCHER_SERVER_PORT";
    public static final String INPUT_IMAGE_FILE_PATH = "INPUT_IMAGE_FILE_PATH";
    public static final String INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME = "INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME";
    public static final String INVALID_ERROR = "INVALID_ERROR";
    public static final String MATCH_ERROR = "MATCH_ERROR";
    public static final String GENERAL_ERROR = "GENERAL_ERROR";
    public static final String INVALID_PARAMS = "INVALID_PARAMS";
    final static Logger logger = org.apache.logging.log4j.LogManager.getLogger(CreateFaceTemplateUseCase.class);
    private Properties props = null;

    public CreateFaceTemplateUseCase() {
        this.props = new Properties();
    }

    public CreateFaceTemplateUseCase(Properties props) {
        this.props = props;
    }

    public Outcome run() {
        logger.info("CreateFaceTemplateUseCase.run");
        Helpers.initLibraryPath();

        if (!validateParameters()) {
            return Outcome.createFailedOutcome(CreateFaceTemplateUseCase.INVALID_PARAMS, CreateFaceTemplateUseCase.INVALID_ERROR);
        }

        try {
            Outcome outcome = CreateFaceTemplateUseCase.createFaceTemplate(
                    this.props.getProperty(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_HOST),
                    Integer.valueOf(this.props.getProperty(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_PORT)),
                    this.props.getProperty(CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH),
                    this.props.getProperty(CreateFaceTemplateUseCase.INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME));

            if (!outcome.isValid()) {
                logger.error("Outcome not valid");
                for (OutcomeError o: outcome.getOutcomeErrorList()) {
                    logger.error("Error: " + o.toString());
                }
            }
            return outcome;
        }  catch (Throwable throwable) {
            return Outcome.createFailedOutcome(CreateFaceTemplateUseCase.MATCH_ERROR, CreateFaceTemplateUseCase.GENERAL_ERROR);
        }
    }

    private boolean validateParameters() {

        if (null == this.props.getProperty(CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH)) {
            return false;
        }

        if (null == this.props.getProperty(CreateFaceTemplateUseCase.INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME)) {
            return false;
        }

        if (null == this.props.getProperty(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_HOST)) {
            return false;
        }

        if (null ==   this.props.getProperty(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_PORT)) {
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

    public static Outcome createFaceTemplate(String serverAddress, Integer serverPort, String imageFile, String bucketName) throws Throwable {

        URL imageFileUrl = new URL(imageFile);
        String localImagePath = FileDownloader.downloadFromUrl(imageFileUrl);

        NBiometricClient biometricClient = new NBiometricClient();
        NSubject subject = new NSubject();
        NFace face = new NFace();

        // perform all biometric operations on remote server only
        biometricClient.setLocalOperations(EnumSet.noneOf(NBiometricOperation.class));
        NClusterBiometricConnection connection = new NClusterBiometricConnection();
        connection.setHost(serverAddress);
        connection.setAdminPort(serverPort);
        biometricClient.getRemoteConnections().add(connection);

        face.setFileName(localImagePath);
        subject.getFaces().add(face);
        biometricClient.setFacesTemplateSize(NTemplateSize.LARGE);

        NBiometricStatus status = biometricClient.createTemplate(subject);

        if (status == NBiometricStatus.OK) {
            String uniqueId = new BigInteger(130, new SecureRandom()).toString(32);
            File templateFile = File.createTempFile(uniqueId, ".template");

            NFile.writeAllBytes(templateFile.getPath(), subject.getTemplateBuffer());
            S3Helper s3Helper = new S3Helper();

            File originalImageFile = new File(localImagePath);

            String uploadImageUrl = s3Helper.uploadFile(originalImageFile, bucketName, uniqueId + ".image");
            String fileUrl = s3Helper.uploadFile(templateFile, bucketName, uniqueId + ".template");

            CreateFaceTemplateUseCaseResult result = new CreateFaceTemplateUseCaseResult();
            result.setFaceTemplateUrl(fileUrl);
            result.setImageUrl(uploadImageUrl);
            System.out.println(result.toString());
            return Outcome.createSuccessOutcome(result);
        } else {
            return Outcome.createFailedOutcome(CreateFaceTemplateUseCase.MATCH_ERROR, status.toString());
        }
    }

}
