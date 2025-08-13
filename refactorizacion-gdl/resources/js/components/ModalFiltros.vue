<template>
  <div v-if="show" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="cerrar"></div>

      <div class="inline-block align-bottom bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-2xl sm:w-full">
        <!-- Header -->
        <div class="bg-gradient-to-r from-purple-600 to-purple-800 px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"/>
                </svg>
              </div>
              <div class="text-white">
                <h3 class="text-xl font-bold" id="modal-title">Filtros Avanzados</h3>
                <p class="text-purple-200 text-sm">Configure los criterios de búsqueda y filtrado</p>
              </div>
            </div>
            <button @click="cerrar" class="text-white hover:text-gray-200 transition-colors">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Contenido -->
        <div class="p-6 space-y-6">
          <!-- Filtro por Tipo de Pavimento -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-3">
              <svg class="w-5 h-5 inline-block mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
              </svg>
              Tipo de Pavimento
            </label>
            <div class="grid grid-cols-3 gap-3">
              <button
                @click="filtros.tipo_pavimento = ''"
                :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                  filtros.tipo_pavimento === '' 
                    ? 'border-purple-500 bg-purple-50 text-purple-700' 
                    : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-purple-300'
                }`"
              >
                <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                </svg>
                Todos
              </button>
              <button
                @click="filtros.tipo_pavimento = 'A'"
                :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                  filtros.tipo_pavimento === 'A' 
                    ? 'border-purple-500 bg-purple-50 text-purple-700' 
                    : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-purple-300'
                }`"
              >
                <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"/>
                </svg>
                Asfalto
              </button>
              <button
                @click="filtros.tipo_pavimento = 'H'"
                :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                  filtros.tipo_pavimento === 'H' 
                    ? 'border-purple-500 bg-purple-50 text-purple-700' 
                    : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-purple-300'
                }`"
              >
                <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                </svg>
                Concreto
              </button>
            </div>
          </div>

          <!-- Filtro por Estado de Adeudos -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-3">
              <svg class="w-5 h-5 inline-block mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              Estado de Pagos
            </label>
            <div class="grid grid-cols-3 gap-3">
              <button
                @click="filtros.con_adeudos = null"
                :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                  filtros.con_adeudos === null 
                    ? 'border-purple-500 bg-purple-50 text-purple-700' 
                    : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-purple-300'
                }`"
              >
                <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                </svg>
                Todos
              </button>
              <button
                @click="filtros.con_adeudos = true"
                :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                  filtros.con_adeudos === true 
                    ? 'border-red-500 bg-red-50 text-red-700' 
                    : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-red-300'
                }`"
              >
                <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                </svg>
                Con Adeudos
              </button>
              <button
                @click="filtros.con_adeudos = false"
                :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                  filtros.con_adeudos === false 
                    ? 'border-green-500 bg-green-50 text-green-700' 
                    : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-green-300'
                }`"
              >
                <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Al Corriente
              </button>
            </div>
          </div>

          <!-- Filtro por Rango de Montos -->
          <div class="bg-gray-50 rounded-lg p-4">
            <label class="block text-sm font-semibold text-gray-700 mb-4">
              <svg class="w-5 h-5 inline-block mr-2 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/>
              </svg>
              Rango de Inversión
            </label>
            
            <div class="grid grid-cols-2 gap-4">
              <div>
                <label class="block text-xs font-medium text-gray-600 mb-2">Monto Mínimo</label>
                <div class="relative">
                  <span class="absolute left-3 top-3 text-gray-500">$</span>
                  <input
                    v-model="filtros.monto_min"
                    type="number"
                    min="0"
                    step="0.01"
                    class="w-full pl-8 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="0.00"
                  >
                </div>
              </div>
              
              <div>
                <label class="block text-xs font-medium text-gray-600 mb-2">Monto Máximo</label>
                <div class="relative">
                  <span class="absolute left-3 top-3 text-gray-500">$</span>
                  <input
                    v-model="filtros.monto_max"
                    type="number"
                    min="0"
                    step="0.01"
                    class="w-full pl-8 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                    placeholder="0.00"
                  >
                </div>
              </div>
            </div>
            
            <!-- Presets de rangos comunes -->
            <div class="mt-4">
              <p class="text-xs font-medium text-gray-600 mb-2">Rangos comunes:</p>
              <div class="flex flex-wrap gap-2">
                <button
                  @click="establecerRango(0, 10000)"
                  class="px-3 py-1 text-xs font-medium bg-white border border-gray-300 rounded-full hover:border-purple-400 hover:bg-purple-50 transition-colors"
                >
                  Hasta $10,000
                </button>
                <button
                  @click="establecerRango(10000, 50000)"
                  class="px-3 py-1 text-xs font-medium bg-white border border-gray-300 rounded-full hover:border-purple-400 hover:bg-purple-50 transition-colors"
                >
                  $10,000 - $50,000
                </button>
                <button
                  @click="establecerRango(50000, null)"
                  class="px-3 py-1 text-xs font-medium bg-white border border-gray-300 rounded-full hover:border-purple-400 hover:bg-purple-50 transition-colors"
                >
                  Más de $50,000
                </button>
                <button
                  @click="limpiarRangos"
                  class="px-3 py-1 text-xs font-medium bg-red-100 text-red-700 border border-red-200 rounded-full hover:bg-red-200 transition-colors"
                >
                  Limpiar rangos
                </button>
              </div>
            </div>
          </div>

          <!-- Resumen de filtros -->
          <div v-if="tienesFiltrosActivos" class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <h4 class="text-sm font-semibold text-blue-800 mb-2 flex items-center">
              <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              Filtros que se aplicarán:
            </h4>
            <ul class="text-sm text-blue-700 space-y-1">
              <li v-if="filtros.tipo_pavimento">
                • Tipo: {{ filtros.tipo_pavimento === 'A' ? 'Asfalto' : 'Concreto Hidráulico' }}
              </li>
              <li v-if="filtros.con_adeudos !== null">
                • Estado: {{ filtros.con_adeudos ? 'Con adeudos pendientes' : 'Al corriente' }}
              </li>
              <li v-if="filtros.monto_min || filtros.monto_max">
                • Monto: 
                <span v-if="filtros.monto_min && filtros.monto_max">
                  Entre {{ formatCurrency(filtros.monto_min) }} y {{ formatCurrency(filtros.monto_max) }}
                </span>
                <span v-else-if="filtros.monto_min">
                  Mayor a {{ formatCurrency(filtros.monto_min) }}
                </span>
                <span v-else>
                  Menor a {{ formatCurrency(filtros.monto_max) }}
                </span>
              </li>
            </ul>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="flex items-center justify-between px-6 py-4 bg-gray-50 border-t border-gray-200">
          <button
            @click="limpiarTodosFiltros"
            class="bg-red-100 hover:bg-red-200 text-red-700 px-4 py-2 rounded-lg font-semibold transition-all duration-200"
          >
            Limpiar Todo
          </button>
          
          <div class="flex items-center space-x-3">
            <button
              @click="cerrar"
              class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-2 rounded-lg font-semibold transition-all duration-200"
            >
              Cancelar
            </button>
            
            <button
              @click="aplicarFiltros"
              class="bg-gradient-to-r from-purple-600 to-purple-700 hover:from-purple-700 hover:to-purple-800 text-white px-8 py-2 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105"
            >
              <svg class="w-4 h-4 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"/>
              </svg>
              Aplicar Filtros
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModalFiltros',
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'apply'],
  
  data() {
    return {
      filtros: {
        tipo_pavimento: '',
        con_adeudos: null,
        monto_min: '',
        monto_max: ''
      }
    }
  },
  
  computed: {
    tienesFiltrosActivos() {
      return this.filtros.tipo_pavimento ||
             this.filtros.con_adeudos !== null ||
             this.filtros.monto_min ||
             this.filtros.monto_max
    }
  },
  
  methods: {
    formatCurrency(value) {
      if (!value || isNaN(value)) return '$0.00'
      return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(value)
    },
    
    establecerRango(min, max) {
      this.filtros.monto_min = min || ''
      this.filtros.monto_max = max || ''
    },
    
    limpiarRangos() {
      this.filtros.monto_min = ''
      this.filtros.monto_max = ''
    },
    
    limpiarTodosFiltros() {
      this.filtros = {
        tipo_pavimento: '',
        con_adeudos: null,
        monto_min: '',
        monto_max: ''
      }
    },
    
    aplicarFiltros() {
      // Limpiar filtros vacíos
      const filtrosLimpios = {}
      
      Object.entries(this.filtros).forEach(([key, value]) => {
        if (value !== '' && value !== null && value !== undefined) {
          filtrosLimpios[key] = value
        }
      })
      
      this.$emit('apply', filtrosLimpios)
    },
    
    cerrar() {
      this.$emit('close')
    }
  }
}
</script>

<style scoped>
/* Transiciones para los botones de filtro */
button {
  transition: all 0.2s ease;
}

button:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

/* Estados activos para filtros */
.border-purple-500 {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(147, 51, 234, 0.2);
}

.border-red-500 {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
}

.border-green-500 {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(34, 197, 94, 0.2);
}

/* Focus states */
input:focus {
  box-shadow: 0 0 0 3px rgba(147, 51, 234, 0.1);
}
</style>