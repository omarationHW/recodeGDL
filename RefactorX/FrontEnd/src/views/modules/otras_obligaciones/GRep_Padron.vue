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
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
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
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Vigencia Contrato:</label>
              <select v-model="formData.vigencia_cont" class="municipal-form-control">
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

            <div class="form-group">
              <label class="municipal-form-label">Tipo de Adeudos:</label>
              <select v-model="formData.tipo_adeudos" class="municipal-form-control" @change="handleTipoAdeudosChange">
                <option value="V">Vencidos</option>
                <option value="A">Acumulados al Periodo</option>
              </select>
            </div>
          </div>

          <div class="form-row" v-if="formData.tipo_adeudos === 'A'">
            <div class="form-group">
              <label class="municipal-form-label">Año:</label>
              <input type="number" v-model.number="formData.anio" class="municipal-form-control" :min="2000" :max="2099" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mes:</label>
              <select v-model.number="formData.mes" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <button class="btn-municipal-primary" @click="handleGenerarReporte" :disabled="loading">
                <font-awesome-icon icon="print" /> Generar Reporte
              </button>
              <button class="btn-municipal-secondary" @click="handleExportar" :disabled="loading || padronData.length === 0" style="margin-left: 10px;">
                <font-awesome-icon icon="download" /> Exportar Excel
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card mt-3" v-if="padronData.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> {{ nombreTabla }}</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table table-municipal">
              <thead>
                <tr>
                  <th>{{ etiquetas.etiq_control }}</th>
                  <th>{{ etiquetas.concesionario }}</th>
                  <th>{{ etiquetas.ubicacion }}</th>
                  <th>{{ etiquetas.superficie }}</th>
                  <th>{{ etiquetas.licencia }}</th>
                  <th>{{ etiquetas.sector }}</th>
                  <th>{{ etiquetas.zona }}</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-center">Opciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in padronData" :key="index">
                  <td>{{ item.control }}</td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.ubicacion }}</td>
                  <td class="text-right">{{ item.superficie }}</td>
                  <td class="text-center">{{ item.licencia }}</td>
                  <td>{{ item.sector }}</td>
                  <td class="text-center">{{ item.zona }}</td>
                  <td class="text-right">{{ formatCurrency(item.total_adeudo) }}</td>
                  <td class="text-center">
                    <button class="btn-icon-info" @click="verDetalle(item)" title="Ver Detalle">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="totales-container">
            <strong>Total General: {{ formatCurrency(totalGeneral) }}</strong>
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
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const dialogDetalle = ref(false)
const padronData = ref([])
const detalleAdeudos = ref([])
const vigencias = ref([])
const nombreTabla = ref('PADRÓN CON ADEUDOS')
const selectedRow = ref(null)

const formData = reactive({
  tabla: '3',
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
  try {
    const response = await callApi('SP_GREP_PADRON_VIGENCIAS', {
      par_tab: formData.tabla
    })
    vigencias.value = response.data || []
  } catch (error) {
    handleError(error, 'Error al cargar vigencias')
  }
}

const cargarEtiquetas = async () => {
  try {
    const response = await callApi('SP_GREP_PADRON_ETIQUETAS', {
      par_tab: formData.tabla
    })
    if (response.data && response.data.length > 0) {
      etiquetas.value = response.data[0]
    }
  } catch (error) {
    handleError(error, 'Error al cargar etiquetas')
  }
}

const handleGenerarReporte = async () => {
  if (formData.tipo_adeudos === 'A' && (!formData.anio || !formData.mes)) {
    showToast('warning', 'Debe especificar año y mes para adeudos acumulados')
    return
  }

  loading.value = true
  try {
    const response = await callApi('SP_GREP_PADRON_OBTENER', {
      par_tabla: formData.tabla,
      par_Vigencia: formData.vigencia_cont
    })

    if (response.data && response.data.length > 0) {
      padronData.value = response.data

      for (const item of padronData.value) {
        const fecha = `${formData.anio}-${String(formData.mes).padStart(2, '0')}`
        const adeudosResponse = await callApi('SP_GREP_PADRON_ADEUDOS', {
          par_tab: formData.tabla,
          par_Control: item.id_34_datos,
          par_Rep: formData.tipo_adeudos,
          par_Fecha: fecha
        })

        const adeudos = adeudosResponse.data || []
        item.total_adeudo = adeudos.reduce((sum, ade) =>
          sum + (ade.importe_adeudos || 0) + (ade.importe_recargos || 0) +
          (ade.importe_multa || 0) + (ade.importe_gastos || 0) +
          (ade.importe_actualizacion || 0), 0
        )
        item.adeudos = adeudos
      }

      showToast('success', 'Reporte generado exitosamente')
    } else {
      showToast('info', 'No se encontraron registros')
      padronData.value = []
    }
  } catch (error) {
    handleError(error, 'Error al generar reporte')
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

const goBack = () => {
  router.push('/otras_obligaciones')
}

onMounted(() => {
  cargarVigencias()
  cargarEtiquetas()
})
</script>
