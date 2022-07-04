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
    * @param classMethod <class>.<method> if applicable
    */
   global void debug(String message, String classMethod) {
      LogService.log(message, classMethod, LoggingLevel.DEBUG);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   global void debug(String message, String classMethod, String affectedId) {
      LogService.log(message, classMethod, affectedId, LoggingLevel.DEBUG);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    */
   global void warn(String message, String classMethod) {
      LogService.log(message, classMethod, LoggingLevel.WARN);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   global void warn(String message, String classMethod, String affectedId) {
      LogService.log(message, classMethod, affectedId, LoggingLevel.WARN);
   }

   /**
    * Write error with exception data
    *
    * @param ex exception to log
    * @param classMethod <class>.<method> if applicable
    */
   global void error(Exception ex, String classMethod) {
      LogService.log(ex, classMethod, LoggingLevel.ERROR);
   }

   /**
    * Write error with exception data
    *
    * @param ex exception to logq
    * @param classMethod <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   global void error(Exception ex, String classMethod, String affectedId) {
      LogService.log(ex, classMethod, affectedId, LoggingLevel.ERROR);
   }

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    */
   global void error(String message, String classMethod) {
      LogService.log(message, classMethod, LoggingLevel.ERROR);
   }
}