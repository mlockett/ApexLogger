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
				SELECT COUNT(Id) LogCount, MIN(CreatedDate) FirstCreatedDate, LogLevel__c
				FROM AppLog__c
				GROUP BY LogLevel__c
				ORDER BY LogLevel__c];
		return results;
	}

	@AuraEnabled
	public static List<AggregateResult> getLogCountByLevelDate(String relDateFilter){
		// Valid filters list
		Set<String> validFilters = new Set<String>{
			'TODAY',
			'YESTERDAY',
			'THIS_WEEK', 
			'LAST_WEEK', 
			'THIS_MONTH', 
			'LAST_MONTH', 
			'THIS_YEAR', 
			'LAST_YEAR'
		};

		// Validate input
		if (relDateFilter != null && !validFilters.contains(relDateFilter.toUpperCase())) {
			throw new AuraHandledException('Invalid date filter provided');
		}

		String query = 'SELECT COUNT(Id) LogCount, MIN(CreatedDate) FirstCreatedDate, LogLevel__c '
				+ 'FROM AppLog__c ';
		
		// Add date filter if provided (null means ALL TIME)
		if (validFilters.contains(relDateFilter)) {
			query += ' WHERE CreatedDate = ' + relDateFilter;  // Use the literal directly in SOQL
		}
		// Order by custom order: INFO, DEBUG, WARN, ERROR
		query += ' GROUP BY LogLevel__c '
				+ 'ORDER BY LogLevel__c ';

		return Database.query(query);
	}

	@AuraEnabled
	public static void deleteLogsByLevel(String logLevel, String relDateFilter) {
		system.debug('Deleting logs with log level: ' + logLevel + ' and date filter: ' + relDateFilter);
		// Valid filters list
		Set<String> validFilters = new Set<String>{
			'TODAY',
			'YESTERDAY',
			'THIS_WEEK', 
			'LAST_WEEK', 
			'THIS_MONTH', 
			'LAST_MONTH', 
			'THIS_YEAR', 
			'LAST_YEAR'
		};

		// Validate inputs
		if (String.isBlank(logLevel)) {
			throw new AuraHandledException('Log level must be specified');
		}
		if (relDateFilter != null && !validFilters.contains(relDateFilter.toUpperCase())) {
			throw new AuraHandledException('Invalid date filter provided');
		}

		String query = 'SELECT Id FROM AppLog__c WHERE LogLevel__c = :logLevel';
		
		// Add date filter if provided (null means ALL TIME)
		if (relDateFilter != null) {
			query += ' AND CreatedDate = ' + relDateFilter;
		}
		try {
			List<AppLog__c> logsToDelete = Database.query(query);
			delete logsToDelete;
		} catch (Exception e) {
			throw new AuraHandledException('Error deleting logs: ' + e.getMessage());
		}
	}

	public class LogParamWrapper {
		@AuraEnabled
		public List<String> logLevels { get; set; }
		public String cacheBuster { get; set; }
		@AuraEnabled
		public Integer logsPerPage { get; set; }
	}
}