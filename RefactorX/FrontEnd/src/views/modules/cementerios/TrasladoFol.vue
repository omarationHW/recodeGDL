<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="exchange-alt" />
      </div>
      <div class="module-view-info">
        <h1>Traslado de Folios</h1>
        <p>Traslado de pagos entre folios</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Búsqueda de Folios -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="search" />
        Selección de Folios
      </div>
      <div class="municipal-card-body">
        <div class="alert-info mb-3">
          <font-awesome-icon icon="info-circle" />
          <span>Ingrese el folio origen (de donde se trasladarán los pagos) y el folio destino</span>
        </div>

        <div class="form-grid-three">
          <div class="form-group">
            <label class="form-label required">Folio Origen (DE)</label>
            <input
              type="number"
              v-model.number="folioOrigen"
              class="municipal-form-control"
              placeholder="Folio de traslado"
              @keyup.enter="verificarFolios"
            />
            <small class="form-help">Folio desde el cual se trasladarán los pagos</small>
          </div>
          <div class="form-group">
            <label class="form-label required">Folio Destino (A)</label>
            <input
              type="number"
              v-model.number="folioDestino"
              class="municipal-form-control"
              placeholder="Folio a trasladar"
              @keyup.enter="verificarFolios"
            />
            <small class="form-help">Folio hacia el cual se trasladarán los pagos</small>
          </div>
          <div class="form-group align-end">
            <button
              class="btn-municipal-primary"
              @click="verificarFolios"
              :disabled="!foliosValidos"
            >
              <font-awesome-icon icon="search" />
              Verificar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información de Folios -->
    <div v-if="datosOrigen && datosDestino" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="info-circle" />
        Información de Folios
      </div>
      <div class="municipal-card-body">
        <div class="folio-comparison">
          <!-- Folio Origen -->
          <div class="folio-info">
            <h3 class="folio-title origin">
              <font-awesome-icon icon="arrow-right" />
              Folio Origen
            </h3>
            <div class="info-section">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Folio:</span>
                  <span class="info-value">{{ datosOrigen.control_rcm }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Cementerio:</span>
                  <span class="info-value">{{ datosOrigen.cementerio }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Ubicación:</span>
                  <span class="info-value">
                    {{ datosOrigen.clase_alfa }}-{{ datosOrigen.seccion_alfa }}-{{ datosOrigen.linea_alfa }}-{{ datosOrigen.fosa_alfa }}
                  </span>
                </div>
                <div class="info-item full-width">
                  <span class="info-label">Nombre:</span>
                  <span class="info-value">{{ datosOrigen.nombre }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Flecha de traslado -->
          <div class="transfer-arrow">
            <font-awesome-icon icon="arrow-circle-right" />
          </div>

          <!-- Folio Destino -->
          <div class="folio-info">
            <h3 class="folio-title destination">
              <font-awesome-icon icon="arrow-left" />
              Folio Destino
            </h3>
            <div class="info-section">
              <div class="info-grid">
                <div class="info-item">
                  <span class="info-label">Folio:</span>
                  <span class="info-value">{{ datosDestino.control_rcm }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Cementerio:</span>
                  <span class="info-value">{{ datosDestino.cementerio }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Ubicación:</span>
                  <span class="info-value">
                    {{ datosDestino.clase_alfa }}-{{ datosDestino.seccion_alfa }}-{{ datosDestino.linea_alfa }}-{{ datosDestino.fosa_alfa }}
                  </span>
                </div>
                <div class="info-item full-width">
                  <span class="info-label">Nombre:</span>
                  <span class="info-value">{{ datosDestino.nombre }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Pagos para Trasladar -->
    <div v-if="pagosOrigen.length > 0" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list-check" />
        Pagos a Trasladar ({{ pagosSeleccionados.length }} seleccionados)
      </div>
      <div class="municipal-card-body">
        <div class="alert-warning mb-3">
          <font-awesome-icon icon="exclamation-triangle" />
          <span>Seleccione los pagos que desea trasladar del folio {{ folioOrigen }} al folio {{ folioDestino }}</span>
        </div>

        <div class="table-actions mb-3">
          <button class="btn-municipal-secondary" @click="seleccionarTodos">
            <font-awesome-icon icon="check-square" />
            Seleccionar Todos
          </button>
          <button class="btn-municipal-secondary" @click="deseleccionarTodos">
            <font-awesome-icon icon="square" />
            Deseleccionar Todos
          </button>
        </div>

        <div class="table-container">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>
                  <input
                    type="checkbox"
                    @change="toggleTodos"
                    :checked="todosMarcados"
                  />
                </th>
                <th>Fecha Ingreso</th>
                <th>Recibo</th>
                <th>Control ID</th>
                <th>Años</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagosOrigen" :key="pago.control_id">
                <td>
                  <input
                    type="checkbox"
                    :value="pago.control_id"
                    v-model="pagosSeleccionados"
                  />
                </td>
                <td>{{ formatDate(pago.fecing) }}</td>
                <td>{{ pago.recing }}</td>
                <td>{{ pago.control_id }}</td>
                <td>{{ pago.axo_pago_desde }} - {{ pago.axo_pago_hasta }}</td>
                <td>{{ formatCurrency(pago.importe_anual) }}</td>
                <td>{{ formatCurrency(pago.importe_recargos) }}</td>
                <td class="text-bold">
                  {{ formatCurrency(pago.importe_anual + pago.importe_recargos) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="summary-box mt-3">
          <div class="summary-item">
            <span class="summary-label">Total Pagos:</span>
            <span class="summary-value">{{ pagosOrigen.length }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Seleccionados:</span>
            <span class="summary-value primary">{{ pagosSeleccionados.length }}</span>
          </div>
          <div class="summary-item">
            <span class="summary-label">Total a Trasladar:</span>
            <span class="summary-value success">
              {{ formatCurrency(totalSeleccionado) }}
            </span>
          </div>
        </div>

        <div class="form-actions">
          <button
            class="btn-municipal-secondary"
            @click="cancelar"
          >
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button
            class="btn-municipal-primary"
            @click="confirmarTraslado"
            :disabled="pagosSeleccionados.length === 0"
          >
            <font-awesome-icon icon="exchange-alt" />
            Trasladar Pagos ({{ pagosSeleccionados.length }})
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'TrasladoFol'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Estado
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const folioOrigen = ref(null)
const folioDestino = ref(null)
const datosOrigen = ref(null)
const datosDestino = ref(null)
const pagosOrigen = ref([])
const pagosSeleccionados = ref([])

// Validaciones
const foliosValidos = computed(() => {
  return folioOrigen.value > 0 && folioDestino.value > 0 && folioOrigen.value !== folioDestino.value
})

const todosMarcados = computed(() => {
  return pagosOrigen.value.length > 0 &&
         pagosSeleccionados.value.length === pagosOrigen.value.length
})

const totalSeleccionado = computed(() => {
  return pagosOrigen.value
    .filter(p => pagosSeleccionados.value.includes(p.control_id))
    .reduce((sum, p) => sum + p.importe_anual + p.importe_recargos, 0)
})

// Verificar folios
const verificarFolios = async () => {
  if (!foliosValidos.value) {
    showToast('error', 'Por favor ingrese dos folios diferentes válidos')
    return
  }

  showLoading()

  try {
    // Buscar folio origen
    const response = await execute(
      'sp_abcf_get_folio',
      'cementerio',
       [
      { nombre: 'p_folio', valor: folioOrigen.value, tipo: 'integer' }
    ], 
    '',
    null,
    'public')

    if(response?.result?.length > 0 )
    {
      datosOrigen.value = response.result[0]
    }
    else{
      showToast('error', 'El folio origen no existe')
          return

    }
    
    // Buscar folio destino
    const resultDestino = await execute(
      'sp_abcf_get_folio',
      'cementerio',
      [
      { nombre: 'p_folio', valor: folioDestino.value, tipo: 'integer' }
      ], 
      '',
      null, 
      'public')


    if(resultDestino?.result?.length > 0 )
    {
      datosDestino.value = resultDestino.result[0]
    }
    else{
      showToast('error', 'El folio destino no existe')
          return

    }
    
    // Cargar pagos del folio origen
    await cargarPagosOrigen()

  } catch (error) {
    console.error('Error al verificar folios:', error)
    showToast('error', 'Error al verificar los folios')
  } finally {
    hideLoading()
  }
}

// Cargar pagos del folio origen
const cargarPagosOrigen = async () => {
  try {
    const response = await execute(
      'sp_trasladofol_listar_pagos_folio',
      'cementerio', 
       [
        { nombre: 'p_control_rcm', valor: folioOrigen.value, tipo: 'integer' }
       ],
      'cementerio', 
        null,
      'public')

    if(response?.result?.length > 0 )
    {
      pagosOrigen.value = response.result
    }
    else{
      showToast('error', 'El folio origen no tiene pagos para trasladar')
          return

    }
    pagosSeleccionados.value = []

  } catch (error) {
    console.error('Error al cargar pagos:', error)
    showToast('error', 'Error al cargar los pagos')
  }
}

// Seleccionar todos los pagos
const seleccionarTodos = () => {
  pagosSeleccionados.value = pagosOrigen.value.map(p => p.control_id)
}

// Deseleccionar todos los pagos
const deseleccionarTodos = () => {
  pagosSeleccionados.value = []
}

// Toggle todos
const toggleTodos = () => {
  if (todosMarcados.value) {
    deseleccionarTodos()
  } else {
    seleccionarTodos()
  }
}

// Confirmar traslado
const confirmarTraslado = async () => {
  if (pagosSeleccionados.value.length === 0) {
    showToast('error', 'Debe seleccionar al menos un pago')
    return
  }

  const result = await Swal.fire({
    title: '¿Confirmar traslado?',
    html: `
      Se trasladarán <strong>${pagosSeleccionados.value.length}</strong> pago(s)<br>
      Del folio <strong>${folioOrigen.value}</strong><br>
      Al folio <strong>${folioDestino.value}</strong><br><br>
      Total: <strong>${formatCurrency(totalSeleccionado.value)}</strong>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, trasladar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  showLoading()

  try {
    // Trasladar pagos
    const controlIds = pagosSeleccionados.value.join(',')
    const response = await execute(
      'sp_trasladofol_trasladar_pagos', 
      'cementerio',
      [
      { nombre: 'p_folio_origen', valor: folioOrigen.value, tipo: 'integer' },
      { nombre: 'p_folio_destino', valor: folioDestino.value, tipo: 'integer' },
      { nombre: 'p_control_ids', valor: controlIds, tipo: 'varchar' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
    ], 
    'cementerio',
    null,
     'public')

    let trasladoData = null
     if(response?.result?.length > 0 ){
      trasladoData = response.result[0]
     }
    if (trasladoData && trasladoData.resultado === 'S') {
      showToast('success', `${trasladoData.registros_actualizados} pago(s) trasladado(s) exitosamente`)

      // Limpiar y recargar
      await verificarFolios()
    } else {
      showToast('error', trasladoData?.mensaje || 'Error al trasladar pagos')
    }
  } catch (error) {
    console.error('Error al trasladar pagos:', error)
    showToast('error', 'Error al trasladar los pagos')
  } finally {
    hideLoading()
  }
}

// Cancelar
const cancelar = () => {
  folioOrigen.value = null
  folioDestino.value = null
  datosOrigen.value = null
  datosDestino.value = null
  pagosOrigen.value = []
  pagosSeleccionados.value = []
}

// Formatear moneda
const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

// Formatear fecha
const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}
</script>
