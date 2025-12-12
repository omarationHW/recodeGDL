<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-xmark" /></div>
      <div class="module-view-info">
        <h1>Baja Múltiple de Folios</h1>
        <p>Consulta de incidencias por archivo</p>
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

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Nombre de archivo</label><input class="municipal-form-control" v-model="archivo" placeholder="Ej. bajas_2025_10_15.csv" /></div>
          </div>
          <div class="municipal-alert municipal-alert-info"><small>Nota: la inserción/aplicación de bajas se realiza con PROCEDUREs (`sp_insert_folios_baja_esta`, `sp14_ejecuta_sp`). El backend actual ejecuta funciones con SELECT. Para procesar el archivo completo por API, es recomendable agregar wrappers FUNCTION en la BD o permitir `CALL` en backend. Aquí puedes consultar las incidencias con `sp_get_incidencias_baja_multiple`.</small></div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Incidencias</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Placa</th><th>Folio Archivo</th><th>Fecha Archivo</th><th>Anomalía</th><th>Referencia</th></tr></thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.placa}-${r.folio_archivo}`"><td>{{ r.placa }}</td><td>{{ r.folio_archivo }}</td><td>{{ r.fecha_archivo }}</td><td>{{ r.anomalia }}</td><td>{{ r.referencia }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin incidencias</td></tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div class="pagination-controls" v-if="rows.length > 0">
            <div class="pagination-info">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} -
              {{ Math.min(currentPage * itemsPerPage, rows.length) }} de
              {{ rows.length }} registros
            </div>
            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary"
                @click="prevPage"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-municipal-secondary"
                @click="nextPage"
                :disabled="currentPage === totalPages"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - BajaMultiplePublicos"
    >
      <h3>Baja Multiple Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'BajaMultiplePublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const archivo = ref('')
const rows = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rows.value.slice(start, end)
})

const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage.value))

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const nextPage = () => goToPage(currentPage.value + 1)
const prevPage = () => goToPage(currentPage.value - 1)

async function consultar() {
  if (!archivo.value.trim()) {
    showToast('warning', 'Ingrese el nombre del archivo a consultar')
    return
  }

  showLoading('Consultando...', 'Buscando incidencias')
  rows.value = []
  currentPage.value = 1
  try {
    const params = [
      { nombre: 'p_archivo', valor: archivo.value.trim(), tipo: 'string' }
    ]
    const resp = await execute('sp_get_incidencias_baja_multiple', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    hideLoading()

    if (rows.value.length === 0) {
      showToast('info', 'No se encontraron incidencias para el archivo especificado')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

