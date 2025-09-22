<template>
  <div class="module-page">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ABC Empresas - Aseo</h1>
      <p class="mt-2 text-gray-600">Gestión de empresas contratistas del sistema de aseo urbano</p>
    </div>

    <div class="bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">ABC_Empresas</h2>
      </div>
      
      <div class="p-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Nueva Empresa</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Razón Social</label>
                <input 
                  type="text" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Nombre de la empresa"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">RFC</label>
                <input 
                  type="text" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="RFC de la empresa"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Teléfono</label>
                <input 
                  type="tel" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Teléfono de contacto"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Servicios</label>
                <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="">Seleccione servicio</option>
                  <option value="recoleccion">Recolección</option>
                  <option value="limpieza">Limpieza de vías</option>
                  <option value="mantenimiento">Mantenimiento</option>
                  <option value="transporte">Transporte de residuos</option>
                </select>
              </div>
            </div>
          </div>
          
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Información de Contrato</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Fecha de Inicio</label>
                <input 
                  type="date" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Fecha de Vencimiento</label>
                <input 
                  type="date" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Monto del Contrato</label>
                <input 
                  type="number" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="0.00"
                  step="0.01"
                />
              </div>
            </div>
          </div>
        </div>
        
        <div class="mt-8">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Empresas Registradas</h3>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Empresa</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">RFC</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Servicio</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr>
                  <td class="px-6 py-4 text-sm font-medium text-gray-900">Servicios Ambientales SA</td>
                  <td class="px-6 py-4 text-sm text-gray-500">SAM850101ABC</td>
                  <td class="px-6 py-4 text-sm text-gray-500">Recolección</td>
                  <td class="px-6 py-4">
                    <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-green-100 text-green-800">
                      Activo
                    </span>
                  </td>
                  <td class="px-6 py-4 text-sm">
                    <button class="text-blue-600 hover:text-blue-900 mr-3">Editar</button>
                    <button class="text-red-600 hover:text-red-900">Eliminar</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors">
            Cancelar
          </button>
          <button class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
            Guardar Empresa
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AseoEmpresas'
}
</script>