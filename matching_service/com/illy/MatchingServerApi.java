package com.illy;

import java.io.IOException;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.util.Map;
import java.util.HashMap;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.glassfish.jersey.servlet.ServletContainer;
import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

import com.illy.CreateFaceTemplateUseCase;
import com.illy.Outcome;

public class MatchingServerApi {

  public static void main(String[] args) throws Exception {

    ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
    context.setContextPath("/");

    Server jettyServer = new Server(8080);
     ServletHolder jerseyServlet = context.addServlet(FaceTemplateServlet.class, "/face_templates");//Set the servlet to run.
   // ServletHolder jerseyServlet = context.addServlet(org.glassfish.jersey.servlet.ServletContainer.class, "/*");
    jettyServer.setHandler(context);
    jerseyServlet.setInitOrder(0);

    // Tells the Jersey Servlet which REST service/class to load.
    jerseyServlet.setInitParameter(
            "jersey.config.server.provider.classnames",
            EntryPoint.class.getCanonicalName());

    try {
      jettyServer.start();
      jettyServer.join();
    } finally {
      jettyServer.destroy();
    }

  }

  @SuppressWarnings("serial")
  public static class FaceTemplateServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

      // Get image template file URL
      HashMap<String, String> params = new HashMap<String, String>();
      params.put(CreateFaceTemplateUseCase.INPUT_IMAGE_FILE_PATH, "/Users/sauron/NewestDropbox/Dropbox/git/illy/matching_service/photosample2.jpg");
      params.put(CreateFaceTemplateUseCase.INPUT_TEMPLATE_FILE_PATH, "templatefile.template");
      CreateFaceTemplateUseCase useCase = new CreateFaceTemplateUseCase(params);

      try {
        Outcome outcome = useCase.run();
        response.getWriter().println("<h1>Hello POST SimpleServlet</h1>");
      } catch (Throwable throwable) {
        response.getWriter().println("<h1>ERROR EXC</h1>" + throwable + throwable.getStackTrace());
      }

      response.setContentType("text/html");
      response.setStatus(HttpServletResponse.SC_OK);

    }
  }

}