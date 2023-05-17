/**
  * Class allow logging at an instance level
  * @author mlockett
  * @date 2019-01-15
 */

global without sharing class Logger implements  ILogger {

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param className class
    */
   global void debug(String message, String className) {
      LogService.log(message, className, LoggingLevel.DEBUG);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param className <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   global void debug(String message, String className, String affectedId) {
      LogService.log(message, className, affectedId, LoggingLevel.DEBUG);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param className <class>.<method> if applicable
    */
   global void warn(String message, String className) {
      LogService.log(message, className, LoggingLevel.WARN);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param className <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   global void warn(String message, String className, String affectedId) {
      LogService.log(message, className, affectedId, LoggingLevel.WARN);
   }

   /**
    * Write error with exception data
    *
    * @param ex exception to log
    * @param className <class>.<method> if applicable
    */
   global void error(Exception ex, String className) {
      LogService.log(ex, className, LoggingLevel.ERROR);
   }

   /**
    * Write error with exception data
    *
    * @param ex exception to logq
    * @param className <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   global void error(Exception ex, String className, String affectedId) {
      LogService.log(ex, className, affectedId, LoggingLevel.ERROR);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param className <class>.<method> if applicable
    */
   global void error(String message, String className) {
      LogService.log(message, className, LoggingLevel.ERROR);
   }
}