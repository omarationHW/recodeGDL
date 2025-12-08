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
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
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
            <button class="btn-municipal-success" @click="handleImprimir" :disabled="loading || padronData.length === 0">
              <font-awesome-icon icon="print" />
              Imprimir
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar" :disabled="loading || padronData.length === 0">
              <font-awesome-icon icon="file-excel" />
              Excel
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
                  <th>{{ etiquetas.etiq_control || 'Control' }}</th>
                  <th>{{ etiquetas.concesionario || 'Concesionario' }}</th>
                  <th>{{ etiquetas.ubicacion || 'Ubicación' }}</th>
                  <th class="text-end">{{ etiquetas.superficie || 'Superficie' }}</th>
                  <th class="text-center">{{ etiquetas.licencia || 'Licencia' }}</th>
                  <th>{{ etiquetas.sector || 'Sector' }}</th>
                  <th class="text-center">{{ etiquetas.zona || 'Zona' }}</th>
                  <th class="text-end">Adeudo Total</th>
                  <th class="text-center">Opciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in padronData" :key="index" class="row-hover">
                  <td><span class="badge badge-purple">{{ item.control }}</span></td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.ubicacion }}</td>
                  <td class="text-end">{{ formatNumber(item.superficie, 2) }}</td>
                  <td class="text-center">{{ item.licencia || '-' }}</td>
                  <td>{{ item.sector || '-' }}</td>
                  <td class="text-center">{{ item.id_zona || '-' }}</td>
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
                    <th>Descripción</th>
                    <th class="text-right">Adeudo</th>
                    <th class="text-right">Recargo</th>
                    <th class="text-right">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(det, idx) in detalleAdeudos" :key="idx">
                    <td>{{ det.descripcion }}</td>
                    <td class="text-right">{{ formatCurrency(det.adeudo) }}</td>
                    <td class="text-right">{{ formatCurrency(det.recargo) }}</td>
                    <td class="text-right fw-bold text-success">
                      {{ formatCurrency((parseFloat(det.adeudo) || 0) + (parseFloat(det.recargo) || 0)) }}
                    </td>
                  </tr>
                </tbody>
                <tfoot>
                  <tr class="table-footer-total">
                    <td colspan="3" class="text-right"><strong>TOTAL:</strong></td>
                    <td class="text-right">
                      <strong class="text-success">
                        {{ formatCurrency(detalleAdeudos.reduce((sum, det) =>
                          sum + (parseFloat(det.adeudo) || 0) + (parseFloat(det.recargo) || 0), 0)) }}
                      </strong>
                    </td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-municipal-secondary" @click="closeDetalle">Cerrar</button>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'GRep_Padron'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'GRep_Padron'"
      :moduleName="'otras_obligaciones'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()
const { exportToPdf } = usePdfExport()
const loading = ref(false)
const showDocumentation = ref(false)
const showTechDocs = ref(false)
const dialogDetalle = ref(false)
const padronData = ref([])
const detalleAdeudos = ref([])
const vigencias = ref([])
const nombreTabla = ref('PADRÓN CON ADEUDOS')
const selectedRow = ref(null)
const loadingVigencias = ref(false)
const loadingEtiquetas = ref(false)

const formData = reactive({
  tabla: 3, // Se puede parametrizar si se recibe desde route
  vigencia_cont: 'TODOS',
  tipo_adeudos: 'V', // V = Vencidos, A = Acumulados al Periodo
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
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(value)
}

const formatNumber = (value, decimals = 2) => {
  if (value === null || value === undefined) return '0.00'
  return parseFloat(value).toFixed(decimals)
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

  try {
    const response = await execute(
      'grep_padron_sp_vigencias_get',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: String(formData.tabla), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      vigencias.value = response.result || []
    }
  } catch (error) {
    console.error('Error cargando vigencias:', error)
    vigencias.value = []
  } finally {
    loadingVigencias.value = false
  }
}

const cargarEtiquetas = async () => {
  loadingEtiquetas.value = true

  try {
    const response = await execute(
      'sp_gfacturacion_get_etiquetas',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: String(formData.tabla), tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error cargando etiquetas:', error)
  } finally {
    loadingEtiquetas.value = false
  }
}

const handleGenerarReporte = async () => {
  if (formData.tipo_adeudos === 'A' && (!formData.anio || !formData.mes)) {
    showToast('warning', 'Debe especificar año y mes para adeudos acumulados')
    return
  }

  loading.value = true
  showLoading('Consultando padrón de concesiones...')

  try {
    // Obtener concesiones - SP solo toma 2 parámetros: par_tab y par_vigencia
    const response = await execute(
      'grep_padron_sp_concesiones_get',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: formData.tabla, tipo: 'integer' },
        { nombre: 'par_vigencia', valor: formData.vigencia_cont === 'TODOS' ? 'T' : formData.vigencia_cont, tipo: 'varchar' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      padronData.value = response.result

      // Obtener adeudos para cada concesión
      for (let i = 0; i < padronData.value.length; i++) {
        const item = padronData.value[i]
        showLoading(`Calculando adeudos... ${i + 1}/${padronData.value.length}`)

        const adeudosResponse = await execute(
          'grep_padron_sp_adeudos_get',
          BASE_DB,
          [
            { nombre: 'par_id_datos', valor: item.id_34_datos, tipo: 'integer' }
          ],
          'guadalajara'
        )

        const adeudos = adeudosResponse?.result || []
        // Calcular total de adeudos (adeudo + recargo)
        item.total_adeudo = adeudos.reduce((sum, ade) =>
          sum + (parseFloat(ade.adeudo) || 0) + (parseFloat(ade.recargo) || 0), 0
        )
        item.adeudos = adeudos
      }

      hideLoading()
      showToast('success', `Reporte generado: ${padronData.value.length} registro(s)`)
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
    loading.value = false
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

const mostrarDocumentacion = () => {
  showTechDocs.value = true
}

const closeTechDocs = () => {
  showTechDocs.value = false
}

const handleImprimir = () => {
  if (padronData.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const columns = [
    { header: 'Control', key: 'control', type: 'string' },
    { header: 'Concesionario', key: 'concesionario', type: 'string' },
    { header: 'Ubicación', key: 'ubicacion', type: 'string' },
    { header: 'Superficie', key: 'superficie', type: 'number' },
    { header: 'Sector', key: 'sector', type: 'string' },
    { header: 'Zona', key: 'zona', type: 'number' },
    { header: 'Adeudo Total', key: 'total_adeudo', type: 'currency' }
  ]

  const tipoAdeudo = formData.tipo_adeudos === 'V' ? 'Vencidos' : 'Acumulados'

  exportToPdf(padronData.value, columns, {
    title: 'Reporte de Padrón con Adeudos - Rastro',
    subtitle: `Tipo: ${tipoAdeudo} - Vigencia: ${formData.vigencia_cont} - Total: ${formatCurrency(totalGeneral.value)}`,
    orientation: 'landscape'
  })
}

const goBack = () => {
  router.push('/otras-obligaciones/menu')
}

onMounted(async () => {
  try {
    await Promise.all([cargarVigencias(), cargarEtiquetas()])
  } catch (e) {
    console.error('Error inicializando:', e)
  }
})
</script>
