import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', () => {
  const user = ref<User | null>(null)
  const loading = ref(false)

  async function initAuth() {
    loading.value = true
    
    try {
      const { data: sessionData, error: sessionError } = await supabase.auth.getSession()
      if (sessionError) throw sessionError
      if (!sessionData.session) {
        user.value = null
        return
      }

      const { data: userData, error: userError } = await supabase.auth.getUser()
      if (userError) throw userError

      user.value = userData.user
    } catch (error) {
      console.error('Error loading auth session:', error)
      user.value = null
    } finally {
      loading.value = false
    }
  }

  async function login(email: string, password: string) {
    loading.value = true

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) throw error

      user.value = data.user
      return data.user
    } catch (error) {
      console.error('Login failed:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error

    user.value = null
  }

  function isAuthenticated() {
    return user.value !== null
  }

  return {
    user,
    loading,
    initAuth,
    login,
    logout,
    isAuthenticated,
  }
})
