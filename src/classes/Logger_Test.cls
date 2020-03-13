/**
 * @author mlockett
 * @date 2019-01-15
 */
@IsTest
public with sharing class Logger_Test {
   static Logger sut = new Logger();

   @IsTest
   static void debugWritesCorrectValues() {

      LogService.ignoreTestMode = true;
      Test.startTest();
      sut.debug('My message', 'foo/method');
      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assertEquals('My message', appLog.Message__c);
      System.assertEquals('DEBUG', appLog.LogLevel__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }

   @IsTest
   static void debugWithIdWritesCorrectValues() {
      LogService.ignoreTestMode = true;
      Test.startTest();
      sut.debug('My message', 'foo/method', 'my id');
      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c, AffectedId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assertEquals('My message', appLog.Message__c);
      System.assertEquals('DEBUG', appLog.LogLevel__c);
      System.assertEquals('my id', appLog.AffectedId__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }

   @IsTest
   static void warnWritesCorrectValues() {
      LogService.ignoreTestMode = true;
      Test.startTest();
      sut.warn('My message', 'foo/method');
      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assertEquals('My message', appLog.Message__c);
      System.assertEquals('WARN', appLog.LogLevel__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }

   @IsTest
   static void warnWithIdWritesCorrectValues() {
      LogService.ignoreTestMode = true;
      Test.startTest();
      sut.warn('My message', 'foo/method', 'my id');
      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c, AffectedId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assertEquals('My message', appLog.Message__c);
      System.assertEquals('WARN', appLog.LogLevel__c);
      System.assertEquals('my id', appLog.AffectedId__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }

   @IsTest
   static void errorWritesCorrectValues() {
      LogService.ignoreTestMode = true;
      Test.startTest();
      sut.error('My message', 'foo/method');
      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assertEquals('My message', appLog.Message__c);
      System.assertEquals('ERROR', appLog.LogLevel__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }

   @IsTest
   static void errorWritesCorrectValuesForException() {
      LogService.ignoreTestMode = true;
      Test.startTest();
      try {
         //noinspection ApexUnusedDeclaration
         Double badNumber = 1 / 0; // force MathException
      }
      catch (Exception ex) {
         sut.error(ex, 'foo/method');
      }

      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assert(appLog.Message__c.startsWith('Exception - Type: System.MathException;'));
      System.assertEquals('ERROR', appLog.LogLevel__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }

   @IsTest
   static void errorWithIdWritesCorrectValuesForException() {
      LogService.ignoreTestMode = true;
      Test.startTest();
      try {
         //noinspection ApexUnusedDeclaration
         Double badNumber = 1 / 0; // force MathException
      }
      catch (Exception ex) {
         sut.error(ex, 'foo/method', 'idValue');
      }

      Test.stopTest();

      AppLog__c appLog = [
            SELECT Message__c, LogLevel__c, UserId__c, AffectedId__c
            FROM AppLog__c
            WHERE ClassMethod__c = 'foo/method'
            LIMIT 1
      ];

      System.assert(appLog.Message__c.startsWith('Exception - Type: System.MathException;'));
      System.assertEquals('idValue', appLog.AffectedId__c);
      System.assertEquals('ERROR', appLog.LogLevel__c);
      System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
   }
}