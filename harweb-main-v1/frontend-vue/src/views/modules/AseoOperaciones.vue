<template>
  <div class="module-page">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ABC Claves de Operación - Aseo</h1>
      <p class="mt-2 text-gray-600">Gestión de claves y operaciones del sistema de aseo urbano</p>
    </div>

    <div class="bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">ABC_Cves_Operacion</h2>
      </div>
      
      <div class="p-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Nueva Operación</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Clave de Operación</label>
                <input 
                  type="text" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Ingrese clave única"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Descripción</label>
                <textarea 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  rows="3"
                  placeholder="Descripción de la operación"
                ></textarea>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Operación</label>
                <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="">Seleccione tipo</option>
                  <option value="recoleccion">Recolección</option>
                  <option value="limpieza">Limpieza</option>
                  <option value="mantenimiento">Mantenimiento</option>
                  <option value="supervision">Supervisión</option>
                </select>
              </div>
            </div>
          </div>
          
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Estadísticas</h3>
            <div class="space-y-4">
              <div class="bg-blue-50 p-4 rounded-lg">
                <div class="text-2xl font-bold text-blue-600">24</div>
                <div class="text-sm text-blue-700">Operaciones Activas</div>
              </div>
              
              <div class="bg-green-50 p-4 rounded-lg">
                <div class="text-2xl font-bold text-green-600">156</div>
                <div class="text-sm text-green-700">Total de Operaciones</div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors">
            Cancelar
          </button>
          <button class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
            Guardar Operación
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AseoOperaciones'
}
</script>