import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/LoginView.vue'),
      meta: { requiresAuth: false },
    },
    {
      path: '/',
      redirect: '/invoices',
    },
    {
      path: '/invoices',
      name: 'invoices',
      component: () => import('@/views/InvoiceListView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/invoices/create',
      name: 'invoice-create',
      component: () => import('@/views/InvoiceFormView.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/invoices/:id',
      name: 'invoice-detail',
      component: () => import('@/views/InvoiceDetailView.vue'),
      meta: { requiresAuth: true },
    },
  ],
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  if (!authStore.user) {
    await authStore.initAuth()
  }

  const requiresAuth = to.meta.requiresAuth !== false

  if (requiresAuth && !authStore.user) {
    next({ name: 'login', query: { redirect: to.fullPath } })
  } else if (to.name === 'login' && authStore.user) {
    next({ name: 'invoices' })
  } else {
    next()
  }
})

export default router
