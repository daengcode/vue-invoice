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

export interface CustomUser {
  id: string
  email: string
  password_hash: string
  full_name: string
  role: string
  is_active: boolean
  created_at: string
  updated_at: string
  last_login_at: string | null
}
