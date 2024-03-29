/**
 * Created by mlockett on 6/16/2018.
 */
@IsTest
public with sharing class LogService_Test {

	public static void testSetup() {
		Logger.testRecordFilters = new List<LogRecordFilter__mdt>();
		LogRecordFilter__mdt filter = new LogRecordFilter__mdt();
		filter.LogLevelCsv__c = 'INFO,DEBUG,WARN,ERROR';
		filter.Active_Log_User__c = '*';
		filter.Active__c = true;

		Logger.testRecordFilters.add(filter);
	}

	/**
	* verifies that determining ability to log does not throw when test recordFilters are not supplied
	*/
	@IsTest
	static void canQueryForLoggable() {
		// clear test values
		Logger.testRecordFilters = null;
		LogService.isLoggable(UserInfo.getUserId(), LoggingLevel.DEBUG);
	}

	@IsTest
	static void filtersLogRecordCorrectly() {
		testSetup();
		Logger.testRecordFilters[0].LogLevelCsv__c = 'INFO,WARN';

		Test.startTest();
		LogService.debug('My message', 'foo/method');
		Test.stopTest();

		List<AppLog__c> appLogs = [SELECT Id FROM AppLog__c];

		System.assertEquals(0, appLogs.size());
	}

	@IsTest
	static void filtersLogRecordCorrectlyWithNullFilter() {
		testSetup();
		Logger.testRecordFilters[0].LogLevelCsv__c = null;

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

		Logger.testMessageFilters = new List<LogMessageFilter__mdt>();//[filter1];
		Logger.testMessageFilters.add(filter1);

		String textToObscure = 'Hide the 123-12-1234 SSN.';
		String expectedText = 'Hide the ***-**-1234 SSN.';

		Logger log = new Logger();

		System.assertEquals(expectedText, log.filterString(textToObscure));
	}

	@IsTest
	static void invocableInfoWritesCorrectValues() {
		testSetup();

		List<LogService.AppLogData> messages = new List<LogService.AppLogData>();
		LogService.AppLogData data = new LogService.AppLogData();
		data.message='abc';
		data.loggingLevel='INFO';
		data.className='My Flow';
		data.affectedId='';
		messages.add(data);

		Logger.ignoreTestMode = true;
		Test.startTest();
		LogService.logData(messages);
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				LIMIT 1
		];

		System.assertEquals('abc', appLog.Message__c);
		System.assertEquals('INFO', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void infoWritesCorrectValues() {
		testSetup();

		Logger.ignoreTestMode = true;
		Test.startTest();
		LogService.info('My message', 'foo/method');
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals('My message', appLog.Message__c);
		System.assertEquals('INFO', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void debugWritesCorrectValues() {
		testSetup();

		Logger.ignoreTestMode = true;
		Test.startTest();
		LogService.debug('My message', 'foo/method');
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals('My message', appLog.Message__c);
		System.assertEquals('DEBUG', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void warnWritesCorrectValues() {
		testSetup();

		Logger.ignoreTestMode = true;
		Test.startTest();
		LogService.warn('My message', 'foo/method');
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals('My message', appLog.Message__c);
		System.assertEquals('WARN', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void errorWritesCorrectValues() {
		testSetup();

		Logger.ignoreTestMode = true;
		Test.startTest();
		LogService.error('My message', 'foo/method');
		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals('My message', appLog.Message__c);
		System.assertEquals('ERROR', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void errorWritesCorrectValuesForException() {
		testSetup();

		Logger.ignoreTestMode = true;
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
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assert(appLog.Message__c.startsWith('Exception - Type: System.MathException;'));
		System.assertEquals('ERROR', appLog.LogLevel__c);
		System.assertEquals(UserInfo.getUserId(), appLog.UserId__c);
	}

	@IsTest
	static void errorWithIdWritesCorrectValuesForException() {

		testSetup();

		Logger.ignoreTestMode = true;
		Test.startTest();
		try {
			//noinspection ApexUnusedDeclaration
			Double badNumber = 1 / 0; // force MathException
		} catch (Exception ex) {
			LogService.error(ex, 'MyClass', 'my id');
		}

		Test.stopTest();

		AppLog__c appLog = [
				SELECT Message__c, LogLevel__c, UserId__c, AffectedId__c
				FROM AppLog__c
				WHERE Class__c = 'MyClass'
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

		Logger.ignoreTestMode = true;
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
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assert(appLog.Message__c.startsWith('Exception - Type: System.MathException;'));
		System.assertEquals('ERROR', appLog.LogLevel__c);
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
		LogService.debug('My message', 'foo/method');
		Test.stopTest();

		List<AppLog__c> appLogs = [
				SELECT Message__c, LogLevel__c, UserId__c
				FROM AppLog__c
				WHERE Class__c = 'foo/method'
				LIMIT 1
		];

		System.assertEquals(0, appLogs.size());
	}

	@IsTest
	static void badEventGeneratesError() {

		testSetup();

		Logger.ignoreTestMode = true;
		String tooLong = '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890'
				+ '12345678901234567890123456789012345678901234567890';
		AppLogEvent__e event = new AppLogEvent__e();
		event.Class__c = tooLong;
		event.Message__c = 'Any message';
		Logger log = new Logger();
		List<Database.Error> errors = log.publishEvent(event);
		System.assertEquals(1, errors.size());
	}
}