public with sharing class StockManagementHandler {

    private static Set<Id> relatedProductIds = new Set<Id>();
    //private static Map<Id, Stock_Change__c> stockChangeById = new Map<Id, Stock_Change__c>();

    public void handleInsertNewOpportunityProductLine(List<OpportunityLineItem> newOppLineItems) {
        Map<String, OpportunityLineItem> emptyMap = new Map<String, OpportunityLineItem>();
        Map<String, OpportunityLineItem> newOppLinesWithPreInsertIdentifier = new Map<String, OpportunityLineItem>();

        for(Integer i = 0; i<newOppLinesWithPreInsertIdentifier.size(); i++) {
            newOppLinesWithPreInsertIdentifier.put('OpportunityLineItem' + i, newOppLineItems[i]);
        }

        handleOpporuntiyProductLineChange(emptyMap, newOppLinesWithPreInsertIdentifier);
    }

    public void handleOpporuntiyProductLineChange(Map<String, OpportunityLineItem> oldOppLineItems, Map<String, OpportunityLineItem> newOppLineItems) {
        
        Map<Id, Stock_Count__c> availableStockByProductId = StockCountSelector.getStockCountsByProductIdMap(relatedProductIds);
/*
        // Handles scenario of changing product in product line eg via Bulk Upload
        for(OpportunityLineItem oppLineItem : oldOppLineItems.values()) {
            if(oppLineItem.Product__c != null) {
                relatedProductIds.add(oppLineItem.Product__c);
            }
        }
*/
        for(OpportunityLineItem oppLineItem : newOppLineItems.values()) {

            Stock_Count__c currentStockCount = availableStockByProductId.get(oppLineItem.Product2Id);
            currentStockCount.Stock_Count__c = currentStockCount.Stock_Count__c - oppLineItem.Quantity;
            availableStockByProductId.put(oppLineItem.Product2Id, currentStockCount);

        }

        try {
            update availableStockByProductId.values();
        } catch (Exception e) {
            System.debug('Error updating stock counts');
            System.debug(e.getMessage());
            throw e;
        }

    }
}
