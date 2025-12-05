<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Reporte General de Mercados</h1>
        <p>Mercados > Reporte General con Estadísticas Completas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || reporte.length === 0">
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
            Parámetros de Consulta
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
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="1995" max="2999"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="periodo" min="1" max="12"
                placeholder="Periodo (1-12)" :disabled="loading" />
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
            <font-awesome-icon icon="table" />
            Estadísticas por Mercado
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="reporte.length > 0">
              {{ formatNumber(reporte.length) }} mercados
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando reporte, por favor espere...</p>
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
                  <th rowspan="2">Mercado</th>
                  <th rowspan="2">Descripción</th>
                  <th rowspan="2" class="text-end">Total Locales</th>
                  <th colspan="3" class="text-center" style="border-bottom: 1px solid #dee2e6;">Pagos</th>
                  <th colspan="3" class="text-center" style="border-bottom: 1px solid #dee2e6;">Adeudos</th>
                  <th rowspan="2" class="text-end">% Cobranza</th>
                </tr>
                <tr>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Cantidad</th>
                  <th class="text-end">Importe</th>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Cantidad</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="reporte.length === 0 && !searchPerformed">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="calendar-check" size="2x" class="empty-icon" />
                    <p>Seleccione oficina, año y periodo para generar el reporte</p>
                  </td>
                </tr>
                <tr v-else-if="reporte.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron datos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in reporte" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.num_mercado }}</strong></td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatNumber(row.total_locales) }}</td>
                  <td class="text-end">{{ formatNumber(row.locales_con_pagos) }}</td>
                  <td class="text-end">{{ formatNumber(row.total_pagos_periodo) }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_pagos) }}</strong>
                  </td>
                  <td class="text-end">{{ formatNumber(row.locales_con_adeudos) }}</td>
                  <td class="text-end">{{ formatNumber(row.total_adeudos_periodo) }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.importe_adeudos) }}</strong>
                  </td>
                  <td class="text-end">
                    <span class="badge" :class="getBadgeClass(row.porcentaje_cobranza)">
                      {{ row.porcentaje_cobranza }}%
                    </span>
                  </td>
                </tr>
                <tr v-if="reporte.length > 0" class="table-footer">
                  <td colspan="5" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end">
                    <strong class="text-success" style="font-size: 1.1em;">{{ formatCurrency(totalPagos) }}</strong>
                  </td>
                  <td colspan="2" class="text-end"></td>
                  <td class="text-end">
                    <strong class="text-danger" style="font-size: 1.1em;">{{ formatCurrency(totalAdeudos) }}</strong>
                  </td>
                  <td></td>
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
const axo = ref(new Date().getFullYear())
const periodo = ref(new Date().getMonth() + 1)
const reporte = ref([])
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
const totalPagos = computed(() => {
  return reporte.value.reduce((sum, item) => sum + (parseFloat(item.importe_pagos) || 0), 0)
})

const totalAdeudos = computed(() => {
  return reporte.value.reduce((sum, item) => sum + (parseFloat(item.importe_adeudos) || 0), 0)
})

// Métodos
const mostrarAyuda = () => {
  showToast('info', 'Seleccione una oficina, año y periodo para generar el reporte general con estadísticas de pagos, adeudos y porcentaje de cobranza por mercado.')
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

const getBadgeClass = (porcentaje) => {
  if (porcentaje >= 80) return 'badge-success'
  if (porcentaje >= 50) return 'badge-warning'
  return 'badge-danger'
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  return new Intl.NumberFormat('es-MX').format(value)
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
  if (!selectedOficina.value || !axo.value || !periodo.value) {
    error.value = 'Debe seleccionar oficina, año y periodo'
    showToast('warning', error.value)
    return
  }

  if (periodo.value < 1 || periodo.value > 12) {
    error.value = 'El periodo debe estar entre 1 y 12'
    showToast('warning', error.value)
    return
  }

  loading.value = true
  error.value = ''
  reporte.value = []
  searchPerformed.value = true

  try {
    const parametros = [
      { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'integer' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_periodo', valor: periodo.value, tipo: 'integer' }
    ]

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_reporte_general_mercados',
        Base: 'padron_licencias',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      reporte.value = res.data.eResponse.data.result || []
      if (reporte.value.length > 0) {
        showToast('success', `Reporte generado con ${reporte.value.length} mercados`)
      } else {
        showToast('info', 'No se encontraron mercados con los criterios especificados')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al generar reporte'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al generar reporte'
    console.error('Error al buscar:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  axo.value = new Date().getFullYear()
  periodo.value = new Date().getMonth() + 1
  reporte.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (reporte.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const headers = [
      'Mercado', 'Descripción', 'Total Locales',
      'Loc. con Pagos', 'Cant. Pagos', 'Importe Pagos',
      'Loc. con Adeudos', 'Cant. Adeudos', 'Importe Adeudos',
      '% Cobranza'
    ]
    const csvRows = []
    csvRows.push(headers.join(','))

    reporte.value.forEach(row => {
      const values = [
        row.num_mercado,
        `"${row.descripcion}"`,
        row.total_locales,
        row.locales_con_pagos,
        row.total_pagos_periodo,
        row.importe_pagos,
        row.locales_con_adeudos,
        row.total_adeudos_periodo,
        row.importe_adeudos,
        row.porcentaje_cobranza
      ]
      csvRows.push(values.join(','))
    })

    // Agregar totales
    csvRows.push(`"","","","","",${totalPagos.value},"","",${totalAdeudos.value},""`)

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `reporte_general_mercados_${axo.value}_${periodo.value}.csv`
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
})
</script>
