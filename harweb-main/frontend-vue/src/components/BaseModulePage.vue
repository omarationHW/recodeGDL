<template>
  <div class="module-page">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">{{ title }}</h1>
      <p class="mt-2 text-gray-600">{{ description }}</p>
    </div>

    <div class="bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">{{ moduleName }}</h2>
      </div>
      
      <div class="p-6">
        <!-- Slot para contenido específico si existe -->
        <slot v-if="$slots.default" />
        
        <!-- Contenido por defecto "en desarrollo" -->
        <div v-else class="text-center py-12">
          <div class="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-yellow-100 mb-4">
            <i class="fas fa-tools text-yellow-600"></i>
          </div>
          
          <h3 class="mt-2 text-sm font-medium text-gray-900">Módulo en Desarrollo</h3>
          <p class="mt-1 text-sm text-gray-500">
            Esta funcionalidad está siendo implementada
          </p>
          
          <div class="mt-6 bg-gray-50 rounded-lg p-4">
            <div class="text-sm text-gray-600">
              <p><strong>Módulo:</strong> {{ moduleName }}</p>
              <p><strong>Estado:</strong> <span class="text-yellow-600 font-medium">En Desarrollo</span></p>
              <p><strong>Tipo:</strong> {{ moduleType }}</p>
            </div>
          </div>
          
          <div class="mt-6">
            <button class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-gray-400 cursor-not-allowed" disabled>
              <i class="fas fa-lock mr-2"></i>
              Funcionalidad No Disponible
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BaseModulePage',
  props: {
    title: {
      type: String,
      required: true
    },
    description: {
      type: String,
      required: true
    },
    moduleName: {
      type: String,
      required: true
    },
    moduleType: {
      type: String,
      default: 'Sistema Municipal'
    }
  }
}
</script>

<style scoped>
.module-page {
  padding: 1.5rem;
  min-height: 100vh;
  background-color: #f8fafc;
}
</style>