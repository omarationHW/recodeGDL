<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-check-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagos</h1>
        <p>Aseo Contratado - Reporte de pagos registrados</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button type="button" class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros del Reporte</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Fecha Desde</label>
              <input type="date" v-model="filtros.fecha_desde" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Fecha Hasta</label>
              <input type="date" v-model="filtros.fecha_hasta" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <select v-model="filtros.recaudadora" class="municipal-form-control">
                <option value="">Todas</option>
                <option v-for="rec in recaudadoras" :key="rec.num_rec" :value="rec.num_rec">
                  {{ rec.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button class="btn-municipal-primary" @click="generarReporte" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'file-chart-column'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
            <button v-if="reporteGenerado" class="btn-municipal-primary" @click="exportarExcel">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="chart-bar" /> Resumen</h5>
        </div>
        <div class="municipal-card-body">
          <div class="summary-grid">
            <div class="summary-card">
              <div class="summary-icon bg-success"><font-awesome-icon icon="money-bill-wave" /></div>
              <div class="summary-info">
                <p class="summary-label">Total de Pagos</p>
                <p class="summary-value">{{ datos.length }}</p>
              </div>
            </div>
            <div class="summary-card highlight">
              <div class="summary-icon bg-primary"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="summary-info">
                <p class="summary-label">Monto Total Recaudado</p>
                <p class="summary-value">{{ formatCurrency(totales.monto_total) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="reporteGenerado && datos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Detalle de Pagos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Folio</th>
                  <th>Fecha</th>
                  <th>Contrato</th>
                  <th>Empresa</th>
                  <th>Recaudadora</th>
                  <th class="text-right">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in datos" :key="pago.folio">
                  <td><strong>{{ pago.folio }}</strong></td>
                  <td>{{ formatDate(pago.fecha) }}</td>
                  <td>{{ pago.num_contrato }}</td>
                  <td>{{ pago.empresa }}</td>
                  <td>{{ pago.recaudadora }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(pago.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-total">
                  <td colspan="5" class="text-right"><strong>TOTAL:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totales.monto_total) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Reporte de Pagos">
      <h3>Reporte de Pagos</h3>
      <p>Genera reportes de pagos registrados en un periodo determinado.</p>
      <h4>Filtros:</h4>
      <ul>
        <li>Rango de fechas (obligatorio)</li>
        <li>Recaudadora específica (opcional)</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Rpt_Pagos'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, computed, onMounted } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const { execute } = useApi()
const { showToast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const showDocumentation = ref(false)
const reporteGenerado = ref(false)
const datos = ref([])
const recaudadoras = ref([])

const filtros = ref({
  fecha_desde: '',
  fecha_hasta: '',
  recaudadora: ''
})

const totales = computed(() => ({
  monto_total: datos.value.reduce((sum, p) => sum + parseFloat(p.importe || 0), 0)
}))

const generarReporte = async () => {
  if (!filtros.value.fecha_desde || !filtros.value.fecha_hasta) {
    showToast('Ingrese el rango de fechas', 'warning')
    return
  }

  showLoading()
  try {
    // Simular datos - implementar SP real
    datos.value = []
    reporteGenerado.value = true
    showToast('Funcionalidad en desarrollo', 'info')
  } catch (error) {
    hideLoading()
    showToast('Error al generar reporte', 'error')
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filtros.value = { fecha_desde: '', fecha_hasta: '', recaudadora: '' }
  datos.value = []
  reporteGenerado.value = false
}

const exportarExcel = () => {
  showToast('Exportación en desarrollo', 'info')
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

const formatDate = (date) => {
  return new Date(date).toLocaleDateString('es-MX')
}

const openDocumentation = () => {
  showDocumentation.value = true
}

onMounted(async () => {
  try {
    const response = await execute('SP_ASEO_RECAUDADORAS_LIST', 'aseo_contratado', {
      p_page: 1,
      p_limit: 100,
      p_search: null
    })
    if (response) recaudadoras.value = response
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
})
</script>

