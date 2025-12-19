<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagos de Locales</h1>
        <p>Inicio > Mercados > Reporte de Pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || report.length === 0">
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
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'angle-up' : 'angle-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Filtros en una sola fila -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaDesde" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaHasta" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRec" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Generar Reporte
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

      <!-- Tabla de Pagos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos Registrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="report.length > 0">
              {{ formatNumber(report.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando reporte, por favor espere...</p>
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
                  <th>Local</th>
                  <th>Fecha Pago</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Periodo</th>
                  <th class="text-end">Importe</th>
                  <th>Folio</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="report.length === 0 && !searchPerformed">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros y genere el reporte</p>
                  </td>
                </tr>
                <tr v-else-if="report.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos para los filtros seleccionados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in report" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.id_local }}</strong></td>
                  <td>{{ formatDate(row.fecha_pago) }}</td>
                  <td>{{ row.oficina_pago }}</td>
                  <td>{{ row.caja_pago }}</td>
                  <td>{{ row.operacion_pago }}</td>
                  <td>{{ row.axo }}-{{ String(row.periodo).padStart(2, '0') }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_pago) }}</strong>
                  </td>
                  <td>{{ row.folio }}</td>
                  <td>{{ row.usuario }}</td>
                </tr>
              </tbody>
              <tfoot v-if="report.length > 0">
                <tr class="table-info">
                  <td colspan="6" class="text-end"><strong>Total:</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></td>
                  <td colspan="2"></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const selectedRec = ref('')
const fechaDesde = ref(new Date().toISOString().split('T')[0])
const fechaHasta = ref(new Date().toISOString().split('T')[0])

// Datos
const report = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Computed
const totalImporte = computed(() => {
  return report.value.reduce((sum, row) => sum + Number(row.importe_pago || 0), 0)
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ayuda: Seleccione un rango de fechas y una oficina para generar el reporte de pagos', 'info')
}

const fetchRecaudadoras = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (res.data.eResponse.success === true) {
      recaudadoras.value = res.data.eResponse.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast(`Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`, 'success')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al cargar recaudadoras'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar recaudadoras'
    console.error('Error al cargar recaudadoras:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const buscar = async () => {
  if (!fechaDesde.value || !fechaHasta.value || !selectedRec.value) {
    error.value = 'Debe seleccionar fecha desde, fecha hasta y oficina'
    showToast(error.value, 'warning')
    return
  }

  if (fechaDesde.value > fechaHasta.value) {
    error.value = 'La fecha desde no puede ser mayor a la fecha hasta'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  report.value = []
  searchPerformed.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_pagos_locales',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_fecha_desde', Valor: fechaDesde.value },
          { Nombre: 'p_fecha_hasta', Valor: fechaHasta.value },
          { Nombre: 'p_oficina', Valor: selectedRec.value }
        ]
      }
    })

    if (res.data.eResponse && res.data.eResponse.success === true) {
      report.value = res.data.eResponse.data.result || []
      if (report.value.length > 0) {
        showToast(`Se encontraron ${report.value.length} pagos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron pagos para los filtros seleccionados', 'info')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al generar reporte'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al generar reporte'
    console.error('Error al generar reporte:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedRec.value = ''
  fechaDesde.value = new Date().toISOString().split('T')[0]
  fechaHasta.value = new Date().toISOString().split('T')[0]
  report.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (report.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('Funcionalidad de exportación Excel en desarrollo', 'info')
}

// Utilidades
const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return '$0.00'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatDate = (value) => {
  if (!value) return ''
  return new Date(value).toLocaleDateString('es-MX')
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando Reporte de Pagos por Locales', 'Preparando oficinas recaudadoras...')
  try {
    await fetchRecaudadoras()
  } finally {
    hideLoading()
  }
})
</script>

<style scoped>
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.text-end {
  text-align: right;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

.required {
  color: #dc3545;
}

.municipal-table td.text-end,
.municipal-table th.text-end {
  text-align: right;
}
</style>
