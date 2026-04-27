import { supabase } from '@/lib/supabase'
import type { Invoice, InvoiceItem, InvoiceForm } from '@/types'

export function useInvoices() {
  async function fetchInvoices() {
    // Get user from localStorage (custom auth)
    const userJson = localStorage.getItem('user')
    if (!userJson) throw new Error('User not authenticated')
    
    const customUser = JSON.parse(userJson)
    const userId = customUser.id

    const { data, error } = await supabase
      .from('invoices')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false })
    
    if (error) throw error
    return data as Invoice[]
  }

  async function fetchInvoice(id: string) {
    const { data: invoice, error: invoiceError } = await supabase
      .from('invoices')
      .select('*')
      .eq('id', id)
      .single()
    
    if (invoiceError) throw invoiceError

    const { data: items, error: itemsError } = await supabase
      .from('invoice_items')
      .select('*')
      .eq('invoice_id', id)
      .order('no_urut', { ascending: true })
    
    if (itemsError) throw itemsError

    return {
      ...invoice,
      items: items as InvoiceItem[],
    } as Invoice & { items: InvoiceItem[] }
  }

  async function createInvoice(form: InvoiceForm) {
    // Get user from localStorage (custom auth)
    const userJson = localStorage.getItem('user')
    if (!userJson) throw new Error('User not authenticated')
    
    const customUser = JSON.parse(userJson)
    const userId = customUser.id

    const subtotal = form.items.reduce((sum, item) => sum + (item.quantity * item.unit_price - item.discount), 0)
    const discountAmount = form.items.reduce((sum, item) => sum + item.discount, 0)
    const total = subtotal - discountAmount
    const credit = Math.max(0, total - form.dp_po)

    const { data: invoice, error: invoiceError } = await supabase
      .from('invoices')
      .insert({
        invoice_number: form.invoice_number,
        invoice_date: form.invoice_date,
        due_date: form.due_date,
        customer_name: form.customer_name,
        customer_address: form.customer_address,
        sales_code: form.sales_code,
        ppn_included: form.ppn_included,
        subtotal,
        discount_amount: discountAmount,
        total,
        dp_po: form.dp_po,
        credit,
        user_id: userId,
      })
      .select()
      .single()
    
    if (invoiceError) throw invoiceError

    const itemsToInsert = form.items.map((item, index) => ({
      invoice_id: invoice.id,
      no_urut: index + 1,
      product_name: item.product_name,
      quantity: item.quantity,
      unit: item.unit,
      unit_price: item.unit_price,
      discount: item.discount,
      total: item.quantity * item.unit_price - item.discount,
    }))

    const { error: itemsError } = await supabase
      .from('invoice_items')
      .insert(itemsToInsert)
    
    if (itemsError) throw itemsError

    return invoice
  }

  async function deleteInvoice(id: string) {
    const { error } = await supabase
      .from('invoices')
      .delete()
      .eq('id', id)
    
    if (error) throw error
  }

  function generateInvoiceNumber(): string {
    const date = new Date()
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0')
    return `INV${year}${month}${day}${random}`
  }

  function numberToWords(num: number): string {
    if (num === 0) return 'Nol'

    const units = ['', 'Satu', 'Dua', 'Tiga', 'Empat', 'Lima', 'Enam', 'Tujuh', 'Delapan', 'Sembilan']
    const teens = ['Sepuluh', 'Sebelas', 'Dua Belas', 'Tiga Belas', 'Empat Belas', 'Lima Belas', 'Enam Belas', 'Tujuh Belas', 'Delapan Belas', 'Sembilan Belas']
    const tens = ['', '', 'Dua Puluh', 'Tiga Puluh', 'Empat Puluh', 'Lima Puluh', 'Enam Puluh', 'Tujuh Puluh', 'Delapan Puluh', 'Sembilan Puluh']
    const scales = ['', 'Ribu', 'Juta', 'Miliar', 'Triliun']

    function convertGroup(n: number): string {
      if (n === 0) return ''
      
      let result = ''
      
      if (n >= 100) {
        if (n >= 200) {
          result += units[Math.floor(n / 100)] + ' Ratus '
        } else {
          result += 'Seratus '
        }
        n %= 100
      }
      
      if (n >= 20) {
        result += tens[Math.floor(n / 10)] + ' '
        n %= 10
      } else if (n >= 10) {
        result += teens[n - 10] + ' '
        return result
      }
      
      if (n > 0) {
        result += units[n] + ' '
      }
      
      return result
    }

    if (num < 0) return 'Minus ' + numberToWords(-num)
    
    let result = ''
    let scaleIndex = 0
    
    while (num > 0) {
      const group = num % 1000
      if (group > 0) {
        if (group === 1 && scaleIndex === 1) {
          result = 'Seribu ' + result
        } else {
          result = convertGroup(group) + scales[scaleIndex] + ' ' + result
        }
      }
      num = Math.floor(num / 1000)
      scaleIndex++
    }
    
    return result.trim() + ' Rupiah'
  }

  return {
    fetchInvoices,
    fetchInvoice,
    createInvoice,
    deleteInvoice,
    generateInvoiceNumber,
    numberToWords,
  }
}
