package com.neurotec.tutorials;

import java.io.FileInputStream;

import com.neurotec.cluster.Client;
import com.neurotec.cluster.ClusterResult;
import com.neurotec.cluster.Task;
import com.neurotec.cluster.TaskMode;
import com.neurotec.cluster.TaskProgress;
import com.neurotec.cluster.TaskResult;
import com.neurotec.lang.NThrowable;
import com.neurotec.tutorials.util.LibraryManager;
import com.neurotec.tutorials.util.Utils;

public final class SendTask {

	private static final String DESCRIPTION = "Demonstrates how to send a task to matching server and wait for result";
	private static final String NAME = "send-task";
	private static final String VERSION = "9.0.0.0";

	private static final String DEFAULT_ADDRESS = "127.0.0.1";
	private static final int DEFAULT_PORT = 25452;
	private static final String DEFAULT_QUERY = "SELECT node_id, dbid FROM node_tbl";

	private static void usage() {
		System.out.println("usage:");
		System.out.format("\t%s -s [server:port] -t [template] -q [query]%n", NAME);
		System.out.println("");
		System.out.println("\t-s server:port   - matching server address (optional parameter, if address specified - port is optional)");
		System.out.println("\t-t template      - template to be sent for matching (required)");
		System.out.println("\t-q query         - database query to execute (optional)");
		System.out.println("default query (if not specified): " + DEFAULT_QUERY);
	}

	public static void main(String[] args) throws Throwable {
		LibraryManager.initLibraryPath();
		Utils.printTutorialHeader(DESCRIPTION, NAME, VERSION, args);

		if (args.length < 2) {
			usage();
			System.exit(-1);
		}

		byte[] template = null;
		Client client = null;
		ParseArgsResult results = null;
		try {
			results = parseArgs(args);
		} catch (Throwable th) {
			th.printStackTrace();

			int errorCode = -1;

			if (th instanceof NThrowable) {
				errorCode = ((NThrowable)th).getCode();
			}

			System.exit(errorCode);
		}

		FileInputStream fis = null;
		try {
			fis = new FileInputStream(results.getTemplateFile());
			template = new byte[fis.available()];
			fis.read(template);
		} catch (Exception e) {
			System.err.format("Could not load template from file %s.%n", args[0]);
			System.exit(-1);
		} finally {
			if (fis != null) {
				fis.close();
			}
		}

		try {
			int taskId;

			Task task = new Task();
			task.setMode(TaskMode.NORMAL);
			task.setTemplate(template);
			task.setQuery(results.getQuery());
			task.setResultLimit(100);

			client = new Client(results.getServerIp(), results.getServerPort());
			taskId = client.sendTask(task);
			if (taskId == -1) {
				throw new Exception("Failed to get task id. Task was not added.");
			}

			System.out.format("... task with ID %d started%n", taskId);

			waitForResult(client, taskId);
		} catch (Throwable th) {
			th.printStackTrace();

			int errorCode = -1;

			if (th instanceof NThrowable) {
				errorCode = ((NThrowable)th).getCode();
			}

			System.exit(errorCode);
		} finally {
			if (client != null) {
				client.finalize();
			}
		}
	}

	private static ParseArgsResult parseArgs(String[] args) throws Exception {
		ParseArgsResult result = new ParseArgsResult();
		result.setServerIp(DEFAULT_ADDRESS);
		result.setServerPort(DEFAULT_PORT);
		result.setQuery(DEFAULT_QUERY);

		result.setTemplateFile("");
		result.setIsStandardTemplate(false);

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
					result.setServerIp(splitAddress[0]);
					result.setServerPort(Integer.parseInt(splitAddress[1]));
				} else {
					result.setServerIp(optarg);
					result.setServerPort(DEFAULT_PORT);
				}
				break;
			case 't':
				i++;
				result.setTemplateFile(optarg);
				break;
			case 'q':
				i++;
				result.setQuery(optarg);
				break;
			default:
				throw new Exception("Wrong parameter found!");
			}
		}

		if (result.getTemplateFile() == "") throw new Exception("Template - required parameter - not specified");
		return result;
	}

	private static void waitForResult(Client client, int taskId) throws Exception {
		System.out.println("Waiting for results ...");
		int count;
		TaskProgress progress;
		do {
			progress = client.getProgress(taskId);

			if (progress.getProgress() != 100) Thread.sleep(100);

			if (progress.getProgress() < 0) {
				System.out.println("Task aborted on server side.");
				return;
			}

		} while (progress.getProgress() != 100);

		count = progress.getResultCount();
		if (count > 0) {
			TaskResult results = client.getTaskResult(taskId, 1, count);
			for (ClusterResult clusterRes : results.getRes()) {
				System.out.println("... matched with id: " + clusterRes.getId() + ", score: " + clusterRes.getSimilarity());
			}
		} else {
			System.out.println("... no matches");
		}

		client.deleteTask(taskId);
	}

	public static class ParseArgsResult {

		private String serverIp;
		private int serverPort;
		private String templateFile;
		private String query;
		private boolean isStandardTemplate;

		public String getServerIp() {
			return serverIp;
		}

		public void setServerIp(String value) {
			serverIp = value;
		}

		public int getServerPort() {
			return serverPort;
		}

		public void setServerPort(int port) {
			serverPort = port;
		}

		public String getTemplateFile() {
			return templateFile;
		}

		public void setTemplateFile(String value) {
			templateFile = value;
		}

		public String getQuery() {
			return query;
		}

		public void setQuery(String value) {
			query = value;
		}

		public boolean getIsStandardTemplate() {
			return isStandardTemplate;
		}

		public void setIsStandardTemplate(boolean value) {
			isStandardTemplate = value;
		}
	}
}
