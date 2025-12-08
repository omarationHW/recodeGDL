<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Locales</h1>
        <p>Otras Obligaciones - Rastro - Consulta de información</p>
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
      <!-- Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Control</h5>
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
              <label class="municipal-form-label">&nbsp;</label>
              <div class="button-group">
                <button class="btn-municipal-primary" @click="handleBuscar">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFormulario">
                  <font-awesome-icon icon="eraser" /> Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Local -->
      <div class="municipal-card" v-if="datosLocal.id_datos">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
          <div class="button-group ms-auto">
            <button class="btn-municipal-success" @click="imprimirReporte">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
            <span class="badge" :class="getStatusClass()">
              {{ datosLocal.statusregistro }}
            </span>
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
              <span>{{ datosLocal.licencia || 'N/A' }}</span>
            </div>
            <div class="info-item">
              <strong>Status:</strong>
              <span :class="getStatusClass()">{{ datosLocal.statusregistro }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.nomcomercial">
              <strong>Nombre Comercial:</strong>
              <span>{{ datosLocal.nomcomercial }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.lugar">
              <strong>Lugar:</strong>
              <span>{{ datosLocal.lugar }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.sector">
              <strong>Sector:</strong>
              <span>{{ datosLocal.sector }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.zona">
              <strong>Zona:</strong>
              <span>{{ datosLocal.zona }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.recaudadora">
              <strong>Recaudadora:</strong>
              <span>{{ datosLocal.recaudadora }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.fechainicio">
              <strong>Fecha Inicio:</strong>
              <span>{{ formatDate(datosLocal.fechainicio) }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.obs">
              <strong>Observaciones:</strong>
              <span>{{ datosLocal.obs }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RConsulta'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
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

const datosLocal = ref({})
const controlBuscado = ref('')

const formData = reactive({
  numero: '',
  letra: ''
})

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  showLoading('Buscando local...')

  try {
    const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`
    controlBuscado.value = control

    const response = await execute(
      'sp_otras_oblig_buscar_cont',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (!response || !response.result || response.result.length === 0 || response.result[0].status === -1) {
      showToast('warning', 'No se encontró el local especificado')
      datosLocal.value = {}
      return
    }

    datosLocal.value = response.result[0]
    showToast('success', 'Local encontrado')
  } catch (error) {
    hideLoading()
    handleApiError(error)
    datosLocal.value = {}
  }
}

const handleExportar = () => {
  if (!datosLocal.value.id_datos) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const dataExport = [{
      'Control': controlBuscado.value,
      'Concesionario': datosLocal.value.concesionario,
      'Ubicación': datosLocal.value.ubicacion,
      'Nombre Comercial': datosLocal.value.nomcomercial || '',
      'Lugar': datosLocal.value.lugar || '',
      'Superficie': datosLocal.value.superficie,
      'Licencia': datosLocal.value.licencia || '',
      'Status': datosLocal.value.statusregistro,
      'Sector': datosLocal.value.sector || '',
      'Zona': datosLocal.value.zona || '',
      'Recaudadora': datosLocal.value.recaudadora || '',
      'Fecha Inicio': formatDate(datosLocal.value.fechainicio),
      'Observaciones': datosLocal.value.obs || ''
    }]

    const ws = XLSX.utils.json_to_sheet(dataExport)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Consulta')

    XLSX.writeFile(wb, `RConsulta_${controlBuscado.value}_${new Date().toISOString().slice(0,10)}.xlsx`)
    showToast('success', 'Archivo exportado')
  } catch {
    showToast('error', 'Error al exportar')
  }
}

const imprimirReporte = () => {
  if (!datosLocal.value.id_datos) {
    showToast('warning', 'Debe buscar un local primero')
    return
  }

  const columns = [
    { header: 'Campo', key: 'campo', type: 'string' },
    { header: 'Valor', key: 'valor', type: 'string' }
  ]

  const data = [
    { campo: 'Control', valor: controlBuscado.value },
    { campo: 'Concesionario', valor: datosLocal.value.concesionario },
    { campo: 'Ubicación', valor: datosLocal.value.ubicacion },
    { campo: 'Superficie', valor: `${datosLocal.value.superficie} m²` },
    { campo: 'Licencia', valor: datosLocal.value.licencia || 'N/A' },
    { campo: 'Status', valor: datosLocal.value.statusregistro },
    { campo: 'Sector', valor: datosLocal.value.sector || 'N/A' },
    { campo: 'Zona', valor: datosLocal.value.zona || 'N/A' },
    { campo: 'Recaudadora', valor: datosLocal.value.recaudadora || 'N/A' },
    { campo: 'Fecha Inicio', valor: formatDate(datosLocal.value.fechainicio) }
  ]

  if (datosLocal.value.nomcomercial) {
    data.push({ campo: 'Nombre Comercial', valor: datosLocal.value.nomcomercial })
  }
  if (datosLocal.value.obs) {
    data.push({ campo: 'Observaciones', valor: datosLocal.value.obs })
  }

  exportToPdf(data, columns, {
    title: 'Consulta de Local',
    subtitle: `Control: ${controlBuscado.value}`,
    orientation: 'portrait'
  })
}

const limpiarFormulario = () => {
  formData.numero = ''
  formData.letra = ''
  datosLocal.value = {}
  controlBuscado.value = ''
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
  } catch {
    return dateString
  }
}

const getStatusClass = () => {
  if (!datosLocal.value.statusregistro) return 'badge-secondary'
  const status = datosLocal.value.statusregistro.toUpperCase()
  if (status === 'VIGENTE') return 'badge-success'
  if (status === 'CANCELADO') return 'badge-danger'
  return 'badge-warning'
}

const goBack = () => router.push('/otras-obligaciones/menu')
</script>

<style scoped>
/* Estilos en municipal-theme.css */
</style>
