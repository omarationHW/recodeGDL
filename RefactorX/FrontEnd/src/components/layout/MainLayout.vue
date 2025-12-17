<template>
  <div class="main-layout">
    <AppHeader />
    <AppSidebar />

    <main class="main-content" :style="{ marginLeft: sidebarCollapsed ? '0' : sidebarWidth + 'px' }">
      <div class="content-wrapper">
        <router-view />
      </div>
    </main>

    <AppFooter />
  </div>
</template>

<script setup>
import AppHeader from './AppHeader.vue'
import AppSidebar from './AppSidebar.vue'
import AppFooter from './AppFooter.vue'
import { useSidebar } from '@/composables/useSidebar'

const { sidebarCollapsed, sidebarWidth } = useSidebar()
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
  width: 100%;
  margin: 0;
  padding: 0;
  transition: margin-left 0.3s ease;
  margin-top: 60px;
}

.content-wrapper {
  width: 100%;
  height: 100%;
  margin: 0;
  padding: 0;
}

.sidebar-collapsed .main-content {
  margin-left: 0 !important;
}
</style>
