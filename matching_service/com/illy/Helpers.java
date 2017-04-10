package com.illy;

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

import com.neurotec.lang.NThrowable;
import com.neurotec.util.concurrent.AggregateExecutionException;


public class Helpers {

    private static final String WIN32_X86 = "Win32_x86";
    private static final String WIN64_X64 = "Win64_x64";
    private static final String LINUX_X86 = "Linux_x86";
    private static final String LINUX_X86_64 = "Linux_x86_64";
    private static final String MAC_OS = "/Library/Frameworks/";

    public static final String FILE_SEPARATOR = System.getProperty("file.separator");
    public static final String PATH_SEPARATOR = System.getProperty("path.separator");
    public static final String LINE_SEPARATOR = System.getProperty("line.separator");

    public static final String DEFAULT_ADDRESS = "127.0.0.1";
    public static final String DEFAULT_HOST = "127.0.0.1";
    public static final int DEFAULT_PORT = 24932;

    public static void initLibraryPath() {
        String libraryPath = getLibraryPath();
        String jnaLibraryPath = System.getProperty("jna.library.path");
        // if (Utils.isNullOrEmpty(jnaLibraryPath)) {
        if ("" == jnaLibraryPath || null == jnaLibraryPath) {
            System.setProperty("jna.library.path", libraryPath.toString());
        } else {
            System.setProperty("jna.library.path", String.format("%s%s%s", jnaLibraryPath, Helpers.PATH_SEPARATOR, libraryPath.toString()));
        }
        System.setProperty("java.library.path", String.format("%s%s%s", System.getProperty("java.library.path"), Helpers.PATH_SEPARATOR, libraryPath.toString()));

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
        int index = Helpers.getWorkingDirectory().lastIndexOf(Helpers.FILE_SEPARATOR);
        if (index == -1) {
            return null;
        }
        String part = Helpers.getWorkingDirectory().substring(0, index);
        if (Platform.isWindows()) {
            if (part.endsWith("Bin")) {
                path.append(part);
                path.append(Helpers.FILE_SEPARATOR);
                path.append(Platform.is64Bit() ? WIN64_X64 : WIN32_X86);
            }
        } else if (Platform.isLinux()) {
            index = part.lastIndexOf(Helpers.FILE_SEPARATOR);
            if (index == -1) {
                return null;
            }
            part = part.substring(0, index);
            path.append(part);
            path.append(Helpers.FILE_SEPARATOR);
            path.append("Lib");
            path.append(Helpers.FILE_SEPARATOR);
            path.append(Platform.is64Bit() ? LINUX_X86_64 : LINUX_X86);
        } else if (Platform.isMac()) {
            path.append(MAC_OS);
        }
        return path.toString();
    }

    public static int handleNThrowable(NThrowable th) {
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

}