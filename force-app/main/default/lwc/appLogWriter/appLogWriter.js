// appLogWriter.js
import { LightningElement, track } from 'lwc';
import debug from '@salesforce/apex/LogService.debug';
import info from '@salesforce/apex/LogService.info';
import warn from '@salesforce/apex/LogService.warn';

export default class AppLogWriter extends LightningElement {
    @track logLevel = 'INFO';
    @track message = '';
    @track showToast = false;
    @track toastMessage = '';
    @track toastType = '';

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

    get toastClass() {
        return `slds-notify slds-notify_toast ${this.toastType === 'success' ? 'slds-theme_success' : 'slds-theme_error'}`;
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
            
            this.showSuccess('Log entry created successfully');
            this.clearForm();
        } catch (error) {
            console.error('Error:', error);
            this.showError('Error creating log entry: ' + error.message);
        }
    }

    clearForm() {
        this.message = '';
        this.template.querySelector('textarea').value = '';
    }

    showSuccess(message) {
        this.showToast = true;
        this.toastMessage = message;
        this.toastType = 'success';
        this.hideToastAfterDelay();
    }

    showError(message) {
        this.showToast = true;
        this.toastMessage = message;
        this.toastType = 'error';
        this.hideToastAfterDelay();
    }

    hideToastAfterDelay() {
        setTimeout(() => {
            this.showToast = false;
        }, 3000);
    }
}