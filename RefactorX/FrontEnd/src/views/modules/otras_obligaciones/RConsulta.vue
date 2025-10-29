<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Consulta</h1>
        <p>Otras Obligaciones - Consulta de información de contratos</p>
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
              <input type="text" v-model="formData.numero" class="municipal-form-control" placeholder="Número" style="width: 120px; display: inline-block; margin-right: 10px;" />
              <span style="margin: 0 10px;">-</span>
              <input type="text" v-model="formData.letra" class="municipal-form-control" placeholder="Letra" style="width: 100px; display: inline-block;" />
            </div>
            <div class="form-group">
              <button class="btn-municipal-primary" @click="handleBuscar" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="info-circle" /> Datos del Local</h5>
          <button class="btn-municipal-secondary" @click="handleExportar">
            <font-awesome-icon icon="download" /> Exportar Excel
          </button>
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
            <div class="info-item">
              <strong>Status:</strong>
              <span>{{ datosLocal.descrip_stat }}</span>
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Buscando...</p>
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
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import * as XLSX from 'xlsx'

const router = useRouter()
const { callApi } = useApi()
const { handleError, showToast } = useLicenciasErrorHandler()

const loading = ref(false)
const showDocumentation = ref(false)
const datosLocal = ref({})
const formData = reactive({ numero: '', letra: '' })

const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control')
    return
  }

  loading.value = true
  try {
    const control = `${formData.numero}-${formData.letra || ''}`
    const response = await callApi('SP_RCONSULTA_OBTENER', { p_control: control })

    if (response.data && response.data.length > 0) {
      datosLocal.value = response.data[0]
      showToast('success', 'Local encontrado')
    } else {
      showToast('warning', 'No se encontró el local')
      datosLocal.value = {}
    }
  } catch (error) {
    handleError(error, 'Error al buscar')
  } finally {
    loading.value = false
  }
}

const handleExportar = () => {
  if (!datosLocal.value.control) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  const dataExport = [{
    'Control': datosLocal.value.control,
    'Concesionario': datosLocal.value.concesionario,
    'Ubicación': datosLocal.value.ubicacion,
    'Superficie': datosLocal.value.superficie,
    'Licencia': datosLocal.value.licencia
  }]

  const ws = XLSX.utils.json_to_sheet(dataExport)
  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, 'Consulta')
  XLSX.writeFile(wb, `Consulta_${Date.now()}.xlsx`)
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
