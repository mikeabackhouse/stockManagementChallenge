public with sharing class StockManagementHandler  {

    private Set<Id> relatedProductIds = new Set<Id>();
    private static final String INSUFFICIENT_STOCK_VALIDATION_IDENTIFIER = 'INSUFFICIENT_STOCK';

    public class StockCountNotFoundException extends Exception {}

    public void handleOpporuntiyProductLineChange(Map<Id, OpportunityLineItem> oldOppLineItemsMap, List<OpportunityLineItem> newOppLineItems) {
 
        setProductIds(oldOppLineItemsMap, newOppLineItems);

        Map<Id, Stock_Count__c> availableStockCountByProductId = StockCountSelector.getStockCountsByProductIdMap(relatedProductIds);

        // Reduce stock count by newly consumed total
        for(OpportunityLineItem oppLineItem : newOppLineItems) {

            Stock_Count__c relatedStockCount = availableStockCountByProductId.get(oppLineItem.Product2Id);
            if(relatedStockCount == null) {
                throw new StockCountNotFoundException('Stock Count tracking records not found');
            } else {
                relatedStockCount.Stock_Count__c = relatedStockCount.Stock_Count__c - oppLineItem.Quantity;
                availableStockCountByProductId.put(oppLineItem.Product2Id, relatedStockCount);
            }

        }

        // Increase stock count by previously reserved amount 
        // (applies delta including scenarios of changing products)
        // Assumption: No use case (yet) for removing one Stock Count record once created. 
        if(oldOppLineItemsMap != null) {
            for(OpportunityLineItem oppLineItem : oldOppLineItemsMap.values()) {

                Stock_Count__c relatedStockCount = availableStockCountByProductId.get(oppLineItem.Product2Id);
                relatedStockCount.Stock_Count__c = relatedStockCount.Stock_Count__c + oppLineItem.Quantity;
                availableStockCountByProductId.put(oppLineItem.Product2Id, relatedStockCount);
    
            }
        }
        

        try {
            update availableStockCountByProductId.values();
        } catch (Exception e) {
            String errorMessage = e.getMessage();
            if(errorMessage.contains(INSUFFICIENT_STOCK_VALIDATION_IDENTIFIER)) {
                errorMessage = '\nInsufficient Stock available for one or more of these products:';
                for(Stock_Count__c toBeStockCount : availableStockCountByProductId.values()) {
                    if(toBeStockCount.Stock_Count__c < 0) {
                        errorMessage += '\n' + toBeStockCount.Product__r.Name + ': ' + (-toBeStockCount.Stock_Count__c) + ' additional units are required, ';
                    }
                    errorMessage.removeEnd(', ');
                }

                for(OpportunityLineItem lineItem : newOppLineItems) {
                    lineItem.addError(errorMessage);
                }
                
            } else { throw e; }
        }

    }

    private void setProductIds(Map<Id, OpportunityLineItem> oldOppLineItemsMap, List<OpportunityLineItem> newOppLineItems) {
        for(OpportunityLineItem oppLineItem : newOppLineItems) {
            if(oppLineItem.Product2Id != null) {
                this.relatedProductIds.add(oppLineItem.Product2Id);
            }
        }

        // Handles scenario of Updating/changing product2id on 
        if(oldOppLineItemsMap != null) {
            for(OpportunityLineItem oppLineItem : oldOppLineItemsMap.values()) {
                if(oppLineItem.Product2Id != null) {
                    this.relatedProductIds.add(oppLineItem.Product2Id);
                }
            }
        }
    }

    
}