// appLogWriter.js
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import debug from '@salesforce/apex/LogService.debug';
import info from '@salesforce/apex/LogService.info';
import warn from '@salesforce/apex/LogService.warn';

export default class AppLogWriter extends LightningElement {
    @track logLevel = 'INFO';
    @track message = '';

    get logLevelOptions() {
        return [
            { label: 'DEBUG', value: 'DEBUG', iconName: 'utility:bug' },
            { label: 'INFO', value: 'INFO', iconName: 'utility:info' },
            { label: 'WARN', value: 'WARN', iconName: 'utility:warning' }
        ];
    }

    get isSubmitDisabled() {
        return !this.message || this.message.trim().length === 0;
    }

    handleLogLevelChange(event) {
        this.logLevel = event.target.value;
    }

    handleMessageChange(event) {
        this.message = event.target.value;
    }

    async handleSubmit() {
        try {
            const className = 'AppLogWriter.component';
            
            switch(this.logLevel) {
                case 'DEBUG':
                    await debug({ message: this.message, className: className });
                    break;
                case 'INFO':
                    await info({ message: this.message, className: className });
                    break;
                case 'WARN':
                    await warn({ message: this.message, className: className });
                    break;
            }
            

            this.showToast('Success', 'Log entry created successfully', 'success');
            this.clearForm();
        } catch (error) {
            this.showToast('Error', 'Error creating log entry: ' + error.message, 'error');
        }
    }

    clearForm() {
        this.message = '';
        this.template.querySelector('textarea').value = '';
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}