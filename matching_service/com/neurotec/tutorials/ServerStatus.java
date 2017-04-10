package com.neurotec.tutorials;


import com.neurotec.cluster.Admin;
import com.neurotec.cluster.ClusterNodeInfo;
import com.neurotec.cluster.ClusterNodeState;
import com.neurotec.cluster.ClusterTaskInfo;
//import com.neurotec.tutorials.util.LibraryManager;
import java.lang.reflect.Field;
import com.sun.jna.Platform;






public final class ServerStatus {


    // ===========================================================
    // Private static fields
    // ===========================================================

    private static final String WIN32_X86 = "Win32_x86";
    private static final String WIN64_X64 = "Win64_x64";
    private static final String LINUX_X86 = "Linux_x86";
    private static final String LINUX_X86_64 = "Linux_x86_64";
    private static final String MAC_OS = "/Library/Frameworks/";

	private static final String DESCRIPTION = "Displays various information about a matching server and nodes.";
	private static final String NAME = "server-status";
	private static final String VERSION = "9.0.0.0";


	private static final int DEFAULT_PORT = 24932;

    public static final String FILE_SEPARATOR = System.getProperty("file.separator");
    public static final String PATH_SEPARATOR = System.getProperty("path.separator");
    public static final String LINE_SEPARATOR = System.getProperty("line.separator");




    // ===========================================================
    // Public static methods
    // ===========================================================

    public static void initLibraryPath() {
        String libraryPath = getLibraryPath();
        String jnaLibraryPath = System.getProperty("jna.library.path");
       // if (Utils.isNullOrEmpty(jnaLibraryPath)) {
         if ("" == jnaLibraryPath || null == jnaLibraryPath) {
            System.setProperty("jna.library.path", libraryPath.toString());
        } else {
            System.setProperty("jna.library.path", String.format("%s%s%s", jnaLibraryPath, ServerStatus.PATH_SEPARATOR, libraryPath.toString()));
        }
        System.setProperty("java.library.path",String.format("%s%s%s", System.getProperty("java.library.path"), ServerStatus.PATH_SEPARATOR, libraryPath.toString()));

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
        int index = ServerStatus.getWorkingDirectory().lastIndexOf(ServerStatus.FILE_SEPARATOR);
        if (index == -1) {
            return null;
        }
        String part = ServerStatus.getWorkingDirectory().substring(0, index);
        if (Platform.isWindows()) {
            if (part.endsWith("Bin")) {
                path.append(part);
                path.append(ServerStatus.FILE_SEPARATOR);
                path.append(Platform.is64Bit() ? WIN64_X64 : WIN32_X86);
            }
        } else if (Platform.isLinux()) {
            index = part.lastIndexOf(ServerStatus.FILE_SEPARATOR);
            if (index == -1) {
                return null;
            }
            part = part.substring(0, index);
            path.append(part);
            path.append(ServerStatus.FILE_SEPARATOR);
            path.append("Lib");
            path.append(ServerStatus.FILE_SEPARATOR);
            path.append(Platform.is64Bit() ? LINUX_X86_64 : LINUX_X86);
        } else if (Platform.isMac()) {
            path.append(MAC_OS);
        }
        return path.toString();
    }

    public static void main(String[] args) throws Throwable {
        ServerStatus.initLibraryPath();
      //  Utils.printTutorialHeader(DESCRIPTION, NAME, VERSION, args);

        if (args.length < 1) {
            System.out.println("Please specify argument to server (ex: localhost:<port>)");
            System.exit(-1);
        }

        String server = null;
        int port = 0;

        try {
            if (args[0].contains(":")) {
                String[] splitAddress = args[0].split(":");
                server = splitAddress[0];
                port = Integer.parseInt(splitAddress[1]);
            } else {
                server = args[0];
                port = DEFAULT_PORT;
                System.out.println("port not specified; using default: " + DEFAULT_PORT);
                System.out.println();
            }
        } catch (Exception e) {
            System.err.println("Server address in wrong format.");
            System.exit(-1);
        }

        ServerStatus serverStatus = new ServerStatus(server, port);
        serverStatus.printServerStatus();
    }

    private final String server;
    private final int port;





    public ServerStatus(String server, int port) {
        this.server = server;
        this.port = port;
    }


    private void printServerStatus() throws Throwable {
        Admin admin = null;

        try {
            System.out.format("Asking info from %s: %d ...%n%n", server, port);
            System.out.println("Requesting info about server ...");

            admin = new Admin(server, port);
            com.neurotec.cluster.ServerStatus status = admin.getServerStatus();
            if (status != null) {
                System.out.println("Server status: " + status);
            } else {
                System.out.println("Unable to determine server status");
            }

            System.out.println();
            System.out.println("Requesting info about nodes ...");
            ClusterNodeState[] states = admin.getClusterNodeInfo();
            if (states != null) {
                System.out.format("%d node(s) running:%n", states.length);
                for (ClusterNodeState item : states) {
                    System.out.format("%d (%s)%n", item.getID(), item.getState());
                }
            } else {
                System.out.println("Failed to recieve info about nodes");
            }

            System.out.println();
            System.out.println("Requesting info about tasks ...");
            ClusterTaskInfo[] tasks = admin.getClusterTaskInfo();
            if (tasks != null) {
                System.out.format("%d task(s):%n", tasks.length);
                for (ClusterTaskInfo taskInfo : tasks) {
                    System.out.println("\tid: " + taskInfo.getTaskId());
                    System.out.println("\tprogress: " + taskInfo.getTaskProgress());
                    System.out.println("\tnodes completed: " + taskInfo.getNodesCompleted());
                    System.out.println("\tworking nodes: " + taskInfo.getWorkingNodesCount());
                    for (ClusterNodeInfo info : taskInfo.getWorkingNodesInfo()) {
                        System.out.println("\t\tnode ID: " + info.getNodeId());
                        System.out.println("\t\tnode progress: " + info.getProgress());
                    }
                }
            } else {
                System.out.println("Failed to receive tasks info");
            }

            System.out.println();
            System.out.println("Requesting info about results ...");

            int[] results = admin.getResultIds();
            if (results != null) {

                System.out.format("%d completed task(s):%n", results.length);
                for (int result : results) {
                    System.out.println(result);
                }
                System.out.println();
            } else {
                System.out.println("Failed to receive results info");
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (admin != null) {
                admin.finalize();
            }
        }
    }


}
