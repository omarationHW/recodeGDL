<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Reportes Estadísticos de Licencias</h1>
        <p>Padrón de Licencias - Análisis Estadístico de Licencias por Giro y Zona</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
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
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Fin: <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fechaFin"
              >
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="generarReporte"
              :disabled="!filters.tipoReporte || !filters.fechaInicio || !filters.fechaFin"
            >
              <font-awesome-icon icon="chart-line" />
              Generar Reporte
            </button>
            <button
              class="btn-municipal-secondary"
              @click="clearFilters"
            >
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="resultados.length > 0">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados del Reporte
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="resultados.length > 0">{{ resultados.length }} registros</span>
            <button
              class="btn-municipal-primary btn-sm ms-2"
              @click="exportarExcel"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
          </div>
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
                <tr
                  v-for="row in resultados"
                  :key="row.id_giro"
                  @click="selectedRow = row"
                  :class="{ 'table-row-selected': selectedRow === row }"
                  class="row-hover"
                >
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
                <tr
                  v-for="(row, index) in resultados"
                  :key="index"
                  @click="selectedRow = row"
                  :class="{ 'table-row-selected': selectedRow === row }"
                  class="row-hover"
                >
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
                <tr
                  v-for="(row, index) in resultados"
                  :key="index"
                  @click="selectedRow = row"
                  :class="{ 'table-row-selected': selectedRow === row }"
                  class="row-hover"
                >
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

      <!-- Empty State - Sin búsqueda -->
      <div v-if="resultados.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="chart-bar" size="3x" />
        </div>
        <h4>Reportes Estadísticos de Licencias</h4>
        <p>Seleccione el tipo de reporte y el rango de fechas para generar el análisis estadístico</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="resultados.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron datos para el reporte seleccionado en el rango de fechas especificado</p>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'repEstadisticosLicfrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Reportes Estadísticos de Licencias'"
        @close="showDocModal = false"
      />
    </div>
  </div>
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useExcelExport } from '@/composables/useExcelExport'
import Swal from 'sweetalert2'

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const { exportToExcel } = useExcelExport()

// Estado
const resultados = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)
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

  showLoading('Generando reporte estadístico...', 'Procesando información de licencias')
  hasSearched.value = true
  selectedRow.value = null

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
    hideLoading()
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
  hasSearched.value = false
  selectedRow.value = null

  // Restablecer fechas por defecto
  const today = new Date()
  const firstDay = new Date(today.getFullYear(), 0, 1)
  filters.value.fechaInicio = firstDay.toISOString().split('T')[0]
  filters.value.fechaFin = today.toISOString().split('T')[0]
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

