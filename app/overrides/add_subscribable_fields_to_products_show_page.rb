Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_subscribable_fields_to_products_show",
 insert_after: ".qty-wrap",
  partial: "spree/products/subscription_fields"
)
