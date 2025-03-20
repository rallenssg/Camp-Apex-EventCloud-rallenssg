public with sharing class CAMPX_SponsorHandler {
    public static void handleCAMPEXSponsors() {
        if (Trigger.isBefore && Trigger.isInsert)
            setStatusOnCreate();
    }

    private static List<CAMPX__Sponsor__c> getOldList() {
        return (List<CAMPX__Sponsor__c>) Trigger.old;
    }

    private static List<CAMPX__Sponsor__c> getNewList() {
        return (List<CAMPX__Sponsor__c>) Trigger.new;
    }

    private static void safeUpdate(List<CAMPX__Sponsor__c> sponsors) {
        try {
            Database.update(sponsors, System.AccessLevel.SYSTEM_MODE);
        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e);
        }
    }

    private static void setStatusOnCreate() {
        List<CAMPX__Sponsor__c> newSponsors = getNewList();

        if (validList(newSponsors))
            return;
        
        List<CAMPX__Sponsor__c> sponsorsToUpdate = new List<CAMPX__Sponsor__c>();

        for (Integer i=0; i<newSponsors.size(); i++) {
            CAMPX__Sponsor__c spnsr = newSponsors[i];

            if (String.isBlank(spnsr.CAMPX__Email__c))
                Trigger.new[i].addError('A sponsor can not be created without an email address');
            
            if (String.isBlank(spnsr.CAMPX__Status__c)) {
                spnsr.CAMPX__Status__c = 'Pending';
                sponsorsToUpdate.add(spnsr);
            }
        }

        safeUpdate(sponsorsToUpdate);
    }

    private static Boolean validList(List<SObject> objs) {
        return (objs == null || objs.isEmpty());
    }
}