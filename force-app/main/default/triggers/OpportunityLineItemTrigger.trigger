trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update) {
    StockManagementHandler stockManagementHandler = new StockManagementHandler();
    if(Trigger.isInsert) {
        stockManagementHandler.handleInsertNewOpportunityProductLine(Trigger.New);
    }

    if(Trigger.isUpdate) {
        stockManagementHandler.handleOpporuntiyProductLineChange(Trigger.OldMap, Trigger.NewMap);
    }
}