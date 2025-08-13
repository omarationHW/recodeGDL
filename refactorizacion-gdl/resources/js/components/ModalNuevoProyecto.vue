<template>
  <div v-if="show" class="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    <!-- Fondo oscuro -->
    <div class="flex items-center justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
      <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" @click="cerrar"></div>

      <!-- Contenedor del Modal -->
      <div class="inline-block align-bottom bg-white rounded-xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-4xl sm:w-full">
        <!-- Header -->
        <div class="bg-gradient-to-r from-blue-600 to-blue-800 px-6 py-4">
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <div class="w-10 h-10 bg-white/20 rounded-lg flex items-center justify-center">
                <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
                </svg>
              </div>
              <div class="text-white">
                <h3 class="text-xl font-bold" id="modal-title">
                  {{ proyectoEditar ? 'Actualizar Contrato de Obra' : 'Alta de Nuevo Contrato de Obra' }}
                </h3>
                <p class="text-blue-200 text-sm">
                  {{ proyectoEditar ? 'Modifique los datos del contrato existente' : 'Ingrese los datos del nuevo contrato de pavimentación' }}
                </p>
              </div>
            </div>
            <button @click="cerrar" class="text-white hover:text-gray-200 transition-colors">
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>
        </div>

        <!-- Formulario -->
        <form @submit.prevent="enviarFormulario" class="p-6 space-y-6">
          <!-- Grid de campos principales -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Número de Contrato -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Número de Contrato *
              </label>
              <div class="relative">
                <input
                  v-model="formulario.contrato"
                  type="number"
                  required
                  min="1"
                  class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                  :class="{ 'border-red-500 bg-red-50': errores.contrato }"
                  placeholder="Ej: 2024001"
                  @blur="validarContrato"
                >
                <svg class="w-5 h-5 text-gray-400 absolute right-3 top-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
                </svg>
              </div>
              <p v-if="errores.contrato" class="mt-2 text-sm text-red-600">{{ errores.contrato }}</p>
            </div>

            <!-- Tipo de Pavimento -->
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">
                Tipo de Pavimento *
              </label>
              <select
                v-model="formulario.tipo_pavimento"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                @change="calcularCostoTotal"
              >
                <option value="">Seleccione el tipo de pavimento</option>
                <option value="A">Asfalto</option>
                <option value="H">Concreto Hidráulico</option>
              </select>
            </div>
          </div>

          <!-- Nombre del Contratista -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Nombre del Contratista *
            </label>
            <input
              v-model="formulario.nombre"
              type="text"
              required
              maxlength="100"
              class="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
              placeholder="Nombre completo del contratista"
            >
          </div>

          <!-- Ubicación de la Obra -->
          <div>
            <label class="block text-sm font-semibold text-gray-700 mb-2">
              Ubicación de la Obra *
            </label>
            <div class="relative">
              <input
                v-model="formulario.calle"
                type="text"
                required
                maxlength="100"
                class="w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                placeholder="Calle, número, colonia, referencias"
              >
              <svg class="w-5 h-5 text-gray-400 absolute right-3 top-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"/>
              </svg>
            </div>
          </div>

          <!-- Especificaciones Técnicas -->
          <div class="bg-gray-50 rounded-lg p-6">
            <h4 class="text-lg font-semibold text-gray-900 mb-4 flex items-center">
              <svg class="w-5 h-5 text-blue-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
              </svg>
              Especificaciones Técnicas y Costos
            </h4>
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
              <!-- Metros Cuadrados -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  Superficie (m²) *
                </label>
                <div class="relative">
                  <input
                    v-model="formulario.metros"
                    type="number"
                    step="0.01"
                    min="0.01"
                    max="999.99"
                    required
                    class="w-full px-4 py-3 pr-16 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                    placeholder="0.00"
                    @input="calcularCostoTotal"
                  >
                  <span class="absolute right-3 top-3.5 text-gray-500 text-sm font-medium">m²</span>
                </div>
              </div>

              <!-- Costo por Metro -->
              <div>
                <label class="block text-sm font-semibold text-gray-700 mb-2">
                  Costo por Metro (MXN) *
                </label>
                <div class="relative">
                  <span class="absolute left-3 top-3.5 text-gray-500">$</span>
                  <input
                    v-model="formulario.costomtr"
                    type="number"
                    step="0.01"
                    min="0.01"
                    required
                    class="w-full pl-8 pr-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200"
                    placeholder="0.00"
                    @input="calcularCostoTotal"
                  >
                </div>
              </div>
            </div>

            <!-- Costo Total Calculado -->
            <div class="mt-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-blue-700">Costo Total del Contrato:</span>
                <span class="text-2xl font-bold text-blue-900">
                  {{ formatCurrency(formulario.costototal) }}
                </span>
              </div>
              <p class="text-xs text-blue-600 mt-2">
                Se calculará automáticamente: {{ formulario.metros || 0 }} m² × {{ formatCurrency(formulario.costomtr || 0) }}/m²
              </p>
            </div>
          </div>

          <!-- Información de Adeudos -->
          <div v-if="!proyectoEditar" class="bg-amber-50 border border-amber-200 rounded-lg p-4">
            <div class="flex items-start space-x-3">
              <svg class="w-6 h-6 text-amber-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <div>
                <h5 class="text-sm font-semibold text-amber-800">Generación Automática de Adeudos</h5>
                <p class="text-sm text-amber-700 mt-1">
                  Al crear el contrato, se generarán automáticamente 12 mensualidades (enero a diciembre 2025) 
                  distribuidas en partes iguales del costo total.
                </p>
                <p class="text-xs text-amber-600 mt-2">
                  Mensualidad aproximada: <strong>{{ formatCurrency((formulario.costototal || 0) / 12) }}</strong>
                </p>
              </div>
            </div>
          </div>

          <!-- Botones de Acción -->
          <div class="flex items-center justify-between pt-6 border-t border-gray-200">
            <button
              type="button"
              @click="cerrar"
              class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-6 py-3 rounded-lg font-semibold transition-all duration-200"
            >
              Cancelar
            </button>
            
            <div class="flex items-center space-x-3">
              <button
                v-if="!proyectoEditar"
                type="button"
                @click="limpiarFormulario"
                class="bg-amber-100 hover:bg-amber-200 text-amber-700 px-4 py-3 rounded-lg font-semibold transition-all duration-200"
              >
                Limpiar
              </button>
              
              <button
                type="submit"
                :disabled="!formularioValido || enviando"
                class="bg-gradient-to-r from-blue-600 to-blue-700 hover:from-blue-700 hover:to-blue-800 disabled:from-gray-400 disabled:to-gray-500 text-white px-8 py-3 rounded-lg font-semibold transition-all duration-200 transform hover:scale-105 disabled:transform-none disabled:cursor-not-allowed"
              >
                <svg v-if="enviando" class="animate-spin -ml-1 mr-3 h-5 w-5 text-white inline-block" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                {{ enviando ? 'Guardando...' : (proyectoEditar ? 'Actualizar Contrato' : 'Crear Contrato') }}
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModalNuevoProyecto',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    proyectoEditar: {
      type: Object,
      default: null
    }
  },
  emits: ['close', 'submit'],
  
  data() {
    return {
      enviando: false,
      errores: {},
      formulario: {
        contrato: '',
        nombre: '',
        calle: '',
        metros: '',
        costomtr: '',
        costototal: 0,
        tipo_pavimento: ''
      }
    }
  },
  
  computed: {
    formularioValido() {
      return this.formulario.contrato &&
             this.formulario.nombre &&
             this.formulario.calle &&
             this.formulario.metros &&
             this.formulario.costomtr &&
             this.formulario.tipo_pavimento &&
             !this.errores.contrato
    }
  },
  
  watch: {
    show(nuevo) {
      if (nuevo) {
        if (this.proyectoEditar) {
          this.cargarDatosEdicion()
        } else {
          this.limpiarFormulario()
        }
        // Focus en el primer campo
        this.$nextTick(() => {
          const primerInput = this.$el.querySelector('input')
          if (primerInput) primerInput.focus()
        })
      }
    },
    
    proyectoEditar(nuevo) {
      if (nuevo && this.show) {
        this.cargarDatosEdicion()
      }
    }
  },
  
  methods: {
    formatCurrency(value) {
      if (!value || isNaN(value)) return '$0.00'
      return new Intl.NumberFormat('es-MX', {
        style: 'currency',
        currency: 'MXN'
      }).format(value)
    },
    
    calcularCostoTotal() {
      const metros = parseFloat(this.formulario.metros) || 0
      const costomtr = parseFloat(this.formulario.costomtr) || 0
      this.formulario.costototal = metros * costomtr
    },
    
    validarContrato() {
      this.errores.contrato = ''
      
      if (!this.formulario.contrato) {
        this.errores.contrato = 'El número de contrato es requerido'
        return
      }
      
      if (this.formulario.contrato < 1) {
        this.errores.contrato = 'El número de contrato debe ser mayor a 0'
        return
      }
      
      // Aquí podrías agregar validación de contrato duplicado si tienes acceso a la lista
      // Por ahora se validará en el backend
    },
    
    limpiarFormulario() {
      this.formulario = {
        contrato: '',
        nombre: '',
        calle: '',
        metros: '',
        costomtr: '',
        costototal: 0,
        tipo_pavimento: ''
      }
      this.errores = {}
    },
    
    cargarDatosEdicion() {
      if (this.proyectoEditar) {
        this.formulario = {
          contrato: this.proyectoEditar.contrato,
          nombre: this.proyectoEditar.nombre,
          calle: this.proyectoEditar.calle,
          metros: this.proyectoEditar.metros,
          costomtr: this.proyectoEditar.costomtr,
          costototal: this.proyectoEditar.costototal,
          tipo_pavimento: this.proyectoEditar.tipo_pavimento
        }
      }
    },
    
    async enviarFormulario() {
      if (!this.formularioValido || this.enviando) return
      
      this.enviando = true
      
      try {
        // Asegurar que el costo total esté actualizado
        this.calcularCostoTotal()
        
        // Preparar datos para enviar
        const datos = { ...this.formulario }
        
        // Convertir tipos apropiados
        datos.contrato = parseInt(datos.contrato)
        datos.metros = parseFloat(datos.metros)
        datos.costomtr = parseFloat(datos.costomtr)
        datos.costototal = parseFloat(datos.costototal)
        
        this.$emit('submit', datos)
      } catch (error) {
        console.error('Error en formulario:', error)
      } finally {
        this.enviando = false
      }
    },
    
    cerrar() {
      if (!this.enviando) {
        this.$emit('close')
      }
    }
  }
}
</script>

<style scoped>
/* Transiciones suaves para los inputs */
input:focus, select:focus {
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

/* Animación para el modal */
.modal-enter-active, .modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from, .modal-leave-to {
  opacity: 0;
}

/* Estado loading del botón */
button:disabled {
  cursor: not-allowed;
  opacity: 0.6;
}

/* Mejoras visuales para campos de error */
input.border-red-500:focus {
  box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.1);
}
</style>