trigger CAMPX_SponsorTrigger on CAMPX__Sponsor__c (before insert) {
    CAMPX_SponsorHandler.handleCAMPEXSponsors();
}