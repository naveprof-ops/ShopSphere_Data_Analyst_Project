# Power BI Implementation Guide

## Model

Use a star schema:

**FactOrders**
- order_id
- customer_id
- product_id
- order_date
- quantity
- unit_price
- discount
- order_status
- delivery_days
- region

**DimCustomer**
- customer_id
- gender
- age
- city
- state
- signup_date
- customer_segment
- acquisition_channel

**DimProduct**
- product_id
- product_name
- category
- sub_category
- brand
- cost_price
- selling_price

**FactReturns**
- return_id
- order_id
- return_date
- return_reason
- refund_amount

Create a dedicated Date table and relate Date[Date] to FactOrders[order_date].

## DAX

```DAX
Gross Revenue =
CALCULATE(
    SUMX(
        FactOrders,
        FactOrders[quantity] * FactOrders[unit_price] * (1 - FactOrders[discount])
    ),
    FactOrders[order_status] <> "Cancelled"
)

Total Orders = DISTINCTCOUNT(FactOrders[order_id])

Total Customers = DISTINCTCOUNT(FactOrders[customer_id])

Average Order Value =
DIVIDE([Gross Revenue], [Total Orders])

Returned Orders =
CALCULATE(
    DISTINCTCOUNT(FactOrders[order_id]),
    FactOrders[order_status] = "Returned"
)

Return Rate =
DIVIDE([Returned Orders], [Total Orders])

Cancelled Orders =
CALCULATE(
    DISTINCTCOUNT(FactOrders[order_id]),
    FactOrders[order_status] = "Cancelled"
)

Cancellation Rate =
DIVIDE([Cancelled Orders], DISTINCTCOUNT(FactOrders[order_id]))

Estimated Profit =
CALCULATE(
    SUMX(
        FactOrders,
        FactOrders[quantity] *
        (
            FactOrders[unit_price] * (1 - FactOrders[discount])
            - RELATED(DimProduct[cost_price])
        )
    ),
    FactOrders[order_status] <> "Cancelled"
)

Profit Margin =
DIVIDE([Estimated Profit], [Gross Revenue])

Monthly Revenue = [Gross Revenue]

Previous Month Revenue =
CALCULATE(
    [Gross Revenue],
    DATEADD('Date'[Date], -1, MONTH)
)

MoM Growth % =
DIVIDE(
    [Monthly Revenue] - [Previous Month Revenue],
    [Previous Month Revenue]
)
```

## Dashboard pages

1. Executive Overview
2. Customer Retention & RFM
3. Product & Category Performance
4. Revenue Leakage & Operations

## Recommended visuals

- KPI cards
- line chart for monthly revenue
- clustered bar for category revenue
- map/bar for regional revenue
- donut for customer segments
- scatter for revenue vs return rate
- matrix for category/product performance
- slicers for date, region, category and acquisition channel
