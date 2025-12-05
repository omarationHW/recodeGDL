<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cash-register" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagos por Caja</h1>
        <p>Mercados > Reporte de Pagos por Caja Recaudadora</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || pagos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedOficina" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaDesde" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaHasta" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Caja (Opcional)</label>
              <input type="text" class="municipal-form-control" v-model="caja" placeholder="Todas las cajas"
                :disabled="loading" maxlength="10" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar
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

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos por Caja
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="pagos.length > 0">
              {{ formatNumber(pagos.length) }} registros
            </span>
            <span class="badge-success ms-2" v-if="totalGeneral > 0">
              Total: {{ formatCurrency(totalGeneral) }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Procesando reporte...</p>
          </div>

          <!-- Error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Caja</th>
                  <th>Mercado</th>
                  <th>Descripción</th>
                  <th class="text-end">Total Pagos</th>
                  <th class="text-end">Importe Total</th>
                  <th>Primer Pago</th>
                  <th>Último Pago</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="pagos.length === 0 && !searchPerformed">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="calendar-alt" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros para consultar pagos por caja</p>
                  </td>
                </tr>
                <tr v-else-if="pagos.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in pagos" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.caja_pago }}</strong></td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatNumber(row.total_pagos) }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_total) }}</strong>
                  </td>
                  <td>{{ formatDate(row.fecha_inicio) }}</td>
                  <td>{{ formatDate(row.fecha_fin) }}</td>
                </tr>
                <tr v-if="pagos.length > 0" class="table-footer">
                  <td colspan="4" class="text-end"><strong>TOTAL GENERAL:</strong></td>
                  <td class="text-end">
                    <strong class="text-primary" style="font-size: 1.1em;">{{ formatCurrency(totalGeneral) }}</strong>
                  </td>
                  <td colspan="2"></td>
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
const recaudadoras = ref([])
const selectedOficina = ref('')
const fechaDesde = ref('')
const fechaHasta = ref('')
const caja = ref('')
const pagos = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const totalGeneral = computed(() => {
  return pagos.value.reduce((sum, item) => sum + (parseFloat(item.importe_total) || 0), 0)
})

// Métodos
const mostrarAyuda = () => {
  showToast('info', 'Seleccione una oficina y rango de fechas para consultar los pagos agrupados por caja recaudadora.')
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

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  return new Intl.NumberFormat('es-MX').format(value)
}

const formatDate = (value) => {
  if (!value) return '-'
  const date = new Date(value)
  return date.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const setFechasIniciales = () => {
  const hoy = new Date()
  const primerDiaMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1)
  fechaDesde.value = primerDiaMes.toISOString().split('T')[0]
  fechaHasta.value = hoy.toISOString().split('T')[0]
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
    if (res.data.eResponse.success) {
      recaudadoras.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err)
  }
}

const buscar = async () => {
  if (!selectedOficina.value || !fechaDesde.value || !fechaHasta.value) {
    error.value = 'Debe seleccionar oficina y rango de fechas'
    showToast('warning', error.value)
    return
  }

  if (new Date(fechaDesde.value) > new Date(fechaHasta.value)) {
    error.value = 'La fecha desde no puede ser mayor que la fecha hasta'
    showToast('warning', error.value)
    return
  }

  loading.value = true
  error.value = ''
  pagos.value = []
  searchPerformed.value = true

  try {
    const parametros = [
      { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'integer' },
      { nombre: 'p_fecha_desde', valor: fechaDesde.value, tipo: 'date' },
      { nombre: 'p_fecha_hasta', valor: fechaHasta.value, tipo: 'date' }
    ]

    if (caja.value) {
      parametros.push({ nombre: 'p_caja', valor: caja.value, tipo: 'character varying' })
    } else {
      parametros.push({ nombre: 'p_caja', valor: null, tipo: 'character varying' })
    }

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_pagos_caja',
        Base: 'padron_licencias',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      pagos.value = res.data.eResponse.data.result || []
      if (pagos.value.length > 0) {
        showToast('success', `Se encontraron ${pagos.value.length} registros de pagos`)
      } else {
        showToast('info', 'No se encontraron pagos con los criterios especificados')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar pagos'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar pagos'
    console.error('Error al buscar:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  caja.value = ''
  setFechasIniciales()
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

  try {
    const headers = ['Caja', 'Mercado', 'Descripción', 'Total Pagos', 'Importe Total', 'Primer Pago', 'Último Pago']
    const csvRows = []
    csvRows.push(headers.join(','))

    pagos.value.forEach(row => {
      const values = [
        `"${row.caja_pago}"`,
        row.num_mercado,
        `"${row.descripcion}"`,
        row.total_pagos,
        row.importe_total,
        formatDate(row.fecha_inicio),
        formatDate(row.fecha_fin)
      ]
      csvRows.push(values.join(','))
    })

    // Agregar total
    csvRows.push(`"","","","TOTAL",${totalGeneral.value},"",""`)

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `pagos_por_caja_${fechaDesde.value}_${fechaHasta.value}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('success', 'Archivo exportado exitosamente')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('error', 'Error al exportar el archivo')
  }
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
  setFechasIniciales()
})
</script>
