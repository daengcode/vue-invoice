export interface Invoice {
  id: string
  invoice_number: string
  invoice_date: string
  due_date: string
  customer_name: string
  customer_address: string
  sales_code: string
  ppn_included: boolean
  subtotal: number
  discount_amount: number
  total: number
  dp_po: number
  credit: number
  seller_name: string
  buyer_name: string
  user_id: string
  created_at: string
}

export interface InvoiceItem {
  id: string
  invoice_id: string
  no_urut: number
  product_name: string
  quantity: number
  unit: string
  unit_price: number
  discount: number
  total: number
}

export interface InvoiceWithItems extends Invoice {
  items: InvoiceItem[]
}

export interface InvoiceForm {
  invoice_number: string
  invoice_date: string
  due_date: string
  customer_name: string
  customer_address: string
  sales_code: string
  ppn_included: boolean
  dp_po: number
  credit: number
  seller_name: string
  buyer_name: string
  items: InvoiceItemForm[]
}

export interface InvoiceItemForm {
  id?: string
  no_urut: number
  product_name: string
  quantity: number
  unit: string
  unit_price: number
  discount: number
}

export interface StoreSettings {
  store_address: string
  phone_number: string
  whatsapp_number: string
  bank_name: string
  account_number: string
  account_holder_name: string
}
