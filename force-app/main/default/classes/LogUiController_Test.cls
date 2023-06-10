/**
 * Test class for LogController
 * @author mikelockett
 * @date 6/3/23.
 */

@IsTest
public with sharing class LogUiController_Test {
    @IsTest
    static void getReturnsRecords() {
        LogService_Test.testSetup();
        // insert a log
        insert new AppLog__c(Message__c = 'My error', LogLevel__c = 'Error');

        // create params
        LogUiController.LogParamWrapper params = new LogUiController.LogParamWrapper();
        params.logLevels = new List<String>{
                'Error'
        };
        params.logsPerPage = 10;
        params.cacheBuster = 'anything';

        List<AppLog__c> appLogs = LogUiController.getLogs(params);
        Assert.areEqual(1, appLogs.size());
    }

    @IsTest
    static void getLogCountByLevelReturnCorrectValues() {
        LogService_Test.testSetup();

        // insert a few logs
        insert new List<AppLog__c>{
                new AppLog__c(Message__c = 'My error', LogLevel__c = 'Error'),
                new AppLog__c(Message__c = 'My warning', LogLevel__c = 'Warn')
        };

        // call system under test
        List<AggregateResult> results = LogUiController.getLogCountByLevel();

        // expect 2 results
        Assert.areEqual(2, results.size());

        // expect 1 error log
        Integer logCount = Integer.valueOf(results[0].get('LogCount'));
        String logLevel = String.valueOf(results[0].get('LogLevel__c'));

        Assert.areEqual('Error', logLevel);
        Assert.areEqual(1, logCount);

        // expect 1 warn log
        Integer logCount2 = Integer.valueOf(results[1].get('LogCount'));
        String logLevel2 = String.valueOf(results[1].get('LogLevel__c'));

        Assert.areEqual('Warn', logLevel2);
        Assert.areEqual(1, logCount2);
    }
}