import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '@/lib/supabase'
import * as bcrypt from 'bcryptjs'

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

export const useAuthStore = defineStore('auth', () => {
  const user = ref<CustomUser | null>(null)
  const loading = ref(false)

  async function initAuth() {
    loading.value = true
    
    try {
      // Check if user is stored in localStorage
      const storedUser = localStorage.getItem('user')
      if (storedUser) {
        user.value = JSON.parse(storedUser)
      }
    } catch (error) {
      console.error('Error loading user from localStorage:', error)
      localStorage.removeItem('user')
    } finally {
      loading.value = false
    }
  }

  async function login(email: string, password: string) {
    loading.value = true
    console.log('=== LOGIN START ===', email)

    try {
      console.log('Step 1: Querying user...')
      // Fetch user from custom users table
      const { data: userData, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .maybeSingle()

      console.log('Step 1 result:', { userData, error })

      if (error) {
        console.error('Database error:', error)
        throw new Error('Database error: ' + error.message)
      }

      if (!userData) {
        console.error('User not found for email:', email)
        throw new Error('User not found')
      }

      console.log('Step 2: User found, checking active status...')
      console.log('is_active:', userData.is_active)

      if (!userData.is_active) {
        throw new Error('Account is not active')
      }

      console.log('Step 3: Verifying password...')
      console.log('Password input length:', password.length)
      console.log('Hash exists:', !!userData.password_hash)
      console.log('Hash length:', userData.password_hash?.length)

      // Verify password using bcryptjs
      let isValidPassword = false
      try {
        console.log('Calling bcrypt.compare...')
        isValidPassword = await bcrypt.compare(password, userData.password_hash)
        console.log('Bcrypt result:', isValidPassword)
      } catch (bcryptError) {
        console.error('Bcrypt error:', bcryptError)
        throw new Error('Bcrypt error: ' + (bcryptError instanceof Error ? bcryptError.message : String(bcryptError)))
      }

      if (!isValidPassword) {
        console.error('Password does not match')
        throw new Error('Password does not match')
      }

      console.log('Step 4: Password verified, updating last_login...')
      // Update last_login_at
      const { error: updateError } = await supabase
        .from('users')
        .update({ last_login_at: new Date().toISOString() })
        .eq('id', userData.id)

      if (updateError) {
        console.warn('Failed to update last_login_at:', updateError)
      }

      console.log('Step 5: Storing user in state...')
      // Store user in state and localStorage
      user.value = userData
      localStorage.setItem('user', JSON.stringify(userData))

      console.log('=== LOGIN SUCCESS ===')
      return userData
    } catch (error) {
      console.error('=== LOGIN FAILED ===')
      console.error('Error:', error)
      console.error('Error type:', error instanceof Error ? error.message : String(error))
      throw error
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    user.value = null
    localStorage.removeItem('user')
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
