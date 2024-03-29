/**
 * get number of App Log records and the oldest creation date per log level
 * @author mikelockett
 * @date 6/3/23.
 */

import { LightningElement } from "lwc";
import getLogCountByLevel from "@salesforce/apex/LogUiController.getLogCountByLevel";

export default class AppLogStorage extends LightningElement {
  data;
  error;

  connectedCallback() {
    this.getData();
  }

  /**
   * retrieves data
   */
  getData() {
    getLogCountByLevel()
      .then(data => {
        this.data = data;
      })
      .catch(e => {
        this.error = e;
      });
  }
}