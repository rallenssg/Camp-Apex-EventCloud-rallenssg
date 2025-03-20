public with sharing class CAMPX_EventHandler {

    public static void hadleCAMPXEvents() {
        if (Trigger.isBefore && Trigger.isInsert)
            setStatusOnCreate();
        
        if (Trigger.isBefore && Trigger.isUpdate)
            setStatusChangeDate();
    }

    private static List<CAMPX__Event__c> getNewList() {
        return (List<CAMPX__Event__c>) Trigger.new;
    }

    private static List<CAMPX__Event__c> getOldList() {
        return (List<CAMPX__Event__c>) Trigger.old;
    }

    private static void safeUpdate(List<CAMPX__Event__c> evts) {
        try {
            Database.update(evts, System.AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e);
        }
    }

    private static void setStatusOnCreate() {
        List<CAMPX__Event__c> evts = getNewList();

        if (evts == null || evts.isEmpty())
            return;

        List<CAMPX__Event__c> evtsToUpdate = new List<CAMPX__Event__c>();

        for (CAMPX__Event__c evt: evts) {
            evt.CAMPX__Status__c = 'Planning';
            evtsToUpdate.add(evt);
        }
        safeUpdate(setStatusChangeDate(evtsToUpdate));
    }

    private static List<CAMPX__Event__c> setStatusChangeDate(List<CAMPX__Event__c> evts) {
        List<CAMPX__Event__c> resList = new List<CAMPX__Event__c>();

        if (evts != null && !evts.isEmpty()) {
            for (CAMPX__Event__c evt: evts) {
                evt.CAMPX__StatusChangeDate__c = Datetime.now();
                resList.add(evt);
            }
        }
        return resList;
    }

    private static void setStatusChangeDate() {
        List<CAMPX__Event__c> newEvts = getNewList();
        List<CAMPX__Event__c> oldEvts = getOldList();

        if (newEvts == null || newEvts.isEmpty())
            return;

        List<CAMPX__Event__c> evtsToUpdate = new List<CAMPX__Event__c>();

        for (Integer i=0; i<newEvts.size(); i++) {
            CAMPX__Event__c evt = newEvts[i];
            if (evt.CAMPX__Status__c == oldEvts[i].CAMPX__Status__c)
                continue;
            
            evt.CAMPX__StatusChangeDate__c = Datetime.now();
            evtsToUpdate.add(evt);
        }

        safeUpdate(evtsToUpdate);
    }
}