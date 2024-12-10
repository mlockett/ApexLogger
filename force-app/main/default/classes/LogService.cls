/**
 * For writing persistent logs using platform events
 *
 * @author mike lockett
 * @date 2018-06-16
 */
global without sharing class LogService {

	// this can be set to a different logger if necessary - or use a service locator to select the appropriate service.
	//https://github.com/mlockett/ApexServiceLocator
    public static ILogger logger = new Logger();

    //*******************************************************************
    // wrappers for logger
    //*******************************************************************

    /**
     * writes debug log with message data
     *
     * @param message message to be logged
     * @param className <class>.<method> if applicable
     */
    @AuraEnabled(cacheable=false)
    global static void debug(String message, String className) {
        logger.debug(message, className);
    }

    /**
     * writes info log with message data
     *
     * @param message message to be logged
     * @param className <class>.<method> if applicable
     */
    @AuraEnabled(cacheable=false)
    global static void info(String message, String className) {
        logger.info(message, className);
    }

    /**
     * writes warning log with message data
     *
     * @param message message to be logged
     * @param className <class>.<method> if applicable
     */
    @AuraEnabled(cacheable=false)
    global static void warn(String message, String className) {
        logger.warn(message, className);
    }

    /**
     * Write error with exception data
     *
     * @param ex exception to log
     * @param className <class>.<method> if applicable
     */
    global static void error(Exception ex, String className) {
        logger.error(ex, className);
    }

    /**
     * Write error with exception data
     *
     * @param ex exception to log
     * @param className <class>.<method> if applicable
     * @param affectedId record Id(s) related to log event
     */
    global static void error(Exception ex, String className, String affectedId) {
        logger.error(ex, className, affectedId);
    }

    /**
     * writes log with message data
     *
     * @param message message to be logged
     * @param className <class>.<method> if applicable
     */
    global static void error(String message, String className) {
        logger.error(message, className);
    }

    //*******************************************************************
    // end wrappers for logger
    //*******************************************************************

    /**
     * determines whether entry should be logged based on user and loglevel using LogRecordFilter__mdt
     *
     * @param currentUserId user id to evaluate
     * @param logLevel log level to evaluate
     *
     * @return whether entry should be logged
     */
    public static Boolean isLoggable(String currentUserId, LoggingLevel logLevel) {
        return logger.isLoggable(currentUserId, logLevel);
    }

    /**
     * allow declaratively publishing log events
     * @param logs list of AppLogData
     */
    @InvocableMethod(Label='Write Log Data' Description='Writes desired data to AppLog')
    global static void logData(List<AppLogData> logs) {

        for (AppLogData dataItem : logs) {
            String message = dataItem.message;
            String loggingLevel = dataItem.loggingLevel;
            String className = dataItem.className;
            String affectedId = dataItem.affectedId;

            logger.log(message, className, affectedId, loggingLevel);
        }
    }

    /**
     * Encapsulates data for declaratively raising log events
     */
    global class AppLogData {
        @InvocableVariable(Label='Message' Description='Message to be logged' Required=true)
        global String message;

        @InvocableVariable(Label='Logging Level' Description='Level to Log')
        global String loggingLevel;

        @InvocableVariable(Label='Flow Name' Description='Name of Flow error occurred in')
        global String className;

        @InvocableVariable(Label='Object Id' Description='Id of object error occurred on')
        global String affectedId;
    }
}