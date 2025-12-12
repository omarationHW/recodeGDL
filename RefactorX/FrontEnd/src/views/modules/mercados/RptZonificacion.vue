<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marker-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Ingresos por Zonificación</h1>
        <p>Mercados > Reporte de Ingresos Zonificados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || ingresos.length === 0">
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
            <font-awesome-icon icon="calendar-alt" />
            Rango de Fechas
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaDesde" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaHasta" :disabled="loading" />
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

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="chart-bar" />
            Ingresos por Zona
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="ingresos.length > 0">
              {{ ingresos.length }} zonas
            </span>
            <span class="badge-success ms-2" v-if="totalGeneral > 0">
              Total: {{ formatCurrency(totalGeneral) }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Procesando ingresos...</p>
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
                  <th>ID Zona</th>
                  <th>Zona</th>
                  <th class="text-end">Ingreso Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="ingresos.length === 0 && !searchPerformed">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="calendar-alt" size="2x" class="empty-icon" />
                    <p>Seleccione un rango de fechas para consultar ingresos por zona</p>
                  </td>
                </tr>
                <tr v-else-if="ingresos.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron ingresos en el rango de fechas especificado</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in ingresos" :key="index" class="row-hover">
                  <td>{{ row.id_zona }}</td>
                  <td><strong>{{ row.zona }}</strong></td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.pagado) }}</strong>
                  </td>
                </tr>
                <tr v-if="ingresos.length > 0" class="table-footer">
                  <td colspan="2" class="text-end"><strong>TOTAL GENERAL:</strong></td>
                  <td class="text-end">
                    <strong class="text-primary" style="font-size: 1.1em;">{{ formatCurrency(totalGeneral) }}</strong>
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
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)
const fechaDesde = ref('')
const fechaHasta = ref('')
const ingresos = ref([])

// Computed
const totalGeneral = computed(() => {
  return ingresos.value.reduce((sum, item) => sum + (parseFloat(item.pagado) || 0), 0)
})

// Métodos
const mostrarAyuda = () => {
  showToast('Seleccione un rango de fechas para consultar los ingresos agrupados por zona geográfica', 'info')
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const setFechasIniciales = () => {
  const hoy = new Date()
  const primerDiaMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1)
  fechaDesde.value = primerDiaMes.toISOString().split('T')[0]
  fechaHasta.value = hoy.toISOString().split('T')[0]
}

const consultar = async () => {
  if (!fechaDesde.value || !fechaHasta.value) {
    error.value = 'Debe seleccionar ambas fechas'
    showToast(error.value, 'warning')
    return
  }

  if (new Date(fechaDesde.value) > new Date(fechaHasta.value)) {
    error.value = 'La fecha desde no puede ser mayor que la fecha hasta'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  showLoading()
  error.value = ''
  ingresos.value = []
  searchPerformed.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_ingreso_zonificado',
        Base: 'mercados',
        Parametros: [
          { nombre: 'p_fecdesde', valor: fechaDesde.value, tipo: 'date' },
          { nombre: 'p_fechasta', valor: fechaHasta.value, tipo: 'date' }
        ]
      }
    })

    if (res.data.eResponse.success) {
      ingresos.value = res.data.eResponse.data.result || []
      if (ingresos.value.length > 0) {
        showToast(`Se encontraron ${ingresos.value.length} zonas con ingresos`, 'success')
      } else {
        showToast('No se encontraron ingresos en el rango de fechas especificado', 'info')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar ingresos'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar ingresos'
    console.error('Error al consultar:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  setFechasIniciales()
  ingresos.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (ingresos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    const headers = ['ID Zona', 'Zona', 'Ingreso Total']
    const csvRows = []
    csvRows.push(headers.join(','))

    ingresos.value.forEach(row => {
      const values = [
        row.id_zona,
        `"${row.zona}"`,
        row.pagado
      ]
      csvRows.push(values.join(','))
    })

    // Agregar total
    csvRows.push(`"","TOTAL GENERAL",${totalGeneral.value}`)

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `ingresos_zonificacion_${fechaDesde.value}_${fechaHasta.value}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('Archivo exportado exitosamente', 'success')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('Error al exportar el archivo', 'error')
  }
}

// Lifecycle
onMounted(() => {
  setFechasIniciales()
})
</script>
