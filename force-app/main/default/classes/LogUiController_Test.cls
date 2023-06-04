/**
 * Test class for LogController
 * @author mikelockett
 * @date 6/3/23.
 */

@IsTest
public with sharing class LogUiController_Test {
    @IsTest
    static void getReturnsRecords(){
        // insert a log

        // create params
        LogUiController.LogParamWrapper params = new LogUiController.LogParamWrapper();
        params.logLevels = new List<String>{'INFO'};
        params.logsPerPage = 10;
        params.cacheBuster = 'anything';

        List<AppLog__c> appLogs = LogUiController.getLogs(params);
        Assert.areEqual(0, appLogs.size());
    }

}