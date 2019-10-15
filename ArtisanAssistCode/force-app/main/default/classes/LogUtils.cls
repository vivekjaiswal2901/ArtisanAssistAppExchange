/*
 * Artisan Assistance Utility class with methods to support logging debug messages and exceptions to a custom object
 *
 * @author Richard Clarke (based on prior work by Mohamed Atheek)
 * @date 15/07/2017 
 */
public class LogUtils {
	
	private static List<Apex_Log__c > logs = new List<Apex_Log__c >();
	
	@TestVisible
	private static String limitChars(String s, Integer maxChars) {
		return s != null ? s.substring(0, Math.min(Math.max(maxChars, 0), s.length())) : s;
	}  
	
	//saves the log message in the Apex_Log__c object
	public static void log(String message, Integer lineNumber, Type klass) {
// system.debug('***LogUtils log message: ' + message + ' lineNumber: ' + lineNumber + ', klass=' + klass.toString());
		addLog(message, lineNumber, klass);
		commitLogs();
	}
	
	//saves the log message in the Apex_Log__c object
	public static void log(Exception e) {
		log(e, '');
	}
	
	//saves the log message in the Apex_Log__c object
	public static void log(Exception e, String additionalInfo) {
// system.debug('***LogUtils log Exception e: ' + e + ' (' + additionalInfo + ')');
		addLog(e, additionalInfo);
		commitLogs();
	}
	
	//adds the log message in the log list held in memory
	public static void addLog(Exception e) {
		addLog(e, '');
	}
	
	//adds the log message in the log list held in memory
	public static void addLog(String message, Integer lineNumber, Type klass) {
// system.debug('***LogUtils addLog message: ' + message + ' (' + klass + '-' + lineNumber + ')');
        try {
            SecurityUtils.checkInsert( Apex_Log__c.getSObjectType(), new List<SObjectField> { 
                Apex_Log__c.Message__c, 
                Apex_Log__c.Line_Number__c, 
                Apex_Log__c.Class_Name__c, 
                Apex_Log__c.Log_Type__c
			});
            Apex_Log__c log = new Apex_Log__c();
            log.Message__c = limitChars(message, 32000);
            log.Line_Number__c = lineNumber;
            log.Class_Name__c = limitChars(klass != null ? klass.getName() : null, 255);
            log.Log_Type__c = 'DEBUG';
            logs.add(log);
        } catch ( Exception eCreatable ){
            system.debug('Unable to add log record in LogUtils.addLog - message: ' + message + ' (' + klass + '-' + lineNumber + ') [' + eCreatable.getMessage() + ']');
        }
	}
	
	//adds the log message in the log list held in memory
	public static void addLog(Exception e, String additionalInfo) {
// system.debug('***LogUtils addLog Exception e: ' + e + ' (' + additionalInfo + ')');
		if (e != null) {
            try {
                SecurityUtils.checkInsert( Apex_Log__c.getSObjectType(), new List<SObjectField> { 
                    Apex_Log__c.Message__c, 
                    Apex_Log__c.Additional_Info__c,
                    Apex_Log__c.Line_Number__c, 
                    Apex_Log__c.Exception_Type__c,
                    Apex_Log__c.Stack_Trace__c, 
                    Apex_Log__c.Log_Type__c 
				});
                Apex_Log__c log = new Apex_Log__c();
                log.Message__c = limitChars(e.getMessage(), 32000);
                log.Additional_Info__c = limitChars(additionalInfo, 32000);
                log.Line_Number__c = e.getLineNumber();
                log.Exception_Type__c = limitChars(e.getTypeName(), 255);
                log.Stack_Trace__c = limitChars(e.getStackTraceString(), 32000);
                log.Log_Type__c = 'ERROR';
                logs.add(log);
            } catch ( Exception eCreatable ){
	            system.debug('Unable to add log record in LogUtils.addLog - exception e: ' + e + ' (' + additionalInfo + ') [' + eCreatable.getMessage() + ']');
            }
		}
	}
	
	public static void commitLogs() {
// system.debug('***LogUtils comitLogs size: ' + logs.size());
		if (!logs.isEmpty()) {
            try {
				SecurityUtils.checkObjectIsInsertable(Apex_Log__c.getSObjectType());
                Database.insert(logs, false);
                logs.clear();
            } catch ( Exception eCreatable ){
	            system.debug('Unable to commit log records in LogUtils.commitLogs - logs ' + logs + ') [' + eCreatable.getMessage() + ']');
                logs.clear();
            }
		}
	}
	
	//saves the log list in the Apex_Log__c object in a queuable
	public static void commitLogsAsync() {
// system.debug('***LogUtils comitLogsAsync size: ' + logs.size());
		if (!logs.isEmpty()) {
			//Executing asyncronously to avoid mixed DML exception
			System.enqueueJob(new LogQueueable(logs));
		}
	}
	
	class LogQueueable implements Queueable {
		private List<Apex_Log__c > internalLogs = new List<Apex_Log__c >();	
		
	    public LogQueueable(List<Apex_Log__c > internalLogs) {
	    	this.internalLogs = internalLogs;
	    }    
	    
		public void execute(QueueableContext conext) {
			if (internalLogs != null && internalLogs.size() > 0) {
				SecurityUtils.checkObjectIsInsertable(Apex_Log__c.getSObjectType());
				Database.insert(internalLogs, false);
			}
		}
	}  
}