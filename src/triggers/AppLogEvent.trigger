trigger AppLogEvent on AppLogEvent__e (after insert) {
	LogService.insertAppLogs(Trigger.new);
}