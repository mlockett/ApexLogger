/**
 * @description 
 *
 * @author mikelockett 
 * @date 2020-03-16
 */

public without sharing class LogUiController {
	@AuraEnabled
	public static List<AppLog__c> getLogs(LogParamWrapper params) {
		System.debug(params);
		String query = 'SELECT AffectedId__c, Class__c, CreatedDate, '
				+ 'Id, LogLevel__c, Message__c, Name, ShortMessage__c '
				+ 'FROM AppLog__c '
				+ 'WHERE LogLevel__c IN :params.logLevels '
				+ ' ORDER BY CreatedDate DESC '
				+ ' LIMIT = ' + params.logsPerPage;
		List<AppLog__c> retVal = [
				SELECT AffectedId__c,
						Class__c,
						CreatedDate,
						Id,
						LogLevel__c,
						Message__c,
						Name,
						ShortMessage__c
				FROM AppLog__c
				WHERE LogLevel__c IN :params.logLevels
				ORDER BY CreatedDate DESC
				LIMIT :params.logsPerPage
		];
		return retVal;
	}

	@AuraEnabled
	public static List<AggregateResult> getLogCountByLevel(){
		List<AggregateResult> results = [
				SELECT COUNT(Id), MIN(CreatedDate), LogLevel__c
				FROM AppLog__c
				GROUP BY LogLevel__c
				ORDER BY LogLevel__c];
		return results;
	}

	public class LogParamWrapper {
		@AuraEnabled
		public List<String> logLevels { get; set; }
		public String cacheBuster { get; set; }
		@AuraEnabled
		public Integer logsPerPage { get; set; }
	}
}