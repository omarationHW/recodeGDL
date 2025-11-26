<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-pie" />
      </div>
      <div class="module-view-info">
        <h1>Estadística de Pagos y Adeudos</h1>
        <p>Inicio > Mercados > Estadística Pagos/Adeudos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || result.length === 0">
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de Consulta -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="selectedRec" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.axo" min="1995" max="2100" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.mes" min="1" max="12" :disabled="loading" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fechaDesde" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fechaHasta" :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="consultar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Consultar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="result.length > 0">
              {{ formatNumber(result.length) }} mercados
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando estadísticas, por favor espere...</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th rowspan="2">Mercado</th>
                  <th rowspan="2">Nombre</th>
                  <th colspan="3" class="text-center group-header-success">Pagados</th>
                  <th colspan="3" class="text-center group-header-info">Capturados</th>
                  <th colspan="3" class="text-center group-header-danger">Adeudos</th>
                </tr>
                <tr>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Periodos</th>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Periodos</th>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Periodos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="result.length === 0 && !searchPerformed">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros y consulte</p>
                  </td>
                </tr>
                <tr v-else-if="result.length === 0">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron datos</p>
                  </td>
                </tr>
                <tr v-else v-for="row in result" :key="row.num_mercado_nvo" class="row-hover">
                  <td class="text-center"><strong>{{ row.num_mercado_nvo }}</strong></td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ row.localpag }}</td>
                  <td class="text-end text-success"><strong>{{ formatCurrency(row.pagospag) }}</strong></td>
                  <td class="text-end">{{ row.periodospag }}</td>
                  <td class="text-end">{{ row.localcap }}</td>
                  <td class="text-end text-info"><strong>{{ formatCurrency(row.pagoscap) }}</strong></td>
                  <td class="text-end">{{ row.periodoscap }}</td>
                  <td class="text-end">{{ row.localade }}</td>
                  <td class="text-end text-danger"><strong>{{ formatCurrency(row.pagosade) }}</strong></td>
                  <td class="text-end">{{ row.periodosade }}</td>
                </tr>
                <tr v-if="result.length > 0" class="total-row">
                  <td colspan="2" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end"><strong>{{ totales.localesPag }}</strong></td>
                  <td class="text-end text-success"><strong>{{ formatCurrency(totales.importePag) }}</strong></td>
                  <td class="text-end"><strong>{{ totales.periodosPag }}</strong></td>
                  <td class="text-end"><strong>{{ totales.localesCap }}</strong></td>
                  <td class="text-end text-info"><strong>{{ formatCurrency(totales.importeCap) }}</strong></td>
                  <td class="text-end"><strong>{{ totales.periodosCap }}</strong></td>
                  <td class="text-end"><strong>{{ totales.localesAde }}</strong></td>
                  <td class="text-end text-danger"><strong>{{ formatCurrency(totales.importeAde) }}</strong></td>
                  <td class="text-end"><strong>{{ totales.periodosAde }}</strong></td>
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
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const selectedRec = ref('')
const loading = ref(false)
const searchPerformed = ref(false)

const form = ref({
  axo: new Date().getFullYear(),
  mes: new Date().getMonth() + 1,
  fechaDesde: new Date().toISOString().split('T')[0],
  fechaHasta: new Date().toISOString().split('T')[0]
})

// Datos
const result = ref([])

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const totales = computed(() => {
  return result.value.reduce((acc, row) => {
    acc.localesPag += Number(row.localpag || 0)
    acc.importePag += Number(row.pagospag || 0)
    acc.periodosPag += Number(row.periodospag || 0)
    acc.localesCap += Number(row.localcap || 0)
    acc.importeCap += Number(row.pagoscap || 0)
    acc.periodosCap += Number(row.periodoscap || 0)
    acc.localesAde += Number(row.localade || 0)
    acc.importeAde += Number(row.pagosade || 0)
    acc.periodosAde += Number(row.periodosade || 0)
    return acc
  }, {
    localesPag: 0, importePag: 0, periodosPag: 0,
    localesCap: 0, importeCap: 0, periodosCap: 0,
    localesAde: 0, importeAde: 0, periodosAde: 0
  })
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ayuda: Consulte estadísticas de pagos, capturas y adeudos por mercado')
}

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const formatCurrency = (value) => {
  if (value === null || value === undefined || value === '') return '$0.00'
  const num = typeof value === 'number' ? value : parseFloat(value)
  if (isNaN(num)) return '$0.00'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const fetchRecaudadoras = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (res.data.eResponse?.success === true) {
      recaudadoras.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    showToast('error', 'Error al cargar recaudadoras')
  }
}

const consultar = async () => {
  if (!selectedRec.value || !form.value.axo || !form.value.mes || !form.value.fechaDesde || !form.value.fechaHasta) {
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }

  loading.value = true
  result.value = []
  searchPerformed.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_estadistica_pagos_adeudos',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: selectedRec.value },
          { Nombre: 'p_axo', Valor: form.value.axo },
          { Nombre: 'p_mes', Valor: form.value.mes },
          { Nombre: 'p_fecha_desde', Valor: form.value.fechaDesde },
          { Nombre: 'p_fecha_hasta', Valor: form.value.fechaHasta }
        ]
      }
    })
    if (res.data.eResponse?.success) {
      result.value = res.data.eResponse.data.result || []
      if (result.value.length > 0) {
        showToast('success', `Se encontraron ${result.value.length} mercados`)
        showFilters.value = false
      } else {
        showToast('info', 'No hay datos para los filtros seleccionados')
      }
    } else {
      showToast('error', res.data.eResponse?.message || 'Error en la consulta')
    }
  } catch (err) {
    showToast('error', 'Error al consultar estadísticas')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedRec.value = ''
  form.value.axo = new Date().getFullYear()
  form.value.mes = new Date().getMonth() + 1
  form.value.fechaDesde = new Date().toISOString().split('T')[0]
  form.value.fechaHasta = new Date().toISOString().split('T')[0]
  result.value = []
  searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (result.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }
  showToast('info', 'Funcionalidad de exportación Excel en desarrollo')
}

onMounted(() => {
  fetchRecaudadoras()
})
</script>

<style scoped>
.empty-icon { color: #ccc; margin-bottom: 1rem; }
.text-end { text-align: right; }
.text-center { text-align: center; }
.spinner-border { width: 3rem; height: 3rem; }
.row-hover:hover { background-color: #f8f9fa; }
.required { color: #dc3545; }

.group-header-success {
  background-color: #d4edda !important;
  color: #155724;
}

.group-header-info {
  background-color: #d1ecf1 !important;
  color: #0c5460;
}

.group-header-danger {
  background-color: #f8d7da !important;
  color: #721c24;
}

.text-success { color: #28a745; }
.text-info { color: #17a2b8; }
.text-danger { color: #dc3545; }

.total-row {
  background-color: #f8f9fa;
  font-weight: bold;
  border-top: 2px solid #dee2e6;
}

.municipal-table td.text-end, .municipal-table th.text-end { text-align: right; }
.municipal-table td.text-center, .municipal-table th.text-center { text-align: center; }
</style>
