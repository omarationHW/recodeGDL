<template>
  <AppLayout>
    <div class="min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
      <!-- Header Gubernamental -->
      <div class="bg-gradient-to-r from-blue-900 via-blue-800 to-blue-900 shadow-xl">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex items-center justify-between py-6">
            <div class="flex items-center space-x-4">
              <div class="flex items-center space-x-3">
                <img 
                  src="/images/logo1.png" 
                  alt="Gobierno de Guadalajara" 
                  class="w-14 h-14 object-contain bg-white rounded-lg p-1 shadow-lg"
                >
                <div class="w-12 h-12 bg-white/20 rounded-lg flex items-center justify-center">
                  <svg class="w-8 h-8 text-white" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5"/>
                  </svg>
                </div>
              </div>
              <div class="text-white">
                <h1 class="text-3xl font-bold tracking-tight">Sistema de Pavimentación</h1>
                <p class="text-blue-200 text-lg">Gestión de Obras y Adeudos Municipales</p>
                <p class="text-blue-300 text-sm font-medium">Gobierno Municipal de Guadalajara</p>
              </div>
            </div>
            <div class="hidden md:flex items-center space-x-4 text-white">
              <div class="text-right">
                <p class="text-sm text-blue-200">{{ fechaActual }}</p>
                <p class="text-lg font-semibold">Guadalajara, Jalisco</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Panel de Control y Estadísticas -->
        <div class="grid grid-cols-1 lg:grid-cols-4 gap-6 mb-8">
          <div class="lg:col-span-3">
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
              <!-- Estadística: Total Contratos -->
              <div class="bg-white rounded-xl shadow-lg border border-gray-100 p-6 transform hover:scale-105 transition-all duration-200">
                <div class="flex items-center">
                  <div class="flex-shrink-0">
                    <div class="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                      <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                      </svg>
                    </div>
                  </div>
                  <div class="ml-4 flex-1">
                    <p class="text-sm font-medium text-gray-600">Total Contratos</p>
                    <p class="text-2xl font-bold text-gray-900">{{ estadisticas.total_contratos || proyectos.length }}</p>
                    <p class="text-xs text-gray-500 mt-1">Activos en sistema</p>
                  </div>
                </div>
              </div>

              <!-- Estadística: Inversión Total -->
              <div class="bg-white rounded-xl shadow-lg border border-gray-100 p-6 transform hover:scale-105 transition-all duration-200">
                <div class="flex items-center">
                  <div class="flex-shrink-0">
                    <div class="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                      <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1"/>
                      </svg>
                    </div>
                  </div>
                  <div class="ml-4 flex-1">
                    <p class="text-sm font-medium text-gray-600">Inversión Total</p>
                    <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(estadisticas.inversion_total || totalInversion) }}</p>
                    <p class="text-xs text-gray-500 mt-1">Acumulado</p>
                  </div>
                </div>
              </div>

              <!-- Estadística: Adeudos Pendientes -->
              <div class="bg-white rounded-xl shadow-lg border border-gray-100 p-6 transform hover:scale-105 transition-all duration-200">
                <div class="flex items-center">
                  <div class="flex-shrink-0">
                    <div class="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
                      <svg class="w-6 h-6 text-red-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
                      </svg>
                    </div>
                  </div>
                  <div class="ml-4 flex-1">
                    <p class="text-sm font-medium text-gray-600">Adeudos Pendientes</p>
                    <p class="text-2xl font-bold text-gray-900">{{ formatCurrency(estadisticas.adeudo_total || totalAdeudos) }}</p>
                    <p class="text-xs text-gray-500 mt-1">Por cobrar</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Panel de Acciones Rápidas -->
          <div class="lg:col-span-1">
            <div class="bg-white rounded-xl shadow-lg border border-gray-100 p-6">
              <h3 class="text-lg font-semibold text-gray-900 mb-4">Acciones Rápidas</h3>
              <div class="space-y-3">
                <button 
                  @click="mostrarModalNuevo = true"
                  class="w-full bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 text-white px-4 py-3 rounded-lg text-sm font-semibold shadow-lg transition-all duration-200 transform hover:scale-105"
                >
                  <svg class="w-5 h-5 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                  </svg>
                  Nuevo Contrato
                </button>
                
                <button 
                  @click="mostrarModalFiltros = true"
                  class="w-full bg-gradient-to-r from-gray-600 to-gray-700 hover:from-gray-700 hover:to-gray-800 text-white px-4 py-3 rounded-lg text-sm font-semibold shadow-lg transition-all duration-200 transform hover:scale-105"
                >
                  <svg class="w-5 h-5 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"/>
                  </svg>
                  Aplicar Filtros
                </button>
                
                <div class="pt-2 border-t border-gray-200">
                  <button 
                    @click="exportarExcel"
                    class="w-full bg-gradient-to-r from-green-600 to-green-700 hover:from-green-700 hover:to-green-800 text-white px-4 py-2 rounded-lg text-sm font-semibold shadow-lg transition-all duration-200 transform hover:scale-105 mb-2"
                  >
                    <svg class="w-4 h-4 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
                    </svg>
                    Exportar Excel
                  </button>
                  
                  <button 
                    @click="generarPDF"
                    class="w-full bg-gradient-to-r from-red-600 to-red-700 hover:from-red-700 hover:to-red-800 text-white px-4 py-2 rounded-lg text-sm font-semibold shadow-lg transition-all duration-200 transform hover:scale-105"
                  >
                    <svg class="w-4 h-4 inline-block mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                    </svg>
                    Generar PDF
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Filtros Activos -->
        <div v-if="filtrosActivos.length > 0" class="mb-6">
          <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center space-x-2">
                <svg class="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.707A1 1 0 013 7V4z"/>
                </svg>
                <span class="text-blue-800 font-medium">Filtros activos:</span>
                <div class="flex flex-wrap gap-2">
                  <span 
                    v-for="filtro in filtrosActivos" 
                    :key="filtro.key"
                    class="inline-flex items-center px-3 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800"
                  >
                    {{ filtro.label }}: {{ filtro.value }}
                    <button 
                      @click="removerFiltro(filtro.key)"
                      class="ml-2 text-blue-600 hover:text-blue-800"
                    >
                      ×
                    </button>
                  </span>
                </div>
              </div>
              <button 
                @click="limpiarFiltros"
                class="text-blue-600 hover:text-blue-800 text-sm font-medium"
              >
                Limpiar todos
              </button>
            </div>
          </div>
        </div>

        <!-- Mensajes de Alerta -->
        <div v-if="mensaje" class="mb-6">
          <div :class="`p-4 rounded-lg border ${mensajeError ? 'bg-red-50 border-red-200 text-red-800' : 'bg-green-50 border-green-200 text-green-800'}`">
            <div class="flex items-center">
              <svg v-if="mensajeError" class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L3.732 16.5c-.77.833.192 2.5 1.732 2.5z"/>
              </svg>
              <svg v-else class="w-5 h-5 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span class="font-medium">{{ mensaje }}</span>
            </div>
          </div>
        </div>

        <!-- Tabla de Proyectos Mejorada -->
        <div class="bg-white rounded-xl shadow-lg border border-gray-100 overflow-hidden">
          <div class="px-6 py-4 border-b border-gray-200">
            <div class="flex items-center justify-between">
              <div>
                <h2 class="text-xl font-bold text-gray-900">Catálogo de Obras de Pavimento</h2>
                <p class="text-sm text-gray-600 mt-1">Total: {{ proyectosFiltrados.length }} contratos</p>
              </div>
              <div class="flex items-center space-x-3">
                <div class="relative">
                  <input
                    v-model="busqueda"
                    type="text"
                    placeholder="Buscar por nombre o contrato..."
                    class="pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                  >
                  <svg class="w-5 h-5 text-gray-400 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                  </svg>
                </div>
                <button 
                  @click="cargarProyectos"
                  class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg transition-colors duration-200"
                >
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>

          <!-- Tabla -->
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    <button @click="ordenar('contrato')" class="flex items-center space-x-1 hover:text-gray-700">
                      <span>Contrato</span>
                      <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l4-4 4 4m0 6l-4 4-4-4"/>
                      </svg>
                    </button>
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contratista</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Ubicación</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Especificaciones</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Inversión</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Adeudo</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr 
                  v-for="proyecto in proyectosFiltrados" 
                  :key="proyecto.id_control"
                  class="hover:bg-gray-50 transition-colors duration-150"
                >
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="flex items-center">
                      <div class="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center mr-3">
                        <span class="text-blue-600 font-bold text-sm">{{ proyecto.contrato }}</span>
                      </div>
                      <span class="text-sm font-medium text-gray-900">#{{ proyecto.contrato }}</span>
                    </div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="text-sm font-medium text-gray-900">{{ proyecto.nombre }}</div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="text-sm text-gray-900">{{ proyecto.calle }}</div>
                  </td>
                  <td class="px-6 py-4">
                    <div class="text-sm text-gray-900">
                      <span class="block">{{ proyecto.metros }}m²</span>
                      <span class="text-xs text-gray-500">
                        {{ proyecto.tipo_pavimento === 'A' ? 'Asfalto' : 'Concreto Hidráulico' }}
                      </span>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm">
                      <div class="font-medium text-gray-900">{{ formatCurrency(proyecto.costototal) }}</div>
                      <div class="text-xs text-gray-500">{{ formatCurrency(proyecto.costomtr) }}/m²</div>
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <div class="text-sm font-medium" :class="proyecto.adeudo_total > 0 ? 'text-red-600' : 'text-green-600'">
                      {{ formatCurrency(proyecto.adeudo_total || 0) }}
                    </div>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span 
                      :class="`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        proyecto.adeudo_total > 0 
                          ? 'bg-red-100 text-red-800' 
                          : 'bg-green-100 text-green-800'
                      }`"
                    >
                      {{ proyecto.adeudo_total > 0 ? 'Con adeudos' : 'Al corriente' }}
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div class="flex items-center space-x-2">
                      <button 
                        @click="verDetalle(proyecto)"
                        class="text-blue-600 hover:text-blue-900 transition-colors duration-200"
                        title="Ver detalle"
                      >
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                        </svg>
                      </button>
                      <button 
                        @click="editarProyecto(proyecto)"
                        class="text-amber-600 hover:text-amber-900 transition-colors duration-200"
                        title="Editar"
                      >
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Estado de carga o vacío -->
            <div v-if="cargando" class="text-center py-12">
              <svg class="animate-spin h-8 w-8 text-blue-600 mx-auto mb-4" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <p class="text-gray-500">Cargando información...</p>
            </div>
            
            <div v-else-if="proyectosFiltrados.length === 0" class="text-center py-12">
              <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
              </svg>
              <h3 class="text-lg font-medium text-gray-900 mb-2">No se encontraron contratos</h3>
              <p class="text-gray-500 mb-4">No hay contratos que coincidan con los filtros aplicados</p>
              <button 
                @click="mostrarModalNuevo = true"
                class="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-lg transition-colors duration-200"
              >
                Crear primer contrato
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Modales -->
      <ModalNuevoProyecto 
        :show="mostrarModalNuevo"
        :proyecto-editar="proyectoAEditar"
        @close="cerrarModalNuevo"
        @submit="guardarProyecto"
      />

      <ModalFiltros 
        :show="mostrarModalFiltros"
        @close="mostrarModalFiltros = false"
        @apply="aplicarFiltros"
      />

      <ModalDetalleProyecto 
        :show="mostrarModalDetalle"
        :proyecto="proyectoSeleccionado"
        @close="mostrarModalDetalle = false"
        @actualizar="actualizarProyecto"
      />

      <!-- Modal Vista Previa PDF -->
      <ModalVistaPreviaPDF 
        :show="mostrarVistaPreviaPDF"
        @close="mostrarVistaPreviaPDF = false"
        @generar="confirmarGenerarPDF"
      />
    </div>
  </AppLayout>
</template>

<script>
import AppLayout from '@/Layouts/AppLayout.vue'
import ModalNuevoProyecto from '@/Components/ModalNuevoProyecto.vue'
import ModalFiltros from '@/Components/ModalFiltros.vue'
import ModalDetalleProyecto from '@/Components/ModalDetalleProyecto.vue'
import ModalVistaPreviaPDF from '@/Components/ModalVistaPreviaPDF.vue'
import { proyectoService } from '@/Services/proyectoService'

export default {
  name: 'PavimentacionIndex',
  components: {
    AppLayout,
    ModalNuevoProyecto,
    ModalFiltros,
    ModalDetalleProyecto,
    ModalVistaPreviaPDF
  },
  props: {
    initialProyectos: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      proyectos: this.initialProyectos,
      estadisticas: {},
      
      // Estados de modales
      mostrarModalNuevo: false,
      mostrarModalFiltros: false,
      mostrarModalDetalle: false,
      mostrarVistaPreviaPDF: false,
      
      // Estados de datos
      proyectoSeleccionado: null,
      proyectoAEditar: null,
      mensaje: '',
      mensajeError: false,
      cargando: false,
      
      // Búsqueda y filtros
      busqueda: '',
      filtros: {},
      filtrosActivos: [],
      ordenActual: { campo: 'contrato', direccion: 'asc' }
    }
  },
  computed: {
    fechaActual() {
      return new Date().toLocaleDateString('es-MX', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }).replace(/^\w/, (c) => c.toUpperCase())
    },
    
    totalAdeudos() {
      return this.proyectos.reduce((total, p) => total + parseFloat(p.adeudo_total || 0), 0)
    },
    
    totalInversion() {
      return this.proyectos.reduce((total, p) => total + parseFloat(p.costototal || 0), 0)
    },
    
    proyectosFiltrados() {
      let resultado = [...this.proyectos]
      
      // Aplicar búsqueda
      if (this.busqueda) {
        const termino = this.busqueda.toLowerCase()
        resultado = resultado.filter(p => 
          p.nombre.toLowerCase().includes(termino) ||
          p.contrato.toString().includes(termino) ||
          p.calle.toLowerCase().includes(termino)
        )
      }
      
      // Aplicar filtros
      Object.entries(this.filtros).forEach(([key, value]) => {
        if (value !== null && value !== '') {
          resultado = resultado.filter(p => {
            switch (key) {
              case 'tipo_pavimento':
                return p.tipo_pavimento === value
              case 'con_adeudos':
                return value ? p.adeudo_total > 0 : p.adeudo_total === 0
              case 'monto_min':
                return parseFloat(p.costototal) >= parseFloat(value)
              case 'monto_max':
                return parseFloat(p.costototal) <= parseFloat(value)
              default:
                return true
            }
          })
        }
      })
      
      // Aplicar ordenamiento
      resultado.sort((a, b) => {
        const direccion = this.ordenActual.direccion === 'asc' ? 1 : -1
        const valorA = a[this.ordenActual.campo]
        const valorB = b[this.ordenActual.campo]
        
        if (typeof valorA === 'number' && typeof valorB === 'number') {
          return (valorA - valorB) * direccion
        }
        
        return valorA.toString().localeCompare(valorB.toString()) * direccion
      })
      
      return resultado
    }
  },
  
  mounted() {
    this.cargarEstadisticas()
    if (this.proyectos.length === 0) {
      this.cargarProyectos()
    }
  },
  
  methods: {
    formatCurrency(value) {
      if (!value) return '$0.00'
      return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(value)
    },
    
    async cargarEstadisticas() {
      try {
        const response = await proyectoService.getEstadisticas()
        this.estadisticas = response.data
      } catch (error) {
        console.error('Error al cargar estadísticas:', error)
      }
    },
    
    async cargarProyectos() {
      this.cargando = true
      try {
        const response = await proyectoService.getAll()
        this.proyectos = response.data
        await this.cargarEstadisticas()
      } catch (error) {
        this.mostrarMensaje('Error al cargar los proyectos', true)
      } finally {
        this.cargando = false
      }
    },
    
    async guardarProyecto(formData) {
      try {
        if (this.proyectoAEditar) {
          // Actualizar proyecto existente
          const response = await proyectoService.update(this.proyectoAEditar.id_control, formData)
          const index = this.proyectos.findIndex(p => p.id_control === this.proyectoAEditar.id_control)
          if (index !== -1) {
            this.proyectos.splice(index, 1, response.data)
          }
          this.mostrarMensaje('Contrato actualizado correctamente', false)
        } else {
          // Crear nuevo proyecto
          const response = await proyectoService.create(formData)
          this.proyectos.push(response.data)
          this.mostrarMensaje('Contrato registrado correctamente', false)
        }
        
        this.cerrarModalNuevo()
        await this.cargarEstadisticas()
      } catch (error) {
        const message = error.response?.data?.message || 'Error al guardar el proyecto'
        this.mostrarMensaje(message, true)
      }
    },
    
    verDetalle(proyecto) {
      this.proyectoSeleccionado = proyecto
      this.mostrarModalDetalle = true
    },
    
    editarProyecto(proyecto) {
      this.proyectoAEditar = proyecto
      this.mostrarModalNuevo = true
    },
    
    cerrarModalNuevo() {
      this.mostrarModalNuevo = false
      this.proyectoAEditar = null
    },
    
    aplicarFiltros(filtros) {
      this.filtros = filtros
      this.actualizarFiltrosActivos()
      this.mostrarModalFiltros = false
    },
    
    actualizarFiltrosActivos() {
      this.filtrosActivos = []
      Object.entries(this.filtros).forEach(([key, value]) => {
        if (value !== null && value !== '') {
          let label = ''
          let displayValue = value
          
          switch (key) {
            case 'tipo_pavimento':
              label = 'Tipo'
              displayValue = value === 'A' ? 'Asfalto' : 'Concreto'
              break
            case 'con_adeudos':
              label = 'Estado'
              displayValue = value ? 'Con adeudos' : 'Al corriente'
              break
            case 'monto_min':
              label = 'Monto mínimo'
              displayValue = this.formatCurrency(value)
              break
            case 'monto_max':
              label = 'Monto máximo'
              displayValue = this.formatCurrency(value)
              break
          }
          
          this.filtrosActivos.push({ key, label, value: displayValue })
        }
      })
    },
    
    removerFiltro(key) {
      delete this.filtros[key]
      this.actualizarFiltrosActivos()
    },
    
    limpiarFiltros() {
      this.filtros = {}
      this.filtrosActivos = []
    },
    
    ordenar(campo) {
      if (this.ordenActual.campo === campo) {
        this.ordenActual.direccion = this.ordenActual.direccion === 'asc' ? 'desc' : 'asc'
      } else {
        this.ordenActual = { campo, direccion: 'asc' }
      }
    },
    
    async exportarExcel() {
      if (this.proyectosFiltrados.length === 0) {
        this.mostrarMensaje('No existe información para exportar a Excel', true)
        return
      }
      
      try {
        await proyectoService.exportExcel()
        this.mostrarMensaje('Archivo Excel descargado correctamente', false)
      } catch (error) {
        this.mostrarMensaje('Error al exportar a Excel', true)
      }
    },
    
    generarPDF() {
      if (this.proyectosFiltrados.length === 0) {
        this.mostrarMensaje('No existe información para generar reporte', true)
        return
      }
      
      this.mostrarVistaPreviaPDF = true
    },
    
    async confirmarGenerarPDF(configuracion) {
      try {
        await proyectoService.generatePDF(configuracion)
        this.mostrarMensaje('Reporte PDF generado correctamente', false)
        this.mostrarVistaPreviaPDF = false
      } catch (error) {
        this.mostrarMensaje('Error al generar reporte PDF', true)
      }
    },
    
    async actualizarProyecto(proyecto) {
      try {
        const index = this.proyectos.findIndex(p => p.id_control === proyecto.id_control)
        if (index !== -1) {
          this.proyectos.splice(index, 1, proyecto)
        }
        await this.cargarEstadisticas()
        this.mostrarMensaje('Proyecto actualizado correctamente', false)
      } catch (error) {
        this.mostrarMensaje('Error al actualizar el proyecto', true)
      }
    },
    
    mostrarMensaje(texto, esError = false) {
      this.mensaje = texto
      this.mensajeError = esError
      setTimeout(() => {
        this.mensaje = ''
      }, 5000)
    }
  }
}
</script>

<style scoped>
/* Animaciones personalizadas */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-10px); }
  to { opacity: 1; transform: translateY(0); }
}

.fade-in {
  animation: fadeIn 0.3s ease-out;
}

/* Estilos para scrollbar personalizada */
::-webkit-scrollbar {
  width: 6px;
}

::-webkit-scrollbar-track {
  background: #f1f1f1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb {
  background: #c1c1c1;
  border-radius: 3px;
}

::-webkit-scrollbar-thumb:hover {
  background: #a8a8a8;
}
</style>