# Salesforce App Logger
This is a framework adding persistent, configurable, and queryable log functionality to Salesforce.

## Features

### Writes persistent reportable/queryable logs
Log data to Salesforce database for convenient access with reports and SOQL.

### Logs are not rolled back on errors
By using platform events, logs do not get rolled back when unhandled errors occur.

### Logs do not hit the immediate SOQL limits
By using platform events, logs are written in a separate context with its own set of limits.

### Filter sensitive data
Configure data that should be filtered out of logs, e.g. Social Security numbers.

### Optimize what logs are written
Configure which entries are logged by LoggingLevel/User

### Write logs declaratively
You can write Logs from Flows that use the features included in the framework.

### See new logs in real time
A Lightning Web Component sees events in real times.

### Easily view record counts of logs
On the App Log view page, there is section to see current counts of records to help with purging strategies. 

### Offers an interface, static methods and concrete methods for versatile development
Provides both static methods, and a concrete class that implements an interface developers that might want to mock logging in tests, or provide other loggers.

## What's new?

Added "Invocable" properties to enable more advanced logging in Flows.

Added Permission Set for reading logs.

Added App page with LWC so logs can be viewed in realtime.

Added List View page which includes and LWC to view number of records by logging level.

Changed message filters so they are applied before creating event.

## Usage
### Using static methods
`LogService.debug('my debug text', 'className');` 

`LogService.debug('my debug text', 'className', affectedId);` 

`LogService.warn('my warning text', 'className');` 

`LogService.warn('my warning text', 'className', affectedId);` 

`LogService.error('my error text', 'className');`

`LogService.error('my error text', 'className', affectedId);` 

`LogService.error(myException, 'className');` 

`LogService.error(myException, 'className', affectedId);` 

Exception example:

    try{
       Account acct = [SELECT Id FROM Account WHERE Id=:id];
    } catch( Exception ex ){
       LogService.error( ex, 'className');
    }

### Using LogService in a Flow

To log from within a Flow, add an Immediate Action; select the type Apex; for Apex Class, select 
"Write Log"; then under Apex Variables, select the field "messages", then add the desired text.

![Image of flow screen](https://objectfactory.ws/ext_images/logger/logger_flow.png)


### Using Logger instance
    @TestVIsible
    ILogger log = new Logger(); // this allows you to switch to any ILogger for testing
    
    log.debug('my debug text', 'className');  
    log.debug('my debug text', 'className', affectedId);
    log.warn('my warning text', 'className');
    log.warn('my warning text', 'className', affectedId);
    log.error('my error text', 'className');
    log.error('my error text', 'className', affectedId);
    log.error(myException, 'className');
    log.error(myException, 'className', affectedId);

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

The developer should be able to filter out anything that can be identified by a regex on an org-wide basis assuming it is supported in Apex.

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

Using the Custom Metadata type _Log Record Filter_ allows you to setup metadata records
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

  After deploying: 

  * Ensure users that should be able to read the logs are assigned the AppLogReader permission set.
  * Add an assignment on the _App Logs_ application to the profiles of users that should read logs.
  * Ensure that the Profiles for users reading logs can view the following tabs:  App Logs, Log Reader, Log List, Log Tester. These can be set to _Default On_.	


## History
| Date       | Features                                                                                                                                                                   |  
|:-----------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|  
| 2018-11-18 | Initial commit                                                                                                                                                             |  
| 2019-02-18 | Added _Logger_ instance class, and _ILogger_ interface, allowing more versatility in object instantiation, and inheritance.                                                |
| 2020-03-12 | Added Log filtering to help avoid logging sensitive data. Added a short Message field that is a truncated version of the message field to enable better SOQL manipulation. |
| 2020-03-15 | Added the ability to only log records configured in Log Record Filter custom metadata type.                                                                                |
| 2020-03-15 | Added calls for LogService.info(). Added an invocable call to LogService.info().                                                                                           |
| 2020-07-04 | Code clean up. Changed so message filter runs before the event is published to prevent publishing sensitive data.                                                          |
| 2023-05-16 | Fixed a deployment error. Added a permission set, Apex Log Reader, for reading log data. Split ClassMethod field into two field, Class__c and Method__c.                   |
| 2023-05-17 | Changed to DX Source.                   |
| 2023-07-24 | Refactored so most logic is in the Logger instance class                    |

## Future Plans

Add a mechanism to delete old logs systematically thru a scheduled job.

Develop a strategy to allow for multiple loggers (all implementing the ILogger interface).

## Addendum

This does not replace built-in Salesforce Debug Logging. Built-in system debug logs are
a good solution for debugging issues where the reproduction steps are known, and can be generated at will and read within a maximum 24-hours time-frame. Offline debugging uses the standard Salesforce logs.

## Project Creation

To work with the library in a scratch org, here are a few tips.

To create a scratch org:

    sfdx org create scratch -f ./config/project-scratch-def.json -a logger -v <dev hub>

To deploy source to scratch org:

    sfdx project deploy start -o logger

To retrieve changes from scratch org:

    sfdx project retrieve start -o logger

To delete scratch org:

    sfdx org delete scratch -o logger