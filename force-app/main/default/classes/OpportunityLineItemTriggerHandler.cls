public with sharing class OpportunityLineItemTriggerHandler extends TriggerHandler {
    
    private StockManagementHandler stockManagementHandler;

    public OpportunityLineItemTriggerHandler() {
        this.stockManagementHandler = new StockManagementHandler();
    }
    
    
    public override void beforeInsert() {
        stockManagementHandler.handleOpporuntiyProductLineChange( null,  (List<OpportunityLineItem>) Trigger.New);
    }

    public override void beforeUpdate() {
        stockManagementHandler.handleOpporuntiyProductLineChange( (Map<Id, OpportunityLineItem>) Trigger.OldMap, (List<OpportunityLineItem>) Trigger.New);
    }

}

