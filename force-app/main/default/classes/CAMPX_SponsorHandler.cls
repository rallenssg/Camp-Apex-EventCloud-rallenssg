public with sharing class CAMPX_SponsorHandler {
    public static void handleCAMPEXSponsors() {
        if (Trigger.isBefore && Trigger.isInsert)
            setStatusOnCreate();

        if (Trigger.isBefore && Trigger.isUpdate)
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
            CAMPX__Sponsor__c spnsr = validateStatus(newSponsors[i]);

            if (String.isBlank(spnsr.CAMPX__Email__c))
                Trigger.new[i].addError('A sponsor can not be created without an email address');
            
            if (String.isBlank(spnsr.CAMPX__Status__c)) {
                spnsr.CAMPX__Status__c = 'Pending';
                sponsorsToUpdate.add(spnsr);
            }
        }

        safeUpdate(setTierOnUpdate(sponsorsToUpdate));
    }

    private static List<CAMPX__Sponsor__c> setTierOnUpdate(List<CAMPX__Sponsor__c> newSponsors) {

        if (validList(newSponsors))
            return null;

        List<CAMPX__Sponsor__c> sponsorsToUpdate = new List<CAMPX__Sponsor__c>();

        for (CAMPX__Sponsor__c spnsr: newSponsors) {
            if (spnsr.CAMPX__ContributionAmount__c >= 5000)
                spnsr.CAMPX__Tier__c = 'Gold';
            else if (spnsr.CAMPX__ContributionAmount__c >= 1000)
                spnsr.CAMPX__Tier__c = 'Silver';
            else if (spnsr.CAMPX__ContributionAmount__c > 0)
                spnsr.CAMPX__Tier__c = 'Bronze';
            else
                spnsr.CAMPX__Tier__c = null;

            sponsorsToUpdate.add(validateStatus(spnsr));
        }
        return sponsorsToUpdate;
    }

    private static CAMPX__Sponsor__c validateStatus(CAMPX__Sponsor__c spnsr) {
        if (spnsr.CAMPX__Status__c == 'Accepted' && spnsr.CAMPX__Event__c == null)
            Trigger.new[Trigger.new.indexOf(spnsr)].addError('A Sponsor must be associated with an event before being Accepted.');
        return spnsr;
    }

    private static void setTierOnUpdate() {
        List<CAMPX__Sponsor__c> newSponsors = getNewList();

        if (validList(newSponsors))
            return;

        safeUpdate(setTierOnUpdate(newSponsors));
    }

    private static Boolean validList(List<SObject> objs) {
        return (objs == null || objs.isEmpty());
    }
}