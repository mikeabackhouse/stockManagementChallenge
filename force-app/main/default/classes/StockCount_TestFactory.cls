@isTest
public with sharing class StockCount_TestFactory {

    //Test Factory Controls
    public Boolean insertOnCreate = true;


    public List<Stock_Count__c> createStockCountsForProducts(Map<Id, Integer> productIdToStockQuantity) {
        List<Stock_Count__c> stockCounts = new List<Stock_Count__c>();
        for(Id product2Id : productIdToStockQuantity.keySet()) {
            Stock_Count__c sc = new StockCount_TestFactory.Builder()
                .setRelatedProduct(product2Id)
                .setStockCount(productIdToStockQuantity.get(product2Id))
                .build();

            stockCounts.add(sc);
        }

        if(stockCounts.size() > 0 && this.insertOnCreate) {
            insert stockCounts;
        }

        return stockCounts;
    }   

    private static Stock_Count__c buildStockCount(Builder builder) {
        Stock_Count__c sc = new Stock_Count__c();
        sc.Product__c = builder.product2Id;
        sc.Stock_Count__c = builder.stockCount;
        return sc;
    }
    public class Builder {
        //Mandatory
        

        //Optional
        private Id product2Id;
        private Integer stockCount;

        public Builder() {}

        public Builder setRelatedProduct(Id productId) {
            this.product2Id = productId;
            return this;
        }

        public Builder setStockCount(Integer stockCount) {
            this.stockCount = stockCount;
            return this;
        }

        //Call at end to construct 
        public Stock_Count__c build() {
            return StockCount_TestFactory.buildStockCount(this);
        }

        
    }

}
