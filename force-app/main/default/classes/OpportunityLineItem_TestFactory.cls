@isTest
public with sharing class OpportunityLineItem_TestFactory {
    //Test Factory Controls
    public Boolean insertOnCreate = true;

    private static OpportunityLineItem buildOpportunityLineItem(Builder builder) {
        OpportunityLineItem oppLine = new OpportunityLineItem();
        oppLine.Product2Id = builder.productId;
        oppLine.OpportunityId = builder.oppId;
        oppLine.Quantity = builder.quantity;
        oppLine.TotalPrice = builder.totalPrice;
        return oppLine;
    }

    public class Builder {
        //Mandatory
        private Id productId; 
        private Id oppId; 
        private Integer quantity; 
        private Decimal totalPrice;
        

        //Optional
        

        public Builder() {
            this.totalPrice = 10;
        }

        //Call at end to construct 
        public OpportunityLineItem build() {
            return OpportunityLineItem_TestFactory.buildOpportunityLineItem(this);
        }

        public Builder setRelatedProduct(Id productId) {
            this.productId = productId;
            return this;
        }

        public Builder setRelatedOpportunity(Id oppId) {
            this.oppId = oppId;
            return this;
        }

        public Builder setQuantity(Integer quantity) {
            this.quantity = quantity;
            return this;
        }

    }
}
