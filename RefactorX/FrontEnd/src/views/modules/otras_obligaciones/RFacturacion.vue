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
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar" /> Período</h5>
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
          </div>
          <div class="form-row">
            <button class="btn-municipal-primary" @click="handleGenerar" :disabled="loading">
              <font-awesome-icon icon="print" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar" :disabled="loading || facturacion.length === 0" style="margin-left: 10px;">
              <font-awesome-icon icon="download" /> Exportar Excel
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="facturacion.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Facturación</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table table-municipal">
              <thead>
                <tr>
                  <th>Control</th>
                  <th>Concesionario</th>
                  <th>Concepto</th>
                  <th class="text-right">Total Facturado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in facturacion" :key="index">
                  <td>{{ item.control }}</td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(item.total_facturado) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Generando reporte...</p>
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
import { ref, reactive } from 'vue'
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
const facturacion = ref([])

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

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const handleGenerar = async () => {
  loading.value = true
  try {
    const response = await callApi('SP_RFACTURACION_OBTENER', {
      par_Aso: formData.anio,
      par_Mes: formData.mes
    })

    facturacion.value = response.data || []
    showToast('success', 'Reporte generado')
  } catch (error) {
    handleError(error, 'Error al generar reporte')
  } finally {
    loading.value = false
  }
}

const handleExportar = () => {
  if (facturacion.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  const ws = XLSX.utils.json_to_sheet(facturacion.value)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Facturación')
  XLSX.writeFile(wb, `Facturacion_${Date.now()}.xlsx`)
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
</script>
