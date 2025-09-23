<template>
  <div class="estacionamientos-bajas">
    <div class="mb-6">
      <div class="flex items-center space-x-3">
        <router-link 
          to="/module/estacionaminetos" 
          class="text-blue-600 hover:text-blue-800"
        >
          <svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
            <path fill-rule="evenodd" d="M12.707 5.293a1 1 0 010 1.414L9.414 10l3.293 3.293a1 1 0 01-1.414 1.414l-4-4a1 1 0 010-1.414l4-4a1 1 0 011.414 0z" clip-rule="evenodd" />
          </svg>
        </router-link>
        <h1 class="text-3xl font-bold text-gray-900">Bajas Múltiples</h1>
      </div>
      <p class="text-lg text-gray-600 mt-2">Procesamiento masivo de salidas de vehículos</p>
    </div>

    <div class="space-y-6">
      <!-- Alerta de información -->
      <div class="bg-yellow-50 border border-yellow-200 rounded-md p-4">
        <div class="flex">
          <div class="flex-shrink-0">
            <svg class="h-5 w-5 text-yellow-400" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
            </svg>
          </div>
          <div class="ml-3">
            <h4 class="text-sm font-medium text-yellow-800">Información Importante</h4>
            <p class="mt-1 text-sm text-yellow-700">
              Esta función permite procesar múltiples bajas de vehículos de forma masiva. 
              Verifique cuidadosamente antes de ejecutar las operaciones.
            </p>
          </div>
        </div>
      </div>

      <!-- Estadísticas -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
          <h4 class="font-medium text-blue-900 mb-2">Vehículos Activos</h4>
          <div class="text-2xl font-bold text-blue-600">{{vehiculosActivos}}</div>
          <p class="text-sm text-blue-700">Disponibles para baja</p>
        </div>
        
        <div class="bg-orange-50 p-4 rounded-lg border border-orange-200">
          <h4 class="font-medium text-orange-900 mb-2">Tiempo Promedio</h4>
          <div class="text-2xl font-bold text-orange-600">{{tiempoPromedio}}</div>
          <p class="text-sm text-orange-700">Permanencia actual</p>
        </div>
        
        <div class="bg-red-50 p-4 rounded-lg border border-red-200">
          <h4 class="font-medium text-red-900 mb-2">Bajas Pendientes</h4>
          <div class="text-2xl font-bold text-red-600">{{bajasPendientes}}</div>
          <p class="text-sm text-red-700">En cola de procesamiento</p>
        </div>
        
        <div class="bg-green-50 p-4 rounded-lg border border-green-200">
          <h4 class="font-medium text-green-900 mb-2">Bajas Procesadas Hoy</h4>
          <div class="text-2xl font-bold text-green-600">{{bajasRealizadas}}</div>
          <p class="text-sm text-green-700">Completadas exitosamente</p>
        </div>
      </div>

      <!-- Filtros y controles -->
      <div class="bg-white shadow rounded-lg">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg font-medium mb-4">Filtros de Selección</h3>
          <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700">Tiempo Mínimo</label>
              <select v-model="filtroTiempo" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                <option value="">Todos</option>
                <option value="1">Más de 1 hora</option>
                <option value="2">Más de 2 horas</option>
                <option value="4">Más de 4 horas</option>
                <option value="8">Más de 8 horas</option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Tipo de Vehículo</label>
              <select v-model="filtroTipo" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                <option value="">Todos</option>
                <option value="auto">Automóviles</option>
                <option value="moto">Motocicletas</option>
                <option value="camioneta">Camionetas</option>
              </select>
            </div>
            
            <div>
              <label class="block text-sm font-medium text-gray-700">Estado de Pago</label>
              <select v-model="filtroPago" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                <option value="">Todos</option>
                <option value="pagado">Pagados</option>
                <option value="pendiente">Pendiente de pago</option>
              </select>
            </div>
            
            <div class="flex items-end">
              <button 
                @click="aplicarFiltros"
                class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded"
              >
                Aplicar Filtros
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Lista de vehículos -->
      <div class="bg-white shadow rounded-lg overflow-hidden">
        <div class="px-4 py-5 sm:p-6">
          <div class="flex justify-between items-center mb-4">
            <h3 class="text-lg font-medium">Vehículos Disponibles para Baja</h3>
            <div class="flex space-x-2">
              <button 
                @click="seleccionarTodos"
                class="bg-gray-600 hover:bg-gray-700 text-white text-sm font-medium py-1 px-3 rounded"
              >
                Seleccionar Todos
              </button>
              <button 
                @click="limpiarSeleccion"
                class="bg-gray-400 hover:bg-gray-500 text-white text-sm font-medium py-1 px-3 rounded"
              >
                Limpiar
              </button>
            </div>
          </div>
          
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    <input 
                      type="checkbox" 
                      @change="toggleTodos"
                      :checked="todosSeleccionados"
                      class="rounded border-gray-300"
                    >
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Placa</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tiempo</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Monto</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="vehiculo in vehiculosFiltrados" :key="vehiculo.id" class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap">
                    <input 
                      type="checkbox" 
                      :id="`vehiculo-${vehiculo.id}`"
                      v-model="vehiculosSeleccionados"
                      :value="vehiculo.id"
                      class="rounded border-gray-300"
                    >
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {{vehiculo.placa}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{vehiculo.tipo}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{vehiculo.tiempo}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${{vehiculo.monto}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="[
                      vehiculo.estadoPago === 'pagado' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800',
                      'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium'
                    ]">
                      {{vehiculo.estadoPago}}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <div class="mt-6 flex justify-between items-center">
            <p class="text-sm text-gray-700">
              {{vehiculosSeleccionados.length}} de {{vehiculosFiltrados.length}} vehículos seleccionados
            </p>
            <button 
              @click="procesarBajasSeleccionadas"
              :disabled="vehiculosSeleccionados.length === 0"
              :class="[
                vehiculosSeleccionados.length === 0 
                  ? 'bg-gray-300 cursor-not-allowed' 
                  : 'bg-red-600 hover:bg-red-700',
                'text-white font-medium py-2 px-6 rounded'
              ]"
            >
              Procesar {{vehiculosSeleccionados.length}} Bajas
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'

export default {
  name: 'EstacionamientosBajas',
  setup() {
    const vehiculosActivos = ref(42)
    const tiempoPromedio = ref('2.8h')
    const bajasPendientes = ref(3)
    const bajasRealizadas = ref(28)
    
    const filtroTiempo = ref('')
    const filtroTipo = ref('')
    const filtroPago = ref('')
    
    const vehiculosSeleccionados = ref([])
    
    const vehiculosParaBaja = ref([
      { id: 1, placa: 'ABC-123', tipo: 'Automóvil', tiempo: '2h 30min', monto: 50.00, estadoPago: 'pagado' },
      { id: 2, placa: 'DEF-456', tipo: 'Motocicleta', tiempo: '1h 45min', monto: 17.50, estadoPago: 'pagado' },
      { id: 3, placa: 'GHI-012', tipo: 'Automóvil', tiempo: '3h 15min', monto: 65.00, estadoPago: 'pendiente' },
      { id: 4, placa: 'MNO-678', tipo: 'Camioneta', tiempo: '45min', monto: 15.00, estadoPago: 'pagado' },
      { id: 5, placa: 'PQR-901', tipo: 'Automóvil', tiempo: '5h 20min', monto: 100.00, estadoPago: 'pagado' },
      { id: 6, placa: 'STU-234', tipo: 'Motocicleta', tiempo: '8h 45min', monto: 87.50, estadoPago: 'pendiente' },
      { id: 7, placa: 'VWX-567', tipo: 'Camioneta', tiempo: '1h 20min', monto: 27.50, estadoPago: 'pagado' },
      { id: 8, placa: 'YZA-890', tipo: 'Automóvil', tiempo: '4h 10min', monto: 82.00, estadoPago: 'pagado' }
    ])
    
    const vehiculosFiltrados = computed(() => {
      let filtrados = vehiculosParaBaja.value
      
      if (filtroTiempo.value) {
        const horasMinimas = parseInt(filtroTiempo.value)
        filtrados = filtrados.filter(v => {
          const tiempo = parseFloat(v.tiempo.split('h')[0])
          return tiempo >= horasMinimas
        })
      }
      
      if (filtroTipo.value) {
        const tipoMap = {
          'auto': 'Automóvil',
          'moto': 'Motocicleta',
          'camioneta': 'Camioneta'
        }
        filtrados = filtrados.filter(v => v.tipo === tipoMap[filtroTipo.value])
      }
      
      if (filtroPago.value) {
        filtrados = filtrados.filter(v => v.estadoPago === filtroPago.value)
      }
      
      return filtrados
    })
    
    const todosSeleccionados = computed(() => {
      return vehiculosFiltrados.value.length > 0 && 
             vehiculosSeleccionados.value.length === vehiculosFiltrados.value.length
    })
    
    const aplicarFiltros = () => {
      vehiculosSeleccionados.value = []
    }
    
    const seleccionarTodos = () => {
      vehiculosSeleccionados.value = vehiculosFiltrados.value.map(v => v.id)
    }
    
    const limpiarSeleccion = () => {
      vehiculosSeleccionados.value = []
    }
    
    const toggleTodos = () => {
      if (todosSeleccionados.value) {
        vehiculosSeleccionados.value = []
      } else {
        vehiculosSeleccionados.value = vehiculosFiltrados.value.map(v => v.id)
      }
    }
    
    const procesarBajasSeleccionadas = () => {
      if (vehiculosSeleccionados.value.length === 0) return
      
      const confirmacion = confirm(
        `¿Está seguro de procesar ${vehiculosSeleccionados.value.length} bajas múltiples? Esta acción no se puede deshacer.`
      )
      
      if (confirmacion) {
        // Simular procesamiento
        const vehiculosProcesados = vehiculosSeleccionados.value.length
        
        // Remover vehículos procesados
        vehiculosParaBaja.value = vehiculosParaBaja.value.filter(
          v => !vehiculosSeleccionados.value.includes(v.id)
        )
        
        // Actualizar estadísticas
        vehiculosActivos.value -= vehiculosProcesados
        bajasRealizadas.value += vehiculosProcesados
        
        // Limpiar selección
        vehiculosSeleccionados.value = []
        
        alert(`${vehiculosProcesados} bajas procesadas exitosamente`)
      }
    }
    
    return {
      vehiculosActivos,
      tiempoPromedio,
      bajasPendientes,
      bajasRealizadas,
      filtroTiempo,
      filtroTipo,
      filtroPago,
      vehiculosSeleccionados,
      vehiculosFiltrados,
      todosSeleccionados,
      aplicarFiltros,
      seleccionarTodos,
      limpiarSeleccion,
      toggleTodos,
      procesarBajasSeleccionadas
    }
  }
}
</script>

<style scoped>
.estacionamientos-bajas {
  padding: 1rem;
}

@media (min-width: 768px) {
  .estacionamientos-bajas {
    padding: 2rem;
  }
}
</style>