@isTest
public with sharing class PriceBookEntry_TestFactory {
    //Test Factory Controls
    public Boolean insertOnCreate = true;

    public List<PricebookEntry> createStandardPriceForProducts(Map<Id, Decimal> productIdToStandardPrice) {
        List<PricebookEntry> pbes  = new List<PricebookEntry>();
        for(Id productId : productIdToStandardPrice.keySet()) {
            PricebookEntry pbe = new PriceBookEntry_TestFactory.Builder()
                .setRelatedProduct(productId)
                .setPrice(productIdToStandardPrice.get(productId))
                .build();
            
            pbes.add(pbe);
        }

        if(pbes.size() > 0 && this.insertOnCreate) {
            insert pbes;
        }

        return pbes;
        
    }

    private static PricebookEntry buildPriceBookEntry(Builder builder) {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id = builder.productId;
        pbe.UnitPrice = builder.price;
        pbe.IsActive = builder.isActive;
        pbe.Pricebook2Id = builder.priceBookId;
        return pbe;
    }

    public class Builder {
        //Mandatory
        private Id priceBookId; 
        private Id productId;
        private Decimal price;
        private Boolean isActive;


        //Constructor requires mandatory params
        public Builder() {
            this.isActive = true;
            this.priceBookId = Test.getStandardPricebookId();
        }

        //Call at end to construct 
        public PricebookEntry build() {
            return PriceBookEntry_TestFactory.buildPriceBookEntry(this);
        }

        
        public Builder setPrice(Decimal price) {
            this.price = price;
            return this;
        }

        public Builder setRelatedProduct(Id productId) {
            this.productId = productId;
            return this;
        }
    }
}
