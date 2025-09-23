<template>
  <div class="estacionamientos-pagos">
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
        <h1 class="text-3xl font-bold text-gray-900">Administración de Pagos</h1>
      </div>
      <p class="text-lg text-gray-600 mt-2">Gestión financiera y configuración de tarifas</p>
    </div>

    <div class="space-y-6">
      <!-- Métricas financieras -->
      <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div class="bg-green-50 p-4 rounded-lg border border-green-200">
          <h4 class="font-medium text-green-900 mb-2">Ingresos Diarios</h4>
          <div class="text-2xl font-bold text-green-600">${{ingresosDiarios.toLocaleString()}}</div>
          <p class="text-sm text-green-700">{{pagosRealizados}} pagos procesados</p>
        </div>
        
        <div class="bg-blue-50 p-4 rounded-lg border border-blue-200">
          <h4 class="font-medium text-blue-900 mb-2">Ingresos Mensuales</h4>
          <div class="text-2xl font-bold text-blue-600">${{ingresosMensuales.toLocaleString()}}</div>
          <p class="text-sm text-blue-700">Meta: $45,000</p>
        </div>
        
        <div class="bg-purple-50 p-4 rounded-lg border border-purple-200">
          <h4 class="font-medium text-purple-900 mb-2">Tarifa Promedio</h4>
          <div class="text-2xl font-bold text-purple-600">${{tarifaPromedio}}</div>
          <p class="text-sm text-purple-700">Por vehículo</p>
        </div>
        
        <div class="bg-yellow-50 p-4 rounded-lg border border-yellow-200">
          <h4 class="font-medium text-yellow-900 mb-2">Tiempo Promedio</h4>
          <div class="text-2xl font-bold text-yellow-600">{{tiempoPromedio}}</div>
          <p class="text-sm text-yellow-700">Permanencia</p>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <!-- Configuración de tarifas -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg font-medium mb-4">Configuración de Tarifas</h3>
            <form @submit.prevent="actualizarTarifas" class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Tarifa por Hora</label>
                <div class="mt-1 relative rounded-md shadow-sm">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span class="text-gray-500 sm:text-sm">$</span>
                  </div>
                  <input 
                    type="number" 
                    v-model="nuevaTarifaHora" 
                    class="pl-7 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                    step="0.50"
                  >
                </div>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Tarifa Mínima</label>
                <div class="mt-1 relative rounded-md shadow-sm">
                  <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                    <span class="text-gray-500 sm:text-sm">$</span>
                  </div>
                  <input 
                    type="number" 
                    v-model="tarifaMinima" 
                    class="pl-7 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                    step="0.50"
                  >
                </div>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Descuento por Tiempo Prolongado (%)</label>
                <input 
                  type="number" 
                  v-model="descuentoProlongado" 
                  class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                  min="0" 
                  max="50"
                >
              </div>
              
              <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium py-2 px-4 rounded">
                Actualizar Tarifas
              </button>
            </form>
          </div>
        </div>

        <!-- Calculadora de tarifas -->
        <div class="bg-white shadow rounded-lg">
          <div class="px-4 py-5 sm:p-6">
            <h3 class="text-lg font-medium mb-4">Calculadora de Tarifas</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700">Tiempo de Permanencia</label>
                <div class="mt-1 grid grid-cols-2 gap-2">
                  <input 
                    type="number" 
                    v-model="horasCalculadora" 
                    placeholder="Horas"
                    class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                    min="0"
                  >
                  <input 
                    type="number" 
                    v-model="minutosCalculadora" 
                    placeholder="Minutos"
                    class="block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500"
                    min="0"
                    max="59"
                  >
                </div>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700">Tipo de Vehículo</label>
                <select v-model="tipoVehiculo" class="mt-1 block w-full border-gray-300 rounded-md shadow-sm focus:ring-blue-500 focus:border-blue-500">
                  <option value="auto">Automóvil</option>
                  <option value="moto">Motocicleta (50% descuento)</option>
                  <option value="camioneta">Camioneta (+25%)</option>
                </select>
              </div>
              
              <div class="bg-gray-50 p-4 rounded">
                <div class="flex justify-between items-center">
                  <span class="text-sm font-medium text-gray-700">Subtotal:</span>
                  <span class="text-lg font-bold">${{subtotalCalculado}}</span>
                </div>
                <div class="flex justify-between items-center">
                  <span class="text-sm font-medium text-gray-700">Descuentos:</span>
                  <span class="text-sm text-green-600">-${{descuentoCalculado}}</span>
                </div>
                <hr class="my-2">
                <div class="flex justify-between items-center">
                  <span class="text-lg font-bold text-gray-900">Total:</span>
                  <span class="text-xl font-bold text-blue-600">${{totalCalculado}}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Historial de pagos -->
      <div class="bg-white shadow rounded-lg overflow-hidden">
        <div class="px-4 py-5 sm:p-6">
          <h3 class="text-lg font-medium mb-4">Historial de Pagos Recientes</h3>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Placa</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tiempo</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Monto</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Método</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr v-for="pago in historialPagos" :key="pago.id">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {{pago.placa}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{pago.tiempo}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    ${{pago.monto}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {{pago.metodo}}
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span :class="[
                      pago.estado === 'pagado' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800',
                      'inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium'
                    ]">
                      {{pago.estado}}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, computed } from 'vue'

export default {
  name: 'EstacionamientosPagos',
  setup() {
    const ingresosDiarios = ref(1250)
    const ingresosMensuales = ref(38500)
    const tarifaPromedio = ref(25.50)
    const tiempoPromedio = ref('2.3h')
    const pagosRealizados = ref(47)
    
    const nuevaTarifaHora = ref(20.00)
    const tarifaMinima = ref(10.00)
    const descuentoProlongado = ref(15)
    
    const horasCalculadora = ref(2)
    const minutosCalculadora = ref(30)
    const tipoVehiculo = ref('auto')
    
    const historialPagos = ref([
      { id: 1, placa: 'ABC-123', tiempo: '2h 15min', monto: 45.00, metodo: 'Efectivo', estado: 'pagado' },
      { id: 2, placa: 'XYZ-789', tiempo: '1h 30min', monto: 30.00, metodo: 'Tarjeta', estado: 'pagado' },
      { id: 3, placa: 'DEF-456', tiempo: '45min', monto: 15.00, metodo: 'Efectivo', estado: 'pagado' },
      { id: 4, placa: 'GHI-012', tiempo: '3h 20min', monto: 66.00, metodo: 'Tarjeta', estado: 'pagado' },
      { id: 5, placa: 'JKL-345', tiempo: '1h 10min', monto: 23.00, metodo: 'Efectivo', estado: 'pendiente' }
    ])
    
    const subtotalCalculado = computed(() => {
      const horas = parseInt(horasCalculadora.value) || 0
      const minutos = parseInt(minutosCalculadora.value) || 0
      const tiempoTotal = horas + (minutos / 60)
      let subtotal = Math.max(tiempoTotal * nuevaTarifaHora.value, tarifaMinima.value)
      
      if (tipoVehiculo.value === 'moto') {
        subtotal *= 0.5
      } else if (tipoVehiculo.value === 'camioneta') {
        subtotal *= 1.25
      }
      
      return subtotal.toFixed(2)
    })
    
    const descuentoCalculado = computed(() => {
      const horas = parseInt(horasCalculadora.value) || 0
      if (horas > 4) {
        return (subtotalCalculado.value * (descuentoProlongado.value / 100)).toFixed(2)
      }
      return 0
    })
    
    const totalCalculado = computed(() => {
      return (subtotalCalculado.value - descuentoCalculado.value).toFixed(2)
    })
    
    const actualizarTarifas = () => {
      alert('Tarifas actualizadas correctamente')
    }
    
    return {
      ingresosDiarios,
      ingresosMensuales,
      tarifaPromedio,
      tiempoPromedio,
      pagosRealizados,
      nuevaTarifaHora,
      tarifaMinima,
      descuentoProlongado,
      horasCalculadora,
      minutosCalculadora,
      tipoVehiculo,
      historialPagos,
      subtotalCalculado,
      descuentoCalculado,
      totalCalculado,
      actualizarTarifas
    }
  }
}
</script>

<style scoped>
.estacionamientos-pagos {
  padding: 1rem;
}

@media (min-width: 768px) {
  .estacionamientos-pagos {
    padding: 2rem;
  }
}
</style>