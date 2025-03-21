trigger CAMPX_SponsorTrigger on CAMPX__Sponsor__c (before insert, before update) {
    CAMPX_SponsorHandler.handleCAMPEXSponsors();
}