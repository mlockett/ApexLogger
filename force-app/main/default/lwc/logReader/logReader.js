/**
 * author mikelockett
 * date 2020-15-03
 */
import { LightningElement, track } from 'lwc';
import { subscribe, unsubscribe, onError, setDebugFlag, isEmpEnabled } from 'lightning/empApi';
import getLogs from '@salesforce/apex/LogUiController.getLogs';

const actions = [
   { label: 'Show details', name: 'show_details' },
   //{ label: 'Delete', name: 'delete' }
];

const defaultColumns = [
   { label: "Log Id", fieldName: "Id", initialWidth: 170, cellAttributes: { class: "idCell" } },
   {
      label: 'Date', fieldName: 'CreatedDate', type: 'date', typeAttributes: {
         year: "numeric",
         month: "short",
         day: "2-digit",
         hour: "2-digit",
         minute: "2-digit",
         second: "2-digit"
      },
      initialWidth: 200,
      sortable: true
   },
   { label: 'Short Message', fieldName: 'ShortMessage__c' },
   { label: 'Location', fieldName: 'Class__c' },
   { label: 'Record Id', fieldName: 'AffectedId__c', initialWidth: 170 },
   { label: 'Level', fieldName: 'LogLevel__c', initialWidth: 100 },
   { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'left' } }
];

export default class LogReader extends LightningElement {
   @track channelName = '/event/AppLogEvent__e';
   @track isSubscribeDisabled = false;
   @track isUnsubscribeDisabled = !this.isSubscribeDisabled;
   @track columns = defaultColumns;
   @track logs;

   @track logLevelsSelected = {
      info:false,
      debug:false,
      warn: false,
      error: true
   }

   get hasLogs() {
      return !!this.logs.length;
   }

   logsError;
   logsErrorJson;
   paramsForGetLog = {
      logLevels: ["INFO", "DEBUG"],
      cacheBuster: "1",
      logsPerPage: 10
   };
   paramsForGetLogJson;

   loadLogs() {
      this.paramsForGetLog.cacheBuster = (new Date()).getTime();
      console.log("Called loadLogs: " + JSON.stringify(this.paramsForGetLog));
      getLogs({ params: this.paramsForGetLog })
         .then(result => {
            this.logs = result;
            this.logError = undefined;
            this.logErrorJson = undefined;
            console.log('log success: ' + this.logs);
         })
         .catch(error => {
            this.logsError = error;
            this.logsErrorJson = JSON.stringify(error);
            this.paramsForGetLogJson = JSON.stringify(this.paramsForGetLog);
         });
   }

   subscription = {};

   // Tracks changes to channelName text field
   handleChannelName(event) {
      this.channelName = event.target.value;
   }

   handleButtonClick(event){
      let logLevel = event.target.getAttribute("data-log-level");
      this.logLevelsSelected[logLevel] = !this.logLevelsSelected[logLevel];
      console.log(JSON.stringify(this.logLevelsSelected));
      this.handleButtonChange();
   }

   handleButtonChange() {
      let logLevelData = [];
      for (const [logLevel, isSelected] of Object.entries(this.logLevelsSelected)) {
         if(isSelected){
            logLevelData.push(logLevel.toUpperCase())
         }
      }

      this.paramsForGetLog.logLevels = logLevelData;
      this.loadLogs();
   }


   @track
   logsPerPage = "10";
   logsPerPageOptions = [
      { label: '10', value: "10" },
      { label: '20', value: "20" },
      { label: '50', value: "50" }
   ];

   handleRowAction(event) {
      const action = event.detail.action;
      const row = event.detail.row;
      switch (action.name) {
         case 'show_details':
            console.log('Showing Details: ' + JSON.stringify(row));
            break;
         case 'delete':
            console.log('Showing Delete: ' + JSON.stringify(row));
            break;
      }
   }

   handleLogsPerPageChange(event) {
      this.logsPerPage = event.detail.value;
      this.paramsForGetLog.logsPerPage = this.logsPerPage;
      this.loadLogs();
   }

   // Handles subscribe button click
   handleSubscribe() {
      // Callback invoked whenever a new event message is received
      const messageCallback = (response) => {
         console.log('New message received : ', JSON.stringify(response));
         this.payload = JSON.stringify(response);
         console.log('this.payload: ' + this.payload);
         // Response contains the payload of the new message received
         this.loadLogs();
      };

      // Invoke subscribe method of empApi. Pass reference to messageCallback
      subscribe(this.channelName, -1, messageCallback).then(response => {
         // Response contains the subscription information on successful subscribe call
         console.log('Successfully subscribed to : ', JSON.stringify(response.channel));
         this.subscription = response;
         this.toggleSubscribeButton(true);
      });
   }

   // Handles unsubscribe button click
   handleUnsubscribe() {
      this.toggleSubscribeButton(false);

      // Invoke unsubscribe method of empApi
      unsubscribe(this.subscription, response => {
         console.log('unsubscribe() response: ', JSON.stringify(response));
         // Response is true for successful unsubscribe
      });
   }

   toggleSubscribeButton(enableSubscribe) {
      this.isSubscribeDisabled = enableSubscribe;
      this.isUnsubscribeDisabled = !enableSubscribe;
   }

   registerErrorListener() {
      // Invoke onError empApi method
      onError(error => {
         console.log('Received error from server: ', JSON.stringify(error));
         // Error contains the server-side error
      });
   }
}