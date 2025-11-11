<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Padrón con Adeudos</h1>
        <p>Otras Obligaciones - Generación de reporte de padrón con adeudos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros del Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" class="me-1" />
                Vigencia Contrato:
              </label>
              <select v-model="formData.vigencia_cont" class="municipal-form-control" :disabled="loadingVigencias">
                <option value="TODOS">TODOS</option>
                <option
                  v-for="vig in vigencias"
                  :key="vig.descripcion"
                  :value="vig.descripcion"
                >
                  {{ vig.descripcion }}
                </option>
              </select>
            </div>

            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="coins" class="me-1" />
                Tipo de Adeudos:
              </label>
              <select v-model="formData.tipo_adeudos" class="municipal-form-control" @change="handleTipoAdeudosChange">
                <option value="V">Vencidos</option>
                <option value="A">Acumulados al Periodo</option>
              </select>
            </div>
          </div>

          <div class="row g-3 mt-2" v-if="formData.tipo_adeudos === 'A'">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-alt" class="me-1" />
                Año:
              </label>
              <input type="number" v-model.number="formData.anio" class="municipal-form-control" :min="2000" :max="2099" />
            </div>

            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-day" class="me-1" />
                Mes:
              </label>
              <select v-model.number="formData.mes" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>

          <div class="button-group mt-4">
            <button class="btn-municipal-primary" @click="handleGenerarReporte" :disabled="loading">
              <font-awesome-icon icon="file-alt" />
              Generar Reporte
            </button>
            <button class="btn-municipal-success" @click="handleExportar" :disabled="loading || padronData.length === 0">
              <font-awesome-icon icon="file-excel" />
              Exportar Excel
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card mt-3" v-if="padronData.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            {{ nombreTabla }}
            <span class="badge badge-purple ms-2">{{ padronData.length }} registro(s)</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>{{ etiquetas.etiq_control }}</th>
                  <th>{{ etiquetas.concesionario }}</th>
                  <th>{{ etiquetas.ubicacion }}</th>
                  <th class="text-end">{{ etiquetas.superficie }}</th>
                  <th class="text-center">{{ etiquetas.licencia }}</th>
                  <th>{{ etiquetas.sector }}</th>
                  <th class="text-center">{{ etiquetas.zona }}</th>
                  <th class="text-end">Adeudo</th>
                  <th class="text-center">Opciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in padronData" :key="index">
                  <td>{{ item.control }}</td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.ubicacion }}</td>
                  <td class="text-end">{{ item.superficie }}</td>
                  <td class="text-center">{{ item.licencia }}</td>
                  <td>{{ item.sector }}</td>
                  <td class="text-center">{{ item.zona }}</td>
                  <td class="text-end fw-bold text-success">{{ formatCurrency(item.total_adeudo) }}</td>
                  <td class="text-center">
                    <button class="btn btn-sm btn-info" @click="verDetalle(item)" title="Ver Detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="alert alert-success mt-3 d-flex align-items-center justify-content-between">
            <div>
              <font-awesome-icon icon="calculator" class="me-2" />
              <strong>Total General:</strong>
            </div>
            <h4 class="mb-0">{{ formatCurrency(totalGeneral) }}</h4>
          </div>
        </div>
      </div>

      <!-- Modal de detalle -->
      <div class="modal-overlay" v-if="dialogDetalle" @click="closeDetalle">
        <div class="modal-dialog" @click.stop>
          <div class="modal-header">
            <h5>Detalle de Adeudos</h5>
            <button class="modal-close" @click="closeDetalle">
              <font-awesome-icon icon="times" />
            </button>
          </div>
          <div class="modal-body">
            <div class="table-responsive">
              <table class="table table-municipal">
                <thead>
                  <tr>
                    <th>Concepto</th>
                    <th class="text-right">Adeudo</th>
                    <th class="text-right">Recargos</th>
                    <th class="text-right">Multas</th>
                    <th class="text-right">Gastos</th>
                    <th class="text-right">Actualización</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(det, idx) in detalleAdeudos" :key="idx">
                    <td>{{ det.concepto }}</td>
                    <td class="text-right">{{ formatCurrency(det.importe_adeudos) }}</td>
                    <td class="text-right">{{ formatCurrency(det.importe_recargos) }}</td>
                    <td class="text-right">{{ formatCurrency(det.importe_multa) }}</td>
                    <td class="text-right">{{ formatCurrency(det.importe_gastos) }}</td>
                    <td class="text-right">{{ formatCurrency(det.importe_actualizacion) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-municipal-secondary" @click="closeDetalle">Cerrar</button>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos...</p>
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

    <!-- Modal de documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'GRep_Padron'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
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
const { showLoading, hideLoading } = useGlobalLoading()
const showDocumentation = ref(false)
const dialogDetalle = ref(false)
const padronData = ref([])
const detalleAdeudos = ref([])
const vigencias = ref([])
const nombreTabla = ref('PADRÓN CON ADEUDOS')
const selectedRow = ref(null)
const loadingVigencias = ref(false)
const loadingEtiquetas = ref(false)

const formData = reactive({
  tabla: 3,
  vigencia_cont: 'TODOS',
  tipo_adeudos: 'V',
  anio: new Date().getFullYear(),
  mes: new Date().getMonth() + 1
})

const etiquetas = ref({
  etiq_control: 'Control',
  concesionario: 'Concesionario',
  ubicacion: 'Ubicación',
  superficie: 'Superficie',
  licencia: 'Licencia',
  sector: 'Sector',
  zona: 'Zona'
})

const meses = [
  { value: 1, label: '01-Enero' },
  { value: 2, label: '02-Febrero' },
  { value: 3, label: '03-Marzo' },
  { value: 4, label: '04-Abril' },
  { value: 5, label: '05-Mayo' },
  { value: 6, label: '06-Junio' },
  { value: 7, label: '07-Julio' },
  { value: 8, label: '08-Agosto' },
  { value: 9, label: '09-Septiembre' },
  { value: 10, label: '10-Octubre' },
  { value: 11, label: '11-Noviembre' },
  { value: 12, label: '12-Diciembre' }
]

const totalGeneral = computed(() => {
  return padronData.value.reduce((sum, item) => sum + (item.total_adeudo || 0), 0)
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const handleTipoAdeudosChange = () => {
  if (formData.tipo_adeudos === 'V') {
    const now = new Date()
    formData.anio = now.getFullYear()
    formData.mes = now.getMonth() + 1
  }
}

const cargarVigencias = async () => {
  loadingVigencias.value = true
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_padron_vigencias',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: formData.tabla, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      vigencias.value = response.result || []
      showToast('success', `${vigencias.value.length} vigencia(s) cargada(s) (${duration}s)`)
    }
  } catch (error) {
    handleApiError(error)
    vigencias.value = []
  } finally {
    loadingVigencias.value = false
  }
}

const cargarEtiquetas = async () => {
  loadingEtiquetas.value = true
  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_padron_etiquetas',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: formData.tabla, tipo: 'integer' }
      ],
      'guadalajara'
    )

    const duration = ((performance.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
      showToast('success', `Etiquetas cargadas (${duration}s)`)
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    loadingEtiquetas.value = false
  }
}

const handleGenerarReporte = async () => {
  if (formData.tipo_adeudos === 'A' && (!formData.anio || !formData.mes)) {
    showToast('warning', 'Debe especificar año y mes para adeudos acumulados')
    return
  }

  setLoading(true, 'Generando reporte...')
  showLoading('Consultando padrón de concesiones...')
  const startTime = performance.now()

  try {
    // Obtener concesiones
    const response = await execute(
      'sp_padron_concesiones_get',
      'otras_obligaciones',
      [
        { nombre: 'p_vigencia', valor: formData.vigencia_cont === 'TODOS' ? 'T' : formData.vigencia_cont, tipo: 'string' },
        { nombre: 'p_tipo_adeudo', valor: formData.tipo_adeudos, tipo: 'string' },
        { nombre: 'p_anio', valor: formData.anio, tipo: 'integer' },
        { nombre: 'p_mes', valor: String(formData.mes).padStart(2, '0'), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      padronData.value = response.result

      // Obtener adeudos para cada concesión
      for (let i = 0; i < padronData.value.length; i++) {
        const item = padronData.value[i]
        showLoading(`Calculando adeudos... ${i + 1}/${padronData.value.length}`)

        const fecha = `${formData.anio}-${String(formData.mes).padStart(2, '0')}`

        const adeudosResponse = await execute(
          'sp_padron_adeudos_get',
          'otras_obligaciones',
          [
            { nombre: 'p_control', valor: item.id_34_datos, tipo: 'integer' },
            { nombre: 'p_tipo', valor: formData.tipo_adeudos, tipo: 'string' },
            { nombre: 'p_fecha', valor: fecha, tipo: 'string' }
          ],
          'guadalajara'
        )

        const adeudos = adeudosResponse?.result || []
        item.total_adeudo = adeudos.reduce((sum, ade) =>
          sum + (ade.adeudo || 0) + (ade.recargo || 0), 0
        )
        item.adeudos = adeudos
      }

      const duration = ((performance.now() - startTime) / 1000).toFixed(2)
      hideLoading()
      showToast('success', `Reporte generado: ${padronData.value.length} registro(s) (${duration}s)`)
    } else {
      hideLoading()
      showToast('info', 'No se encontraron registros')
      padronData.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    padronData.value = []
  } finally {
    setLoading(false)
  }
}

const verDetalle = (row) => {
  selectedRow.value = row
  detalleAdeudos.value = row.adeudos || []
  dialogDetalle.value = true
}

const closeDetalle = () => {
  dialogDetalle.value = false
  selectedRow.value = null
  detalleAdeudos.value = []
}

const handleExportar = () => {
  if (padronData.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  const dataExport = padronData.value.map(item => ({
    'Control': item.control,
    'Concesionario': item.concesionario,
    'Ubicación': item.ubicacion,
    'Superficie': item.superficie,
    'Licencia': item.licencia,
    'Sector': item.sector,
    'Zona': item.zona,
    'Total Adeudo': item.total_adeudo
  }))

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Padrón Adeudos')
  XLSX.writeFile(wb, `Padron_Adeudos_${Date.now()}.xlsx`)
  showToast('success', 'Exportación exitosa')
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

onMounted(() => {
  cargarVigencias()
  cargarEtiquetas()
})
</script>
