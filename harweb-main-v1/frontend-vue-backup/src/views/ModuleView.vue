<template>
  <div class="module-view">
    <div class="mb-6">
      <h1 class="text-3xl font-bold text-gray-900">
        Módulo: {{ $route.params.module }}
      </h1>
      <p v-if="$route.params.submodule" class="text-lg text-gray-600 mt-2">
        Submódulo: {{ $route.params.submodule }}
      </p>
    </div>

    <div class="bg-white shadow rounded-lg p-6">
      <div v-if="$route.params.module === 'estacionaminetos'" class="space-y-6">
        <h2 class="text-xl font-semibold mb-4">Módulo de Estacionamientos</h2>
        <p class="text-gray-600 mb-6">Sistema integral para la gestión de estacionamientos vehiculares</p>
        
        <!-- Grid de submódulos -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <router-link 
            to="/module/estacionaminetos/acceso"
            class="bg-blue-50 hover:bg-blue-100 border border-blue-200 rounded-lg p-6 transition-colors group"
          >
            <div class="flex items-center space-x-4">
              <div class="flex-shrink-0">
                <svg class="w-8 h-8 text-blue-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M3 3a1 1 0 000 2v8a2 2 0 002 2h2a2 2 0 002-2V5a1 1 0 100-2H3zm11.293 4.293a1 1 0 00-1.414 1.414L14.586 10l-1.707 1.293a1 1 0 101.414 1.414l2.5-2a1 1 0 000-1.414l-2.5-2z" clip-rule="evenodd" />
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-semibold text-blue-900 group-hover:text-blue-700">Control de Acceso</h3>
                <p class="text-sm text-blue-700 mt-1">Registro de entrada y salida de vehículos</p>
                <div class="mt-2 text-xs text-blue-600">{{vehiculosActivos}} vehículos activos</div>
              </div>
            </div>
          </router-link>
          
          <router-link 
            to="/module/estacionaminetos/pagos"
            class="bg-green-50 hover:bg-green-100 border border-green-200 rounded-lg p-6 transition-colors group"
          >
            <div class="flex items-center space-x-4">
              <div class="flex-shrink-0">
                <svg class="w-8 h-8 text-green-600" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M4 4a2 2 0 00-2 2v4a2 2 0 002 2V6h10a2 2 0 00-2-2H4zm2 6a2 2 0 012-2h8a2 2 0 012 2v4a2 2 0 01-2 2H8a2 2 0 01-2-2v-4zm6 4a2 2 0 100-4 2 2 0 000 4z" />
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-semibold text-green-900 group-hover:text-green-700">Administración de Pagos</h3>
                <p class="text-sm text-green-700 mt-1">Gestión financiera y tarifas</p>
                <div class="mt-2 text-xs text-green-600">${{ingresosDiarios}} ingresos diarios</div>
              </div>
            </div>
          </router-link>
          
          <router-link 
            to="/module/estacionaminetos/bajas"
            class="bg-red-50 hover:bg-red-100 border border-red-200 rounded-lg p-6 transition-colors group"
          >
            <div class="flex items-center space-x-4">
              <div class="flex-shrink-0">
                <svg class="w-8 h-8 text-red-600" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z" clip-rule="evenodd" />
                  <path fill-rule="evenodd" d="M4 5a2 2 0 012-2v1a1 1 0 001 1h6a1 1 0 001-1V3a2 2 0 012 2v6a2 2 0 01-2 2H6a2 2 0 01-2-2V5zM8 8a1 1 0 012 0v3a1 1 0 11-2 0V8zm4 0a1 1 0 10-2 0v3a1 1 0 102 0V8z" clip-rule="evenodd" />
                </svg>
              </div>
              <div>
                <h3 class="text-lg font-semibold text-red-900 group-hover:text-red-700">Bajas Múltiples</h3>
                <p class="text-sm text-red-700 mt-1">Procesamiento masivo de salidas</p>
                <div class="mt-2 text-xs text-red-600">{{vehiculosParaBaja.length}} vehículos disponibles</div>
              </div>
            </div>
          </router-link>
        </div>
        
        <!-- Resumen estadístico -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg font-medium mb-4">Resumen del Sistema</h3>
            <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
              <div class="text-center">
                <div class="text-2xl font-bold text-blue-600">{{vehiculosActivos}}</div>
                <div class="text-sm text-gray-500">Vehículos Activos</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-green-600">${{ingresosDiarios}}</div>
                <div class="text-sm text-gray-500">Ingresos Diarios</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-purple-600">${{tarifaPromedio}}</div>
                <div class="text-sm text-gray-500">Tarifa Promedio</div>
              </div>
              <div class="text-center">
                <div class="text-2xl font-bold text-yellow-600">{{ingresosDelDia}}</div>
                <div class="text-sm text-gray-500">Ingresos Hoy</div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div v-else class="text-center py-8">
        <div class="text-gray-400 mb-4">
          <svg class="w-16 h-16 mx-auto" fill="currentColor" viewBox="0 0 20 20">
            <path d="M9 2a1 1 0 000 2h2a1 1 0 100-2H9z"/>
            <path fill-rule="evenodd" d="M4 5a2 2 0 012-2v1a1 1 0 001 1h6a1 1 0 001-1V3a2 2 0 012 2v6a2 2 0 01-2 2H6a2 2 0 01-2-2V5zm2.5 5a1.5 1.5 0 100-3 1.5 1.5 0 000 3zm2.45 4a2.5 2.5 0 10-4.9 0h4.9zM12 9a1 1 0 100 2h3a1 1 0 100-2h-3z" clip-rule="evenodd"/>
          </svg>
        </div>
        <h3 class="text-lg font-medium text-gray-900 mb-2">Módulo en desarrollo</h3>
        <p class="text-gray-500">Este módulo está siendo desarrollado y estará disponible pronto.</p>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted, computed } from 'vue'

export default {
  name: 'ModuleView',
  setup() {
    const activeSubmodule = ref('acceso')
    
    // Datos reactivos
    const vehiculosActivos = ref(42)
    const ingresosDelDia = ref(15)
    const ingresosDiarios = ref(1250.00)
    const ingresosMensuales = ref(38500.00)
    const tarifaPromedio = ref(25.50)
    const tarifaHora = ref(20.00)
    
    const submodules = ref([
      { key: 'acceso', name: 'Control de Acceso' },
      { key: 'pagos', name: 'Administración de Pagos' },
      { key: 'bajas', name: 'Bajas Múltiples' }
    ])
    
    const ultimosAccesos = ref([
      { id: 1, placa: 'ABC-123', tipo: 'entrada', hora: '14:30' },
      { id: 2, placa: 'XYZ-789', tipo: 'salida', hora: '14:25' },
      { id: 3, placa: 'DEF-456', tipo: 'entrada', hora: '14:20' },
      { id: 4, placa: 'GHI-012', tipo: 'entrada', hora: '14:15' },
      { id: 5, placa: 'JKL-345', tipo: 'salida', hora: '14:10' }
    ])
    
    const vehiculosParaBaja = ref([
      { id: 1, placa: 'ABC-123', tiempo: '2h 30min' },
      { id: 2, placa: 'DEF-456', tiempo: '1h 45min' },
      { id: 3, placa: 'GHI-012', tiempo: '3h 15min' },
      { id: 4, placa: 'MNO-678', tiempo: '45min' },
      { id: 5, placa: 'PQR-901', tiempo: '5h 20min' }
    ])
    
    onMounted(() => {
      console.log('Módulo cargado')
      // Simular carga de datos desde API
      setTimeout(() => {
        vehiculosActivos.value = Math.floor(Math.random() * 50) + 20
        ingresosDelDia.value = Math.floor(Math.random() * 20) + 10
      }, 1000)
    })
    
    return {
      activeSubmodule,
      submodules,
      vehiculosActivos,
      ingresosDelDia,
      ingresosDiarios,
      ingresosMensuales,
      tarifaPromedio,
      tarifaHora,
      ultimosAccesos,
      vehiculosParaBaja
    }
  }
}
</script>

<style scoped>
.module-view {
  padding: 1rem;
}

@media (min-width: 768px) {
  .module-view {
    padding: 2rem;
  }
}
</style>