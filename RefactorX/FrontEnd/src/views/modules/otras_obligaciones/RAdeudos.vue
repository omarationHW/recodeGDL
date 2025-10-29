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
              <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" maxlength="3" style="width: 120px; display: inline-block; margin-right: 10px;" />
              <span style="margin: 0 10px;">-</span>
              <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" maxlength="2" style="width: 100px; display: inline-block;" />
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
            <table class="table table-municipal">
              <thead>
                <tr>
                  <th>Concepto</th>
                  <th class="text-right">Adeudo</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in adeudosConcentrado" :key="index">
                  <td>{{ row.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(row.importe_adeudo) }}</td>
                  <td class="text-right">{{ formatCurrency(row.importe_recargo) }}</td>
                  <td class="text-right">{{ formatCurrency(row.importe_adeudo + row.importe_recargo) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Tabla desglosada -->
          <div v-else class="table-responsive">
            <table class="table table-municipal">
              <thead>
                <tr>
                  <th>Concepto</th>
                  <th class="text-center">Año</th>
                  <th class="text-center">Mes</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in adeudosDesglosado" :key="index">
                  <td>{{ row.concepto }}</td>
                  <td class="text-center">{{ row.axo }}</td>
                  <td class="text-center">{{ row.mes }}</td>
                  <td class="text-right">{{ formatCurrency(row.importe_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(row.recargos_pagar) }}</td>
                </tr>
              </tbody>
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
          <p>Cargando datos...</p>
        </div>
      </div>
    </div>

    <!-- Modal de documentación -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RAdeudos'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
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
      sum + item.importe_adeudo + item.importe_recargo, 0)
  } else {
    return adeudosDesglosado.value.reduce((sum, item) =>
      sum + item.importe_pagar + item.recargos_pagar, 0)
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
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  if (formData.tipoAdeudos === 'A' && (!formData.anio || !formData.mes)) {
    showToast('warning', 'Debe especificar año y mes')
    return
  }

  loading.value = true
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const localResponse = await callApi('SP_RADEUDOS_BUSCAR_CONTROL', {
      p_cve: '3',
      p_control: control
    })

    if (!localResponse.data || localResponse.data.length === 0) {
      showToast('warning', 'No se encontró el local')
      return
    }

    datosLocal.value = localResponse.data[0]
    const fecha = `${formData.anio}-${String(formData.mes).padStart(2, '0')}`

    const [concentradoResponse, desglosadoResponse] = await Promise.all([
      callApi('SP_RADEUDOS_DETALLE_CONCENTRADO', {
        par_Control: datosLocal.value.id_34_datos,
        par_Rep: formData.tipoAdeudos,
        par_Fecha: fecha
      }),
      callApi('SP_RADEUDOS_DETALLE_DESGLOSADO', {
        par_Control: datosLocal.value.id_34_datos,
        par_Rep: formData.tipoAdeudos,
        par_Fecha: fecha
      })
    ])

    adeudosConcentrado.value = concentradoResponse.data || []
    adeudosDesglosado.value = desglosadoResponse.data || []

    showToast('success', 'Reporte generado')
  } catch (error) {
    handleError(error, 'Error al generar reporte')
  } finally {
    loading.value = false
  }
}

const handleExportar = () => {
  if (adeudosConcentrado.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  const dataExport = adeudosConcentrado.value.map(item => ({
    'Concepto': item.concepto,
    'Adeudo': item.importe_adeudo,
    'Recargos': item.importe_recargo,
    'Total': item.importe_adeudo + item.importe_recargo
  }))

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Adeudos')
  XLSX.writeFile(wb, `Adeudos_${Date.now()}.xlsx`)
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
