<template>
  <div class="min-h-full bg-gradient-to-br from-blue-50 via-white to-indigo-50">
    <!-- Loading State -->
    <div v-if="loading" class="flex items-center justify-center min-h-screen">
      <div class="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="flex items-center justify-center min-h-screen">
      <div class="text-center">
        <div class="text-red-500 text-6xl mb-4">⚠️</div>
        <h2 class="text-2xl font-bold text-gray-900 mb-2">Error al cargar información</h2>
        <p class="text-gray-600 mb-4">{{ error }}</p>
        <button 
          @click="loadModuleInfo" 
          class="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700"
        >
          Reintentar
        </button>
      </div>
    </div>

    <!-- Module Info Content -->
    <div v-else-if="moduleInfo" class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Header -->
      <div class="bg-white shadow-lg rounded-xl mb-8 overflow-hidden">
        <div class="px-8 py-6" :style="`background: linear-gradient(135deg, ${moduleInfo.color}15 0%, ${moduleInfo.color}25 100%)`">
          <div class="flex items-center mb-4">
            <div class="w-16 h-16 rounded-xl flex items-center justify-center mr-6" 
                 :style="`background: ${moduleInfo.color}20`">
              <i :class="moduleInfo.icon" class="text-3xl" :style="`color: ${moduleInfo.color}`"></i>
            </div>
            <div class="flex-1">
              <h1 class="text-3xl font-bold text-gray-900 mb-2">
                {{ moduleInfo.displayName }}
              </h1>
              <p class="text-lg text-gray-600 leading-relaxed">
                {{ moduleInfo.description }}
              </p>
            </div>
          </div>

          <!-- Quick Stats -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mt-6">
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">{{ moduleInfo.stats.components }}</div>
              <div class="text-sm text-gray-600">Componentes</div>
            </div>
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">{{ moduleInfo.stats.forms }}</div>
              <div class="text-sm text-gray-600">Formularios</div>
            </div>
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">{{ moduleInfo.stats.reports }}</div>
              <div class="text-sm text-gray-600">Reportes</div>
            </div>
            <div class="bg-white bg-opacity-70 rounded-lg p-4 text-center">
              <div class="text-2xl font-bold text-gray-900">{{ moduleInfo.stats.procedures }}</div>
              <div class="text-sm text-gray-600">Procedimientos</div>
            </div>
          </div>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Features Section -->
        <div class="bg-white shadow-lg rounded-xl p-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <i class="fas fa-star text-yellow-500 mr-3"></i>
            Funcionalidades Principales
          </h2>
          <ul class="space-y-4">
            <li v-for="(feature, index) in moduleInfo.features" :key="index" 
                class="flex items-start">
              <div class="w-2 h-2 rounded-full mt-2 mr-4 flex-shrink-0" 
                   :style="`background-color: ${moduleInfo.color}`"></div>
              <span class="text-gray-700 leading-relaxed">{{ feature }}</span>
            </li>
          </ul>
        </div>

        <!-- Documentation Section -->
        <div class="bg-white shadow-lg rounded-xl p-8">
          <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
            <i class="fas fa-book text-blue-500 mr-3"></i>
            Documentación Técnica
          </h2>
          <div class="space-y-4">
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <i class="fas fa-file-alt text-gray-500 mr-3"></i>
                <span class="font-medium text-gray-900">Documentos Totales</span>
              </div>
              <span class="bg-blue-100 text-blue-800 px-3 py-1 rounded-full text-sm font-medium">
                {{ moduleInfo.documentation.total_docs }}
              </span>
            </div>
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <i class="fas fa-sitemap text-gray-500 mr-3"></i>
                <span class="font-medium text-gray-900">Casos de Uso</span>
              </div>
              <span class="bg-green-100 text-green-800 px-3 py-1 rounded-full text-sm font-medium">
                {{ moduleInfo.documentation.use_cases }}
              </span>
            </div>
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center">
                <i class="fas fa-vial text-gray-500 mr-3"></i>
                <span class="font-medium text-gray-900">Casos de Prueba</span>
              </div>
              <span class="bg-purple-100 text-purple-800 px-3 py-1 rounded-full text-sm font-medium">
                {{ moduleInfo.documentation.test_cases }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Back Button -->
      <div class="mt-8 text-center">
        <button 
          @click="goBack"
          class="bg-gray-600 text-white px-8 py-3 rounded-lg hover:bg-gray-700 transition-colors duration-200 inline-flex items-center"
        >
          <i class="fas fa-arrow-left mr-2"></i>
          Volver al Dashboard
        </button>
      </div>

      <!-- RefactorX Branding -->
      <div class="mt-8 text-center">
        <div class="bg-white shadow-lg rounded-xl p-6">
          <div class="flex items-center justify-center mb-4">
            <div class="w-12 h-12 bg-blue-600 rounded-lg flex items-center justify-center mr-4">
              <span class="text-white font-bold text-lg">R</span>
            </div>
            <div class="text-left">
              <div class="text-xl font-bold text-gray-900">RefactorX</div>
              <div class="text-gray-600">Especialistas en Recodificación de Sistemas</div>
            </div>
          </div>
          <p class="text-gray-500 text-sm">
            Sistema migrado exitosamente de Delphi a tecnologías web modernas
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModuleInfo',
  data() {
    return {
      moduleInfo: null,
      loading: true,
      error: null
    }
  },
  computed: {
    moduleId() {
      return this.$route.params.module
    }
  },
  mounted() {
    this.loadModuleInfo()
  },
  watch: {
    '$route'() {
      this.loadModuleInfo()
    }
  },
  methods: {
    async loadModuleInfo() {
      this.loading = true
      this.error = null
      
      try {
        const response = await fetch(`http://localhost:8000/module-info.php?module=${this.moduleId}`)
        const result = await response.json()
        
        if (result.success) {
          this.moduleInfo = result.data
        } else {
          this.error = result.message || 'Error al cargar la información del módulo'
        }
      } catch (err) {
        this.error = 'Error de conexión con el servidor'
        console.error('Error loading module info:', err)
      } finally {
        this.loading = false
      }
    },
    goBack() {
      this.$router.push('/dashboard')
    }
  }
}
</script>

<style scoped>
/* Animaciones personalizadas */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter, .fade-leave-to {
  opacity: 0;
}
</style>