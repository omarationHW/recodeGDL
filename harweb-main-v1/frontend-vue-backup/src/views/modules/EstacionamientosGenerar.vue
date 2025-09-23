<template>
  <div class="p-6">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">Generación de Archivos - Estacionamientos</h1>
      <p class="mt-2 text-gray-600">Generación de archivos y reportes del sistema</p>
    </div>

    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Generar Archivo Altas -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Generar Archivo Altas</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Fecha Inicio</label>
            <input type="date" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Fecha Fin</label>
            <input type="date" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <button class="w-full bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md font-medium">
            Generar Archivo
          </button>
        </div>
      </div>

      <!-- Generar Archivo Diario -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Generar Archivo Diario</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Fecha</label>
            <input type="date" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Reporte</label>
            <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500">
              <option>Todos</option>
              <option>Solo Pagados</option>
              <option>Solo Pendientes</option>
            </select>
          </div>
          <button class="w-full bg-green-600 hover:bg-green-700 text-white px-4 py-2 rounded-md font-medium">
            Generar Reporte
          </button>
        </div>
      </div>

      <!-- Generar Individual -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Generar Individual</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Folio</label>
            <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" placeholder="Número de folio"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Placa</label>
            <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" placeholder="Número de placa"/>
          </div>
          <button class="w-full bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-md font-medium">
            Generar
          </button>
        </div>
      </div>

      <!-- Generar Pagos Banorte -->
      <div class="bg-white shadow-sm rounded-lg border">
        <div class="px-6 py-4 border-b border-gray-200">
          <h2 class="text-lg font-medium text-gray-900">Generar Pagos Banorte</h2>
        </div>
        <div class="p-6">
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Remesa</label>
            <input type="text" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500" placeholder="Número de remesa"/>
          </div>
          <div class="mb-4">
            <label class="block text-sm font-medium text-gray-700 mb-2">Fecha de Procesamiento</label>
            <input type="date" class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500"/>
          </div>
          <button class="w-full bg-orange-600 hover:bg-orange-700 text-white px-4 py-2 rounded-md font-medium">
            Procesar Banorte
          </button>
        </div>
      </div>
    </div>

    <!-- Historial de Archivos Generados -->
    <div class="mt-6 bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">Historial de Archivos Generados</h2>
      </div>
      <div class="p-6">
        <div class="overflow-x-auto">
          <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Archivo</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Tipo</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Fecha Generación</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Registros</th>
                <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Acciones</th>
              </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
              <tr>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">altas_20250826.txt</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">Altas</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">2025-08-26 10:30</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">1,245</td>
                <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                  <button class="text-indigo-600 hover:text-indigo-900 mr-4">Descargar</button>
                  <button class="text-red-600 hover:text-red-900">Eliminar</button>
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
  name: 'EstacionamientosGenerar'
}
</script>