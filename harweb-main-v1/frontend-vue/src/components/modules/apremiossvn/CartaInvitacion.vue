<template>
  <div class="min-h-screen bg-gray-100 p-6">
    <div class="max-w-4xl mx-auto bg-white rounded-lg shadow-lg p-8">
      <div class="text-center mb-6">
        <h1 class="text-2xl font-bold text-gray-800 mb-2">Carta de Invitación</h1>
        <p class="text-gray-600">Módulo de Apremios - Sistema HARWEB</p>
      </div>
      
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Número de Folio</label>
            <input 
              v-model="form.folio"
              type="text" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Ingrese el número de folio"
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Contribuyente</label>
            <input 
              v-model="form.contribuyente"
              type="text" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Nombre del contribuyente"
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Domicilio</label>
            <textarea 
              v-model="form.domicilio"
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Domicilio del contribuyente"
            ></textarea>
          </div>
        </div>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Fecha de Invitación</label>
            <input 
              v-model="form.fecha"
              type="date" 
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Concepto</label>
            <select 
              v-model="form.concepto"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="">Seleccione un concepto</option>
              <option value="predial">Impuesto Predial</option>
              <option value="agua">Derechos de Agua</option>
              <option value="licencia">Licencia de Funcionamiento</option>
              <option value="multa">Multa Administrativa</option>
            </select>
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">Monto Adeudo</label>
            <input 
              v-model="form.monto"
              type="number" 
              step="0.01"
              class="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="0.00"
            >
          </div>
        </div>
      </div>
      
      <div class="mt-8 flex justify-center space-x-4">
        <button 
          @click="generarCarta"
          class="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition-colors duration-200"
        >
          Generar Carta
        </button>
        <button 
          @click="limpiarForm"
          class="px-6 py-2 bg-gray-600 text-white rounded-md hover:bg-gray-700 transition-colors duration-200"
        >
          Limpiar
        </button>
      </div>
      
      <div v-if="cartaGenerada" class="mt-8 p-6 bg-gray-50 rounded-lg">
        <h3 class="text-lg font-semibold text-gray-800 mb-4">Vista Previa de la Carta</h3>
        <div class="bg-white p-6 border rounded-lg">
          <div class="text-center mb-6">
            <h2 class="text-xl font-bold">CARTA DE INVITACIÓN</h2>
            <p class="text-sm text-gray-600 mt-2">Folio: {{ form.folio }}</p>
          </div>
          
          <div class="mb-4">
            <p><strong>Fecha:</strong> {{ formatearFecha(form.fecha) }}</p>
            <p><strong>Contribuyente:</strong> {{ form.contribuyente }}</p>
            <p><strong>Domicilio:</strong> {{ form.domicilio }}</p>
          </div>
          
          <div class="mb-4">
            <p class="text-justify">
              Por medio de la presente, le invitamos a regularizar su situación fiscal 
              respecto al adeudo por concepto de {{ form.concepto }} por un monto de 
              ${{ parseFloat(form.monto).toFixed(2) }}.
            </p>
          </div>
          
          <div class="mt-6 text-center">
            <p class="text-sm text-gray-600">
              Atentamente<br>
              Departamento de Cobranza<br>
              Sistema HARWEB
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CartaInvitacion',
  data() {
    return {
      cartaGenerada: false,
      form: {
        folio: '',
        contribuyente: '',
        domicilio: '',
        fecha: new Date().toISOString().split('T')[0],
        concepto: '',
        monto: ''
      }
    }
  },
  methods: {
    generarCarta() {
      if (this.validarForm()) {
        this.cartaGenerada = true;
      } else {
        alert('Por favor complete todos los campos obligatorios');
      }
    },
    
    limpiarForm() {
      this.form = {
        folio: '',
        contribuyente: '',
        domicilio: '',
        fecha: new Date().toISOString().split('T')[0],
        concepto: '',
        monto: ''
      };
      this.cartaGenerada = false;
    },
    
    validarForm() {
      return this.form.folio && this.form.contribuyente && this.form.domicilio && 
             this.form.fecha && this.form.concepto && this.form.monto;
    },
    
    formatearFecha(fecha) {
      if (!fecha) return '';
      const date = new Date(fecha);
      return date.toLocaleDateString('es-ES', {
        year: 'numeric',
        month: 'long', 
        day: 'numeric'
      });
    }
  }
}
</script>

<style scoped>
/* Estilos específicos para CartaInvitacion */
</style>