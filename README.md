# ApexLogger
For adding persistent log functionality to Apex.

This is a very basic class to give the ability to write persistent logs to the 
database. Because it uses Platform Events, the database transaction for writing a 
log does not get rolled back in the case of a failed transaction.

## Features

Writes log data to Salesforce database for convenient access with reports and SOQL

Logs are written in a manner so DML is not added to the current transaction, and there is no rollback when errors occur

Provides both static methods, and a concrete class that implements an interface 
developers that might want to mock logging in tests, or provide other loggers.

Configure data that should be filtered out of logs, e.g. Social Security numbers.

Configure which entries are logged by LoggingLevel/User

Log from ProcessBuilders

## What's new?
Added log record filtering by LoggingLevel/User

Added the ability to filter the log message using regular expressions, read from custom metadata, to help avoid logging sensitive 
data.

Added a Short Message field to the AppLog object to enable better manipulation with SOQL. The new field simply contains
the first 255 characters of the Message.

Include an "Invocable" method enabling log writing from ProcessBuilders

## Usage
### Using static methods
`LogService.debug('my dedug text', 'class/method');` 
`LogService.debug('my dedug text', 'class/method', affectedId);` 
`LogService.warn('my waring text', 'class/method');` 
`LogService.warn('my waring text', 'class/method', affectedId);` 
`LogService.error('my error text', 'class/method');`
`LogService.error('my error text', 'class/method', affectedId);` 
`LogService.error(myException, 'class/method');` 
`LogService.error(myException, 'class/method', affectedId);` 

Exception example:

    try{
       Account acct = [SELECT Id FROM Account WHERE Id=:id];
    } catch( Exception ex ){
       LogService.error( ex, 'class/method');
    }

### Using LogService in a Process Builder

To log from within a Process Builder, add an Immediate Action; select the type Apex; for Apex Class, select 
"Write Log"; then under Apex Variables, select the field "messages", then add the desired text. 
### Using Logger instance
    @TestVIsible
    ILogger log = new Logger(); // this allows you to switch to any ILogger for testing
    
    log.debug('my dedug text', 'class/method');  
    log.debug('my dedug text', 'class/method', affectedId);
    log.warn('my waring text', 'class/method');
    log.warn('my waring text', 'class/method', affectedId);
    log.error('my error text', 'class/method');
    log.error('my error text', 'class/method', affectedId);
    log.error(myException, 'class/method');
    log.error(myException, 'class/method', affectedId);

### Filtering Data
Manage records in the custom metadata type, _Log Filter_. Supply a value for _Regex To Find_ and a value 
for _Regex To Replace With_. 

#### For a less simple case :

1. Set _Regex To Find_ to "\\d{3}-\\d{2}-\\d{4}". This looks for a basic US Social Security number.
1. Set _Regex To Replace With_ to "xxx-xx-xxxx". 

This will replace the SSNs found above with the static text "xxx-xx-xxxx"
in all log Messages and Short Messages.

#### For a more advanced case:
1. Set _Regex To Find_ to "\\d{3}-\\d{2}-(\\d{4})". This looks for a basic US Social Security number.
1. Set _Regex To Replace With_ to "xxx-xx-$1". $1 signifies the first capture group (the _Regex To Find_ part in parens).

By using capture groups, this will obfuscate all but the last four digits of the SSNs found above
in all log Messages and Short Messages. E.g. 123-45-6789 becomes xxx-xx-6789

The developer should be able to filter out anything that can be identified by a regex on an org-wide basis assuming it's supported in Apex.

#### To verify your regex entries:

You can easily test the end result in an anonymous Apex window by calling:

    System.debug(LogService.filterString('My string'));
    
Replace 'My string' with whatever makes sense for your test.


For developers, to test before creating the Log Filter record, you might use something like this:

     String sourceText = 'Hide the 123-12-1234 SSN.';
     String regexToFind = '(\\d{3})-(\\d{2})-(\\d{4})';
     String regexToReplaceWith = 'xxx-xx-$5';
     String result = sourceText.replaceAll(regexToFind, regexToReplaceWith);
     System.debug(result);

#### Important note:

In code, we use "\\d" to indicate a decimal. The first slash is unescaping the second slash for Apex string literals.

**In the custom metadata, we should enter "\d" since it is not an Apex string literal.**

#### Additional notes:
 
Adding large numbers of filters can slow things down since each filter must be processed synchronously.
 
Though it's not expected, an obscure filter could break existing unit tests since Apex test "see" custom metadata, 
even without setting SeeAllData = true.

### Filtering which records are logged

Using the Custom Metadata type Log Record Filtering allows you to setup metadata records
that determine what records should be logged per user. For instance, you could only log errors and 
warnings in production, but log Info in sandboxes. You could also communicate to log DEBUG records
for a single user (like a developer).

This is intended to help reduce "noise" in the logs and can also be used
to im prove performance and/or reduce Events fired should limits be an issue.
 
Use an asterisk (*) in the Active Log User field to indicate all
users.

To indicate what levels should be logged, set the Log Levels CSV field. E.g. 'DEBUG,WARN,ERROR'

#### NOTE: 
For the LoggingLevels, all fields should be capitalized. We could adapt the code, but
it is more efficient to do it only when the metadata record is created.

IF  you  install this project, you will have a LogRecordFilter record that sets up * (all users)
to log INFO,DEBUG,WARN,ERROR. It might be desirable to reduce this for production.
## Installation

* You can clone the repo, then use _ant_ or your favorite IDE to deploy.  
* You might consider creating an unlocked package and deploying it.  
* Or use this handy link: 

  [![Deploy](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png)](https://githubsfdeploy.herokuapp.com/app/githubdeploy/mlockett/ApexLogger)

## History
| Date       |Features |  
| :-------- | :--- |  
| 2018-11-18 | Initial commit  |  
| 2019-02-18 | Added _Logger_ instance class, and _ILogger_ interface, allowing more versatility in object instantiation, and inheritance. |
| 2020-03-12 | Added Log filtering to help avoid logging sensitive data. Added a short Message field that is a truncated version of the message field to enable better SOQL manipulation. |
| 2020-03-15 | Added the ability to only log records configured in Log Record Filter custom metadata type. |
| 2020-03-15 | Added calls for LogService.info(). Added an invocable call to LogService.info(). |

## Future Plans

Add a mechanism to delete old logs systematically thru a scheduled job.

Build a friendly Lightning-based log viewer

## Addendum

This does not replace built-in Salesforce Debug Logging. Built-in system debug logs are
preferable for debugging issues where the reproduction steps are known, and can be generated 
at will and read within a maximum 24-hours time-frame.

