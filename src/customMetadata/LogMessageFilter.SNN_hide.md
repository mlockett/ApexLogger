<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>SNN hide</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>RegexToFind__c</field>
        <value xsi:type="xsd:string">\d{3}-\d{2}-\d{4}</value>
    </values>
    <values>
        <field>RegexToReplaceWith__c</field>
        <value xsi:type="xsd:string">&lt;&lt;SSN hidden&gt;&gt;</value>
    </values>
</CustomMetadata>
