<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-export" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Repositorio Padrón</h1>
        <p>Otras Obligaciones - Reporte completo del padrón</p>
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
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Vigencia:</label>
              <select v-model="formData.vigencia" class="municipal-form-control">
                <option value="T">Todos</option>
                <option value="V">Vigentes</option>
                <option value="C">Cancelados</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="handleGenerar">
              <font-awesome-icon icon="search" /> Generar
            </button>
            <button class="btn-municipal-success" @click="handleImprimir" :disabled="padron.length === 0">
              <font-awesome-icon icon="print" /> Imprimir
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar" :disabled="padron.length === 0">
              <font-awesome-icon icon="file-excel" /> Excel
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="padron.length > 0">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Padrón</h5>
          <span class="badge-purple">Total: {{ padron.length }} registros</span>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="table table-municipal">
              <thead class="municipal-table-header">
                <tr>
                  <th><font-awesome-icon icon="hashtag" /> Control</th>
                  <th><font-awesome-icon icon="user" /> Concesionario</th>
                  <th><font-awesome-icon icon="map-marker-alt" /> Ubicación</th>
                  <th class="text-right"><font-awesome-icon icon="ruler-combined" /> Superficie</th>
                  <th class="text-center"><font-awesome-icon icon="id-card" /> Licencia</th>
                  <th><font-awesome-icon icon="building" /> Sector</th>
                  <th class="text-center"><font-awesome-icon icon="map-marked" /> Zona</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in padron" :key="index" class="row-hover">
                  <td><span class="badge badge-purple">{{ item.control }}</span></td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.ubicacion }}</td>
                  <td class="text-right">{{ formatNumber(item.superficie, 2) }}</td>
                  <td class="text-center">{{ item.licencia || '-' }}</td>
                  <td>{{ item.sector || '-' }}</td>
                  <td class="text-center">{{ item.id_zona || '-' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>

    <DocumentationModal
      :show="showDocumentation"
      :componentName="'RRep_Padron'"
      :moduleName="'otras_obligaciones'"
      @close="closeDocumentation"
    />
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'RRep_Padron'"
      :moduleName="'otras_obligaciones'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { usePdfExport } from '@/composables/usePdfExport'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const { showLoading, hideLoading } = useGlobalLoading()
const { handleApiError, showToast } = useLicenciasErrorHandler()
const { exportToPdf } = usePdfExport()
const showDocumentation = ref(false)
const showTechDocs = ref(false)
const padron = ref([])

const formData = reactive({
  vigencia: 'T'
})

const handleGenerar = async () => {
  showLoading('Generando reporte de padrón...')

  try {
    const response = await execute(
      'sp_rrep_padron_rastro',
      BASE_DB,
      [{ nombre: 'par_vigencia', valor: formData.vigencia, tipo: 'varchar' }],
      'guadalajara'
    )

    padron.value = response?.result || []
    hideLoading()

    if (padron.value.length > 0) {
      showToast('success', `Se encontraron ${padron.value.length} registros`)
    } else {
      showToast('info', 'No se encontraron registros')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const handleExportar = () => {
  if (padron.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  const startTime = performance.now()

  const dataExport = padron.value.map(item => ({
    'Control': item.control,
    'Concesionario': item.concesionario,
    'Ubicación': item.ubicacion,
    'Superficie': formatNumber(item.superficie, 2),
    'Licencia': item.licencia || '-',
    'Sector': item.sector || '-',
    'Zona': item.id_zona || '-'
  }))

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Padrón Repositorio')

  // Ajustar anchos de columna
  ws['!cols'] = [
    { wch: 12 }, // Control
    { wch: 30 }, // Concesionario
    { wch: 40 }, // Ubicación
    { wch: 12 }, // Superficie
    { wch: 12 }, // Licencia
    { wch: 15 }, // Sector
    { wch: 10 }  // Zona
  ]

  XLSX.writeFile(wb, `Padron_Repositorio_${Date.now()}.xlsx`)

  const endTime = performance.now()
  const duration = ((endTime - startTime) / 1000).toFixed(2)
  const timeMessage = duration < 1
    ? `${(duration * 1000).toFixed(0)}ms`
    : `${duration}s`

  showToast('success', 'Archivo exportado')
}

const handleImprimir = () => {
  if (padron.value.length === 0) {
    showToast('warning', 'No hay datos para imprimir')
    return
  }

  const columns = [
    { header: 'Control', key: 'control', type: 'string' },
    { header: 'Concesionario', key: 'concesionario', type: 'string' },
    { header: 'Ubicación', key: 'ubicacion', type: 'string' },
    { header: 'Superficie', key: 'superficie', type: 'number' },
    { header: 'Licencia', key: 'licencia', type: 'number' },
    { header: 'Sector', key: 'sector', type: 'string' },
    { header: 'Zona', key: 'id_zona', type: 'number' }
  ]

  const vigenciaTxt = { T: 'Todos', V: 'Vigentes', C: 'Cancelados' }

  exportToPdf(padron.value, columns, {
    title: 'Reporte Padrón - Rastro',
    subtitle: `Vigencia: ${vigenciaTxt[formData.vigencia]} - Total: ${padron.value.length} registros`,
    orientation: 'landscape'
  })
}

const openDocumentation = () => {
  showDocumentation.value = true
}

const closeDocumentation = () => {
  showDocumentation.value = false
}

const mostrarDocumentacion = () => {
  showTechDocs.value = true
}

const closeTechDocs = () => {
  showTechDocs.value = false
}

const formatNumber = (value, decimals = 2) => {
  if (value === null || value === undefined) return '0.00'
  return parseFloat(value).toFixed(decimals)
}

const goBack = () => {
  router.push('/otras-obligaciones/menu')
}
</script>
