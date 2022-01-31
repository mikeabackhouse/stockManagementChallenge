public with sharing class StockCountSelector {
    
    public static Map<Id, Stock_Count__c> getStockCountsByProductIdMap(Set<Id> productIds) {
        // ASSUMPTION 2: Maximum of 1 'Active' Stock Count.
        // Simplifies output to be a flat Map<Id, Stock_Count__c>, instead of Map<Id, List<Stock_Count__c>>
        List<Stock_Count__c> stockCounts = [SELECT Id, Stock_Count__c, Product__c FROM Stock_Count__c WHERE Product__c IN :productIds];
        Map<Id, Stock_Count__c> stockCountByProductId = new Map<Id, Stock_Count__c>();
        for(Stock_Count__c stockCount : stockCounts) {
            stockCountByProductId.put(stockCount.Product__c, stockCount);
        }

        return stockCountByProductId;
    }
}
