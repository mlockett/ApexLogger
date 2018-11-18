# ApexLogger
For adding persistent log functionality to Apex.

This is a very basic class to give the ability to write persistent logs to the database. Because it uses Platform Events, the database does not get rolled back in the case of a failed transaction.

In this first version, there is nothing built in to remove old logs, since the desired duration of logs would be different per org.

In the future, I might add the ability to configure which types of issues are actually logged (e.g. DEBUG, ERROR, etc.).
