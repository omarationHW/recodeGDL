<template>
  <div class="module-page">
    <div class="mb-6">
      <h1 class="text-2xl font-bold text-gray-900">ABC Recargos - Aseo</h1>
      <p class="mt-2 text-gray-600">Gesti�n de recargos y multas del sistema de aseo urbano</p>
    </div>

    <div class="bg-white shadow-sm rounded-lg border">
      <div class="px-6 py-4 border-b border-gray-200">
        <h2 class="text-lg font-medium text-gray-900">ABC_Recargos</h2>
      </div>
      
      <div class="p-6">
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">Nuevo Recargo</h3>
            <div class="space-y-4">
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Tipo de Recargo</label>
                <select class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                  <option value="">Seleccione tipo</option>
                  <option value="multa_limpieza">Multa por falta de limpieza</option>
                  <option value="recargo_mora">Recargo por mora</option>
                  <option value="servicio_extra">Servicio extraordinario</option>
                  <option value="dano_equipamiento">Da�o al equipamiento</option>
                </select>
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Contribuyente</label>
                <input 
                  type="text" 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  placeholder="Nombre o raz�n social"
                />
              </div>
              
              <div>
                <label class="block text-sm font-medium text-gray-700 mb-2">Descripci�n</label>
                <textarea 
                  class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  rows="3"
                  placeholder="Detalle del recargo o multa"
                ></textarea>
              </div>
              
              <div class="grid grid-cols-2 gap-4">
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Monto Base</label>
                  <input 
                    type="number" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="0.00"
                    step="0.01"
                  />
                </div>
                
                <div>
                  <label class="block text-sm font-medium text-gray-700 mb-2">Recargo (%)</label>
                  <input 
                    type="number" 
                    class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                    placeholder="0"
                    min="0"
                    max="100"
                  />
                </div>
              </div>
            </div>
          </div>
          
          <div>
            <h3 class="text-lg font-medium text-gray-900 mb-4">C�lculo de Recargo</h3>
            <div class="bg-gray-50 p-6 rounded-lg">
              <div class="space-y-3">
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Monto Base:</span>
                  <span class="text-sm font-medium">$0.00</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">Recargo (0%):</span>
                  <span class="text-sm font-medium">$0.00</span>
                </div>
                <div class="flex justify-between">
                  <span class="text-sm text-gray-600">IVA (16%):</span>
                  <span class="text-sm font-medium">$0.00</span>
                </div>
                <hr class="my-2">
                <div class="flex justify-between">
                  <span class="text-base font-medium">Total a Pagar:</span>
                  <span class="text-xl font-bold text-red-600">$0.00</span>
                </div>
              </div>
              
              <div class="mt-6 space-y-3">
                <h4 class="text-sm font-medium text-gray-900">Fechas Importantes</h4>
                <div class="space-y-2 text-sm text-gray-600">
                  <div class="flex justify-between">
                    <span>Fecha de emisi�n:</span>
                    <span>--</span>
                  </div>
                  <div class="flex justify-between">
                    <span>Fecha l�mite de pago:</span>
                    <span>--</span>
                  </div>
                  <div class="flex justify-between">
                    <span>Recargo por mora diaria:</span>
                    <span>2%</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        
        <div class="mt-8">
          <h3 class="text-lg font-medium text-gray-900 mb-4">Historial de Recargos</h3>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Folio</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Contribuyente</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Monto</th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr>
                  <td class="px-6 py-4 text-sm font-medium text-gray-900">REC-2024-001</td>
                  <td class="px-6 py-4 text-sm text-gray-500">Comercial Los Pinos SA</td>
                  <td class="px-6 py-4 text-sm text-gray-500">Multa limpieza</td>
                  <td class="px-6 py-4 text-sm text-gray-900 font-medium">$1,250.00</td>
                  <td class="px-6 py-4">
                    <span class="inline-flex px-2 py-1 text-xs font-semibold rounded-full bg-red-100 text-red-800">
                      Pendiente
                    </span>
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
            Generar Recargo
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AseoRecargos'
}
</script>