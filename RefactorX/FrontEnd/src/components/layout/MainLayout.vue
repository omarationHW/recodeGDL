<template>
  <div class="main-layout" :class="{ 'sidebar-collapsed': sidebarCollapsed }">
    <AppHeader />
    <AppSidebar />
    <main
      class="main-content"
      :style="{ marginLeft: sidebarCollapsed ? '0' : sidebarWidth + 'px' }"
    >
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
