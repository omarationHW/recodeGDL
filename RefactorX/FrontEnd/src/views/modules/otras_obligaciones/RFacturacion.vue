<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Facturación</h1>
        <p>Otras Obligaciones - Reporte de facturación por período</p>
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
      <!-- Estadísticas Cards -->
      <div class="stats-grid" v-if="stats.total > 0">
        <div class="stat-card stat-primary">
          <div class="stat-icon">
            <font-awesome-icon icon="file-invoice" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ stats.total }}</div>
            <div class="stat-label">Registros</div>
          </div>
        </div>
        <div class="stat-card stat-success">
          <div class="stat-icon">
            <font-awesome-icon icon="dollar-sign" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatCurrency(stats.totalFacturado) }}</div>
            <div class="stat-label">Total Facturado</div>
          </div>
        </div>
        <div class="stat-card stat-info">
          <div class="stat-icon">
            <font-awesome-icon icon="calendar-alt" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formData.mes }}/{{ formData.anio }}</div>
            <div class="stat-label">Período</div>
          </div>
        </div>
      </div>

      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Período</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="formData.anio" class="municipal-form-control" :min="2000" :max="2099" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <select v-model.number="formData.mes" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="handleGenerar" :disabled="loading">
              <font-awesome-icon icon="search" /> Generar Reporte
            </button>
            <button class="btn-municipal-success" @click="handleExportar" :disabled="loading || facturacion.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar Excel
            </button>
            <button class="btn-municipal-secondary" @click="handleImprimir" :disabled="loading || facturacion.length === 0">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="facturacion.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Facturación ({{ facturacion.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table table-municipal">
              <thead>
                <tr>
                  <th><font-awesome-icon icon="hashtag" /> Control</th>
                  <th><font-awesome-icon icon="user" /> Concesionario</th>
                  <th><font-awesome-icon icon="file-alt" /> Concepto</th>
                  <th class="text-right"><font-awesome-icon icon="dollar-sign" /> Total Facturado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in facturacion" :key="index" class="row-hover">
                  <td>
                    <span class="badge badge-purple">{{ item.control }}</span>
                  </td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.concepto }}</td>
                  <td class="text-right">
                    <strong class="text-success">{{ formatCurrency(item.total_facturado) }}</strong>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-footer-total">
                  <td colspan="3" class="text-right"><strong>TOTAL:</strong></td>
                  <td class="text-right">
                    <strong class="text-success">{{ formatCurrency(stats.totalFacturado) }}</strong>
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Empty State -->
      <div class="municipal-card" v-else-if="!loading && showEmptyState">
        <div class="municipal-card-body">
          <div class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" class="empty-icon" />
            <h3>No hay datos de facturación</h3>
            <p>No se encontraron registros para el período seleccionado ({{ formData.mes }}/{{ formData.anio }}).</p>
            <p class="text-muted">Seleccione otro período y genere el reporte nuevamente.</p>
          </div>
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

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RFacturacion'"
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
const { execute } = useApi()
const { startLoading, stopLoading } = useGlobalLoading()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const showDocumentation = ref(false)
const facturacion = ref([])
const showEmptyState = ref(false)

const formData = reactive({
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

// Computed - Estadísticas
const stats = computed(() => {
  const total = facturacion.value.length
  const totalFacturado = facturacion.value.reduce((sum, item) => {
    return sum + (parseFloat(item.total_facturado) || 0)
  }, 0)

  return {
    total,
    totalFacturado
  }
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const handleGenerar = async () => {
  const startTime = performance.now()
  setLoading(true, 'Generando reporte...')
  startLoading()
  showEmptyState.value = false

  try {
    const response = await execute(
      'SP_RFACTURACION_OBTENER',
      'otras_obligaciones',
      [
        { nombre: 'par_Aso', valor: formData.anio, tipo: 'integer' },
        { nombre: 'par_Mes', valor: formData.mes, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      facturacion.value = response.result

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)

      if (facturacion.value.length > 0) {
        showToast('success', `Reporte generado: ${facturacion.value.length} registros (${duration}s)`)
      } else {
        showEmptyState.value = true
        showToast('info', 'No se encontraron registros para el período seleccionado')
      }
    } else {
      facturacion.value = []
      showEmptyState.value = true
      showToast('info', 'No se encontraron datos')
    }
  } catch (error) {
    handleApiError(error)
    facturacion.value = []
    showEmptyState.value = true
  } finally {
    setLoading(false)
    stopLoading()
  }
}

const handleExportar = () => {
  if (facturacion.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const exportData = facturacion.value.map(item => ({
      'Control': item.control,
      'Concesionario': item.concesionario,
      'Concepto': item.concepto,
      'Total Facturado': item.total_facturado
    }))

    const ws = XLSX.utils.json_to_sheet(exportData)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Facturación')

    const fileName = `Facturacion_${formData.mes}_${formData.anio}_${Date.now()}.xlsx`
    XLSX.writeFile(wb, fileName)

    showToast('success', `Exportación exitosa: ${facturacion.value.length} registros`)
  } catch (error) {
    showToast('error', 'Error al exportar los datos')
  }
}

const handleImprimir = () => {
  if (facturacion.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  try {
    window.print()
    showToast('info', 'Ventana de impresión abierta')
  } catch (error) {
    showToast('error', 'Error al abrir la ventana de impresión')
  }
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
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  border-left: 4px solid;
}

.stat-card.stat-primary { border-left-color: #ea8215; }
.stat-card.stat-success { border-left-color: #28a745; }
.stat-card.stat-info { border-left-color: #17a2b8; }

.stat-icon {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
  flex-shrink: 0;
}

.stat-primary .stat-icon { background-color: #ea8215; }
.stat-success .stat-icon { background-color: #28a745; }
.stat-info .stat-icon { background-color: #17a2b8; }

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: bold;
  color: #333;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.875rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.badge-purple {
  background-color: #6f42c1;
  color: white;
  padding: 0.35em 0.65em;
  font-size: 0.875rem;
  font-weight: 600;
  border-radius: 4px;
}

.text-success {
  color: #28a745 !important;
}

.text-muted {
  color: #6c757d !important;
  font-size: 0.875rem;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
}

.empty-state .empty-icon {
  color: #dee2e6;
  margin-bottom: 1rem;
}

.empty-state h3 {
  color: #495057;
  margin-bottom: 1rem;
}

.empty-state p {
  color: #6c757d;
  margin-bottom: 0.5rem;
}

.table-footer-total {
  background-color: #f8f9fa;
  font-weight: bold;
  border-top: 2px solid #dee2e6;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

@media print {
  .module-view-header,
  .municipal-card:first-of-type,
  .button-group,
  .stats-grid {
    display: none !important;
  }

  .table {
    font-size: 0.75rem;
  }
}
</style>
