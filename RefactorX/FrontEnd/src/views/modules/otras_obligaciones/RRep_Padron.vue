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
          <div class="form-row">
            <button class="btn-municipal-primary" @click="handleGenerar" :disabled="loading">
              <font-awesome-icon icon="print" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="handleExportar" :disabled="loading || padron.length === 0">
              <font-awesome-icon icon="download" /> Exportar Excel
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
              <thead>
                <tr>
                  <th>Control</th>
                  <th>Concesionario</th>
                  <th>Ubicación</th>
                  <th class="text-right">Superficie</th>
                  <th class="text-center">Licencia</th>
                  <th>Sector</th>
                  <th class="text-center">Zona</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, index) in padron" :key="index">
                  <td>{{ item.control }}</td>
                  <td>{{ item.concesionario }}</td>
                  <td>{{ item.ubicacion }}</td>
                  <td class="text-right">{{ item.superficie }}</td>
                  <td class="text-center">{{ item.licencia }}</td>
                  <td>{{ item.sector }}</td>
                  <td class="text-center">{{ item.id_zona }}</td>
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
      :componentName="'RRep_Padron'"
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
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { callApi } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const padron = ref([])

const formData = reactive({
  vigencia: 'T'
})

const handleGenerar = async () => {
  const startTime = performance.now()
  loading.value = true
  showLoading('Generando reporte de padrón...')

  try {
    const response = await callApi('SP_RREP_PADRON_OBTENER', {
      par_Vigencia: formData.vigencia
    })

    padron.value = response.data || []

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    if (padron.value.length > 0) {
      showToast('success', `Se encontraron ${padron.value.length} registros`, timeMessage)
    } else {
      showToast('info', 'No se encontraron registros', timeMessage)
    }
  } catch (error) {
    handleError(error, 'Error al generar reporte')
  } finally {
    loading.value = false
    hideLoading()
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
    'Superficie': item.superficie,
    'Licencia': item.licencia,
    'Sector': item.sector,
    'Zona': item.id_zona
  }))

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Padrón')
  XLSX.writeFile(wb, `Padron_${Date.now()}.xlsx`)

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
