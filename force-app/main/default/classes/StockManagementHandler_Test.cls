@isTest
public with sharing class StockManagementHandler_Test {
    
    private static Product2_TestFactory product2Factory = new Product2_TestFactory();
    private static StockCount_TestFactory stockCountFactory = new StockCount_TestFactory();
    private static Opportunity_TestFactory oppFactory = new Opportunity_TestFactory();
    private static PriceBookEntry_TestFactory pbeFactory = new PriceBookEntry_TestFactory();
    private static User_TestFactory userFactory = new User_TestFactory();

    private static List<Product2> products;
    

    @TestSetup
    static void makeData(){
        products = product2Factory.createProducts(300);

        Map<Id, Integer> productStockLevels = new Map<Id, Integer>();
        Map<Id, Decimal> productPrices = new Map<Id, Decimal>();

        for(Integer i = 0; i < products.size(); i++) {
            // Stock of Product i (0) is i + 1 (1)
            productStockLevels.put(products[i].Id, i + 1);
            // Price of Product i (0) is £i + 1 (1) 
            productPrices.put(products[i].Id, (Decimal) (i + 1));
        }

        
        stockCountFactory.createStockLevelsForProducts(productStockLevels);
        pbeFactory.createStandardPriceForProducts(productPrices);


    }

    @isTest
    private static void test_StockCount_ReducedByLineItemQuantity_WhenSingleOppLineItemAdded() {
        
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        
        //Product_9 will have 10 stock units
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product_9' LIMIT 1];

        OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(product.Id)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(4)
            .build();
        
        Test.startTest();
        insert oppLine;
        Test.stopTest();

        Stock_Count__c outputStockCount = [
            SELECT Stock_Count__c 
            FROM Stock_Count__c 
            WHERE Product__c = :product.Id
            LIMIT 1
        ];

        System.assertEquals(6, outputStockCount.Stock_Count__c, 'Expected Original (10) - Consumed (4) to show 6 remaining units');
    }

    @isTest
    private static void test_StockCount_ReducedByLineItemQuantity_WhenBulkOppLineItemsAdded() {
        
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, Name FROM Product2]);

        // Set quantity of consumption to be 1 for each
        for(Id productId : products.keyset()) {
            
            OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(productId)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(1)
            .build();

           oppLineItems.add(oppLine);
        }

        
        Test.startTest();
        insert oppLineItems;
        Test.stopTest();

        Map<Id, Stock_Count__c> outputStockCounts = StockCountSelector.getStockCountsByProductIdMap(products.keyset());

        for(Product2 product : products.values()) {
            Integer productIdentifier = Integer.valueOf(product.Name.split('_')[1]);    // Product Integer from name
            Integer expectedRemainingStock = productIdentifier;                         // Original Stock: (Identifier + 1), then -1 for consumption of quantity
            Integer actualRemainingStock = Integer.valueOf((outputStockCounts.get(product.Id)).Stock_Count__c);
            System.assertEquals(expectedRemainingStock, actualRemainingStock, 'Incorrect stock count for product: ' + product.Name);
        }

    }

    @isTest
    private static void test_StockCount_ReducedByLineItemQuantity_WhenBulkOppLineItemsAddedForSameProduct() {
        
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        //Product_9 will have 10 stock units
        Product2 product = [SELECT Id, Name FROM Product2 WHERE Name = 'Product_9' LIMIT 1];

        Set<Id> productIds = new Set<Id>{ product.Id };
        // Set quantity of consumption to be 1 for each
        for(Integer i = 0; i < 3; i++) {
            
            OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(product.Id)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(1)
            .build();

           oppLineItems.add(oppLine);
        }

        
        Test.startTest();
        insert oppLineItems;
        Test.stopTest();

        Map<Id, Stock_Count__c> outputStockCounts = StockCountSelector.getStockCountsByProductIdMap(productIds);

        System.assertEquals(7, (outputStockCounts.get(product.Id)).Stock_Count__c, 'Expected 10 - 3 = 7 Products remaining');

    }

    @isTest 
    private static void test_StockCount_ReducedInSingle_WhenExecutedByStandardUser() {
        User standardUser = userFactory.createSingleSandardUser();

        System.runAs(standardUser) {
            test_StockCount_ReducedByLineItemQuantity_WhenSingleOppLineItemAdded();
        }
    }

    @isTest 
    private static void test_StockCount_ReducedInBulk_WhenExecutedByStandardUser() {
        User standardUser = userFactory.createSingleSandardUser();

        System.runAs(standardUser) {
            test_StockCount_ReducedByLineItemQuantity_WhenBulkOppLineItemsAdded();
        }
    }

    @isTest
    private static void test_StockCount_ReducedByLineItemQuantity_WhenBulkOppLineItemsUpdated() {
        
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        
        //Exclude Product_0 where Stock Count is 1 from test setup
        Map<Id, Product2> products = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE Name != 'Product_0']);

        // Set quantity of consumption to be 0 for each for insert
        for(Id productId : products.keyset()) {
            
            OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(productId)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(1)
            .build();

           oppLineItems.add(oppLine);
        }

        insert oppLineItems;

        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();

        for(OpportunityLineItem lineItem : oppLineItems) {
            oppLineItemsToUpdate.add(
                new OpportunityLineItem(Id = lineItem.Id, Quantity = lineItem.Quantity + 1, TotalPrice = 10)
            );
        }

        
        Test.startTest();
        update oppLineItemsToUpdate;
        Test.stopTest();

        Map<Id, Stock_Count__c> outputStockCounts = StockCountSelector.getStockCountsByProductIdMap(products.keyset());

        for(Product2 product : products.values()) {
            Integer productIdentifier = Integer.valueOf(product.Name.split('_')[1]);    // Product Integer from name
            Integer expectedRemainingStock = productIdentifier - 1;                         // Original Stock: (Identifier + 1), then -2 for consumption of quantity
            Integer actualRemainingStock = Integer.valueOf((outputStockCounts.get(product.Id)).Stock_Count__c);
            System.assertEquals(expectedRemainingStock, actualRemainingStock, 'Incorrect stock count for product: ' + product.Name);
        }

    }


    @isTest
    private static void test_OpportunityLineItem_InsertBlocked_WhenInsufficientStock() {
        
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        String errorMessage = '';
        String expectedErrorMessage = 'Insufficient Stock available for one or more of these products';
        
        //Product_9 will have 10 stock units
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product_9' LIMIT 1];

        OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(product.Id)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(11)
            .build();
        
        Test.startTest();
        try {
            insert oppLine;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        Stock_Count__c outputStockCount = [
            SELECT Stock_Count__c 
            FROM Stock_Count__c 
            WHERE Product__c = :product.Id
            LIMIT 1
        ];

        List<OpportunityLineItem> createdLineItems = [SELECT Id FROM OpportunityLineItem];
        System.debug('outputStockCount.Stock_Count__c: ' + outputStockCount.Stock_Count__c);
        System.debug('errorMessage: ' + errorMessage);
        System.debug('createdLineItems.size(): ' + createdLineItems.size());

        System.assertEquals(10, outputStockCount.Stock_Count__c, 'Expected Stock Count to remain unchanged');
        System.assert(errorMessage.contains(expectedErrorMessage), 'Expected correct error message to be given');
        System.assertEquals(0, createdLineItems.size(), 'Expected no Opp Product Lines to be added');
    }

    @isTest
    private static void test_OpportunityLineItem_UpdateBlocked_WhenInsufficientStock() {
        
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        String errorMessage = '';
        String expectedErrorMessage = 'Insufficient Stock available for one or more of these products';
        
        //Product_9 will have 10 stock units
        Product2 product = [SELECT Id FROM Product2 WHERE Name = 'Product_9' LIMIT 1];

        OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(product.Id)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(1)
            .build();
        
        insert oppLine;

        OpportunityLineItem oppLineToUpdate = new OpportunityLineItem(Id = oppLine.Id, Quantity = 11);
        
        Test.startTest();
        try {
            update oppLineToUpdate;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        Stock_Count__c outputStockCount = [
            SELECT Stock_Count__c 
            FROM Stock_Count__c 
            WHERE Product__c = :product.Id
            LIMIT 1
        ];

        System.assertEquals(9, outputStockCount.Stock_Count__c, 'Expected Stock Count to reflect successful insert, but reject failed update');
        System.assert(errorMessage.contains(expectedErrorMessage), 'Expected correct error message to be given');
    }

    @isTest
    private static void test_OpportunityLineItem_InsertBlocked_WhenNoStockRecordAvaialble() {
        Product2 productWithoutStockCount = product2Factory.createProducts(1)[0];
        Opportunity opp = oppFactory.createOpportunities(1)[0];
        String errorMessage = '';
        String expectedErrorMessage = 'Stock Count tracking records not found';
        

        OpportunityLineItem oppLine =  new OpportunityLineItem_TestFactory.Builder()
            .setRelatedProduct(productWithoutStockCount.Id)
            .setRelatedOpportunity(opp.Id)
            .setQuantity(1)
            .build();
        
        Test.startTest();
        try {
            insert oppLine;
        } catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        List<OpportunityLineItem> createdLineItems = [SELECT Id FROM OpportunityLineItem];

        System.assert(errorMessage.contains(expectedErrorMessage), 'Expected correct error message to be given');
        System.assertEquals(0, createdLineItems.size(), 'Expected no Opp Product Lines to be added');
    }
}
