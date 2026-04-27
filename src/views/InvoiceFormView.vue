<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <h1 class="text-base sm:text-xl font-bold text-gray-900 truncate">Buat Invoice Baru</h1>
          <router-link
            to="/invoices"
            class="flex-shrink-0 ml-4 inline-flex items-center px-3 py-1.5 sm:px-4 sm:py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            Kembali
          </router-link>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <form @submit.prevent="handleSubmit">
          <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Informasi Invoice</h3>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">No. Transaksi</label>
                <input
                  v-model="form.invoice_number"
                  type="text"
                  readonly
                  class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal</label>
                <input
                  v-model="form.invoice_date"
                  type="datetime-local"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Tanggal Jatuh Tempo</label>
                <input
                  v-model="form.due_date"
                  type="date"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Kode Sales</label>
                <input
                  v-model="form.sales_code"
                  type="text"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
                />
              </div>
              
              <div class="md:col-span-2">
                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Pelanggan</label>
                <input
                  v-model="form.customer_name"
                  type="text"
                  required
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
                />
              </div>
              
              <div class="md:col-span-2">
                <label class="block text-sm font-medium text-gray-700 mb-1">Alamat</label>
                <textarea
                  v-model="form.customer_address"
                  rows="2"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">DP PO</label>
                <input
                  v-model.number="form.dp_po"
                  type="number"
                  min="0"
                  step="0.01"
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Kredit (Total - DP PO)</label>
                <input
                  :value="formatCurrency(Math.max(0, calculateTotal() - form.dp_po))"
                  type="text"
                  readonly
                  class="w-full px-3 py-2 border border-gray-300 rounded-md bg-gray-100"
                />
              </div>
              
              <div class="md:col-span-2">
                <label class="flex items-center">
                  <input
                    v-model="form.ppn_included"
                    type="checkbox"
                    class="rounded border-gray-300 text-orange-primary shadow-sm focus:border-orange-light focus:ring focus:ring-orange-100 focus:ring-opacity-50"
                  />
                  <span class="ml-2 text-sm text-gray-700">PPN Included</span>
                </label>
              </div>
            </div>
          </div>

          <div class="bg-white shadow rounded-lg p-6 mb-6">
            <div class="flex justify-between items-center mb-4">
              <h3 class="text-lg font-medium text-gray-900">Item</h3>
              <button
                type="button"
                @click="addItem"
                class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-green-600 hover:bg-green-700"
              >
                + Tambah Item
              </button>
            </div>
            
            <!-- Mobile: card per item -->
            <div class="sm:hidden space-y-3">
              <div
                v-for="(item, index) in form.items"
                :key="index"
                class="border border-gray-200 rounded-lg p-4 bg-gray-50"
              >
                <div class="flex justify-between items-center mb-3">
                  <span class="text-sm font-semibold text-gray-700">Item {{ index + 1 }}</span>
                  <button type="button" @click="removeItem(index)" class="text-red-600 hover:text-red-900 text-lg leading-none">✕</button>
                </div>
                <div class="space-y-3">
                  <div>
                    <label class="block text-xs font-medium text-gray-500 mb-1">Nama Item</label>
                    <input v-model="item.product_name" type="text" required placeholder="Nama item"
                      class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-orange-primary focus:border-orange-primary" />
                  </div>
                  <div class="grid grid-cols-2 gap-3">
                    <div>
                      <label class="block text-xs font-medium text-gray-500 mb-1">Jumlah</label>
                      <input v-model.number="item.quantity" type="number" min="1" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </div>
                    <div>
                      <label class="block text-xs font-medium text-gray-500 mb-1">Satuan</label>
                      <input v-model="item.unit" type="text" required placeholder="pcs, kg..."
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </div>
                  </div>
                  <div class="grid grid-cols-2 gap-3">
                    <div>
                      <label class="block text-xs font-medium text-gray-500 mb-1">Harga Satuan</label>
                      <input v-model.number="item.unit_price" type="number" min="0" step="0.01" required
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </div>
                    <div>
                      <label class="block text-xs font-medium text-gray-500 mb-1">Diskon</label>
                      <input v-model.number="item.discount" type="number" min="0" step="0.01"
                        class="w-full px-3 py-2 border border-gray-300 rounded-md text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </div>
                  </div>
                  <div class="flex justify-between items-center pt-2 border-t border-gray-200">
                    <span class="text-xs font-medium text-gray-500">Total</span>
                    <span class="text-sm font-semibold text-gray-900">{{ formatCurrency(calculateItemTotal(item)) }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- Desktop: tabel -->
            <div class="hidden sm:block overflow-x-auto">
              <table class="min-w-full divide-y divide-gray-200">
                <thead class="bg-gray-50">
                  <tr>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">No</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Nama Item</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Jumlah</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Satuan</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Harga</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Diskon</th>
                    <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
                    <th class="px-4 py-3"></th>
                  </tr>
                </thead>
                <tbody class="bg-white divide-y divide-gray-200">
                  <tr v-for="(item, index) in form.items" :key="index">
                    <td class="px-4 py-2 whitespace-nowrap text-sm text-gray-900">{{ index + 1 }}</td>
                    <td class="px-4 py-2">
                      <input v-model="item.product_name" type="text" required
                        class="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </td>
                    <td class="px-4 py-2">
                      <input v-model.number="item.quantity" type="number" min="1" required
                        class="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </td>
                    <td class="px-4 py-2">
                      <input v-model="item.unit" type="text" required
                        class="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </td>
                    <td class="px-4 py-2">
                      <input v-model.number="item.unit_price" type="number" min="0" step="0.01" required
                        class="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </td>
                    <td class="px-4 py-2">
                      <input v-model.number="item.discount" type="number" min="0" step="0.01"
                        class="w-full px-2 py-1 border border-gray-300 rounded text-sm focus:ring-orange-primary focus:border-orange-primary" />
                    </td>
                    <td class="px-4 py-2 whitespace-nowrap text-sm text-gray-900">{{ formatCurrency(calculateItemTotal(item)) }}</td>
                    <td class="px-4 py-2">
                      <button type="button" @click="removeItem(index)" class="text-red-600 hover:text-red-900">✕</button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <div class="bg-white shadow rounded-lg p-6 mb-6">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Ringkasan</h3>
            
            <div class="space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-600">Sub Total</span>
                <span class="font-medium text-gray-900">{{ formatCurrency(calculateSubtotal()) }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-600">Potongan</span>
                <span class="font-medium text-gray-900">{{ formatCurrency(calculateDiscount()) }}</span>
              </div>
              <div class="flex justify-between border-t pt-2">
                <span class="font-medium text-gray-900">Total</span>
                <span class="font-bold text-gray-900">{{ formatCurrency(calculateTotal()) }}</span>
              </div>
            </div>
          </div>

          <div v-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded mb-6">
            {{ error }}
          </div>

          <div class="flex justify-end space-x-4">
            <router-link
              to="/invoices"
              class="px-6 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Batal
            </router-link>
            <button
              type="submit"
              :disabled="loading"
              class="px-6 py-2 border border-transparent rounded-md text-white bg-orange-primary hover:bg-orange-dark disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ loading ? 'Menyimpan...' : 'Simpan' }}
            </button>
          </div>
        </form>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useInvoices } from '@/composables/useInvoices'
import type { InvoiceForm, InvoiceItemForm } from '@/types'

const router = useRouter()
const { createInvoice, generateInvoiceNumber } = useInvoices()

const form = ref<InvoiceForm>({
  invoice_number: '',
  invoice_date: new Date().toISOString().slice(0, 16),
  due_date: new Date().toISOString().slice(0, 10),
  customer_name: '',
  customer_address: '',
  sales_code: '',
  ppn_included: false,
  dp_po: 0,
  credit: 0,
  items: [],
})

const loading = ref(false)
const error = ref('')

function addItem() {
  form.value.items.push({
    no_urut: form.value.items.length + 1,
    product_name: '',
    quantity: 1,
    unit: '',
    unit_price: 0,
    discount: 0,
  })
}

function removeItem(index: number) {
  form.value.items.splice(index, 1)
  form.value.items.forEach((item, i) => {
    item.no_urut = i + 1
  })
}

function calculateItemTotal(item: InvoiceItemForm) {
  return (item.quantity * item.unit_price) - item.discount
}

function calculateSubtotal() {
  return form.value.items.reduce((sum, item) => sum + (item.quantity * item.unit_price), 0)
}

function calculateDiscount() {
  return form.value.items.reduce((sum, item) => sum + item.discount, 0)
}

function calculateTotal() {
  return calculateSubtotal() - calculateDiscount()
}

function formatCurrency(amount: number) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
  }).format(amount)
}

async function handleSubmit() {
  if (form.value.items.length === 0) {
    error.value = 'Harap tambahkan minimal satu item'
    return
  }

  loading.value = true
  error.value = ''

  try {
    await createInvoice(form.value)
    router.push('/invoices')
  } catch (err: unknown) {
    error.value = err instanceof Error ? err.message : 'Gagal menyimpan invoice'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  form.value.invoice_number = generateInvoiceNumber()
  addItem()
})
</script>
