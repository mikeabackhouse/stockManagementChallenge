@isTest
public with sharing class StockCountSelector_Test {

    private static Product2_TestFactory product2Factory = new Product2_TestFactory();
    private static StockCount_TestFactory stockCountFactory = new StockCount_TestFactory();
    private static Map<Id, Stock_Count__c> emtpyStockCountMap = new Map<Id, Stock_Count__c>();

    @isTest
    private static void testEmptyMapIsReturnedWhenNoProductsExist() {
        Map<Id, Stock_Count__c> emtpyStockCountMap = new Map<Id, Stock_Count__c>();
        Set<Id> productIds = new Set<Id>();

        Test.startTest();
        Map<Id, Stock_Count__c> outputputMap = StockCountSelector.getStockCountsByProductIdMap(productIds);
        Test.stopTest();

        System.assertEquals(emtpyStockCountMap, outputputMap, 'Expected Empty map when no product Ids given');

    }

    @isTest
    private static void testEmptyMapIsReturnedWhenNoStockCountsExist() {
        List<Product2> products = product2Factory.createProducts(2);
        Set<Id> productIds = (new Map<Id, Product2>(products)).keySet();
        

        Test.startTest();
        Map<Id, Stock_Count__c> outputputMap = StockCountSelector.getStockCountsByProductIdMap(productIds);
        Test.stopTest();

        System.assertEquals(emtpyStockCountMap, outputputMap, 'Expected Empty map when no product Ids given');

    }

    @isTest
    private static void testStockCountLevelsReturnedWhenStockCountsExist() {
        Integer productsCreated = 300;
        List<Product2> products = product2Factory.createProducts(productsCreated);

        Map<Id, Integer> stockLevels = new Map<Id, Integer>();
        for(Integer i = 0; i < productsCreated; i++) {
            stockLevels.put(products[i].Id, i);
        }

        stockCountFactory.createStockCountsForProducts(stockLevels);
        Set<Id> productIds = (new Map<Id, Product2>(products)).keySet();

        Test.startTest();
        Map<Id, Stock_Count__c> outputputMap = StockCountSelector.getStockCountsByProductIdMap(productIds);
        Test.stopTest();

        System.assertEquals(productsCreated, outputputMap.size(), 'Expected 300 (all created) stock counts to be returned');

    }
}
