<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <h1 class="text-base sm:text-xl font-bold text-gray-900 truncate">Catering Hanin Hanif</h1>
          <button
            @click="handleLogout"
            class="ml-4 flex-shrink-0 inline-flex items-center px-3 py-1.5 sm:px-4 sm:py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700"
          >
            Logout
          </button>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-4 sm:py-6 px-4 sm:px-6 lg:px-8">
      <div class="flex justify-between items-center mb-4 sm:mb-6">
        <h2 class="text-xl sm:text-2xl font-bold text-gray-900">Daftar Invoice</h2>
        <router-link
          to="/invoices/create"
          class="flex-shrink-0 inline-flex items-center px-3 py-1.5 sm:px-4 sm:py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-primary hover:bg-orange-dark"
        >
          <span class="hidden sm:inline">Buat Invoice Baru</span>
          <span class="sm:hidden">+ Baru</span>
        </router-link>
      </div>

        <div v-if="loading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-orange-primary"></div>
        </div>

        <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {{ error }}
        </div>

        <div v-else-if="invoices.length === 0" class="text-center py-12 text-gray-500">
          Belum ada invoice. Silakan buat invoice baru.
        </div>

        <div v-else class="bg-white shadow overflow-x-auto border-b border-gray-200 sm:rounded-lg">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">No. Invoice</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Pelanggan</th>
                <th class="hidden sm:table-cell px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tanggal</th>
                <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
                <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Aksi</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr v-for="invoice in invoices" :key="invoice.id">
                <td class="px-4 py-3 text-sm font-medium text-orange-primary">{{ invoice.invoice_number }}</td>
                <td class="px-4 py-3 text-sm text-gray-900">{{ invoice.customer_name }}</td>
                <td class="hidden sm:table-cell px-4 py-3 text-sm text-gray-500 whitespace-nowrap">{{ formatDate(invoice.invoice_date) }}</td>
                <td class="px-4 py-3 text-sm text-gray-900 whitespace-nowrap">{{ formatCurrency(invoice.total) }}</td>
                <td class="px-4 py-3 whitespace-nowrap text-right text-sm font-medium">
                  <router-link :to="`/invoices/${invoice.id}`" class="text-orange-primary hover:text-orange-dark mr-3">Lihat</router-link>
                  <button @click="handleDelete(invoice.id)" class="text-red-600 hover:text-red-900">Hapus</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'
import { useInvoices } from '@/composables/useInvoices'
import type { Invoice } from '@/types'

const router = useRouter()
const authStore = useAuthStore()
const { fetchInvoices, deleteInvoice } = useInvoices()

const invoices = ref<Invoice[]>([])
const loading = ref(false)
const error = ref('')

async function loadInvoices() {
  loading.value = true
  error.value = ''
  try {
    invoices.value = await fetchInvoices()
  } catch (err: unknown) {
    error.value = err instanceof Error ? err.message : 'Gagal memuat invoice'
  } finally {
    loading.value = false
  }
}

async function handleDelete(id: string) {
  if (confirm('Apakah Anda yakin ingin menghapus invoice ini?')) {
    try {
      await deleteInvoice(id)
      await loadInvoices()
    } catch (err: unknown) {
      error.value = err instanceof Error ? err.message : 'Gagal menghapus invoice'
    }
  }
}

async function handleLogout() {
  await authStore.logout()
  router.push('/login')
}

function formatDate(date: string) {
  return new Date(date).toLocaleDateString('id-ID', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  })
}

function formatCurrency(amount: number) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
  }).format(amount)
}

onMounted(() => {
  loadInvoices()
})
</script>
