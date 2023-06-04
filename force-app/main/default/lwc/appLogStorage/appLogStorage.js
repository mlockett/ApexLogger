/**
 * @author mikelockett
 * @date 6/3/23.
 */

import { LightningElement } from "lwc";
import getLogCountByLevel from '@salesforce/apex/LogUiController.getLogCountByLevel';

export default class AppLogStorage extends LightningElement {
  data;
  error;

  connectedCallback() {
    this.getData();
  }

  getData(){
    getLogCountByLevel()
      .then(data => {
        this.data = data;
        console.log(JSON.stringify(data));
      })
      .catch(e => this.error = e);
  }
}