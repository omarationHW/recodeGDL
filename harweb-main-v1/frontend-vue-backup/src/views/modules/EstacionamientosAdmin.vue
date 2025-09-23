<template>
  <div class="p-6">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Administración - Estacionamientos</h1>
      <p class="mt-2 text-gray-600">Herramientas administrativas y configuración</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <!-- Gestión de Contraseñas -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Gestión de Contraseñas</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Usuario</label>
            <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" placeholder="Nombre de usuario"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Nueva Contraseña</label>
            <input type="password" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <button class="w-full bg-pink-600 hover:bg-pink-700 text-white px-4 py-2 rounded-md font-medium">
            Actualizar Contraseña
          </button>
        </div>
      </div>

      <!-- Cargar Archivo Estado Externo -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Cargar Archivo Estado Externo</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Archivo</label>
            <input type="file" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" accept=".txt,.csv,.xlsx"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Archivo</label>
            <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500">
              <option>Estado de Cuenta</option>
              <option>Listado de Morosos</option>
              <option>Actualizaciones</option>
            </select>
          </div>
          <button class="w-full bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-md font-medium">
            Cargar Archivo
          </button>
        </div>
      </div>

      <!-- Medidores -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Configuración de Medidores</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">ID Medidor</label>
            <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" placeholder="ID del medidor"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Estado</label>
            <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500">
              <option>Activo</option>
              <option>Inactivo</option>
              <option>Mantenimiento</option>
            </select>
          </div>
          <button class="w-full bg-cyan-600 hover:bg-cyan-700 text-white px-4 py-2 rounded-md font-medium">
            Actualizar Medidor
          </button>
        </div>
      </div>
    </div>

    <!-- Lista de Usuarios del Sistema -->
    <div class="mt-6 bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">Usuarios del Sistema</h2>
      </div>
      <div class="p-6">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Usuario</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rol</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Último Acceso</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Estado</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">admin01</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Administrador</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">2025-08-26 09:15</td>
                <td class="px-6 py-4 whitespace-nowrap">
                  <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800">
                    Activo
                  </span>
                </td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button class="text-indigo-600 hover:text-indigo-900 mr-4">Editar</button>
                  <button class="text-red-600 hover:text-red-900">Desactivar</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EstacionamientosAdmin'
}
</script>