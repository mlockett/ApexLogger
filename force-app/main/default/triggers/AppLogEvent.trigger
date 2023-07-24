trigger AppLogEvent on AppLogEvent__e (after insert) {
	new Logger().insertAppLogs(Trigger.new);
}