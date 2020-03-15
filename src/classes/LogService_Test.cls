/**
 * Created by mlockett on 6/16/2018.
 */
@IsTest
public with sharing class LogService_Test {

	static void testSetup() {
		LogService.testRecordFilters = new List<LogRecordFilter__mdt>();
		LogRecordFilter__mdt filter = new LogRecordFilter__mdt();
		filter.LogLevelCsv__c = 'INFO,DEBUG,WARN,ERROR';
		filter.Active_Log_User__c = '*';
		filter.Active__c = true;

		LogService.testRecordFilters.add(filter);
	}

	/**
	* verifies that determining ability to log does not throw when test recordFilters are not supplied
	*/
	@IsTest
	static void canQueryForLoggable() {
		// clear test values
		LogService.testRecordFilters = null;
		LogService.isLoggable(UserInfo.getUserId(), LoggingLevel.DEBUG);
	}

	@IsTest
	static void filtersLogRecordCorrectly() {
		testSetup();
		LogService.testRecordFilters[0].LogLevelCsv__c = 'INFO,WARN';

		Test.startTest();
		LogService.debug('My message', 'foo/method');
		Test.stopTest();

		List<AppLog__c> appLogs = [SELECT Id FROM AppLog__c];

		System.assertEquals(0, appLogs.size());
	}

	@IsTest
	static void filtersLogRecordCorrectlyWithNullFilter() {
		testSetup();
		LogService.testRecordFilters[0].LogLevelCsv__c = null;

		Test.startTest();
		LogService.debug('My message', 'foo/method');
		Test.stopTest();

		List<AppLog__c> appLogs = [SELECT Id FROM AppLog__c];

		System.assertEquals(0, appLogs.size());
	}

	@IsTest
	static void verifyFilter() {
		testSetup();

		LogMessageFilter__mdt filter1 = new LogMessageFilter__mdt();
		filter1.RegexToReplaceWith__c = '***-**-$3';
		filter1.RegexToFind__c = '(\\d{3})-(\\d{2})-(\\d{4})';

		LogService.testMessageFilters = new List<LogMessageFilter__mdt>();//[filter1];
		LogService.testMessageFilters.add(filter1);

		String textToObscure = 'Hide the 123-12-1234 SSN.';
		String expectedText = 'Hide the ***-**-1234 SSN.';

		System.assertEquals(expectedText, LogService.filterString(textToObscure));
	}

	@IsTest
	static void logWritesCorrectValues() {
		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		LogService.log('My message', 'foo/method', LoggingLevel.WARN);
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
	static void invocableInfoWritesCorrectValues() {
		testSetup();

		List<String> messages = new List<String>{'a','b','c'};

		LogService.ignoreTestMode = true;
		Test.startTest();
		LogService.info(messages);
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				LIMIT 1
		];

		// for reasons currently unclear, Salesforce seems to truncate the final \n :-(
		String expected = 'a;\nb;\nc;';

		System.assertEquals(expected, appLog.Message__c);
		System.assertEquals('INFO', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void infoWritesCorrectValues() {
		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		LogService.info('My message', 'foo/method');
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE ClassMethod__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals('My message', appLog.Message__c);
		System.assertEquals('INFO', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void debugWritesCorrectValues() {
		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		LogService.debug('My message', 'foo/method');
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
	static void warnWritesCorrectValues() {
		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		LogService.warn('My message', 'foo/method');
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
	static void errorWritesCorrectValues() {
		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		LogService.error('My message', 'foo/method');
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
		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		try {
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		} catch (Exception ex) {
			LogService.error(ex, 'foo/method');
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

		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		try {
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		} catch (Exception ex) {
			LogService.error(ex, 'foo/method', 'my id');
		}

		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c, AffectedId__c
				FROM AppLog__c
				WHERE ClassMethod__c = 'foo/method'
				LIMIT 1
		];

		System.assert(appLog.Message__c.startsWith('Exception - Type: System.MathException;'));
		System.assertEquals('ERROR', appLog.LogLevel__c);
		System.assertEquals('my id', appLog.AffectedId__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void logWritesCorrectValuesForException() {

		testSetup();

		LogService.ignoreTestMode = true;
		Test.startTest();
		try {
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		} catch (Exception ex) {
			LogService.log(ex, 'foo/method', LoggingLevel.DEBUG);
		}

		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE ClassMethod__c = 'foo/method'
				LIMIT 1
		];

		System.assert(appLog.Message__c.startsWith('Exception - Type: System.MathException;'));
		System.assertEquals('DEBUG', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void errorDoesNotThrow() {

		testSetup();

		String tooLong = '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890';
		Test.startTest();
		LogService.warn('errorDoesNotThrow_message', tooLong);
		Test.stopTest();

		List<AppLog__c> appLogs = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE LogLevel__c = 'WARN'
				LIMIT 1
		];
		System.assertEquals(0, appLogs.size());

	}

	@IsTest
	static void logFailsSansIgnoreTestMode() {

		testSetup();

		Test.startTest();
		LogService.log('My message', 'foo/method', LoggingLevel.DEBUG);
		Test.stopTest();

		List<AppLog__c> appLogs = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE ClassMethod__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals(0, appLogs.size());
	}

	@IsTest
	static void badEventGeneratesError() {

		testSetup();

		LogService.ignoreTestMode = true;
		String tooLong = '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890';
		AppLogEvent__e event = new AppLogEvent__e();
		event.ClassMethod__c = tooLong;
		List<Database.Error> errors = LogService.publishEvent(event);
		System.assertEquals(1, errors.size());
	}
}