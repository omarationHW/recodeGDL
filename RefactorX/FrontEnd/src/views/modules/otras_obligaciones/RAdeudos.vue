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
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
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
              <label class="municipal-form-label">Número:</label>
              <input
                type="text"
                v-model="formData.numero"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="10"
                @keyup.enter="handleBuscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Letra:</label>
              <input
                type="text"
                v-model="formData.letra"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="5"
                @keyup.enter="handleBuscar"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo Adeudos:</label>
              <select v-model="formData.tipoAdeudos" class="municipal-form-control" @change="handleTipoChange">
                <option value="V">Vencidos</option>
                <option value="A">Acumulados al Periodo</option>
              </select>
            </div>
            <div class="form-group" v-if="formData.tipoAdeudos === 'A'">
              <label class="municipal-form-label">Año:</label>
              <input type="number" v-model.number="formData.anio" class="municipal-form-control" :min="2000" :max="2099" />
            </div>
            <div class="form-group" v-if="formData.tipoAdeudos === 'A'">
              <label class="municipal-form-label">Mes:</label>
              <select v-model.number="formData.mes" class="municipal-form-control">
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="button-group">
                <button class="btn-municipal-primary" @click="handleBuscar">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del local -->
      <div class="municipal-card" v-if="datosLocal.id_datos">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
          <div class="button-group ms-auto">
            <button class="btn-municipal-success" @click="imprimirReporte">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar" :disabled="adeudosConcentrado.length === 0">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>Control:</strong>
              <span>{{ controlBuscado }}</span>
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
              <span>{{ datosLocal.superficie }} m²</span>
            </div>
            <div class="info-item">
              <strong>Licencia:</strong>
              <span>{{ datosLocal.licencia }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos -->
      <div class="municipal-card" v-if="datosLocal.id_datos">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Adeudos Registrados</h5>
          <div class="button-group ms-auto">
            <button
              class="btn-municipal-primary"
              :class="{ 'active': vistaDetalle === 'concentrado' }"
              @click="vistaDetalle = 'concentrado'"
            >
              Concentrado
            </button>
            <button
              class="btn-municipal-secondary"
              :class="{ 'active': vistaDetalle === 'desglosado' }"
              @click="vistaDetalle = 'desglosado'"
            >
              Desglosado
            </button>
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
                <tr v-for="(row, index) in adeudosConcentrado" :key="index">
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
                  <td class="text-right font-weight-bold text-primary-orange">
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
                  <th class="text-right">Descto. Imp.</th>
                  <th class="text-right">Descto. Rec.</th>
                  <th class="text-right">Actualización</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, index) in adeudosDesglosado" :key="index">
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
                  <td class="text-right font-weight-bold text-primary-orange">
                    {{ formatCurrency(totalAdeudos) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Sin adeudos -->
          <div v-if="adeudosConcentrado.length === 0 && adeudosDesglosado.length === 0" class="text-center p-4">
            <font-awesome-icon icon="check-circle" size="3x" class="text-success mb-3" />
            <p class="text-muted">No se encontraron adeudos para este control</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
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
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const BASE_DB = 'otras_obligaciones'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()

const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const datosLocal = ref({})
const adeudosConcentrado = ref([])
const adeudosDesglosado = ref([])
const vistaDetalle = ref('concentrado')
const controlBuscado = ref('')

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
    return adeudosConcentrado.value.reduce((sum, item) => sum + (item.importe || 0), 0)
  } else {
    return adeudosDesglosado.value.reduce((sum, item) => sum + (item.total_periodo || 0), 0)
  }
})

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const handleTipoChange = () => {
  if (formData.tipoAdeudos === 'V') {
    formData.anio = new Date().getFullYear()
    formData.mes = new Date().getMonth() + 1
  }
}

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  if (formData.tipoAdeudos === 'A' && (!formData.anio || !formData.mes)) {
    showToast('warning', 'Debe especificar año y mes')
    return
  }

  showLoading('Consultando adeudos...')

  try {
    const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`
    controlBuscado.value = control

    const localResponse = await execute(
      'sp_otras_oblig_buscar_cont',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (!localResponse || !localResponse.result || localResponse.result.length === 0 || localResponse.result[0].status === -1) {
      hideLoading()
      showToast('warning', 'No se encontró el local especificado')
      return
    }

    datosLocal.value = localResponse.result[0]

    const [concentradoResponse, desglosadoResponse] = await Promise.all([
      execute(
        'sp_otras_oblig_buscar_totales',
        BASE_DB,
        [
          { nombre: 'par_tabla', valor: 3, tipo: 'integer' },
          { nombre: 'par_id_datos', valor: datosLocal.value.id_datos, tipo: 'integer' },
          { nombre: 'par_aso', valor: formData.anio, tipo: 'integer' },
          { nombre: 'par_mes', valor: formData.mes, tipo: 'integer' }
        ],
        'guadalajara'
      ),
      execute(
        'sp_otras_oblig_buscar_adeudos',
        BASE_DB,
        [
          { nombre: 'par_tabla', valor: 3, tipo: 'integer' },
          { nombre: 'par_id_datos', valor: datosLocal.value.id_datos, tipo: 'integer' },
          { nombre: 'par_aso', valor: formData.anio, tipo: 'integer' },
          { nombre: 'par_mes', valor: formData.mes, tipo: 'integer' }
        ],
        'guadalajara'
      )
    ])

    hideLoading()

    adeudosConcentrado.value = (concentradoResponse?.result || []).filter(r => r.concepto)
    adeudosDesglosado.value = (desglosadoResponse?.result || []).filter(r => r.concepto)

    if (adeudosConcentrado.value.length > 0 || adeudosDesglosado.value.length > 0) {
      showToast('success', 'Adeudos encontrados')
    } else {
      showToast('info', 'No se encontraron adeudos')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const imprimirReporte = () => {
  if (!datosLocal.value.id_datos) {
    showToast('warning', 'Debe buscar un local primero')
    return
  }

  const hasAdeudos = adeudosConcentrado.value.length > 0 || adeudosDesglosado.value.length > 0

  if (hasAdeudos) {
    const columns = vistaDetalle.value === 'concentrado'
      ? [
          { header: 'Concepto', key: 'concepto', type: 'string' },
          { header: 'Periodos', key: 'cuenta', type: 'number' },
          { header: 'Importe', key: 'importe', type: 'currency' }
        ]
      : [
          { header: 'Concepto', key: 'concepto', type: 'string' },
          { header: 'Año', key: 'axo', type: 'number' },
          { header: 'Mes', key: 'mes', type: 'number' },
          { header: 'Importe', key: 'importe_pagar', type: 'currency' },
          { header: 'Recargos', key: 'recargos_pagar', type: 'currency' },
          { header: 'Total', key: 'total_periodo', type: 'currency' }
        ]

    const data = vistaDetalle.value === 'concentrado' ? adeudosConcentrado.value : adeudosDesglosado.value

    exportToPdf(data, columns, {
      title: 'Reporte de Adeudos',
      subtitle: `Control: ${controlBuscado.value} - ${datosLocal.value.concesionario}`,
      orientation: 'landscape'
    })
  } else {
    const columns = [
      { header: 'Campo', key: 'campo', type: 'string' },
      { header: 'Valor', key: 'valor', type: 'string' }
    ]
    const data = [
      { campo: 'Control', valor: controlBuscado.value },
      { campo: 'Concesionario', valor: datosLocal.value.concesionario },
      { campo: 'Ubicación', valor: datosLocal.value.ubicacion },
      { campo: 'Superficie', valor: `${datosLocal.value.superficie} m²` },
      { campo: 'Status', valor: datosLocal.value.statusregistro },
      { campo: 'Adeudos', valor: 'SIN ADEUDOS PENDIENTES' }
    ]

    exportToPdf(data, columns, {
      title: 'Consulta de Adeudos',
      subtitle: `Control: ${controlBuscado.value}`,
      orientation: 'portrait'
    })
  }
}

const handleExportar = () => {
  if (adeudosConcentrado.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const dataExport = adeudosConcentrado.value.map(item => ({
      'Concepto': item.concepto,
      'Periodos': item.cuenta,
      'Importe': item.importe
    }))

    dataExport.push({ 'Concepto': 'TOTAL', 'Periodos': '', 'Importe': totalAdeudos.value })

    const ws = XLSX.utils.json_to_sheet(dataExport)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Adeudos')

    XLSX.writeFile(wb, `RAdeudos_${controlBuscado.value}_${new Date().toISOString().slice(0,10)}.xlsx`)
    showToast('success', 'Archivo exportado')
  } catch (error) {
    showToast('error', 'Error al exportar')
  }
}

const goBack = () => router.push('/otras-obligaciones/menu')

const getNombreMes = (mes) => {
  const nombres = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return nombres[mes - 1] || mes
}
</script>

<style scoped>
/* Estilos en municipal-theme.css */
</style>
