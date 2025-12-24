<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="leaf" />
      </div>
      <div class="module-view-info">
        <h1>Licencia Microgenerador Ecología</h1>
        <p>Consulta de licencias ecológicas de microgeneración</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Búsqueda por RFC</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                class="municipal-form-control"
                v-model="filters.rfc"
                placeholder="Ej: ABC123456XYZ"
                @keyup.enter="consultar"
                maxlength="13"
              />
              <small class="form-text">Ingrese el RFC del solicitante (12-13 caracteres)</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.rfc"
              @click="consultar"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading"/>
              {{ loading ? 'Consultando...' : 'Consultar' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert-danger">
            <font-awesome-icon icon="times-circle"/>
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="rows.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table"/>
            Licencias ecológicas encontradas ({{ rows.length }})
          </h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ c }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in paginatedRows" :key="i">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination Controls -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
              </span>
            </div>
            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="goToPage(1)">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="prevPage">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page-indicator">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="nextPage">
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div class="municipal-card" v-else-if="searched && !error">
        <div class="municipal-card-body">
          <div class="alert-info">
            <font-awesome-icon icon="info-circle"/>
            <strong>No se encontraron licencias ecológicas para el RFC proporcionado</strong>
          </div>
        </div>
      </div>
    </div>    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'LicenciaMicrogeneradorEcologia'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Licencia Microgenerador Ecología'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'LicenciaMicrogeneradorEcologia'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Licencia Microgenerador Ecología'"
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


const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_LICENCIAMICROGENERADORECOLOGIA'
const SCHEMA = 'publico'

const filters = ref({ rfc: '' })
const rows = ref([])
const cols = ref([])
const error = ref(null)
const searched = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)

// Computed properties para paginación
const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value))

const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)

const endIndex = computed(() => {
  const end = startIndex.value + pageSize.value
  return end > rows.value.length ? rows.value.length : end
})

const paginatedRows = computed(() => {
  return rows.value.slice(startIndex.value, endIndex.value)
})

// Funciones de paginación
function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

async function consultar() {
  currentPage.value = 1 // Reset a la primera página al buscar
  error.value = null
  searched.value = false

  const params = [
    { nombre: 'p_rfc', tipo: 'string', valor: String(filters.value.rfc || '').toUpperCase() }
  ]

  try {
    const response = await execute(OP, BASE_DB, params, '', null, SCHEMA)
    searched.value = true

    // Manejar diferentes formatos de respuesta
    let data = null

    if (response?.result) {
      data = response.result
    } else if (response?.rows) {
      data = response.rows
    } else if (Array.isArray(response)) {
      data = response
    } else {
      data = response
    }

    const arr = Array.isArray(data) ? data : []
    rows.value = arr
    cols.value = arr.length > 0 ? Object.keys(arr[0]) : []

  } catch (e) {
    searched.value = true
    error.value = e?.message || 'Error al realizar la consulta'
    rows.value = []
    cols.value = []
  }
}
</script>

