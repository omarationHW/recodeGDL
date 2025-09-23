<template>
  <div class="p-6">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Control de Acceso - Estacionamientos</h1>
      <p class="mt-2 text-gray-600">Gestión de accesos al sistema de estacionamientos</p>
    </div>

    <div class="bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">Acceso</h2>
      </div>
      
      <div class="p-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Usuario</label>
            <input 
              type="text" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Ingrese usuario"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Contraseña</label>
            <input 
              type="password" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              placeholder="Ingrese contraseña"
            />
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Nivel de Acceso</label>
            <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
              <option value="">Seleccione nivel</option>
              <option value="admin">Administrador</option>
              <option value="operator">Operador</option>
              <option value="viewer">Visualizador</option>
            </select>
          </div>
        </div>
        
        <div class="mt-6 flex justify-end space-x-3">
          <button class="px-4 py-2 bg-gray-200 text-gray-800 rounded-md hover:bg-gray-300 transition-colors">
            Cancelar
          </button>
          <button class="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors">
            Acceder
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstacionamientosAcceso'
}
</script>