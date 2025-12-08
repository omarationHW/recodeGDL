<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Facturación</h1>
        <p>Otras Obligaciones - Rastro - Reporte de facturación por período</p>
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
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Período</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
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
            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <button class="btn-municipal-primary" @click="handleGenerar">
                <font-awesome-icon icon="search" /> Generar Reporte
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="facturacion.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Facturación ({{ facturacion.length }} registros)</h5>
          <div class="button-group ms-auto">
            <button class="btn-municipal-success" @click="imprimirReporte">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid mb-3">
            <div class="info-item">
              <strong>Registros:</strong>
              <span>{{ facturacion.length }}</span>
            </div>
            <div class="info-item">
              <strong>Total Facturado:</strong>
              <span class="text-success">{{ formatCurrency(totalFacturado) }}</span>
            </div>
            <div class="info-item">
              <strong>Período:</strong>
              <span>{{ formData.mes }}/{{ formData.anio }}</span>
            </div>
          </div>

          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Control</th>
                  <th>Concesionario</th>
                  <th>Tipo</th>
                  <th class="text-center">Licencia</th>
                  <th class="text-right">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in facturacion" :key="index">
                  <td><span class="badge-purple">{{ item.control }}</span></td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.tipo }}</td>
                  <td class="text-center">{{ item.licencia || '-' }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(item.importe) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="4" class="text-right"><strong>TOTAL:</strong></td>
                  <td class="text-right"><strong class="text-primary-orange">{{ formatCurrency(totalFacturado) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <!-- Sin datos -->
      <div class="municipal-card" v-else-if="showEmptyState">
        <div class="municipal-card-body text-center p-4">
          <font-awesome-icon icon="inbox" size="3x" class="text-muted mb-3" />
          <h5>No hay datos de facturación</h5>
          <p class="text-muted">No se encontraron registros para el período {{ formData.mes }}/{{ formData.anio }}</p>
        </div>
      </div>
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
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const BASE_DB = 'otras_obligaciones'
const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

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

const totalFacturado = computed(() => {
  return facturacion.value.reduce((sum, item) => sum + (parseFloat(item.importe) || 0), 0)
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const handleGenerar = async () => {
  showLoading('Generando reporte...')
  showEmptyState.value = false

  try {
    const response = await execute(
      'sp_con34_gfact_02',
      BASE_DB,
      [
        { nombre: 'par_Tab', valor: '3', tipo: 'string' },
        { nombre: 'par_Ade', valor: 'A', tipo: 'string' },
        { nombre: 'Par_Rcgo', valor: 'N', tipo: 'string' },
        { nombre: 'par_Axo', valor: formData.anio, tipo: 'integer' },
        { nombre: 'par_Mes', valor: formData.mes, tipo: 'integer' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response?.result?.length > 0) {
      facturacion.value = response.result
      showToast('success', `Reporte generado: ${facturacion.value.length} registros`)
    } else {
      facturacion.value = []
      showEmptyState.value = true
      showToast('info', 'No se encontraron registros')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    facturacion.value = []
    showEmptyState.value = true
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
      'Tipo': item.tipo,
      'Licencia': item.licencia || '-',
      'Importe': item.importe
    }))

    exportData.push({
      'Control': '',
      'Concesionario': '',
      'Tipo': '',
      'Licencia': 'TOTAL:',
      'Importe': totalFacturado.value
    })

    const ws = XLSX.utils.json_to_sheet(exportData)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Facturacion')

    XLSX.writeFile(wb, `RFacturacion_${formData.mes}_${formData.anio}.xlsx`)
    showToast('success', 'Archivo exportado')
  } catch {
    showToast('error', 'Error al exportar')
  }
}

const imprimirReporte = () => {
  if (facturacion.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const columns = [
    { header: 'Control', key: 'control', type: 'string' },
    { header: 'Concesionario', key: 'concesionario', type: 'string' },
    { header: 'Tipo', key: 'tipo', type: 'string' },
    { header: 'Licencia', key: 'licencia', type: 'string' },
    { header: 'Importe', key: 'importe', type: 'currency' }
  ]

  exportToPdf(facturacion.value, columns, {
    title: 'Reporte de Facturación',
    subtitle: `Período: ${formData.mes}/${formData.anio} - Total: ${formatCurrency(totalFacturado.value)}`,
    orientation: 'landscape'
  })
}

const goBack = () => router.push('/otras-obligaciones/menu')
</script>

<style scoped>
/* Estilos en municipal-theme.css */
</style>
