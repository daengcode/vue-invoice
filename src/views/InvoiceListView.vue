<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex flex-col gap-3 py-4 sm:flex-row sm:items-center sm:justify-between sm:py-0 sm:h-16">
          <h1 class="text-lg font-bold text-gray-900 sm:text-xl">Catering Hanin Hanif</h1>
          <div class="grid grid-cols-2 gap-2 sm:flex sm:items-center">
            <router-link
              to="/settings"
              class="inline-flex items-center justify-center px-3 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 sm:px-4"
            >
              Pengaturan
            </router-link>
            <button
              @click="handleLogout"
              class="inline-flex items-center justify-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700 sm:px-4"
            >
              Logout
            </button>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto py-4 sm:py-6 px-4 sm:px-6 lg:px-8">
      <div class="flex flex-col gap-3 mb-4 sm:mb-6 sm:flex-row sm:items-center sm:justify-between">
        <h2 class="text-2xl font-bold text-gray-900">Daftar Invoice</h2>
        <router-link
          to="/invoices/create"
          class="inline-flex w-full items-center justify-center px-4 py-2.5 border border-transparent text-sm font-medium rounded-md text-white bg-orange-primary hover:bg-orange-dark sm:w-auto"
        >
          Buat Invoice Baru
        </router-link>
      </div>

        <div v-if="loading" class="text-center py-12">
          <div class="inline-block animate-spin rounded-full h-8 w-8 border-b-2 border-orange-primary"></div>
        </div>

        <div v-else-if="error" class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {{ error }}
        </div>

        <div v-else-if="invoices.length === 0" class="rounded-lg border border-dashed border-gray-300 bg-white px-4 py-12 text-center text-gray-500">
          <p class="text-sm">Belum ada invoice.</p>
          <router-link
            to="/invoices/create"
            class="mt-4 inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-orange-primary hover:bg-orange-dark"
          >
            Buat Invoice Baru
          </router-link>
        </div>

        <div v-else>
          <div class="space-y-3 sm:hidden">
            <article
              v-for="invoice in invoices"
              :key="invoice.id"
              class="rounded-lg border border-gray-200 bg-white p-4 shadow-sm"
            >
              <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                  <p class="truncate text-sm font-semibold text-orange-primary">{{ invoice.invoice_number }}</p>
                  <h3 class="mt-1 truncate text-base font-semibold text-gray-900">{{ invoice.customer_name }}</h3>
                </div>
                <button
                  type="button"
                  class="inline-flex h-9 w-9 flex-shrink-0 items-center justify-center rounded-md border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-primary focus:ring-offset-1"
                  :aria-expanded="openActionMenuId === invoice.id"
                  :aria-controls="`invoice-actions-${invoice.id}`"
                  aria-haspopup="menu"
                  title="Aksi invoice"
                  @click.stop="toggleActionMenu($event, invoice)"
                  @keydown.escape.stop="closeActionMenu"
                >
                  <span class="sr-only">Buka menu aksi invoice {{ invoice.invoice_number }}</span>
                  <span class="text-xl leading-none" aria-hidden="true">⋮</span>
                </button>
              </div>

              <dl class="mt-4 grid grid-cols-2 gap-3">
                <div>
                  <dt class="text-xs font-medium uppercase text-gray-500">Tanggal</dt>
                  <dd class="mt-1 text-sm text-gray-900">{{ formatShortDate(invoice.invoice_date) }}</dd>
                </div>
                <div class="text-right">
                  <dt class="text-xs font-medium uppercase text-gray-500">Total</dt>
                  <dd class="mt-1 text-sm font-semibold text-gray-900">{{ formatCurrency(invoice.total) }}</dd>
                </div>
              </dl>
            </article>
          </div>

          <div class="hidden bg-white shadow overflow-x-auto border-b border-gray-200 sm:block sm:rounded-lg">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">No. Invoice</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Pelanggan</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tanggal</th>
                  <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Total</th>
                  <th class="px-4 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Aksi</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="invoice in invoices" :key="invoice.id">
                  <td class="px-4 py-3 text-sm font-medium text-orange-primary">{{ invoice.invoice_number }}</td>
                  <td class="px-4 py-3 text-sm text-gray-900">{{ invoice.customer_name }}</td>
                  <td class="px-4 py-3 text-sm text-gray-500 whitespace-nowrap">{{ formatDate(invoice.invoice_date) }}</td>
                  <td class="px-4 py-3 text-sm text-gray-900 whitespace-nowrap">{{ formatCurrency(invoice.total) }}</td>
                  <td class="px-4 py-3 whitespace-nowrap text-right text-sm font-medium">
                    <div class="relative inline-block text-left">
                      <button
                        type="button"
                        class="inline-flex h-9 w-9 items-center justify-center rounded-md border border-gray-200 bg-white text-gray-600 hover:bg-gray-50 hover:text-gray-900 focus:outline-none focus:ring-2 focus:ring-orange-primary focus:ring-offset-1"
                        :aria-expanded="openActionMenuId === invoice.id"
                        :aria-controls="`invoice-actions-${invoice.id}`"
                        aria-haspopup="menu"
                        title="Aksi invoice"
                        @click.stop="toggleActionMenu($event, invoice)"
                        @keydown.escape.stop="closeActionMenu"
                      >
                        <span class="sr-only">Buka menu aksi invoice {{ invoice.invoice_number }}</span>
                        <span class="text-xl leading-none" aria-hidden="true">⋮</span>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <Teleport to="body">
          <div
            v-if="openActionMenuInvoice"
            :id="`invoice-actions-${openActionMenuInvoice.id}`"
            class="fixed z-50 w-36 rounded-md border border-gray-200 bg-white py-1 text-left shadow-lg focus:outline-none"
            :style="actionMenuStyle"
            role="menu"
            @click.stop
          >
            <router-link
              :to="`/invoices/${openActionMenuInvoice.id}`"
              class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-orange-primary"
              role="menuitem"
              @click="closeActionMenu"
            >
              Lihat
            </router-link>
            <router-link
              :to="`/invoices/${openActionMenuInvoice.id}/edit`"
              class="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-blue-600"
              role="menuitem"
              @click="closeActionMenu"
            >
              Edit
            </router-link>
            <button
              type="button"
              class="block w-full px-4 py-2 text-left text-sm text-red-600 hover:bg-red-50"
              role="menuitem"
              @click="handleDelete(openActionMenuInvoice.id)"
            >
              Hapus
            </button>
          </div>
        </Teleport>
    </main>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, onMounted, onUnmounted } from 'vue'
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
const openActionMenuId = ref<string | null>(null)
const openActionMenuInvoice = ref<Invoice | null>(null)
const actionMenuPosition = ref({ top: 0, left: 0 })

const actionMenuStyle = computed(() => ({
  top: `${actionMenuPosition.value.top}px`,
  left: `${actionMenuPosition.value.left}px`,
}))

function toggleActionMenu(event: MouseEvent, invoice: Invoice) {
  if (openActionMenuId.value === invoice.id) {
    closeActionMenu()
    return
  }

  const button = event.currentTarget as HTMLElement
  const rect = button.getBoundingClientRect()
  const menuWidth = 144
  const menuHeight = 122
  const gap = 8
  const viewportPadding = 8
  const opensUp = rect.bottom + gap + menuHeight > window.innerHeight

  actionMenuPosition.value = {
    top: opensUp ? Math.max(viewportPadding, rect.top - gap - menuHeight) : rect.bottom + gap,
    left: Math.min(
      window.innerWidth - menuWidth - viewportPadding,
      Math.max(viewportPadding, rect.right - menuWidth),
    ),
  }

  openActionMenuId.value = invoice.id
  openActionMenuInvoice.value = invoice
}

function closeActionMenu() {
  openActionMenuId.value = null
  openActionMenuInvoice.value = null
}

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
  closeActionMenu()
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

function formatShortDate(date: string) {
  return new Date(date).toLocaleDateString('id-ID', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  })
}

function formatCurrency(amount: number) {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
  }).format(amount)
}

onMounted(() => {
  document.addEventListener('click', closeActionMenu)
  window.addEventListener('resize', closeActionMenu)
  window.addEventListener('scroll', closeActionMenu, true)
  loadInvoices()
})

onUnmounted(() => {
  document.removeEventListener('click', closeActionMenu)
  window.removeEventListener('resize', closeActionMenu)
  window.removeEventListener('scroll', closeActionMenu, true)
})
</script>
