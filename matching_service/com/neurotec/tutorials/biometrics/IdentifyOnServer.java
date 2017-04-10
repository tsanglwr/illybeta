package com.neurotec.tutorials.biometrics;

import java.io.IOException;
import java.util.EnumSet;

import com.neurotec.biometrics.NBiometricOperation;
import com.neurotec.biometrics.NBiometricStatus;
import com.neurotec.biometrics.NBiometricTask;
import com.neurotec.biometrics.NMatchingResult;
import com.neurotec.biometrics.NSubject;
import com.neurotec.biometrics.client.NBiometricClient;
import com.neurotec.biometrics.client.NClusterBiometricConnection;
import com.neurotec.io.NFile;
// import com.neurotec.tutorials.util.LibraryManager;
//import com.neurotec.tutorials.util.Utils;
import com.sun.jna.Platform;
import java.lang.reflect.Field;


public final class IdentifyOnServer {
	
	private static final String DESCRIPTION = "Demonstrates how to identify template on server";
	private static final String NAME = "identify-on-server";
	private static final String VERSION = "9.0.0.0";
	
	private static final String DEFAULT_ADDRESS = "127.0.0.1";
	private static final int DEFAULT_PORT = 24932;


  private static final String WIN32_X86 = "Win32_x86";
    private static final String WIN64_X64 = "Win64_x64";
    private static final String LINUX_X86 = "Linux_x86";
    private static final String LINUX_X86_64 = "Linux_x86_64";
    private static final String MAC_OS = "/Library/Frameworks/";

    public static final String FILE_SEPARATOR = System.getProperty("file.separator");
    public static final String PATH_SEPARATOR = System.getProperty("path.separator");
    public static final String LINE_SEPARATOR = System.getProperty("line.separator");


	private static void usage() {
		System.out.format("usage:\n");
		System.out.format("\t%s -s [server:port] -t [template]\n", NAME);
		System.out.format("");
		System.out.format("\t-s server:port   - matching server address (optional parameter, if address specified - port is optional)\n");
		System.out.format("\t-t template      - template to be sent for enrollment (required)\n");
	}

 public static void initLibraryPath() {
        String libraryPath = getLibraryPath();
        String jnaLibraryPath = System.getProperty("jna.library.path");
       // if (Utils.isNullOrEmpty(jnaLibraryPath)) {
         if ("" == jnaLibraryPath || null == jnaLibraryPath) {
            System.setProperty("jna.library.path", libraryPath.toString());
        } else {
            System.setProperty("jna.library.path", String.format("%s%s%s", jnaLibraryPath, IdentifyOnServer.PATH_SEPARATOR, libraryPath.toString()));
        }
        System.setProperty("java.library.path",String.format("%s%s%s", System.getProperty("java.library.path"), IdentifyOnServer.PATH_SEPARATOR, libraryPath.toString()));

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
        int index = IdentifyOnServer.getWorkingDirectory().lastIndexOf(IdentifyOnServer.FILE_SEPARATOR);
        if (index == -1) {
            return null;
        }
        String part = IdentifyOnServer.getWorkingDirectory().substring(0, index);
        if (Platform.isWindows()) {
            if (part.endsWith("Bin")) {
                path.append(part);
                path.append(IdentifyOnServer.FILE_SEPARATOR);
                path.append(Platform.is64Bit() ? WIN64_X64 : WIN32_X86);
            }
        } else if (Platform.isLinux()) {
            index = part.lastIndexOf(IdentifyOnServer.FILE_SEPARATOR);
            if (index == -1) {
                return null;
            }
            part = part.substring(0, index);
            path.append(part);
            path.append(IdentifyOnServer.FILE_SEPARATOR);
            path.append("Lib");
            path.append(IdentifyOnServer.FILE_SEPARATOR);
            path.append(Platform.is64Bit() ? LINUX_X86_64 : LINUX_X86);
        } else if (Platform.isMac()) {
            path.append(MAC_OS);
        }
        return path.toString();
    }


	public static void main(String[] args) {
		IdentifyOnServer.initLibraryPath();

	//	Utils.printTutorialHeader(DESCRIPTION, NAME, VERSION, args);

		if (args.length < 2) {
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

		NBiometricClient biometricClient = null;
		NSubject subject = null;
		NClusterBiometricConnection connection = null;
		NBiometricTask task = null;

		try {
			biometricClient = new NBiometricClient();
			subject = createSubject(parseArgsResult.templateFile, parseArgsResult.templateFile);
			
			connection = new NClusterBiometricConnection();
			connection.setHost(parseArgsResult.serverAddress);
			connection.setAdminPort(parseArgsResult.serverPort);
			
			biometricClient.getRemoteConnections().add(connection);
			
			task = biometricClient.createTask(EnumSet.of(NBiometricOperation.IDENTIFY), subject);
			
			biometricClient.performTask(task);
			
			if (task.getStatus() != NBiometricStatus.OK) {
				System.out.format("Identification was unsuccessful. Status: %s.\n", task.getStatus());
				if (task.getError() != null) throw task.getError();
				System.exit(-1);
			}
			
			for (NMatchingResult matchingResult : subject.getMatchingResults()) {
				System.out.format("Matched with ID: '%s' with score %d", matchingResult.getId(), matchingResult.getScore());
			}
			
		} catch (Throwable th) {
			//Utils.handleError(th);
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
	
	private static ParseArgsResult parseArgs(String[] args) throws Exception {
		ParseArgsResult result = new ParseArgsResult();
		result.serverAddress = DEFAULT_ADDRESS;
		result.serverPort = DEFAULT_PORT;

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
			case 't':
				i++;
				result.templateFile = optarg;
				break;
			default:
				throw new Exception("Wrong parameter found!");
			}
		}

		if (result.templateFile.equals("")) throw new Exception("Template - required parameter - not specified");
		return result;
	}
	
	private static class ParseArgsResult {
		private String serverAddress;
		private int serverPort;
		private String templateFile;
	}

}
