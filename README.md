
# Epic: Stock Management

# Story: Stock Reservation
- As a Sales User
- I want the central Stock Count to be updated when I reserve units for my customers
- So that my customers can be confident that quoted products can be delivered as soon as an order is conformed


## Scenarios
### Scenario 1: Opportunity Stock Consumption
Given 
- An opportunity exists for a customer
- Stock count for Product A is 10

When 
- I add an Opportunity Product Line for Product A with the Quantity of 4

Then 
- The Opportunity Product Line Item is successfully added
-  The Product A stock count is reduced to 6

### Scenario 2: Single Opportunity with unavailable stock
Given 
-  An opportunity exists for a customer
- Stock count for Product A is 10

When 
- I add an Opportunity Product Line for Product A with the Quantity of 11

Then 
- The Opportunity Product Line Item is not added
- The Sales user is notified by an error message noting the quantity requested is more than the available stock, with a count of each
- The Product A Stock Count remains at 10

### Scenario 3: Bulk Opportunities with available stock
Given 
-  300 opportunities exist for a customer
- Stock count for Product A is 500

When 
- I add an Opportunity Product Line for Product A with the Quantity of 1 to each Opportunity (in bulk / a single operation)

Then 
- The Opportunity Product Line Items are added
-  The Product A stock count is reduced to 200

### Scenario 4: Bulk Opportunities with unavailable stock
Given 
-  300 opportunities exist for a customer
- Stock count for Product A is 100

When 
- I add an Opportunity Product Line for Product A with the Quantity of 1 to each Opportunity (in bulk / a single operation)

Then 
- The Opportunity Product Line Items are not added
- The Product A stock count remains at 100


## Story: Stock Management for Lost Opportunity (Not Implemented)
- As a Sales User
- I want the central Stock Count to be updated when an opportunity is lost
- So that I can supply the previously reserved units to other customers

## Story: Amending Available Stock (Not Implemented)
- As a System Admin/Integration User
- I want to be able to update the available stock of products
- So that the when new stock is available, it can be added for Sales Reps to sell

### Scenario 1: Stock Manager Allowed to Update Stock
Given
- The active user has the Stock Management custom permission
- The current stock for Product A is 0

When
- I update the stock for Product A to be increased by 10

Then
- The stock is updated to be 10

### Scenario 2: Sales User Blocked from central stock update

Given
- The active user does not have the Stock Management custom permission
- And the user is not setting an Opportunity as closed-lost
- And the stock of Product A is 0

When
- I update the stock for Product A to be 10

Then
- The stock is not updated
- An error message is shown to the user that they do not have the stock management permission


# Discussions & Assumptions
## Requirements
- Requirements suggest a 1 Product to zero or many Stock Count records. There could be many reasons for this such as different locations or different time intervals at which  a given stock count is active.
- ASSUMPTION 1: 1 correct active stock count per product in the 'Final solution' 
- ASSUMPTION 2: Current story/implementation supports a max of 1 stock count record per product. No validation is applied here assuming that would be the scope of a future story.
- ASSUMPTION 3: If no stock count is present, assume 0 units of stock
- ASSUMPTION 4: All or nothing Bulk uploads. If 10 units available and 15 units requested accross multiple opportunities, Sales Reps should decide which opportunities to apply the available to capacity to, without arbitrary logic making this decision.

## Technical Decisions
- Basic Trigger framework used. 
- Packaging not used (overkill/time)
