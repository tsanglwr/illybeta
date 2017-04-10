package com.illy.usecases;

import java.util.List;
import java.io.File;
import java.io.FileInputStream;
import java.io.Reader;
import java.io.InputStreamReader;
import java.util.Properties;

import com.illy.utils.*;
import org.apache.logging.log4j.Logger;

public class ImportUsersPhotosFromCsvUseCase implements UseCaseBase {

    public static final String INPUT_MEGAMATCHER_SERVER_HOST = "INPUT_MEGAMATCHER_SERVER_HOST";
    public static final String INPUT_MEGAMATCHER_SERVER_PORT = "INPUT_MEGAMATCHER_SERVER_PORT";
    public static final String INPUT_IMAGE_FILE_PATH = "INPUT_IMAGE_FILE_PATH";
    public static final String INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME = "INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME";
    public static final String INVALID_ERROR = "INVALID_ERROR";
    public static final String MATCH_ERROR = "MATCH_ERROR";
    public static final String GENERAL_ERROR = "GENERAL_ERROR";
    final static Logger logger = org.apache.logging.log4j.LogManager.getLogger(CreateFaceTemplateUseCase.class);
    private Properties props = null;

    public ImportUsersPhotosFromCsvUseCase() {
        this.props = new Properties();
    }

    public ImportUsersPhotosFromCsvUseCase(Properties props) {
        this.props = props;
    }

    public Outcome run() {
        logger.info("ImportUsersPhotosFromCsvUseCase.run");
        Helpers.initLibraryPath();

        if (!validateParameters()) {
            return Outcome.createFailedOutcome(CreateFaceTemplateUseCase.INVALID_ERROR, CreateFaceTemplateUseCase.INVALID_ERROR);
        }

        try {
            ImportUsersPhotosFromCsvUseCase.readData();
            Outcome outcome = Outcome.createSuccessOutcome(null);

            if (!outcome.isValid()) {
                logger.error("Outcome not valid");
                for (OutcomeError o : outcome.getOutcomeErrorList()) {
                    logger.error("Error: " + o.toString());
                }
            }
            return outcome;
        } catch (Throwable throwable) {
            return Outcome.createFailedOutcome(CreateFaceTemplateUseCase.MATCH_ERROR, CreateFaceTemplateUseCase.GENERAL_ERROR);
        }
    }

    private boolean validateParameters() {
        return true;
    }

    public static void readData() throws Exception {

        RecordReader r = new RecordReader();

        File file = new File("/Users/sauron/Desktop/users.xml");

        FileInputStream fis = new FileInputStream(file);
        r.readFromXML(fis);
    }
}
