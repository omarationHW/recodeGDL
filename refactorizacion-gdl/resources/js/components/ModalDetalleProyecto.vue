<template>
  <div v-if="show && proyecto" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="cerrar"></div>

      <div class="inline-block align-bottom bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-6xl sm:w-full">
        <!-- Header con logo gubernamental -->
        <div class="bg-gradient-to-r from-blue-600 to-blue-800 px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-4">
              <img 
                src="/images/logo1.png" 
                alt="Gobierno de Guadalajara" 
                class="w-12 h-12 object-contain bg-white rounded-lg p-1"
              >
              <div class="text-white">
                <h3 class="text-xl font-bold" id="modal-title">
                  Detalle del Contrato #{{ proyecto.contrato }}
                </h3>
                <p class="text-blue-200 text-sm">{{ proyecto.nombre }}</p>
              </div>
            </div>
            <div class="flex items-center space-x-3">
              <button 
                @click="imprimirDetalle"
                class="bg-white/20 hover:bg-white/30 text-white px-3 py-2 rounded-lg transition-colors text-sm"
                title="Imprimir detalle"
              >
                <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                </svg>
              </button>
              <button @click="cerrar" class="text-white hover:text-gray-200 transition-colors">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
                </svg>
              </button>
            </div>
          </div>
        </div>

        <div class="max-h-[80vh] overflow-y-auto">
          <!-- Información General del Contrato -->
          <div class="p-6 border-b border-gray-200">
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
              <!-- Panel Izquierdo: Información Básica -->
              <div class="space-y-4">
                <div class="bg-gray-50 rounded-lg p-4">
                  <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center">
                    <svg class="w-5 h-5 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/>
                    </svg>
                    Información del Contrato
                  </h4>
                  
                  <div class="space-y-3">
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-600">Número de Contrato:</span>
                      <span class="text-sm font-bold text-gray-900">#{{ proyecto.contrato }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-600">Contratista:</span>
                      <span class="text-sm font-semibold text-gray-900">{{ proyecto.nombre }}</span>
                    </div>
                    <div class="flex items-center justify-between">
                      <span class="text-sm font-medium text-gray-600">Tipo de Pavimento:</span>
                      <span class="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                            :class="proyecto.tipo_pavimento === 'A' ? 'bg-green-100 text-green-800' : 'bg-gray-100 text-gray-800'">
                        {{ proyecto.tipo_pavimento === 'A' ? 'Asfalto' : 'Concreto Hidráulico' }}
                      </span>
                    </div>
                    <div class="pt-2 border-t border-gray-300">
                      <div class="flex items-center justify-between">
                        <span class="text-sm font-medium text-gray-600">Ubicación:</span>
                      </div>
                      <p class="text-sm text-gray-900 mt-1">{{ proyecto.calle }}</p>
                    </div>
                  </div>
                </div>
                
                <!-- Especificaciones Técnicas -->
                <div class="bg-blue-50 rounded-lg p-4">
                  <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center">
                    <svg class="w-5 h-5 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                    </svg>
                    Especificaciones
                  </h4>
                  
                  <div class="grid grid-cols-2 gap-4">
                    <div class="text-center bg-white rounded-lg p-3">
                      <div class="text-2xl font-bold text-blue-600">{{ proyecto.metros }}</div>
                      <div class="text-xs text-gray-600">Metros Cuadrados</div>
                    </div>
                    <div class="text-center bg-white rounded-lg p-3">
                      <div class="text-lg font-bold text-green-600">{{ formatCurrency(proyecto.costomtr) }}</div>
                      <div class="text-xs text-gray-600">Costo por m²</div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Panel Derecho: Información Financiera -->
              <div class="space-y-4">
                <div class="bg-green-50 rounded-lg p-4">
                  <h4 class="text-lg font-semibold text-gray-900 mb-3 flex items-center">
                    <svg class="w-5 h-5 text-green-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/>
                    </svg>
                    Información Financiera
                  </h4>
                  
                  <div class="space-y-3">
                    <div class="bg-white rounded-lg p-3">
                      <div class="flex items-center justify-between">
                        <span class="text-sm font-medium text-gray-600">Inversión Total:</span>
                        <span class="text-xl font-bold text-green-600">{{ formatCurrency(proyecto.costototal) }}</span>
                      </div>
                    </div>
                    
                    <div class="bg-white rounded-lg p-3">
                      <div class="flex items-center justify-between">
                        <span class="text-sm font-medium text-gray-600">Adeudo Pendiente:</span>
                        <span class="text-xl font-bold" :class="proyecto.adeudo_total > 0 ? 'text-red-600' : 'text-green-600'">
                          {{ formatCurrency(proyecto.adeudo_total || 0) }}
                        </span>
                      </div>
                    </div>
                    
                    <div class="bg-white rounded-lg p-3">
                      <div class="flex items-center justify-between">
                        <span class="text-sm font-medium text-gray-600">Monto Pagado:</span>
                        <span class="text-xl font-bold text-blue-600">
                          {{ formatCurrency((proyecto.costototal || 0) - (proyecto.adeudo_total || 0)) }}
                        </span>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Progreso de Pagos -->
                <div class="bg-gray-50 rounded-lg p-4">
                  <h5 class="text-md font-semibold text-gray-900 mb-3">Progreso de Pagos</h5>
                  <div class="w-full bg-gray-200 rounded-full h-3 mb-2">
                    <div 
                      class="bg-gradient-to-r from-blue-500 to-blue-600 h-3 rounded-full transition-all duration-500"
                      :style="`width: ${porcentajePagado}%`"
                    ></div>
                  </div>
                  <div class="flex justify-between text-xs text-gray-600">
                    <span>0%</span>
                    <span class="font-medium">{{ porcentajePagado.toFixed(1) }}% Pagado</span>
                    <span>100%</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Detalle de Adeudos por Mensualidad -->
          <div class="p-6">
            <div class="flex items-center justify-between mb-6">
              <h4 class="text-xl font-bold text-gray-900 flex items-center">
                <svg class="w-6 h-6 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                </svg>
                Control de Adeudos Mensuales
              </h4>
              
              <div class="flex items-center space-x-2">
                <div class="flex items-center space-x-1">
                  <div class="w-3 h-3 bg-green-500 rounded-full"></div>
                  <span class="text-xs text-gray-600">Pagado</span>
                </div>
                <div class="flex items-center space-x-1">
                  <div class="w-3 h-3 bg-red-500 rounded-full"></div>
                  <span class="text-xs text-gray-600">Pendiente</span>
                </div>
              </div>
            </div>

            <!-- Tabla de Adeudos -->
            <div class="bg-white rounded-lg border border-gray-200 overflow-hidden">
              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mes</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Año</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Mensualidad</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Recibo</th>
                      <th class="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <tr 
                      v-for="adeudo in adeudosOrdenados" 
                      :key="adeudo.id_adeudo"
                      class="hover:bg-gray-50 transition-colors duration-150"
                      :class="adeudo.estado === 'P' ? 'bg-green-50' : 'bg-red-50'"
                    >
                      <td class="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                        {{ nombreMes(adeudo.mes) }}
                      </td>
                      <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900">
                        {{ adeudo.axo }}
                      </td>
                      <td class="px-4 py-3 whitespace-nowrap text-sm font-semibold text-gray-900">
                        {{ formatCurrency(adeudo.mensualidad) }}
                      </td>
                      <td class="px-4 py-3 whitespace-nowrap">
                        <span 
                          :class="`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                            adeudo.estado === 'P' 
                              ? 'bg-green-100 text-green-800' 
                              : 'bg-red-100 text-red-800'
                          }`"
                        >
                          <svg 
                            :class="`w-4 h-4 mr-1 ${adeudo.estado === 'P' ? 'text-green-600' : 'text-red-600'}`" 
                            fill="none" 
                            stroke="currentColor" 
                            viewBox="0 0 24 24"
                          >
                            <path v-if="adeudo.estado === 'P'" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                            <path v-else stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                          </svg>
                          {{ adeudo.estado === 'P' ? 'Pagado' : 'Pendiente' }}
                        </span>
                      </td>
                      <td class="px-4 py-3 whitespace-nowrap text-sm text-gray-900">
                        <span v-if="adeudo.numero_recibo" class="font-mono bg-gray-100 px-2 py-1 rounded text-xs">
                          {{ adeudo.numero_recibo }}
                        </span>
                        <span v-else class="text-gray-400 text-xs italic">Sin recibo</span>
                      </td>
                      <td class="px-4 py-3 whitespace-nowrap text-sm font-medium">
                        <button
                          v-if="adeudo.estado === 'V'"
                          @click="marcarComoPagado(adeudo)"
                          class="text-green-600 hover:text-green-900 transition-colors mr-3"
                          title="Marcar como pagado"
                        >
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/>
                          </svg>
                        </button>
                        <button
                          @click="imprimirRecibo(adeudo)"
                          class="text-blue-600 hover:text-blue-900 transition-colors"
                          title="Imprimir recibo"
                        >
                          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                          </svg>
                        </button>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- Resumen Final -->
            <div class="mt-6 bg-blue-50 rounded-lg p-4">
              <div class="grid grid-cols-1 md:grid-cols-3 gap-4 text-center">
                <div>
                  <div class="text-2xl font-bold text-blue-600">{{ adeudosPagados }}</div>
                  <div class="text-sm text-gray-600">Mensualidades Pagadas</div>
                </div>
                <div>
                  <div class="text-2xl font-bold text-red-600">{{ adeudosPendientes }}</div>
                  <div class="text-sm text-gray-600">Mensualidades Pendientes</div>
                </div>
                <div>
                  <div class="text-2xl font-bold text-green-600">{{ formatCurrency(totalPagado) }}</div>
                  <div class="text-sm text-gray-600">Total Pagado</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div class="flex items-center justify-between px-6 py-4 bg-gray-50 border-t border-gray-200">
          <div class="text-sm text-gray-500">
            <img src="/images/logo1.png" alt="Gobierno de Guadalajara" class="w-6 h-6 inline-block mr-2">
            Sistema de Pavimentación - Gobierno Municipal de Guadalajara
          </div>
          
          <div class="flex items-center space-x-3">
            <button
              @click="exportarDetalleExcel"
              class="bg-green-100 hover:bg-green-200 text-green-700 px-4 py-2 rounded-lg text-sm font-semibold transition-all duration-200"
            >
              <svg class="w-4 h-4 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
              </svg>
              Exportar Detalle
            </button>
            
            <button
              @click="cerrar"
              class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-2 rounded-lg font-semibold transition-all duration-200"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModalDetalleProyecto',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    proyecto: {
      type: Object,
      default: null
    }
  },
  emits: ['close', 'actualizar'],
  
  computed: {
    adeudosOrdenados() {
      if (!this.proyecto?.adeudos) return []
      
      return [...this.proyecto.adeudos].sort((a, b) => {
        if (a.axo !== b.axo) return a.axo - b.axo
        return a.mes - b.mes
      })
    },
    
    adeudosPagados() {
      if (!this.proyecto?.adeudos) return 0
      return this.proyecto.adeudos.filter(a => a.estado === 'P').length
    },
    
    adeudosPendientes() {
      if (!this.proyecto?.adeudos) return 0
      return this.proyecto.adeudos.filter(a => a.estado === 'V').length
    },
    
    totalPagado() {
      if (!this.proyecto?.adeudos) return 0
      return this.proyecto.adeudos
        .filter(a => a.estado === 'P')
        .reduce((total, a) => total + parseFloat(a.mensualidad), 0)
    },
    
    porcentajePagado() {
      if (!this.proyecto) return 0
      const total = parseFloat(this.proyecto.costototal)
      if (total === 0) return 0
      return ((total - (this.proyecto.adeudo_total || 0)) / total) * 100
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
    
    nombreMes(numeroMes) {
      const meses = [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ]
      return meses[numeroMes - 1] || `Mes ${numeroMes}`
    },
    
    async marcarComoPagado(adeudo) {
      // Implementar lógica para marcar como pagado
      console.log('Marcar como pagado:', adeudo)
      // Aquí llamarías a la API para actualizar el estado
      this.$emit('actualizar', this.proyecto.id_control)
    },
    
    imprimirRecibo(adeudo) {
      // Implementar lógica para imprimir recibo individual
      console.log('Imprimir recibo:', adeudo)
    },
    
    imprimirDetalle() {
      // Implementar lógica para imprimir detalle completo
      console.log('Imprimir detalle completo del proyecto')
      window.print()
    },
    
    exportarDetalleExcel() {
      // Implementar lógica para exportar este proyecto específico a Excel
      console.log('Exportar detalle a Excel')
    },
    
    cerrar() {
      this.$emit('close')
    }
  }
}
</script>

<style scoped>
/* Mejoras visuales para la tabla */
tbody tr:hover {
  transform: translateX(2px);
}

/* Animaciones para los estados */
.bg-green-50 {
  border-left: 4px solid #10b981;
}

.bg-red-50 {
  border-left: 4px solid #ef4444;
}

/* Barra de progreso animada */
.bg-gradient-to-r {
  background-size: 200% 200%;
  animation: shimmer 2s infinite;
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}

/* Scroll personalizado para el modal */
.max-h-[80vh]::-webkit-scrollbar {
  width: 8px;
}

.max-h-[80vh]::-webkit-scrollbar-track {
  background: #f1f5f9;
}

.max-h-[80vh]::-webkit-scrollbar-thumb {
  background: #cbd5e1;
  border-radius: 4px;
}

.max-h-[80vh]::-webkit-scrollbar-thumb:hover {
  background: #94a3b8;
}

/* Estados de impresión */
@media print {
  .no-print {
    display: none !important;
  }
  
  .print-header {
    display: block !important;
  }
}
</style>