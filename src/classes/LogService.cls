/**
 * Created by mlockett on 6/16/2018.
 */
/**
 * For writing persistent logs using platform events
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

	/**
	 * writes log with message data
	 *
	 * @param message
	 * @param classMethod
	 */
	global static void debug(String message, String classMethod) {
		LogService.log(message, classMethod, LoggingLevel.DEBUG);
	}

	/**
	 * writes log with message data
	 *
	 * @param message
	 * @param classMethod
	 */
	global static void warn(String message, String classMethod) {
		LogService.log(message, classMethod, LoggingLevel.WARN);
	}

	/**
	 *
	 * Write error with exception data
	 *
	 * @param ex
	 * @param classMethod
	 */
	global static void error(Exception ex, String classMethod) {
		LogService.log(ex, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * writes log with message data
	 *
	 * @param message
	 * @param classMethod
	 */
	global static void error(String message, String classMethod) {
		LogService.log(message, classMethod, LoggingLevel.ERROR);
	}

	/**
	 * Called from trigger to write to log
	 *
	 * @param events
	 */
	global static void insertAppLogs(List<AppLogEvent__e> events) {
		List<AppLog__c> logEntries = new List<AppLog__c>();
		for (AppLogEvent__e event : events) {
			AppLog__c logEntry = new AppLog__c();
			logEntry.ClassMethod__c = event.ClassMethod__c;
			logEntry.LogLevel__c = event.LogLevel__c;
			logEntry.UserId__c = event.UserId__c;
			logEntry.Message__c = event.Message__c;
			logEntries.add(logEntry);
		}
		insert logEntries;
	}

	/**
	 * Returns consistent string for exception message
	 *
	 * @param ex
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
	 * @param event AppLogEvent__e
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
	 * @param message
	 * @param logLevel
	 * @param classMethod
	 */
	@TestVisible
	private static void log(String message, String classMethod, System.LoggingLevel logLevel) {
		AppLogEvent__e event = new AppLogEvent__e();
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
	 * writes log with exception data
	 *
	 * @param ex
	 * @param logLevel
	 * @param classMethod
	 */
	@TestVisible
	private static void log(Exception ex, String classMethod, System.LoggingLevel logLevel) {
		String message = getExceptionText(ex);
		LogService.log(message, classMethod, logLevel);
	}
}