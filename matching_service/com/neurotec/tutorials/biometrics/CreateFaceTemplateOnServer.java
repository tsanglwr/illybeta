package com.neurotec.tutorials.biometrics;

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
//import com.neurotec.tutorials.util.LibraryManager;
//import com.neurotec.tutorials.util.Utils;
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

import com.neurotec.lang.NThrowable;
import com.neurotec.util.concurrent.AggregateExecutionException;

public final class CreateFaceTemplateOnServer {
	private static final String DESCRIPTION = "Demonstrates how to create face template from image on server";
	private static final String NAME = "create-face-template-on-server";
	private static final String VERSION = "9.0.0.0";

    private static final String WIN32_X86 = "Win32_x86";
    private static final String WIN64_X64 = "Win64_x64";
    private static final String LINUX_X86 = "Linux_x86";
    private static final String LINUX_X86_64 = "Linux_x86_64";
    private static final String MAC_OS = "/Library/Frameworks/";

    public static final String FILE_SEPARATOR = System.getProperty("file.separator");
    public static final String PATH_SEPARATOR = System.getProperty("path.separator");
    public static final String LINE_SEPARATOR = System.getProperty("line.separator");

	private static final String DEFAULT_ADDRESS = "127.0.0.1";
	private static final int DEFAULT_PORT = 24932;

	private static void usage() {
		System.out.println("usage:");
		System.out.format("\t%s -s [server:port] -i [input image] -t [output template]%n", NAME);
		System.out.println();
		System.out.println("\t-s [server:port]   - matching server address (optional parameter, if address specified - port is optional)");
		System.out.println("\t-i [image]   - image filename to store finger image.");
		System.out.println("\t-t [output template]   - filename to store finger template.");
		System.out.println();
		System.out.println();
		System.out.println("example:");
		System.out.format("\t%s -s 127.0.0.1 -i image.jpg -t template.dat%n", NAME);
	}
   // ===========================================================
    // Public static methods
    // ===========================================================

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


    public static void initLibraryPath() {
        String libraryPath = getLibraryPath();
        String jnaLibraryPath = System.getProperty("jna.library.path");
       // if (Utils.isNullOrEmpty(jnaLibraryPath)) {
         if ("" == jnaLibraryPath || null == jnaLibraryPath) {
            System.setProperty("jna.library.path", libraryPath.toString());
        } else {
            System.setProperty("jna.library.path", String.format("%s%s%s", jnaLibraryPath, CreateFaceTemplateOnServer.PATH_SEPARATOR, libraryPath.toString()));
        }
        System.setProperty("java.library.path",String.format("%s%s%s", System.getProperty("java.library.path"), CreateFaceTemplateOnServer.PATH_SEPARATOR, libraryPath.toString()));

        try {
            Field fieldSysPath = ClassLoader.class.getDeclaredField("sys_paths");
            fieldSysPath.setAccessible(true);
            fieldSysPath.set(null, null);
        } catch (SecurityException e) {
            e.printStackTrace();
        } catch (NoSuchFieldException e) {
        } catch (IllegalArgumentException e) {
        } catch (IllegalAccessException e) {
        }
    }


    /**
     * Gets user working directory.
     */
    public static String getWorkingDirectory() {
        return System.getProperty("user.dir");
    }

    /**
     * Gets user home directory.
     */
    public static String getHomeDirectory() {
        return System.getProperty("user.home");
    }

    public static String getLibraryPath() {
        StringBuilder path = new StringBuilder();
        int index = CreateFaceTemplateOnServer.getWorkingDirectory().lastIndexOf(CreateFaceTemplateOnServer.FILE_SEPARATOR);
        if (index == -1) {
            return null;
        }
        String part = CreateFaceTemplateOnServer.getWorkingDirectory().substring(0, index);
        if (Platform.isWindows()) {
            if (part.endsWith("Bin")) {
                path.append(part);
                path.append(CreateFaceTemplateOnServer.FILE_SEPARATOR);
                path.append(Platform.is64Bit() ? WIN64_X64 : WIN32_X86);
            }
        } else if (Platform.isLinux()) {
            index = part.lastIndexOf(CreateFaceTemplateOnServer.FILE_SEPARATOR);
            if (index == -1) {
                return null;
            }
            part = part.substring(0, index);
            path.append(part);
            path.append(CreateFaceTemplateOnServer.FILE_SEPARATOR);
            path.append("Lib");
            path.append(CreateFaceTemplateOnServer.FILE_SEPARATOR);
            path.append(Platform.is64Bit() ? LINUX_X86_64 : LINUX_X86);
        } else if (Platform.isMac()) {
            path.append(MAC_OS);
        }
        return path.toString();
    }

	public static void main(String[] args) {
		CreateFaceTemplateOnServer.initLibraryPath();

		//Utils.printTutorialHeader(DESCRIPTION, NAME, VERSION, args);

		if (args.length < 3) {
			usage();
			System.exit(1);
		}

		ParseArgsResult parseArgsResult = null;

		try {
			parseArgsResult = parseArgs(args);
		} catch (Exception e) {
			usage();
			System.exit(-1);
		}

		try {
			NBiometricClient biometricClient = new NBiometricClient();
			NSubject subject = new NSubject();
			NFace face = new NFace();

			// perform all biometric operations on remote server only
			biometricClient.setLocalOperations(EnumSet.noneOf(NBiometricOperation.class));
			NClusterBiometricConnection connection = new NClusterBiometricConnection();
			connection.setHost(parseArgsResult.serverAddress);
			connection.setAdminPort(parseArgsResult.serverPort);
			biometricClient.getRemoteConnections().add(connection);

			face.setFileName(parseArgsResult.imageFile);
			subject.getFaces().add(face);
			biometricClient.setFacesTemplateSize(NTemplateSize.LARGE);

			NBiometricStatus status = biometricClient.createTemplate(subject);

			if (status == NBiometricStatus.OK) {
				System.out.println("Template extracted");
				NFile.writeAllBytes(parseArgsResult.templateFile, subject.getTemplateBuffer());
				System.out.println("Template saved successfully");
			} else {
				System.out.format("Extraction failed: %s\n", status);
			}

		} catch (Throwable th) {

		    System.out.println("failed");
			//Utils.handleError(th);

			if (th == null)
            			throw new NullPointerException("th");
            		int errorCode = -1;
            		if (th instanceof NThrowable) {
            			errorCode = handleNThrowable((NThrowable) th);
            		} else if (th.getCause() instanceof NThrowable) {
            			errorCode = handleNThrowable((NThrowable) th.getCause());
            		}
            		th.printStackTrace();
            		System.exit(errorCode);

		}
	}

	private static ParseArgsResult parseArgs(String[] args) throws Exception {
		ParseArgsResult result = new ParseArgsResult();
		result.serverAddress = DEFAULT_ADDRESS;
		result.serverPort = DEFAULT_PORT;

		result.imageFile = "";
		result.templateFile = "";

		for (int i = 0; i < args.length; i++) {
			String optarg = "";

			if (args[i].length() != 2 || args[i].charAt(0) != '-') {
				throw new Exception("Parameter parse error");
			}

			if (args.length > i + 1 && args[i + 1].charAt(0) != '-') {
				optarg = args[i + 1]; // we have a parameter for given flag
			}

			if (optarg == "") {
				throw new Exception("Parameter parse error");
			}

			switch (args[i].charAt(1)) {
			case 's':
				i++;
				if (optarg.contains(":")) {
					String[] splitAddress = optarg.split(":");
					result.serverAddress = splitAddress[0];
					result.serverPort = Integer.parseInt(splitAddress[1]);
				} else {
					result.serverAddress = optarg;
					result.serverPort = DEFAULT_PORT;
				}
				break;
			case 'i':
				i++;
				result.imageFile = optarg;
				break;
			case 't':
				i++;
				result.templateFile = optarg;
				break;
			default:
				throw new Exception("Wrong parameter found!");
			}
		}
		if (result.imageFile.equals("")) throw new Exception("Image - required parameter - not specified");
		if (result.templateFile.equals("")) throw new Exception("Template - required parameter - not specified");
		return result;
	}

	private static class ParseArgsResult {
		private String serverAddress;
		private int serverPort;
		private String imageFile;
		private String templateFile;
	}
}