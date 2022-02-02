@isTest
public with sharing class Opportunity_TestFactory {
    //Test Factory Controls
    public Boolean insertOnCreate = true;

    public List<Opportunity> createOpportunities(Integer numberOfOpportunities) {
        List<Opportunity> opps = new List<Opportunity>();
        for(Integer i = 0; i < numberOfOpportunities; i++) {
            Opportunity opp = new Opportunity_TestFactory.Builder('Opp_' + i)
                .build();
            
            opps.add(opp);
        }

        if(opps.size() > 0 && this.insertOnCreate) {
            insert opps;
        }

        return opps;
    }

    private static Opportunity buildOpportunity(Builder builder) {
        Opportunity opp = new Opportunity();
        opp.Name = builder.name;
        opp.StageName = builder.stageName;
        opp.CloseDate = builder.closeDate;
        opp.Pricebook2Id = builder.priceBookId;
        return opp;
    }

    public class Builder {
        //Mandatory
        private Id priceBookId;
        private String name; 
        private String stageName; 
        private Date closeDate;

        //Optional
        

        //Constructor builds mandatory/default params
        public Builder(String opportunityName) {
            this.name = opportunityName;
            this.stageName = 'Prospecting';
            this.closeDate = System.today() + 7;
            this.priceBookId = Test.getStandardPricebookId();
        }

        //Call at end to construct 
        public Opportunity build() {
            return Opportunity_TestFactory.buildOpportunity(this);
        }

    }
}
