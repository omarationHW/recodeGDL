<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Reportes Estadísticos de Licencias</h1>
        <p>Padrón de Licencias - Análisis Estadístico de Licencias por Giro y Zona</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de reporte -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Configuración del Reporte
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Reporte: <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model="filters.tipoReporte"
                :disabled="loading"
              >
                <option value="">Seleccionar tipo...</option>
                <option value="1">Reporte 1 - Licencias por Giro y Zona</option>
                <option value="2">Reporte 2 - Licencias Reglamentadas por Zona</option>
                <option value="3">Reporte 3 - Estadística de Pagos</option>
                <option value="4">Reporte 4 - Giros por Zona (Detallado)</option>
                <option value="5">Reporte 5 - Giros Reglamentados por Zona</option>
              </select>
            </div>
          </div>

          <div class="form-row" v-if="filters.tipoReporte">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Inicio: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaInicio"
                :disabled="loading"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaFin"
                :disabled="loading"
              >
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="loading || !filters.tipoReporte || !filters.fechaInicio || !filters.fechaFin"
            >
              <font-awesome-icon icon="chart-line" />
              Generar Reporte
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultados.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados del Reporte
            <span class="badge-purple" v-if="resultados.length > 0">{{ resultados.length }} registros</span>
          </h5>
          <button
            class="btn-municipal-primary"
            @click="exportarExcel"
            :disabled="loading"
          >
            <font-awesome-icon icon="file-excel" />
            Exportar a Excel
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <!-- Reporte tipo 1 y 2: Por giro y zona -->
            <table class="municipal-table" v-if="filters.tipoReporte === '1' || filters.tipoReporte === '2'">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Giro</th>
                  <th>Descripción</th>
                  <th class="text-center">Zona 1</th>
                  <th class="text-center">Zona 2</th>
                  <th class="text-center">Zona 3</th>
                  <th class="text-center">Zona 4</th>
                  <th class="text-center">Zona 5</th>
                  <th class="text-center">Zona 6</th>
                  <th class="text-center">Zona 7</th>
                  <th class="text-center">Otros</th>
                  <th class="text-center"><strong>Total</strong></th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in resultados" :key="row.id_giro" class="clickable-row">
                  <td>
                    <span class="badge-secondary">{{ row.id_giro }}</span>
                  </td>
                  <td><strong>{{ row.descripcion }}</strong></td>
                  <td class="text-center">{{ row.z_1 || 0 }}</td>
                  <td class="text-center">{{ row.z_2 || 0 }}</td>
                  <td class="text-center">{{ row.z_3 || 0 }}</td>
                  <td class="text-center">{{ row.z_4 || 0 }}</td>
                  <td class="text-center">{{ row.z_5 || 0 }}</td>
                  <td class="text-center">{{ row.z_6 || 0 }}</td>
                  <td class="text-center">{{ row.z_7 || 0 }}</td>
                  <td class="text-center">{{ row.otros || 0 }}</td>
                  <td class="text-center">
                    <span class="badge-primary"><strong>{{ row.total || 0 }}</strong></span>
                  </td>
                </tr>
                <tr v-if="totales" class="table-total-row">
                  <td colspan="2" class="text-right"><strong>TOTALES:</strong></td>
                  <td class="text-center"><strong>{{ totales.z_1 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.z_2 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.z_3 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.z_4 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.z_5 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.z_6 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.z_7 }}</strong></td>
                  <td class="text-center"><strong>{{ totales.otros }}</strong></td>
                  <td class="text-center">
                    <span class="badge-success"><strong>{{ totales.total }}</strong></span>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Reporte tipo 3: Pagos -->
            <table class="municipal-table" v-if="filters.tipoReporte === '3'">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-right">Cantidad</th>
                  <th class="text-right">Monto Total</th>
                  <th class="text-right">Promedio</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in resultados" :key="index" class="clickable-row">
                  <td><strong>{{ row.concepto }}</strong></td>
                  <td class="text-right">{{ row.cantidad || 0 }}</td>
                  <td class="text-right">{{ formatCurrency(row.monto_total) }}</td>
                  <td class="text-right">{{ formatCurrency(row.promedio) }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Reporte tipo 4 y 5: General -->
            <table class="municipal-table" v-if="filters.tipoReporte === '4' || filters.tipoReporte === '5'">
              <thead class="municipal-table-header">
                <tr>
                  <th>Zona</th>
                  <th>Giro</th>
                  <th>Descripción</th>
                  <th class="text-center">Cantidad</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in resultados" :key="index" class="clickable-row">
                  <td>
                    <span class="badge-purple">Zona {{ row.zona || 'N/A' }}</span>
                  </td>
                  <td>
                    <span class="badge-secondary">{{ row.id_giro }}</span>
                  </td>
                  <td><strong>{{ row.descripcion }}</strong></td>
                  <td class="text-center">{{ row.cantidad || 0 }}</td>
                  <td class="text-right">{{ row.total || 0 }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay datos -->
      <div class="municipal-card" v-if="!loading && resultados.length === 0 && filters.tipoReporte">
        <div class="municipal-card-body text-center text-muted">
          <font-awesome-icon icon="chart-bar" size="3x" class="empty-icon" />
          <p>No se encontraron datos para el reporte seleccionado en el rango de fechas especificado</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Generando reporte estadístico...</p>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'repEstadisticosLicfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useExcelExport } from '@/composables/useExcelExport'
import Swal from 'sweetalert2'

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { exportToExcel } = useExcelExport()

// Estado
const resultados = ref([])
const filters = ref({
  tipoReporte: '',
  fechaInicio: '',
  fechaFin: ''
})

// Computed
const totales = computed(() => {
  if (resultados.value.length === 0) return null
  if (filters.value.tipoReporte !== '1' && filters.value.tipoReporte !== '2') return null

  return {
    z_1: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_1) || 0), 0),
    z_2: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_2) || 0), 0),
    z_3: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_3) || 0), 0),
    z_4: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_4) || 0), 0),
    z_5: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_5) || 0), 0),
    z_6: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_6) || 0), 0),
    z_7: resultados.value.reduce((sum, row) => sum + (parseInt(row.z_7) || 0), 0),
    otros: resultados.value.reduce((sum, row) => sum + (parseInt(row.otros) || 0), 0),
    total: resultados.value.reduce((sum, row) => sum + (parseInt(row.total) || 0), 0)
  }
})

// Métodos
const generarReporte = async () => {
  if (!filters.value.tipoReporte || !filters.value.fechaInicio || !filters.value.fechaFin) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Validar que fecha inicio sea menor que fecha fin
  if (new Date(filters.value.fechaInicio) > new Date(filters.value.fechaFin)) {
    await Swal.fire({
      icon: 'warning',
      title: 'Rango de fechas inválido',
      text: 'La fecha de inicio debe ser anterior a la fecha fin',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Generando reporte...')

  try {
    let spName = ''
    const params = [
      { nombre: 'fecha1', valor: filters.value.fechaInicio, tipo: 'string' },
      { nombre: 'fecha2', valor: filters.value.fechaFin, tipo: 'string' }
    ]

    // Determinar el SP según el tipo de reporte
    switch (filters.value.tipoReporte) {
      case '1':
        spName = 'sp_rep_est_lic_report1'
        break
      case '2':
        spName = 'sp_rep_est_lic_report2'
        break
      case '3':
        spName = 'sp_rep_est_lic_report3'
        break
      case '4':
        spName = 'sp_rep_est_lic_report4'
        break
      case '5':
        spName = 'sp_rep_est_lic_report5'
        break
      default:
        throw new Error('Tipo de reporte no válido')
    }

    const response = await execute(
      spName,
      'padron_licencias',
      params,
      'guadalajara'
    )

    if (response && response.result) {
      resultados.value = response.result
      showToast('success', `Reporte generado: ${resultados.value.length} registros encontrados`)
    } else {
      resultados.value = []
      showToast('info', 'No se encontraron datos para el reporte')
    }
  } catch (error) {
    handleApiError(error)
    resultados.value = []
  } finally {
    setLoading(false)
  }
}

const exportarExcel = async () => {
  if (resultados.value.length === 0) {
    await Swal.fire({
      icon: 'warning',
      title: 'Sin datos',
      text: 'No hay datos para exportar',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  try {
    let columns = []
    let sheetName = 'Reporte'

    // Definir columnas según tipo de reporte
    if (filters.value.tipoReporte === '1' || filters.value.tipoReporte === '2') {
      columns = [
        { header: 'ID Giro', key: 'id_giro', width: 10 },
        { header: 'Descripción', key: 'descripcion', width: 40 },
        { header: 'Zona 1', key: 'z_1', type: 'integer', width: 10 },
        { header: 'Zona 2', key: 'z_2', type: 'integer', width: 10 },
        { header: 'Zona 3', key: 'z_3', type: 'integer', width: 10 },
        { header: 'Zona 4', key: 'z_4', type: 'integer', width: 10 },
        { header: 'Zona 5', key: 'z_5', type: 'integer', width: 10 },
        { header: 'Zona 6', key: 'z_6', type: 'integer', width: 10 },
        { header: 'Zona 7', key: 'z_7', type: 'integer', width: 10 },
        { header: 'Otros', key: 'otros', type: 'integer', width: 10 },
        { header: 'Total', key: 'total', type: 'integer', width: 12 }
      ]
      sheetName = filters.value.tipoReporte === '1' ? 'Licencias_por_Giro_Zona' : 'Lic_Reglamentadas_Zona'
    } else if (filters.value.tipoReporte === '3') {
      columns = [
        { header: 'Concepto', key: 'concepto', width: 30 },
        { header: 'Cantidad', key: 'cantidad', type: 'integer', width: 15 },
        { header: 'Monto Total', key: 'monto_total', type: 'currency', width: 18 },
        { header: 'Promedio', key: 'promedio', type: 'currency', width: 15 }
      ]
      sheetName = 'Estadistica_Pagos'
    } else if (filters.value.tipoReporte === '4' || filters.value.tipoReporte === '5') {
      columns = [
        { header: 'Zona', key: 'zona', width: 10 },
        { header: 'ID Giro', key: 'id_giro', width: 10 },
        { header: 'Descripción', key: 'descripcion', width: 40 },
        { header: 'Cantidad', key: 'cantidad', type: 'integer', width: 12 },
        { header: 'Total', key: 'total', type: 'integer', width: 12 }
      ]
      sheetName = filters.value.tipoReporte === '4' ? 'Giros_Zona_Detallado' : 'Giros_Reglam_Zona'
    }

    const filename = `Rep_Estadistico_Tipo${filters.value.tipoReporte}_${filters.value.fechaInicio}_${filters.value.fechaFin}`
    const success = exportToExcel(resultados.value, columns, filename, sheetName)

    if (success) {
      showToast('success', `Excel exportado: ${resultados.value.length} registros`)
    } else {
      showToast('error', 'Error al exportar Excel')
    }
  } catch (error) {
    showToast('error', 'Error al generar el archivo Excel')
  }
}

const clearFilters = () => {
  filters.value = {
    tipoReporte: '',
    fechaInicio: '',
    fechaFin: ''
  }
  resultados.value = []
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  const num = parseFloat(value)
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(num)
}

// Lifecycle
onMounted(() => {
  // Establecer fecha por defecto: primer día del año actual
  const today = new Date()
  const firstDay = new Date(today.getFullYear(), 0, 1)
  filters.value.fechaInicio = firstDay.toISOString().split('T')[0]
  filters.value.fechaFin = today.toISOString().split('T')[0]
})
</script>

