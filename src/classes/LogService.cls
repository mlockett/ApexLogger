/**
 * For writing persistent logs using platform events
 *
 * @author mike lockett
 * @date 2018-06-16
 */
global without sharing class LogService {
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
	 * Enables logging to be called from Process Builder
	 *
	 * @param messages because PB can insert/update multiple records, method takes a list which is concatenated
	 */
	@InvocableMethod(Label='Write Log' Description='Writes desired data to AppLog')
	global static void info(List<String> messages){
		String messageString = '';
		for(String message: messages){
			messageString += message + ';\n';
		}
		LogService.log(messageString, 'Invocable', LoggingLevel.INFO);
	}

	global static void info(String message, String classMethod){
		LogService.log(message, classMethod, LoggingLevel.INFO);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	global static void debug(String message, String classMethod) {
		LogService.log(message, classMethod, LoggingLevel.DEBUG);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	global static void warn(String message, String classMethod) {
		LogService.log(message, classMethod, LoggingLevel.WARN);
	}

	/**
	 * Write error with exception data
	 *
	 * @param ex exception to log
	 * @param classMethod <class>.<method> if applicable
	 */
	global static void error(Exception ex, String classMethod) {
		LogService.log(ex, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * Write error with exception data
	 *
	 * @param ex exception to log
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 */
	global static void error(Exception ex, String classMethod, String affectedId) {
		LogService.log(ex, classMethod, affectedId, LoggingLevel.ERROR);
	}

	/**
	 * writes log with message data
	 *
	 * @param message message to be logged
	 * @param classMethod <class>.<method> if applicable
	 */
	global static void error(String message, String classMethod) {
		LogService.log(message, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * Called from trigger to write to log
	 *
	 * @param events list of events to be logged
	 */
	global static void insertAppLogs(List<AppLogEvent__e> events) {
		List<AppLog__c> logEntries = new List<AppLog__c>();
		for (AppLogEvent__e event : events) {
			String message = event.Message__c;
			message = LogService.filterString(message);
			AppLog__c logEntry = new AppLog__c();
			logEntry.ClassMethod__c = event.ClassMethod__c;
			logEntry.LogLevel__c = event.LogLevel__c;
			logEntry.UserId__c = event.UserId__c;
			logEntry.Message__c = message;
			logEntry.ShortMessage__c = message.left(255);
			logEntry.AffectedId__c = event.AffectedId__c;
			logEntries.add(logEntry);
		}
		insert logEntries;
	}

	/**
	 * Returns consistent string for exception message
	 *
	 * @param ex the exception to retrieve text for
	 *
	 * @return desired text from exception
	 */
	@TestVisible
	private static String getExceptionText(Exception ex) {
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
	private static List<Database.Error> publishEvent(AppLogEvent__e event) {
		// don't publish event during unit tests unless ignoreTestMode is true
		if (!ignoreTestMode && Test.isRunningTest()) {
			return null;
		}
		Database.SaveResult dbResult = EventBus.publish(event);

		// Inspect publishing result
		if (dbResult.isSuccess()) {
			System.debug('Successfully published event:' + event);
		}
		else {
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
	 * @param classMethod <class>.<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(String message, String classMethod, System.LoggingLevel logLevel) {
      // check if entry should be logged
      if(!isLoggable(UserInfo.getUserId(), logLevel)){
         return;
      }
		AppLogEvent__e event = new AppLogEvent__e();
		message = LogService.filterString(message);
		event.Message__c = message;
		event.LogLevel__c = logLevel.name();
		event.ClassMethod__c = classMethod;
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
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(String message, String classMethod, String affectedId, System.LoggingLevel logLevel) {
		AppLogEvent__e event = new AppLogEvent__e();
		event.Message__c = message;
		event.LogLevel__c = logLevel.name();
		event.ClassMethod__c = classMethod;
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
	 * @param classMethod <class>.<method> if applicable
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(Exception ex, String classMethod, System.LoggingLevel logLevel) {
		String message = getExceptionText(ex);
		LogService.log(message, classMethod, logLevel);
	}

	/**
	 * writes log with exception data
	 *
	 * @param ex the exception to be logged
	 * @param classMethod <class>.<method> if applicable
	 * @param affectedId record Id(s) related to log event
	 * @param logLevel the System.LoggingLevel to log as
	 */
	public static void log(Exception ex, String classMethod, String affectedId, System.LoggingLevel logLevel) {
		String message = getExceptionText(ex);
		LogService.log(message, classMethod, affectedId, logLevel);
	}

	/**
	 * Filters string based on LogFilter__mdt or optionally testFilters
	 *
	 * @param inputString string to filter
	 *
	 * @return string with replacements made for all active filters
	 */
	public static String filterString(String inputString) {
		List<LogMessageFilter__mdt> filters = getMessageFilters();

		for (LogMessageFilter__mdt filter : filters) {
			inputString = inputString.replaceAll(filter.RegexToFind__c, filter.RegexToReplaceWith__c);
			System.debug('inputString: ' + inputString);
		}
		return inputString;
	}

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
		}
		else {
			filters = testMessageFilters;
		}
		return filters;
	}

	/**
	 * determines whether entry should be logged based on user and loglevel using LogRecordFilter__mdt
	 *
	 * @param currentUserId user id to evaluate
	 * @param logLevel log level to evaluate
	 *
	 * @return whether entry should be logged
	 */
	public static Boolean isLoggable(String currentUserId, LoggingLevel logLevel) {
		List<LogRecordFilter__mdt> recordFilters = getRecordFilters(currentUserId);
		String strLogLevel = logLevel.name();
		for (LogRecordFilter__mdt filter : recordFilters) {
			if (filter.LogLevelCsv__c == null) {
				continue;
			}
         // splits on comma space or comma
			List<String> logLevels = filter.LogLevelCsv__c.split(', |,');

			if (logLevels.contains(strLogLevel) && (filter.Active_Log_User__c == '*')
         || filter.Active_Log_User__c == currentUserId){
				return true;
			}
		}
		return false;
	}

   /**
    * gets LogRecordFilter__mdt for current user and for * (all users)
    *
    * @param currentUserId active user in execution context
    *
    * @return list of log filters
    */
   private static List<LogRecordFilter__mdt> getRecordFilters(Id currentUserId) {
      if(testRecordFilters != null){
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
}