<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-circle-check" />
      </div>
      <div class="module-view-info">
        <h1>Prescripción Sec 01</h1>
        <p>Consulta de prescripciones de multas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Búsqueda de Prescripciones</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro de Búsqueda</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.q"
                placeholder="ID Multa, Oficio, Dependencia, Capturista..."
                @keyup.enter="reload"
              />
              <small class="form-text">Busca por ID Multa, Oficio, Dependencia o Capturista. Deja vacío para ver los últimos registros.</small>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="reload"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card" v-if="rows.length > 0 || hasSearched">
        <div class="municipal-card-header">
          <h5>Prescripciones ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" v-if="rows.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Prescripción</th>
                  <th>Fecha Autorización</th>
                  <th>Fecha Prescripción</th>
                  <th>Oficio</th>
                  <th>ID Multa</th>
                  <th>Capturista</th>
                  <th>Dependencia</th>
                  <th>Observaciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_prescri" class="row-hover">
                  <td><strong>{{ r.id_prescri }}</strong></td>
                  <td>{{ formatDate(r.fecaut) }}</td>
                  <td>{{ formatDate(r.fecha_prescri) }}</td>
                  <td>{{ r.oficio }}</td>
                  <td><strong>{{ r.id_multa }}</strong></td>
                  <td>{{ r.capturista }}</td>
                  <td>{{ r.dependencia }}</td>
                  <td class="text-truncate" :title="r.observaciones">
                    {{ truncateText(r.observaciones, 50) }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="empty-state">
            <font-awesome-icon icon="search" size="3x" />
            <p>No se encontraron prescripciones</p>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++">
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'sfrm_prescrip_sec01'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Prescripción Sec 01'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'sfrm_prescrip_sec01'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Prescripción Sec 01'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_SFRM_PRESCRIP_SEC01'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({
  q: ''
})

const rows = ref([])
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Formatear fecha
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// Truncar texto
function truncateText(text, maxLength) {
  if (!text) return 'N/A'
  if (text.length <= maxLength) return text
  return text.substring(0, maxLength) + '...'
}

async function reload() {
  hasSearched.value = true

  // IMPORTANTE: Usar formato español (nombre/tipo/valor)
  const params = [
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta
    let arr = []
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      arr = response.eResponse.data.result
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      arr = response.data.result
    } else if (response?.result && Array.isArray(response.result)) {
      arr = response.result
    } else if (response?.rows && Array.isArray(response.rows)) {
      arr = response.rows
    } else if (Array.isArray(response)) {
      arr = response
    }

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    currentPage.value = 1
  } catch (e) {
    console.error('Error al buscar prescripciones:', e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { q: '' }
  rows.value = []
  hasSearched.value = false
  currentPage.value = 1
}
</script>

