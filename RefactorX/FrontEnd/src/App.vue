<template>
  <div id="app">
    <!-- Layout completo (con sidebar, header, footer) para rutas autenticadas -->
    <MainLayout v-if="layoutType === 'full'" />

    <!-- Layout solo con header (sin sidebar) para dashboard -->
    <HeaderOnlyLayout v-else-if="layoutType === 'header-only'" />

    <!-- Layout vacío (sin sidebar, sin header) para rutas públicas como login -->
    <router-view v-else />

    <GlobalLoading />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import MainLayout from './components/layout/MainLayout.vue'
import HeaderOnlyLayout from './components/layout/HeaderOnlyLayout.vue'
import GlobalLoading from './components/common/GlobalLoading.vue'

const route = useRoute()

// Rutas que NO deben mostrar ningún layout (sin sidebar, sin header, sin footer)
const emptyLayoutRoutes = [
  '/login',
  '/mercados/acceso',
  '/cementerios/acceso',
  '/estacionamiento-publico/accesos',
  '/multas-reglamentos/acceso',
  '/aseo-contratado/acceso',
  '/padron-licencias/acceso',
  '/estacionamiento-exclusivo/acceso',
  '/otras-obligaciones/acceso',
  '/predial/acceso',
  '/distribucion/acceso'
]

// Rutas que solo deben mostrar header (sin sidebar)
const headerOnlyRoutes = [
  '/'
]

// Determinar qué tipo de layout mostrar
const layoutType = computed(() => {
  const currentPath = route.path

  // Si es ruta vacía (login, acceso)
  if (emptyLayoutRoutes.includes(currentPath)) {
    return 'empty'
  }

  // Si es ruta solo con header (dashboard)
  if (headerOnlyRoutes.includes(currentPath)) {
    return 'header-only'
  }

  // Por defecto, layout completo
  return 'full'
})
</script>

<style>
#app {
  min-height: 100vh;
}
</style>
