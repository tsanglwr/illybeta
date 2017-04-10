package com.illy.utils;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.net.URLConnection;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

/**
 * Created by kamwo on 23.04.15.
 */
public class FileDownloader {

    /**
     * Returns a path to the downloaded file
     *
     * @param url
     * @return
     * @throws IOException
     */
    public static String downloadFromUrl(URL url) throws IOException {
        InputStream is = null;
        FileOutputStream fos = null;

        //create a temp file
        File temp = File.createTempFile("tempfile", ".tmp");

        try {
            //connect
            URLConnection urlConn = url.openConnection();

            //get inputstream from connection
            is = urlConn.getInputStream();
            fos = new FileOutputStream(temp);

            // 4KB buffer
            byte[] buffer = new byte[4096];
            int length;

            // read from source and write into local file
            while ((length = is.read(buffer)) > 0) {
                fos.write(buffer, 0, length);
            }
            return temp.getAbsolutePath();//outputPath;
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
            } finally {
                if (fos != null) {
                    fos.close();
                }
            }
        }
    }
}