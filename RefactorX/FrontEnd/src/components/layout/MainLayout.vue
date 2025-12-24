<template>
  <div class="main-layout">
    <!-- Solo mostrar header y sidebar si hay sesión y no estamos en login -->
    <template v-if="showLayout">
      <AppHeader />
      <AppSidebar />
    </template>

    <main class="main-content" :class="{ 'full-width': !showLayout }" :style="mainContentStyle">
      <div class="content-wrapper">
        <router-view />
      </div>
    </main>

    <AppFooter v-if="showLayout" />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import AppHeader from './AppHeader.vue'
import AppSidebar from './AppSidebar.vue'
import AppFooter from './AppFooter.vue'
import { useSidebar } from '@/composables/useSidebar'
import sessionService from '@/services/sessionService'

const route = useRoute()
const { sidebarCollapsed, sidebarWidth } = useSidebar()

// Mostrar layout solo si hay sesión Y no estamos en login/dashboard
const showLayout = computed(() => {
  const publicRoutes = ['/login', '/']
  const isPublicRoute = publicRoutes.includes(route.path)
  const isAuthenticated = sessionService.isAuthenticated()
  
  return isAuthenticated && !isPublicRoute
})

// Estilo del contenido principal
const mainContentStyle = computed(() => {
  if (!showLayout.value) {
    return { marginLeft: '0' }
  }
  return { marginLeft: sidebarCollapsed.value ? '0' : sidebarWidth.value + 'px' }
})
</script>

<style scoped>
.main-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
}

.main-content {
  flex: 1;
  margin: 0;
  padding: 0;
  transition: margin-left 0.3s ease;
  margin-top: 60px;
  overflow-x: hidden;
  overflow-y: auto;
  max-width: 100vw;
}

.main-content.full-width {
  margin-top: 0;
  margin-left: 0 !important;
}

.content-wrapper {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
  max-width: 100%;
  overflow-x: hidden;
}

.sidebar-collapsed .main-content {
  margin-left: 0 !important;
}
</style>
