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
          <!-- Mensaje de error -->
          <div v-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla (loading es manejado por useGlobalLoading) -->
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
                <tr v-else v-for="pago in paginatedPagos" :key="pago.id_pago_energia" class="row-hover">
                  <td><strong class="text-primary">{{ pago.id_energia }}</strong></td>
                  <!-- Badge de año con estilo purple gradient -->
                  <td><span class="badge-purple" style="font-weight: 600;">{{ pago.axo }}</span></td>
                  <!-- Badge de periodo con estilo purple gradient -->
                  <td><span class="badge-purple" style="font-weight: 500;">P{{ pago.periodo }}</span></td>
                  <td>
                    <font-awesome-icon icon="calendar-alt" style="font-size: 0.85rem; margin-right: 0.35rem;" class="text-muted" />
                    {{ formatDate(pago.fecha_pago) }}
                  </td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td class="text-end">
                    <!-- Importe con estilo monospace verde -->
                    <span style="color: #28a745; font-weight: 700; font-size: 1.05rem; font-family: 'Courier New', monospace;">{{ formatCurrency(pago.importe_pago) }}</span>
                  </td>
                  <td>
                    <!-- Folio badge con fondo azul claro -->
                    <span class="badge-info" style="font-family: 'Courier New', monospace;">{{ pago.folio || 'N/A' }}</span>
                  </td>
                  <td>{{ formatDateTime(pago.fecha_modificacion) }}</td>
                  <td>
                    <font-awesome-icon icon="user" style="font-size: 0.85rem; margin-right: 0.35rem;" class="text-muted" />
                    {{ pago.id_usuario || 'N/A' }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div v-if="pagos.length > 0" class="pagination-container">
            <div class="pagination-info">
              <span>Mostrando {{ paginationInfo }}</span>
              <div class="items-per-page">
                <label>Registros por página:</label>
                <select v-model.number="itemsPerPage" @change="changeItemsPerPage(itemsPerPage)" class="form-select form-select-sm">
                  <option v-for="option in itemsPerPageOptions" :key="option" :value="option">
                    {{ option }}
                  </option>
                </select>
              </div>
            </div>

            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="goToPage(1)">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)">
                <font-awesome-icon icon="angle-left" />
              </button>

              <span class="pagination-text">
                Página {{ currentPage }} de {{ totalPages }}
              </span>

              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

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

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(25)
const itemsPerPageOptions = [10, 25, 50, 100]

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(pagos.value.length / itemsPerPage.value)
})

const paginatedPagos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return pagos.value.slice(start, end)
})

const paginationInfo = computed(() => {
  const start = pagos.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage.value + 1
  const end = Math.min(currentPage.value * itemsPerPage.value, pagos.value.length)
  return `${start} - ${end} de ${formatNumber(pagos.value.length)}`
})

// Métodos de UI
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ingrese el ID de energía para consultar todos los pagos realizados para ese servicio.', 'info')
}

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changeItemsPerPage = (newSize) => {
  itemsPerPage.value = newSize
  currentPage.value = 1 // Reset a la primera página
}

const resetPagination = () => {
  currentPage.value = 1
  itemsPerPage.value = 25
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
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  pagos.value = []
  searchPerformed.value = true

  try {
    showLoading('Consultando pagos de energía', 'Por favor espere...')
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
        showToast('No se encontraron pagos para este ID de energía', 'info')
      } else {
        showToast(`Se encontraron ${pagos.value.length} pagos`, 'success')
        showFilters.value = false
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al buscar pagos'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al buscar pagos'
    console.error('Error al buscar pagos:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  form.value.id_energia = ''
  pagos.value = []
  error.value = ''
  searchPerformed.value = false
  resetPagination()
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (pagos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  showToast('Funcionalidad de exportación en desarrollo', 'info')
}

const imprimir = () => {
  if (pagos.value.length === 0) {
    showToast('No hay datos para imprimir', 'warning')
    return
  }
  showToast('Funcionalidad de impresión en desarrollo', 'info')
}
</script>
