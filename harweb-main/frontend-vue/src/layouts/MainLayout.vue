<template>
  <div class="min-h-screen bg-gray-100">
    <!-- Sidebar -->
    <Sidebar />
    
    <!-- Header - Con margen para el sidebar -->
    <header class="bg-white shadow-sm border-bottom" style="margin-left: 280px;">
      <div class="max-w-full mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
          <div class="flex items-center">
            <div class="h-8 w-24 bg-blue-600 rounded mr-4 flex items-center justify-center">
              <span class="text-white text-xs font-bold">RefactorX</span>
            </div>
            <h1 class="text-xl font-semibold text-gray-900">Sistema Municipal</h1>
          </div>
          <div class="flex items-center space-x-4">
            <span class="text-sm text-gray-600">Usuario: harweb</span>
            <button class="text-gray-400 hover:text-gray-600">
              <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
                <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
              </svg>
            </button>
            <span class="text-xs text-blue-600 bg-blue-100 px-2 py-1 rounded font-medium">v1.0.570</span>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content - Con margen para el sidebar -->
    <main class="min-vh-100" style="margin-left: 280px;">
      <div class="p-6">
        <slot />
      </div>
    </main>
  </div>
</template>

<script>
import Sidebar from '../components/Sidebar.vue'

export default {
  name: 'MainLayout',
  components: {
    Sidebar
  }
}
</script>

<style scoped>
/* Responsividad para el layout */
@media (max-width: 1024px) {
  header {
    @apply ml-72;
  }
  
  main {
    @apply ml-72;
  }
}

@media (max-width: 768px) {
  header {
    @apply ml-72;
  }
  
  main {
    @apply ml-72;
  }
}

/* Para pantallas muy pequeñas, podríamos ocultar el sidebar o hacerlo overlay */
@media (max-width: 640px) {
  header {
    @apply ml-0;
  }
  
  main {
    @apply ml-0;
  }
}
</style>