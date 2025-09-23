<template>
  <div class="module-page">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ABC Gastos - Aseo</h1>
      <p class="mt-2 text-gray-600">Control y seguimiento de gastos operativos del sistema de aseo</p>
    </div>

    <div class="bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">ABC_Gastos</h2>
      </div>
      
      <div class="p-6">
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
          <div class="lg:col-span-2">
            <h3 class="text-lg font-medium text-gray-900 mb-4">Registro de Gasto</h3>
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Concepto</label>
                <input 
                  type="text" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Descripci�n del gasto"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Categor�a</label>
                <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="">Seleccione categor�a</option>
                  <option value="combustible">Combustible</option>
                  <option value="mantenimiento">Mantenimiento</option>
                  <option value="personal">Personal</option>
                  <option value="materiales">Materiales</option>
                  <option value="servicios">Servicios</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Monto</label>
                <input 
                  type="number" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="0.00"
                  step="0.01"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Fecha</label>
                <input 
                  type="date" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>
          </div>
          
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Resumen</h3>
            <div class="space-y-4">
              <div class="bg-red-50 p-4 rounded-lg">
                <div class="text-2xl font-bold text-red-600">$12,450</div>
                <div class="text-sm text-red-700">Gastos del Mes</div>
              </div>
              
              <div class="bg-blue-50 p-4 rounded-lg">
                <div class="text-2xl font-bold text-blue-600">$45,200</div>
                <div class="text-sm text-blue-700">Presupuesto Mensual</div>
              </div>
              
              <div class="bg-green-50 p-4 rounded-lg">
                <div class="text-2xl font-bold text-green-600">$32,750</div>
                <div class="text-sm text-green-700">Disponible</div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors">
            Cancelar
          </button>
          <button class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
            Registrar Gasto
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AseoGastos'
}
</script>