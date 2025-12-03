<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos de Energía Eléctrica</h1>
        <p>Inicio > Mercados > Pagos Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel"
          :disabled="loading || pagos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-primary" @click="imprimir"
          :disabled="loading || pagos.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Búsqueda de Pagos
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <form @submit.prevent="buscarPagos">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">ID Energía <span class="required">*</span></label>
                <input
                  v-model="form.id_energia"
                  type="number"
                  class="municipal-form-control"
                  required
                  :disabled="loading"
                  placeholder="Ingrese el ID de energía">
              </div>
            </div>

            <!-- Botones de acción -->
            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="submit" class="btn-municipal-primary me-2" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar
                  </button>
                  <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                    <font-awesome-icon icon="eraser" />
                    Limpiar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla: Resultados de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos de Energía Eléctrica
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="pagos.length > 0">
              {{ formatNumber(pagos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Recaudadora</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th class="text-end">Importe</th>
                  <th>Folio</th>
                  <th>Actualización</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="pagos.length === 0 && !searchPerformed">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Ingrese un ID de energía para consultar los pagos</p>
                  </td>
                </tr>
                <tr v-else-if="pagos.length === 0">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos para este ID de energía</p>
                  </td>
                </tr>
                <tr v-else v-for="pago in pagos" :key="pago.id_pago_energia" class="row-hover">
                  <td><strong class="text-primary">{{ pago.id_energia }}</strong></td>
                  <td><span class="badge-year">{{ pago.axo }}</span></td>
                  <td><span class="badge-period">P{{ pago.periodo }}</span></td>
                  <td>
                    <font-awesome-icon icon="calendar-alt" class="icon-small text-muted" />
                    {{ formatDate(pago.fecha_pago) }}
                  </td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td class="text-end">
                    <span class="amount-success">{{ formatCurrency(pago.importe_pago) }}</span>
                  </td>
                  <td>
                    <span class="folio-badge">{{ pago.folio || 'N/A' }}</span>
                  </td>
                  <td>{{ formatDateTime(pago.fecha_modificacion) }}</td>
                  <td>
                    <font-awesome-icon icon="user" class="icon-small text-muted" />
                    {{ pago.id_usuario || 'N/A' }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
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
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'

// Estado
const showFilters = ref(true)
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Formulario
const form = ref({
  id_energia: ''
})

// Datos
const pagos = ref([])

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Métodos de UI
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ingrese el ID de energía para consultar todos los pagos realizados para ese servicio.')
}

const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Utilidades
const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return 'N/A'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return 'N/A'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const formatDate = (dateStr) => {
  if (!dateStr) return 'N/A'
  try {
    return new Date(dateStr).toLocaleDateString('es-MX')
  } catch (e) {
    return dateStr
  }
}

const formatDateTime = (dateStr) => {
  if (!dateStr) return 'N/A'
  try {
    return new Date(dateStr).toLocaleString('es-MX')
  } catch (e) {
    return dateStr
  }
}

// Búsqueda
const buscarPagos = async () => {
  if (!form.value.id_energia) {
    error.value = 'Debe ingresar un ID de energía'
    showToast('warning', error.value)
    return
  }

  loading.value = true
  error.value = ''
  pagos.value = []
  searchPerformed.value = true

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_pagos_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_energia', Valor: parseInt(form.value.id_energia) }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      pagos.value = response.data.eResponse.data.result || []
      if (pagos.value.length === 0) {
        showToast('info', 'No se encontraron pagos para este ID de energía')
      } else {
        showToast('success', `Se encontraron ${pagos.value.length} pagos`)
        showFilters.value = false
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al buscar pagos'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al buscar pagos'
    console.error('Error al buscar pagos:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  form.value.id_energia = ''
  pagos.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (pagos.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }
  showToast('info', 'Funcionalidad de exportación en desarrollo')
}

const imprimir = () => {
  if (pagos.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }
  showToast('info', 'Funcionalidad de impresión en desarrollo')
}
</script>

<style scoped>
/* Los estilos están definidos en municipal-theme.css */

/* Estilos específicos del componente */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.required {
  color: #dc3545;
}

.row-hover:hover {
  background-color: #f8f9fa;
  cursor: pointer;
}

/* Badges */
.badge-year {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-block;
}

.badge-period {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  font-size: 0.8rem;
  display: inline-block;
}

.folio-badge {
  background: #e3f2fd;
  color: #1565c0;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  font-size: 0.8rem;
  font-family: 'Courier New', monospace;
  display: inline-block;
}

/* Montos */
.amount-success {
  color: #28a745;
  font-weight: 700;
  font-size: 1.05rem;
  font-family: 'Courier New', monospace;
}

/* Iconos */
.icon-small {
  font-size: 0.85rem;
  margin-right: 0.35rem;
}

/* Tabla responsive */
.municipal-table td.text-end,
.municipal-table th.text-end {
  text-align: right;
}
</style>
