trigger CAMPX_EventTrigger on CAMPX__Event__c (before insert, before update) {
    CAMPX_EventHandler.hadleCAMPXEvents();
}