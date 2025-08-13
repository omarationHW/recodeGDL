<template>
  <div v-if="show" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="cerrar"></div>

      <div class="inline-block align-bottom bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
        <!-- Header -->
        <div class="bg-gradient-to-r from-red-600 to-red-800 px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <img 
                src="/images/logo1.png" 
                alt="Gobierno de Guadalajara" 
                class="w-10 h-10 object-contain bg-white rounded-lg p-1"
              >
              <div class="text-white">
                <h3 class="text-xl font-bold" id="modal-title">Configuración de Reporte</h3>
                <p class="text-red-200 text-sm">Personalice las opciones para la generación del reporte PDF</p>
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
        <div class="p-6">
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <!-- Configuración del Reporte -->
            <div class="space-y-6">
              <div>
                <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                  <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6V4m0 2a2 2 0 100 4m0-4a2 2 0 110 4m-6 8a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4m6 6v10m6-2a2 2 0 100-4m0 4a2 2 0 100 4m0-4v2m0-6V4"/>
                  </svg>
                  Configuración del Reporte
                </h4>

                <!-- Título del Reporte -->
                <div class="mb-4">
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Título del Reporte</label>
                  <input
                    v-model="configuracion.titulo"
                    type="text"
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
                    placeholder="Reporte de Obras de Pavimentación"
                  >
                </div>

                <!-- Período del Reporte -->
                <div class="mb-4">
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Período</label>
                  <select 
                    v-model="configuracion.periodo" 
                    class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-red-500 focus:border-transparent"
                  >
                    <option value="2025">Año 2025 (Completo)</option>
                    <option value="2025-actual">Año 2025 (Hasta la fecha)</option>
                    <option value="custom">Período personalizado</option>
                  </select>
                </div>

                <!-- Filtros Aplicados -->
                <div class="mb-4">
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Incluir en el Reporte</label>
                  <div class="space-y-3">
                    <label class="flex items-center">
                      <input 
                        v-model="configuracion.incluir_estadisticas" 
                        type="checkbox" 
                        class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
                      >
                      <span class="ml-3 text-sm text-gray-700">Resumen ejecutivo y estadísticas</span>
                    </label>
                    
                    <label class="flex items-center">
                      <input 
                        v-model="configuracion.incluir_detalles" 
                        type="checkbox" 
                        class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
                      >
                      <span class="ml-3 text-sm text-gray-700">Detalle de contratos</span>
                    </label>
                    
                    <label class="flex items-center">
                      <input 
                        v-model="configuracion.incluir_adeudos" 
                        type="checkbox" 
                        class="h-4 w-4 text-red-600 focus:ring-red-500 border-gray-300 rounded"
                      >
                      <span class="ml-3 text-sm text-gray-700">Control de adeudos mensuales</span>
                    </label>
                    
                  </div>
                </div>

                <!-- Formato -->
                <div class="mb-4">
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Formato de Página</label>
                  <div class="grid grid-cols-2 gap-3">
                    <button
                      @click="configuracion.formato = 'carta'"
                      :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                        configuracion.formato === 'carta' 
                          ? 'border-red-500 bg-red-50 text-red-700' 
                          : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-red-300'
                      }`"
                    >
                      <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                      </svg>
                      Carta
                    </button>
                    <button
                      @click="configuracion.formato = 'oficio'"
                      :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                        configuracion.formato === 'oficio' 
                          ? 'border-red-500 bg-red-50 text-red-700' 
                          : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-red-300'
                      }`"
                    >
                      <svg class="w-5 h-5 mx-auto mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                      </svg>
                      Oficio
                    </button>
                  </div>
                </div>

                <!-- Orientación -->
                <div class="mb-4">
                  <label class="block text-sm font-semibold text-gray-700 mb-2">Orientación</label>
                  <div class="grid grid-cols-2 gap-3">
                    <button
                      @click="configuracion.orientacion = 'vertical'"
                      :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                        configuracion.orientacion === 'vertical' 
                          ? 'border-red-500 bg-red-50 text-red-700' 
                          : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-red-300'
                      }`"
                    >
                      <div class="w-4 h-6 bg-current mx-auto mb-1 rounded"></div>
                      Vertical
                    </button>
                    <button
                      @click="configuracion.orientacion = 'horizontal'"
                      :class="`p-3 rounded-lg border-2 text-sm font-medium transition-all duration-200 ${
                        configuracion.orientacion === 'horizontal' 
                          ? 'border-red-500 bg-red-50 text-red-700' 
                          : 'border-gray-200 bg-gray-50 text-gray-700 hover:border-red-300'
                      }`"
                    >
                      <div class="w-6 h-4 bg-current mx-auto mb-1 rounded"></div>
                      Horizontal
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Vista Previa -->
            <div class="bg-gray-100 rounded-lg p-4">
              <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
                <svg class="w-5 h-5 text-red-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                </svg>
                Vista Previa
              </h4>

              <!-- Simulación de página PDF -->
              <div class="bg-white rounded-lg shadow-lg p-6 mx-auto" 
                   :style="estilosVistaPreviaWidth">
                <!-- Header del PDF -->
                <div class="border-b border-gray-300 pb-4 mb-4">
                  <div class="flex items-center justify-between">
                    <div class="flex items-center space-x-3">
                      <img 
                        src="/images/logo1.png" 
                        alt="Gobierno de Guadalajara" 
                        class="w-12 h-12 object-contain"
                      >
                      <div>
                        <h1 class="text-lg font-bold text-gray-900">{{ configuracion.titulo }}</h1>
                        <p class="text-sm text-gray-600">Gobierno Municipal de Guadalajara</p>
                        <p class="text-xs text-gray-500">{{ fechaReporte }}</p>
                      </div>
                    </div>
                    <div class="text-right text-xs text-gray-500">
                      <p>Fecha: {{ fechaActual }}</p>
                      <p>Página: 1 de N</p>
                    </div>
                  </div>
                </div>

                <!-- Contenido simulado -->
                <div class="space-y-4">
                  <div v-if="configuracion.incluir_estadisticas" class="bg-blue-50 rounded p-3">
                    <h3 class="font-semibold text-sm mb-2">Resumen Ejecutivo</h3>
                    <div class="grid grid-cols-3 gap-2 text-xs">
                      <div>Total Contratos: 9</div>
                      <div>Inversión Total: $94,232.50</div>
                      <div>Adeudos: $83,917.90</div>
                    </div>
                  </div>

                  <div v-if="configuracion.incluir_detalles" class="border border-gray-200 rounded p-3">
                    <h3 class="font-semibold text-sm mb-2">Detalle de Contratos</h3>
                    <div class="space-y-1 text-xs">
                      <div class="grid grid-cols-4 gap-1 font-medium border-b pb-1">
                        <span>Contrato</span>
                        <span>Contratista</span>
                        <span>Tipo</span>
                        <span>Monto</span>
                      </div>
                      <div class="grid grid-cols-4 gap-1 text-gray-600">
                        <span>001</span>
                        <span>BENITA CABRERA...</span>
                        <span>Concreto</span>
                        <span>$9,750.00</span>
                      </div>
                      <div class="text-center text-gray-500 py-2">...</div>
                    </div>
                  </div>

                  <div v-if="configuracion.incluir_adeudos" class="border border-gray-200 rounded p-3">
                    <h3 class="font-semibold text-sm mb-2">Control de Adeudos</h3>
                    <div class="text-xs text-gray-600">
                      <p>Tabla detallada de adeudos mensuales por contrato...</p>
                    </div>
                  </div>

                </div>

                <!-- Footer del PDF -->
                <div class="border-t border-gray-300 pt-2 mt-4 text-xs text-gray-500 text-center">
                  <p>Sistema de Pavimentación - Gobierno Municipal de Guadalajara</p>
                  <p>Generado el {{ fechaActual }} - Documento oficial</p>
                </div>
              </div>

              <!-- Información adicional -->
              <div class="mt-4 p-3 bg-yellow-50 border border-yellow-200 rounded-lg">
                <div class="flex items-start space-x-2">
                  <svg class="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                  </svg>
                  <div>
                    <h5 class="text-sm font-semibold text-yellow-800">Información del Reporte</h5>
                    <ul class="text-sm text-yellow-700 mt-1 space-y-1">
                      <li>• Se incluirán {{ conteoSecciones }} secciones principales</li>
                      <li>• Formato: {{ configuracion.formato.toUpperCase() }} en orientación {{ configuracion.orientacion }}</li>
                      <li>• El reporte incluirá marca de agua y numeración de páginas</li>
                      <li>• Fecha de generación y firma digital oficial</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Botones de Acción -->
        <div class="flex items-center justify-between px-6 py-4 bg-gray-50 border-t border-gray-200">
          <div class="text-sm text-gray-500 flex items-center">
            <svg class="w-4 h-4 mr-2 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            El reporte se generará con la configuración actual
          </div>
          
          <div class="flex items-center space-x-3">
            <button
              @click="cerrar"
              class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-2 rounded-lg font-semibold transition-all duration-200"
            >
              Cancelar
            </button>
            
            <button
              @click="generarReporte"
              :disabled="generando"
              class="bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 disabled:from-gray-400 disabled:to-gray-500 text-white px-8 py-2 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105 disabled:transform-none disabled:cursor-not-allowed"
            >
              <svg v-if="generando" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <svg v-else class="w-5 h-5 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
              </svg>
              {{ generando ? 'Generando...' : 'Generar Reporte PDF' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModalVistaPreviaPDF',
  props: {
    show: {
      type: Boolean,
      default: false
    }
  },
  emits: ['close', 'generar'],
  
  data() {
    return {
      generando: false,
      configuracion: {
        titulo: 'Reporte de Obras de Pavimentación 2025',
        periodo: '2025',
        formato: 'carta',
        orientacion: 'vertical',
        incluir_estadisticas: true,
        incluir_detalles: true,
        incluir_adeudos: true
      }
    }
  },
  
  computed: {
    fechaActual() {
      return new Date().toLocaleDateString('es-MX', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
    },
    
    fechaReporte() {
      switch (this.configuracion.periodo) {
        case '2025':
          return 'Ejercicio Fiscal 2025 (Enero - Diciembre)'
        case '2025-actual':
          return `Enero - ${new Date().toLocaleDateString('es-MX', { month: 'long' })} 2025`
        default:
          return 'Período personalizado'
      }
    },
    
    conteoSecciones() {
      let secciones = 1 // Siempre incluye header
      if (this.configuracion.incluir_estadisticas) secciones++
      if (this.configuracion.incluir_detalles) secciones++
      if (this.configuracion.incluir_adeudos) secciones++
      return secciones
    },
    
    estilosVistaPreviaWidth() {
      const baseWidth = this.configuracion.orientacion === 'vertical' ? '210mm' : '297mm'
      const scale = 0.3 // Escala para la vista previa
      
      return {
        width: this.configuracion.orientacion === 'vertical' ? '250px' : '350px',
        minHeight: this.configuracion.orientacion === 'vertical' ? '320px' : '250px'
      }
    }
  },
  
  methods: {
    async generarReporte() {
      if (this.generando) return
      
      this.generando = true
      
      try {
        await new Promise(resolve => setTimeout(resolve, 1500)) // Simular tiempo de generación
        this.$emit('generar', this.configuracion)
      } catch (error) {
        console.error('Error al generar reporte:', error)
      } finally {
        this.generando = false
      }
    },
    
    cerrar() {
      if (!this.generando) {
        this.$emit('close')
      }
    }
  }
}
</script>

<style scoped>
/* Animaciones para la vista previa */
.shadow-lg {
  transition: transform 0.3s ease;
}

.shadow-lg:hover {
  transform: scale(1.02);
}

/* Estilos para botones de configuración */
button {
  transition: all 0.2s ease;
}

.border-red-500 {
  transform: scale(1.05);
  box-shadow: 0 4px 12px rgba(239, 68, 68, 0.2);
}

/* Vista previa responsive */
@media (max-width: 1024px) {
  .grid-cols-1.lg\\:grid-cols-2 {
    grid-template-columns: 1fr;
  }
}

/* Estados de loading */
button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

.animate-spin {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}
</style>