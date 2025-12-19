<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-pie" />
      </div>
      <div class="module-view-info">
        <h1>Resumen de Pagos</h1>
        <p>Mercados > Resumen Consolidado de Pagos por Mercado</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || resumen.length === 0">
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
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
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
              <label class="municipal-form-label">Mercado (Opcional)</label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="loading || !selectedOficina || mercados.length === 0">
                <option value="">Todos los mercados</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
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
            Resumen de Pagos
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="resumen.length > 0">
              {{ formatNumber(resumen.length) }} mercados
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
            <p class="mt-3 text-muted">Procesando resumen...</p>
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
                  <th>Mercado</th>
                  <th>Descripción</th>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Total Pagos</th>
                  <th class="text-end">Periodos</th>
                  <th class="text-end">Importe Total</th>
                  <th class="text-end">Pago Promedio</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="resumen.length === 0 && !searchPerformed">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="calendar-alt" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros para consultar el resumen de pagos</p>
                  </td>
                </tr>
                <tr v-else-if="resumen.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in resumen" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.num_mercado }}</strong></td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatNumber(row.total_locales_con_pago) }}</td>
                  <td class="text-end">{{ formatNumber(row.total_pagos) }}</td>
                  <td class="text-end">{{ formatNumber(row.total_periodos_pagados) }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_total) }}</strong>
                  </td>
                  <td class="text-end">{{ formatCurrency(row.pago_promedio) }}</td>
                </tr>
                <tr v-if="resumen.length > 0" class="table-footer">
                  <td colspan="5" class="text-end"><strong>TOTAL GENERAL:</strong></td>
                  <td class="text-end">
                    <strong class="text-primary" style="font-size: 1.1em;">{{ formatCurrency(totalGeneral) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong>{{ formatCurrency(promedioGlobal) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import axios from 'axios'

const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const recaudadoras = ref([])
const mercados = ref([])
const selectedOficina = ref('')
const selectedMercado = ref('')
const fechaDesde = ref('')
const fechaHasta = ref('')
const resumen = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Computed
const totalGeneral = computed(() => {
  return resumen.value.reduce((sum, item) => sum + (parseFloat(item.importe_total) || 0), 0)
})

const promedioGlobal = computed(() => {
  if (resumen.value.length === 0) return 0
  return totalGeneral.value / resumen.value.reduce((sum, item) => sum + (parseInt(item.total_pagos) || 0), 0)
})

// Métodos
const mostrarAyuda = () => {
  showToast('Seleccione una oficina y rango de fechas para consultar un resumen consolidado de pagos por mercado.', 'info')
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  return new Intl.NumberFormat('es-MX').format(value)
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
        Base: 'mercados',
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

const fetchMercados = async (idRecaudadora) => {
  if (!idRecaudadora) {
    mercados.value = []
    return
  }

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(idRecaudadora) }
        ]
      }
    })
    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
    mercados.value = []
  }
}

const buscar = async () => {
  if (!selectedOficina.value || !fechaDesde.value || !fechaHasta.value) {
    error.value = 'Debe seleccionar oficina y rango de fechas'
    showToast(error.value, 'warning')
    return
  }

  if (new Date(fechaDesde.value) > new Date(fechaHasta.value)) {
    error.value = 'La fecha desde no puede ser mayor que la fecha hasta'
    showToast(error.value, 'warning')
    return
  }

  showLoading('Generando resumen de pagos...', 'Por favor espere')
  loading.value = true
  error.value = ''
  resumen.value = []
  searchPerformed.value = true

  try {
    const parametros = [
      { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'integer' },
      { nombre: 'p_fecha_desde', valor: fechaDesde.value, tipo: 'date' },
      { nombre: 'p_fecha_hasta', valor: fechaHasta.value, tipo: 'date' }
    ]

    if (selectedMercado.value) {
      parametros.push({ nombre: 'p_mercado', valor: selectedMercado.value, tipo: 'integer' })
    } else {
      parametros.push({ nombre: 'p_mercado', valor: null, tipo: 'integer' })
    }

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_resumen_pagos',
        Base: 'mercados',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      resumen.value = res.data.eResponse.data.result || []
      if (resumen.value.length > 0) {
        showToast(`Se encontró resumen de ${resumen.value.length} mercados`, 'success')
      } else {
        showToast('No se encontraron pagos con los criterios especificados', 'info')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar resumen'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar resumen'
    console.error('Error al buscar:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  selectedMercado.value = ''
  mercados.value = []
  setFechasIniciales()
  resumen.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (resumen.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    const headers = ['Mercado', 'Descripción', 'Locales', 'Total Pagos', 'Periodos', 'Importe Total', 'Pago Promedio']
    const csvRows = []
    csvRows.push(headers.join(','))

    resumen.value.forEach(row => {
      const values = [
        row.num_mercado,
        `"${row.descripcion}"`,
        row.total_locales_con_pago,
        row.total_pagos,
        row.total_periodos_pagados,
        row.importe_total,
        row.pago_promedio
      ]
      csvRows.push(values.join(','))
    })

    // Agregar totales
    csvRows.push(`"","","","","TOTAL",${totalGeneral.value},${promedioGlobal.value}`)

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `resumen_pagos_${fechaDesde.value}_${fechaHasta.value}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('Archivo exportado exitosamente', 'success')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('Error al exportar el archivo', 'error')
  }
}

// Watchers
watch(selectedOficina, (newOficina) => {
  // Limpiar mercado seleccionado cuando cambie la oficina
  selectedMercado.value = ''
  mercados.value = []

  // Cargar mercados de la nueva oficina
  if (newOficina) {
    fetchMercados(newOficina)
  }
})

// Lifecycle
onMounted(async () => {
  showLoading('Cargando Reporte de Resumen de Pagos', 'Preparando catálogos...')
  try {
    await fetchRecaudadoras()
    setFechasIniciales()
  } finally {
    hideLoading()
  }
})
</script>
