/**
 * Created by mlockett on 1/15/2019.
 */

global interface ILogger {

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    */
   void debug(String message, String classMethod);

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   void debug(String message, String classMethod, String affectedId);

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    */
   void warn(String message, String classMethod);

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   void warn(String message, String classMethod, String affectedId);

   /**
    * Write error with exception data
    *
    * @param ex
    * @param classMethod <class>.<method> if applicable
    */
   void error(Exception ex, String classMethod);

   /**
    * writes log with message data
    *
    * @param message message to be logged
    * @param classMethod <class>.<method> if applicable
    */
   void error(String message, String classMethod);

   /**
    * Write error with exception data
    *
    * @param ex
    * @param classMethod <class>.<method> if applicable
    * @param affectedId record Id(s) related to log event
    */
   void error(Exception ex, String classMethod, String affectedId);
}