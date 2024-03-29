/**
 * Created by mlockett on 1/15/2019.
 */

global interface ILogger {

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 */
	void debug(String message, String className);

	/**
	 * writes debug log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	void debug(String message, String className, String affectedId);


	/**
	 * writes info log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 */
	void info(String message, String className);

	/**
	 * writes warning log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 */
	void warn(String message, String className);

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	void warn(String message, String className, String affectedId);

	/**
	 * Write error with exception data
	 *
	 * @param ex
	 * @param className <class>.<method> if applicable
	 */
	void error(Exception ex, String className);

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 */
	void error(String message, String className);

	/**
	 * Write error with exception data
	 *
	 * @param ex
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	void error(Exception ex, String className, String affectedId);

	/**
	 * writes log with message
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 * @param logLevel the String to log as
	 */
	void log(String message, String className, String affectedId, String logLevel);

	/**
	 * determines whether entry should be logged based on user and loglevel using LogRecordFilter__mdt
	 *
	 * @param currentUserId user id to evaluate
	 * @param logLevel log level to evaluate
	 *
	 * @return whether entry should be logged
	 */
	 Boolean isLoggable(String currentUserId, LoggingLevel logLevel);
}