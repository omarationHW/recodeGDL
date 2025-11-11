<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos</h1>
        <p>Otras Obligaciones - Consulta de adeudos por local</p>
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
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Adeudos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Control:</label>
              <div class="control-input-group">
                <input
                  type="text"
                  v-model="formData.numero"
                  class="municipal-form-control control-numero"
                  placeholder="Número"
                  maxlength="10"
                />
                <span class="control-separator">-</span>
                <input
                  type="text"
                  v-model="formData.letra"
                  class="municipal-form-control control-letra"
                  placeholder="Letra"
                  maxlength="5"
                />
              </div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo Adeudos:</label>
              <select v-model="formData.tipoAdeudos" class="municipal-form-control" @change="handleTipoChange">
                <option value="V">Vencidos</option>
                <option value="A">Acumulados al Periodo</option>
              </select>
            </div>
          </div>

          <div class="form-row" v-if="formData.tipoAdeudos === 'A'">
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
              <button class="btn-municipal-primary" @click="handleImprimir" :disabled="loading">
                <font-awesome-icon icon="print" /> Generar Reporte
              </button>
              <button class="btn-municipal-secondary" @click="handleExportar" :disabled="loading || adeudosConcentrado.length === 0" style="margin-left: 10px;">
                <font-awesome-icon icon="download" /> Exportar Excel
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del local -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Control:</strong>
              <span>{{ datosLocal.control }}</span>
            </div>
            <div class="info-item">
              <strong>Concesionario:</strong>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item">
              <strong>Ubicación:</strong>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <strong>Superficie:</strong>
              <span>{{ datosLocal.superficie }}</span>
            </div>
            <div class="info-item">
              <strong>Licencia:</strong>
              <span>{{ datosLocal.licencia }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Selector de vista -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Adeudos Registrados</h5>
          <div class="radio-group">
            <label class="radio-label">
              <input type="radio" name="vista" value="concentrado" v-model="vistaDetalle" />
              <span>Concentrado</span>
            </label>
            <label class="radio-label">
              <input type="radio" name="vista" value="desglosado" v-model="vistaDetalle" />
              <span>Desglosado</span>
            </label>
          </div>
        </div>
        <div class="municipal-card-body">
          <!-- Tabla concentrada -->
          <div v-if="vistaDetalle === 'concentrado'" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-center">Periodos</th>
                  <th class="text-right">Importe Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in adeudosConcentrado" :key="index" class="row-hover">
                  <td>{{ row.concepto }}</td>
                  <td class="text-center">
                    <span class="badge-purple">{{ row.cuenta }}</span>
                  </td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(row.importe) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td class="font-weight-bold" colspan="2">TOTAL A PAGAR:</td>
                  <td class="text-right font-weight-bold total-amount">
                    {{ formatCurrency(totalAdeudos) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Tabla desglosada -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-center">Año</th>
                  <th class="text-center">Mes</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Descto. Importe</th>
                  <th class="text-right">Descto. Recargos</th>
                  <th class="text-right">Actualización</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in adeudosDesglosado" :key="index" class="row-hover">
                  <td>{{ row.concepto }}</td>
                  <td class="text-center">{{ row.axo }}</td>
                  <td class="text-center">{{ getNombreMes(row.mes) }}</td>
                  <td class="text-right">{{ formatCurrency(row.importe_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(row.recargos_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(row.dscto_importe) }}</td>
                  <td class="text-right">{{ formatCurrency(row.dscto_recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(row.actualizacion_pagar) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(row.total_periodo) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td class="font-weight-bold" colspan="8">TOTAL:</td>
                  <td class="text-right font-weight-bold total-amount">
                    {{ formatCurrency(totalAdeudos) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <div class="totales-container">
            <strong>Total: {{ formatCurrency(totalAdeudos) }}</strong>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>{{ loadingMessage }}</p>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'RAdeudos'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

// Router
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local de loading
const loading = ref(false)
const loadingMessage = ref('Cargando...')

// Estado
const datosLocal = ref({})
const adeudosConcentrado = ref([])
const adeudosDesglosado = ref([])
const vistaDetalle = ref('concentrado')

const formData = reactive({
  numero: '',
  letra: '',
  tipoAdeudos: 'V',
  anio: new Date().getFullYear(),
  mes: new Date().getMonth() + 1
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

const totalAdeudos = computed(() => {
  if (vistaDetalle.value === 'concentrado') {
    return adeudosConcentrado.value.reduce((sum, item) =>
      sum + (item.importe || 0), 0)
  } else {
    return adeudosDesglosado.value.reduce((sum, item) =>
      sum + (item.total_periodo || 0), 0)
  }
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const handleTipoChange = () => {
  if (formData.tipoAdeudos === 'V') {
    const now = new Date()
    formData.anio = now.getFullYear()
    formData.mes = now.getMonth() + 1
  }
}

const handleImprimir = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control', null)
    return
  }

  if (formData.tipoAdeudos === 'A' && (!formData.anio || !formData.mes)) {
    showToast('warning', 'Debe especificar año y mes', null)
    return
  }

  const startTime = performance.now()
  loading.value = true
  loadingMessage.value = 'Generando reporte...'
  showLoading('Consultando adeudos...', 'Procesando datos')

  try {
    const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`

    // Buscar datos del local
    const localResponse = await execute(
      'sp_otras_oblig_buscar_cont',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' }
      ],
      '',
      null,
      'public'
    )

    if (!localResponse || !localResponse.result || localResponse.result.length === 0 || localResponse.result[0].status === 1) {
      showToast('warning', 'No se encontró el local especificado', null)
      return
    }

    datosLocal.value = localResponse.result[0]
    const anoActual = formData.anio
    const mesActual = formData.mes

    // Cargar adeudos concentrados y desglosados en paralelo
    const [concentradoResponse, desglosadoResponse] = await Promise.all([
      execute(
        'sp_otras_oblig_buscar_totales',
        'otras_obligaciones',
        [
          { nombre: 'par_tabla', valor: 3, tipo: 'integer' },
          { nombre: 'par_id_datos', valor: datosLocal.value.id_datos, tipo: 'integer' },
          { nombre: 'par_aso', valor: anoActual, tipo: 'integer' },
          { nombre: 'par_mes', valor: mesActual, tipo: 'integer' }
        ],
        '',
        null,
        'public'
      ),
      execute(
        'sp_otras_oblig_buscar_adeudos',
        'otras_obligaciones',
        [
          { nombre: 'par_tabla', valor: 3, tipo: 'integer' },
          { nombre: 'par_id_datos', valor: datosLocal.value.id_datos, tipo: 'integer' },
          { nombre: 'par_aso', valor: anoActual, tipo: 'integer' },
          { nombre: 'par_mes', valor: mesActual, tipo: 'integer' }
        ],
        '',
        null,
        'public'
      )
    ])

    adeudosConcentrado.value = (concentradoResponse && concentradoResponse.result) ? concentradoResponse.result.filter(r => r.concepto) : []
    adeudosDesglosado.value = (desglosadoResponse && desglosadoResponse.result) ? desglosadoResponse.result.filter(r => r.concepto) : []

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    if (adeudosConcentrado.value.length > 0 || adeudosDesglosado.value.length > 0) {
      showToast('success', 'Reporte generado correctamente', timeMessage)
    } else {
      showToast('info', 'No se encontraron adeudos para este control', timeMessage)
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const handleExportar = () => {
  if (adeudosConcentrado.value.length === 0) {
    showToast('warning', 'No hay datos para exportar', null)
    return
  }

  try {
    const dataExport = adeudosConcentrado.value.map(item => ({
      'Concepto': item.concepto,
      'Periodos': item.cuenta,
      'Importe': item.importe
    }))

    // Agregar fila de total
    dataExport.push({
      'Concepto': 'TOTAL',
      'Periodos': '',
      'Importe': totalAdeudos.value
    })

    const ws = XLSX.utils.json_to_sheet(dataExport)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Adeudos')

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19)
    XLSX.writeFile(wb, `RAdeudos_${datosLocal.value.control}_${timestamp}.xlsx`)

    showToast('success', 'Archivo exportado correctamente', null)
  } catch (error) {
    console.error('Error al exportar:', error)
    showToast('error', 'Error al exportar el archivo', null)
  }
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

// Utilidades
const getNombreMes = (mes) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[mes - 1] || mes
}
</script>

<style scoped>
/* Control input group */
.control-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.control-numero {
  flex: 0 0 120px;
  max-width: 120px;
}

.control-letra {
  flex: 0 0 100px;
  max-width: 100px;
}

.control-separator {
  font-weight: bold;
  font-size: 1.2rem;
  color: #666;
}

/* Toast duration */
.toast-duration {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 0.85rem;
  color: rgba(255, 255, 255, 0.9);
  margin-left: 8px;
}

/* Table improvements */
.total-amount {
  color: #ea8215;
  font-size: 1.1rem;
}
</style>
