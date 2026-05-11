import { ref } from 'vue'
import type { StoreSettings } from '@/types'

const SETTINGS_KEY = 'store_settings'

const defaultSettings: StoreSettings = {
  store_address: 'Jl. Tamangapa V No. 12345\nMakassar 90235, Sulawesi Selatan',
  phone_number: '(0411) 123-4567',
  whatsapp_number: '0812-3456-7890',
  bank_name: 'Bank BCA',
  account_number: '123-456-7890',
  account_holder_name: 'Catering Hanin Hanif',
}

function readSettings(): StoreSettings {
  const saved = localStorage.getItem(SETTINGS_KEY)
  if (!saved) return { ...defaultSettings }

  try {
    return {
      ...defaultSettings,
      ...JSON.parse(saved),
    }
  } catch {
    return { ...defaultSettings }
  }
}

const settings = ref<StoreSettings>(readSettings())

export function useSettings() {
  function saveSettings(value: StoreSettings) {
    settings.value = { ...value }
    localStorage.setItem(SETTINGS_KEY, JSON.stringify(settings.value))
  }

  function resetSettings() {
    saveSettings(defaultSettings)
  }

  return {
    settings,
    saveSettings,
    resetSettings,
  }
}
