package com.illy;

import java.io.*;
import java.util.HashMap;

import java.util.Properties;
import java.io.FileInputStream;
import com.google.gson.Gson;

import com.illy.usecases.*;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.fasterxml.jackson.databind.ObjectMapper;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

import com.illy.utils.Outcome;

/**
 * Main entry point to the MatchingServerAPI
 */
public class MatchingServerApi {

    private static String megaMatcherServerHost = "127.0.0.1";  // Host to access MegaMatcher
    private static Integer megaMatcherServerPort = 24932;       // Port to access MegaMatcher
    private static String bucketName = "illys3md";              // Location to store intermediate files
    final static Logger logger = org.apache.logging.log4j.LogManager.getLogger(MatchingServerApi.class);

    /**
     *  Load the main HTTP server
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {

        logger.debug("Starting MatchingServerApi");
        loadParams();

        ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
        context.setContextPath("/");

        Server jettyServer = new Server(8090);
        ServletHolder jerseyServlet = context.addServlet(FaceTemplateServlet.class, "/face_templates");//Set the servlet to run.
        context.addServlet(FaceTemplateEnrolmentsServlet.class, "/face_template_enrolments");
        context.addServlet(FaceTemplateMatchQueryRequestsServlet.class, "/face_template_match_query_requests");
        context.addServlet(ImportCSVServlet.class, "/import_csv");

        jettyServer.setHandler(context);
        jerseyServlet.setInitOrder(0);

        // Tells the Jersey Servlet which REST service/class to load.
       //
        try {
            jettyServer.start();
            jettyServer.join();
        } finally {
            jettyServer.destroy();
        }
    }

    /**
     *  Setup the properties and configuration
     *
     * @throws FileNotFoundException
     * @throws IOException
     */
    private static void loadParams() throws FileNotFoundException, IOException {

        Properties log4jProps = new Properties();
        log4jProps.load(new FileInputStream("log4j.properties"));

        Properties props = new Properties();
        InputStream is = null;

        // First try loading from the current directory
        try {
            File f = new File("config.properties");
            is = new FileInputStream(f);
        } catch (Exception e) {
            is = null;
            logger.error("Failed to load config.properties");
        }

        try {

            // Try loading properties from the file (if found)
            props.load(is);
        } catch (Exception e) {
        }

        megaMatcherServerHost = props.getProperty("megamatcher_server_host", "192.168.0.1");
        megaMatcherServerPort = new Integer(Integer.valueOf(props.getProperty("megamatcher_server_port", "24932")));
        bucketName = props.getProperty("s3bucketName", "illys3md");
    }

    /**
     * Helper to execute and serialize response
     *
     * @param useCase
     * @param response
     */
    private static void prepareResponse(UseCaseBase useCase, HttpServletResponse response) {
        response.setContentType("application/json");

        ObjectMapper mapper = new ObjectMapper();
        Outcome outcome = null;
        outcome = useCase.run();

        try {
            if (outcome.isValid()) {
                mapper.writeValue(System.out, outcome.result);
                response.getWriter().println(mapper.writeValueAsString(outcome.result));
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                response.getWriter().println(mapper.writeValueAsString(outcome.getOutcomeErrorList()));
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            }
        } catch (IOException exception) {
            logger.error("IOException" + exception.getStackTrace());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @SuppressWarnings("serial")
    public static class FaceTemplateServlet extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            FaceTemplateResource faceTemplateResource = gson.fromJson(reader, FaceTemplateResource.class);

            // Get image template file URL
            Properties props = new Properties();
            props.put(CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH, faceTemplateResource.getImageUrl());
            props.put(CreateFaceTemplateUseCase.INPUT_TEMPLATE_STORAGE_S3_BUCKETNAME, MatchingServerApi.bucketName);
            props.put(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_HOST, MatchingServerApi.megaMatcherServerHost);
            props.put(CreateFaceTemplateUseCase.INPUT_MEGAMATCHER_SERVER_PORT, String.valueOf(MatchingServerApi.megaMatcherServerPort));

            CreateFaceTemplateUseCase useCase = new CreateFaceTemplateUseCase(props);
            MatchingServerApi.prepareResponse(useCase, response);
        }
    }

    @SuppressWarnings("serial")
    public static class FaceTemplateEnrolmentsServlet extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            FaceTemplateEnrolmentResource faceTemplateEnrolmentResource = gson.fromJson(reader, FaceTemplateEnrolmentResource.class);

            // Get image template file URL
            Properties props = new Properties();
            props.put(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_URL, faceTemplateEnrolmentResource.getFaceTemplateUrl());
            props.put(CreateFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID, faceTemplateEnrolmentResource.getFaceTemplateUUID());
            props.put(CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_HOST, MatchingServerApi.megaMatcherServerHost);
            props.put(CreateFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_PORT, String.valueOf(MatchingServerApi.megaMatcherServerPort));

            CreateFaceTemplateEnrolmentUseCase useCase = new CreateFaceTemplateEnrolmentUseCase(props);
            MatchingServerApi.prepareResponse(useCase, response);
        }

        @Override
        protected void doDelete(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            FaceTemplateDeleteEnrolmentResource faceTemplateDeleteEnrolmentResource = gson.fromJson(reader, FaceTemplateDeleteEnrolmentResource.class);

            // Get image template file URL
            Properties props = new Properties();
            props.put(DeleteFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID, faceTemplateDeleteEnrolmentResource.getFaceTemplateUUID());

            props.put(DeleteFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_HOST, MatchingServerApi.megaMatcherServerHost);
            props.put(DeleteFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_PORT, String.valueOf(MatchingServerApi.megaMatcherServerPort));

            DeleteFaceTemplateEnrolmentUseCase useCase = new DeleteFaceTemplateEnrolmentUseCase(props);
            MatchingServerApi.prepareResponse(useCase, response);
        }
    }

    @SuppressWarnings("serial")
    public static class FaceTemplateMatchQueryRequestsServlet extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            FaceTemplateMatchQueryRequestResource faceTemplateMatchQueryRequestResource = gson.fromJson(reader, FaceTemplateMatchQueryRequestResource.class);

            // Get image template file URL
            Properties props = new Properties();
            props.put(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_FACE_TEMPLATE_URL, faceTemplateMatchQueryRequestResource.getFaceTemplateUrl());
            props.put(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_HOST, MatchingServerApi.megaMatcherServerHost);
            props.put(CreateFaceTemplateMatchQueryRequestUseCase.INPUT_MEGAMATCHER_SERVER_PORT, String.valueOf(MatchingServerApi.megaMatcherServerPort));

            CreateFaceTemplateMatchQueryRequestUseCase useCase = new CreateFaceTemplateMatchQueryRequestUseCase(props);
            MatchingServerApi.prepareResponse(useCase, response);
        }
    }

    @SuppressWarnings("serial")
    public static class FaceTemplateDeleteEnrolmentsServlet extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            BufferedReader reader = request.getReader();
            Gson gson = new Gson();
            FaceTemplateDeleteEnrolmentResource faceTemplateDeleteEnrolmentResource = gson.fromJson(reader, FaceTemplateDeleteEnrolmentResource.class);

            // Get image template file URL
            Properties props = new Properties();
            props.put(DeleteFaceTemplateEnrolmentUseCase.INPUT_FACE_TEMPLATE_UUID, faceTemplateDeleteEnrolmentResource.getFaceTemplateUUID());
            props.put(DeleteFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_HOST, MatchingServerApi.megaMatcherServerHost);
            props.put(DeleteFaceTemplateEnrolmentUseCase.INPUT_MEGAMATCHER_SERVER_PORT, String.valueOf(MatchingServerApi.megaMatcherServerPort));

            DeleteFaceTemplateEnrolmentUseCase useCase = new DeleteFaceTemplateEnrolmentUseCase(props);
            MatchingServerApi.prepareResponse(useCase, response);
        }
    }


    @SuppressWarnings("serial")
    public static class ImportCSVServlet extends HttpServlet {

        @Override
        protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
            BufferedReader reader = request.getReader();

            ImportUsersPhotosFromCsvUseCase useCase = new ImportUsersPhotosFromCsvUseCase();
            MatchingServerApi.prepareResponse(useCase, response);
        }
    }
}
