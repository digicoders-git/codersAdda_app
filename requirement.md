# Coders Adda App - Requirements

## Coupon System

### Feature: Apply Coupon on Course/PDF Purchase

**Requirement:**
- Jahan bhi courses ya PDFs buy karne ka option hai, wahan coupon apply karne ka system hona chahiye
- User coupon code enter kar sake
- Coupon validate ho aur discount apply ho
- Final price coupon discount ke baad show ho

**Implementation Locations:**
1. Course Purchase Page (`course_purchase_page.dart`)
2. PDF Purchase Page (if applicable)
3. Any other purchase/checkout screens

**Features Needed:**
- Coupon code input field
- Apply/Validate button
- Discount calculation
- Show original price, discount, and final price
- Error handling for invalid coupons
- Success message for valid coupons

**API Integration:**
- Coupon validation API endpoint
- Apply coupon to order API
