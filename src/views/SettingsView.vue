<template>
  <div class="min-h-screen bg-gray-50">
    <nav class="bg-white shadow">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <h1 class="text-base sm:text-xl font-bold text-gray-900 truncate">Pengaturan</h1>
          <router-link
            to="/invoices"
            class="flex-shrink-0 ml-4 inline-flex items-center px-3 py-1.5 sm:px-4 sm:py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50"
          >
            Kembali
          </router-link>
        </div>
      </div>
    </nav>

    <main class="max-w-4xl mx-auto py-6 sm:px-6 lg:px-8">
      <div class="px-4 py-6 sm:px-0">
        <form @submit.prevent="handleSubmit" class="bg-white shadow rounded-lg p-6">
          <h2 class="text-lg font-medium text-gray-900 mb-6">Informasi Toko dan Rekening</h2>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Alamat Toko</label>
              <textarea
                v-model="form.store_address"
                rows="3"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nomor Telephone</label>
              <input
                v-model="form.phone_number"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nomor WA</label>
              <input
                v-model="form.whatsapp_number"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nama Rekening</label>
              <input
                v-model="form.bank_name"
                type="text"
                required
                placeholder="Contoh: Bank BCA"
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
              />
            </div>

            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Nomor Rekening</label>
              <input
                v-model="form.account_number"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
              />
            </div>

            <div class="md:col-span-2">
              <label class="block text-sm font-medium text-gray-700 mb-1">Nama Pengguna Rekening</label>
              <input
                v-model="form.account_holder_name"
                type="text"
                required
                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-orange-primary focus:border-orange-primary"
              />
            </div>
          </div>

          <div v-if="successMessage" class="mt-6 bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded">
            {{ successMessage }}
          </div>

          <div class="flex justify-end gap-3 mt-6">
            <button
              type="button"
              @click="handleReset"
              title="Mengembalikan semua pengaturan ke nilai awal"
              aria-label="Reset pengaturan ke nilai awal"
              class="px-6 py-2 border border-gray-300 rounded-md text-gray-700 bg-white hover:bg-gray-50"
            >
              Reset
            </button>
            <button
              type="submit"
              class="px-6 py-2 border border-transparent rounded-md text-white bg-orange-primary hover:bg-orange-dark"
            >
              Simpan
            </button>
          </div>
          <p class="mt-2 text-right text-xs text-gray-500">
            Reset akan mengembalikan semua pengaturan ke nilai awal.
          </p>
        </form>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useSettings } from '@/composables/useSettings'
import type { StoreSettings } from '@/types'

const { settings, saveSettings, resetSettings } = useSettings()

const form = ref<StoreSettings>({ ...settings.value })
const successMessage = ref('')

function handleSubmit() {
  saveSettings(form.value)
  successMessage.value = 'Pengaturan berhasil disimpan'
}

function handleReset() {
  resetSettings()
  form.value = { ...settings.value }
  successMessage.value = 'Pengaturan dikembalikan ke nilai awal'
}
</script>
