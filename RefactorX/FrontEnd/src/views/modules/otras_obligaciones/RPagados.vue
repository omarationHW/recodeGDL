<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="check-circle" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagados</h1>
        <p>Otras Obligaciones - Historial de pagos por local</p>
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
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Control:</label>
              <div class="control-inputs">
                <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" />
                <span class="separator">-</span>
                <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" />
              </div>
            </div>
            <div class="form-group">
              <button class="btn-municipal-primary" @click="handleBuscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="pagos.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Historial de Pagos</h5>
          <button class="btn-municipal-secondary" @click="handleExportar">
            <font-awesome-icon icon="download" /> Exportar Excel
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table table-municipal">
              <thead>
                <tr>
                  <th>Periodo</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargo</th>
                  <th>Fecha Pago</th>
                  <th>Folio</th>
                  <th>Usuario</th>
                  <th>Caja</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(pago, index) in pagos" :key="index">
                  <td>{{ pago.periodo }}</td>
                  <td class="text-right">{{ formatCurrency(pago.importe) }}</td>
                  <td class="text-right">{{ formatCurrency(pago.recargo) }}</td>
                  <td>{{ pago.fecha_hora_pago }}</td>
                  <td>{{ pago.folio_recibo }}</td>
                  <td>{{ pago.usuario }}</td>
                  <td>{{ pago.caja }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="totales-container">
            <strong>Total Pagado: {{ formatCurrency(totalPagado) }}</strong>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Buscando pagos...</p>
        </div>
      </div>
    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RPagados'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { callApi } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const pagos = ref([])
const datosLocal = ref({})

const formData = reactive({
  numero: '',
  letra: ''
})

const totalPagado = computed(() => {
  return pagos.value.reduce((sum, pago) => sum + (pago.importe || 0) + (pago.recargo || 0), 0)
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  const startTime = performance.now()
  loading.value = true
  showLoading('Buscando pagos del local...')

  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const localResponse = await callApi('SP_RCONSULTA_OBTENER', {
      p_control: control
    })

    if (!localResponse.data || localResponse.data.length === 0) {
      showToast('warning', 'No se encontró el local')
      loading.value = false
      hideLoading()
      return
    }

    datosLocal.value = localResponse.data[0]

    const pagosResponse = await callApi('SP_RPAGADOS_OBTENER', {
      p_Control: datosLocal.value.id_34_datos
    })

    pagos.value = pagosResponse.data || []

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    if (pagos.value.length === 0) {
      showToast('info', 'No hay pagos registrados para este local', timeMessage)
    } else {
      showToast('success', `Se encontraron ${pagos.value.length} pagos`, timeMessage)
    }
  } catch (error) {
    handleError(error, 'Error al buscar pagos')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const handleExportar = () => {
  const startTime = performance.now()

  const dataExport = pagos.value.map(pago => ({
    'Periodo': pago.periodo,
    'Importe': pago.importe,
    'Recargo': pago.recargo,
    'Total': pago.importe + pago.recargo,
    'Fecha Pago': pago.fecha_hora_pago,
    'Folio': pago.folio_recibo,
    'Usuario': pago.usuario,
    'Caja': pago.caja
  }))

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Pagos')
  XLSX.writeFile(wb, `Pagos_${Date.now()}.xlsx`)

  const endTime = performance.now()
  const duration = ((endTime - startTime) / 1000).toFixed(2)
  const timeMessage = duration < 1
    ? `${(duration * 1000).toFixed(0)}ms`
    : `${duration}s`

  showToast('success', 'Exportación exitosa', timeMessage)
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
</script>

<style scoped>
.control-inputs {
  display: flex;
  align-items: center;
  gap: 10px;
}

.control-inputs input {
  width: 120px;
}

.separator {
  font-weight: bold;
  color: #6c757d;
}

.totales-container {
  margin-top: 15px;
  padding: 15px;
  background-color: #f8f9fa;
  border-radius: 4px;
  text-align: right;
}

.totales-container strong {
  font-size: 1.1rem;
  color: #28a745;
}
</style>
