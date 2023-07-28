/**
  * For logging at an instance level
  * @author mike lockett
  * @date 2019-01-15
 */

global without sharing class Logger implements ILogger {

	/**
	 * When test is running, event will not be published unless ignoreTestMode is set to true
	 */
	@TestVisible
	private static Boolean ignoreTestMode { get; set; }
	static {
		ignoreTestMode = false;
	}

	@TestVisible
			// note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow testing
			// different metadata
	static List<LogMessageFilter__mdt> testMessageFilters = null;

	@TestVisible
			// note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow testing
			// different metadata
	static List<LogRecordFilter__mdt> testRecordFilters = null;

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className class
	 */
	global void debug(String message, String className) {
		log(message, className, LoggingLevel.DEBUG);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	global void debug(String message, String className, String affectedId) {
		log(message, className, affectedId, LoggingLevel.DEBUG);
	}

	global void info(String message, String className) {
		log(message, className, LoggingLevel.INFO);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 */
	global void warn(String message, String className) {
		log(message, className, LoggingLevel.WARN);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	global void warn(String message, String className, String affectedId) {
		log(message, className, affectedId, LoggingLevel.WARN);
	}

	/**
	 * Write error with exception data
	 *
	 * @param ex exception to log
	 * @param className <class>.<method> if applicable
	 */
	global void error(Exception ex, String className) {
		log(ex, className, LoggingLevel.ERROR);
	}

	/**
	 * Write error with exception data
	 *
	 * @param ex exception to logq
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	global void error(Exception ex, String className, String affectedId) {
		log(ex, className, affectedId, LoggingLevel.ERROR);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 */
	global void error(String message, String className) {
		log(message, className, LoggingLevel.ERROR);
	}

	/**
	 * Returns consistent string for exception message
	 *
	 * @param ex the exception to retrieve text for
	 *
	 * @return desired text from exception
	 */
	@TestVisible
	private String getExceptionText(Exception ex) {
		return 'Exception - Type: '
				+ ex.getTypeName() + '; Line: '
				+ ex.getLineNumber() + '; Message: ' + ex.getMessage()
				+ '; Stacktrace: ' + ex.getStackTraceString();
	}

	/**
	 * publishes event... optionally suppresses when in test... deals with errors
	 *
	 * @param event AppLogEvent__e event to be published
	 * @return list of db errors
	 */
	@TestVisible
	private List<Database.Error> publishEvent(AppLogEvent__e event) {
		System.debug('hit publishEvent');
		// don't publish event during unit tests unless ignoreTestMode is true
		if (!ignoreTestMode && Test.isRunningTest()) {
			return null;
		}

		event.Message__c = filterString(event.Message__c);

		System.debug(event);
		Database.SaveResult dbResult = EventBus.publish(event);

		// Inspect publishing result
		if (dbResult.isSuccess()) {
			System.debug('Successfully published event:' + event);
		} else {
			for (Database.Error err : dbResult.getErrors()) {
				System.debug('* Error returned: ' + err.getStatusCode() + ' - ' + err.getMessage());
			}
			return dbResult.getErrors();
		}
		return null;
	}

	/**
	 * writes log with message
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public void log(String message, String className, System.LoggingLevel logLevel) {
		// check if entry should be logged
		if (!isLoggable(UserInfo.getUserId(), logLevel)) {
			return;
		}
		AppLogEvent__e event = new AppLogEvent__e();
		event.Message__c = message;
		event.LogLevel__c = logLevel.name();
		event.Class__c = className;
		String userId = UserInfo.getUserId();
		if (userId != null) {
			event.UserId__c = userId;
		}
		publishEvent(event);
	}

	/**
	 * writes log with message
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public void log(String message, String className, String affectedId, System.LoggingLevel logLevel) {
		// check if entry should be logged
		if (!isLoggable(UserInfo.getUserId(), logLevel)) {
			return;
		}

		AppLogEvent__e event = new AppLogEvent__e();
		event.Message__c = message;
		event.LogLevel__c = logLevel.name();
		event.Class__c = className;
		event.AffectedId__c = affectedId;

		String userId = UserInfo.getUserId();
		if (userId != null) {
			event.UserId__c = userId;
		}
		publishEvent(event);
	}

	/**
	 * writes log with message
	 *
	 * @param message message to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 * @param logLevel the System.LoggingLevel to log as a string
	 */
	public void log(String message, String className, String affectedId, String logLevel) {
		AppLogEvent__e event = new AppLogEvent__e();
		event.Message__c = message;
		event.LogLevel__c = logLevel;
		event.Class__c = className;
		event.AffectedId__c = affectedId;

		String userId = UserInfo.getUserId();
		if (userId != null) {
			event.UserId__c = userId;
		}
		publishEvent(event);
	}

	/**
	 * writes log with exception data
	 *
	 * @param ex the exception to be logged
	 * @param className <class>.<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public void log(Exception ex, String className, System.LoggingLevel logLevel) {
		String message = getExceptionText(ex);
		log(message, className, logLevel);
	}

	/**
	 * writes log with exception data
	 *
	 * @param ex the exception to be logged
	 * @param className <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public void log(Exception ex, String className, String affectedId, System.LoggingLevel logLevel) {
		String message = getExceptionText(ex);
		log(message, className, affectedId, logLevel);
	}

	/**
	 * determines whether entry should be logged based on user and loglevel using LogRecordFilter__mdt
	 *
	 * @param currentUserId user id to evaluate
	 * @param logLevel log level to evaluate
	 *
	 * @return whether entry should be logged
	 */
	public Boolean isLoggable(String currentUserId, LoggingLevel logLevel) {
		List<LogRecordFilter__mdt> recordFilters = getRecordFilters(currentUserId);
		String strLogLevel = logLevel.name();
		for (LogRecordFilter__mdt filter : recordFilters) {
			if (filter.LogLevelCsv__c == null) {
				continue;
			}
			// splits on comma space or comma
			List<String> logLevels = filter.LogLevelCsv__c.split(', |,');

			if (logLevels.contains(strLogLevel) && (filter.Active_Log_User__c == '*')
					|| filter.Active_Log_User__c == currentUserId) {
				System.debug('has logs');
				return true;
			}
		}
		System.debug('not loggable');
		return false;
	}

	/**
	 * gets LogRecordFilter__mdt for current user and for * (all users)
	 *
	 * @param currentUserId active user in execution context
	 *
	 * @return list of log filters
	 */
	private List<LogRecordFilter__mdt> getRecordFilters(Id currentUserId) {
		// provide a simple way to test specific LogRecordFilters
		if (testRecordFilters != null) {
			return testRecordFilters;
		}
		List<LogRecordFilter__mdt> recordFilters = [
				SELECT Id, LogLevelCsv__c, Active_Log_User__c, Active__c
				FROM LogRecordFilter__mdt
				WHERE (Active_Log_User__c = :currentUserId
				OR Active_Log_User__c = '*')
				AND Active__c = TRUE
				ORDER BY Active_Log_User__c
		];
		return recordFilters;
	}

	/**
	 * Filters string based on LogFilter__mdt or optionally testFilters
	 *
	 * @param inputString string to filter
	 *
	 * @return string with replacements made for all active filters
	 */
	public String filterString(String inputString) {
		List<LogMessageFilter__mdt> filters = getMessageFilters();

		for (LogMessageFilter__mdt filter : filters) {
			inputString = inputString.replaceAll(filter.RegexToFind__c, filter.RegexToReplaceWith__c);
			System.debug('inputString: ' + inputString);
		}
		return inputString;
	}

	/**
	 * @return message filters
	 */
	private static List<LogMessageFilter__mdt> getMessageFilters() {
		List<LogMessageFilter__mdt> filters;
		// note: because SF doesn't allow creating custom metadata in tests, we're doing a workaround to allow test to
		// set expected metadata
		if (testMessageFilters == null) {
			filters = [
					SELECT RegexToFind__c, RegexToReplaceWith__c
					FROM LogMessageFilter__mdt
					WHERE Active__c = TRUE
			];
		} else {
			filters = testMessageFilters;
		}
		return filters;
	}

	/**
     * Called from trigger to write to log
     *
     * @param events list of events to be logged
     */
    global void insertAppLogs(List<AppLogEvent__e> events) {
        List<AppLog__c> logEntries = new List<AppLog__c>();
        for (AppLogEvent__e event : events) {
            String message = event.Message__c;
            AppLog__c logEntry = new AppLog__c();
            logEntry.Class__c = event.Class__c;
            logEntry.LogLevel__c = event.LogLevel__c;
            logEntry.UserId__c = event.UserId__c;
            logEntry.Message__c = message;
            logEntry.ShortMessage__c = message.left(255);
            logEntry.AffectedId__c = event.AffectedId__c;
            logEntries.add(logEntry);
        }
        insert logEntries;
    }
}