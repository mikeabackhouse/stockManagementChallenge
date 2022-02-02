@isTest
public with sharing class Product2_TestFactory {

    //Test Factory Controls
    public Boolean insertOnCreate = true;

    public List<Product2> createProducts(Integer numberOfProducts) {
        List<Product2> products = new List<Product2>();
        for(Integer i = 0; i < numberOfProducts; i++) {
            Product2 product = new Product2_TestFactory.Builder('Product_' + i)
                .setProductCode('CODE_' + i)
                .build();

            products.add(product);
            
        }

        if(products.size() > 0 && this.insertOnCreate ) {
            insert products;
        }

        return products;
    }


    private static Product2 buildProduct(Builder builder) {
        Product2 product = new Product2();
        product.Name = builder.productName;
        product.ProductCode = builder.productCode;
        return product;
    }

    

    public class Builder {
        //Mandatory
        private String productName; 

        //Optional
        private String productCode;

        //Constructor requires mandatory params
        public Builder(String productName) {
            this.productName = productName;
        }

        //Call at end to construct 
        public Product2 build() {
            return Product2_TestFactory.buildProduct(this);
        }

        //Optional params
        public Builder setProductCode(String productCode) {
            this.productCode = productCode;
            return this;
        }
    }
}
