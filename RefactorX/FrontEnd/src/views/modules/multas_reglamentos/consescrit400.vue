<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-signature" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Escrituras 400</h1>
        <p>Consulta de escrituras públicas registradas bajo el artículo 400</p>
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
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Cuenta Predial</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                placeholder="Ingrese el número de cuenta predial"
                @keyup.enter="filters.cuenta.trim() && reload()"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta.trim()"
              @click="reload"
            >
              <font-awesome-icon icon="search" v-if="!loading"/>
              <font-awesome-icon icon="spinner" spin v-if="loading"/>
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
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Registros ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ c }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in paginatedRows" :key="i" class="row-hover">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td :colspan="cols.length" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
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
                @click="currentPage++"
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
      :show="showAyuda"
      :component-name="'consescrit400'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Consulta Escrituras 400'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'consescrit400'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Consulta Escrituras 400'"
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
const OP = 'RECAUDADORA_CONSESCRIT400'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ cuenta: '' })
const rows = ref([])
const cols = ref([])
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

async function reload() {
  hasSearched.value = true

  const params = [
    { nombre: 'p_clave_cuenta', valor: String(filters.value.cuenta || ''), tipo: 'string' }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP, BASE_DB, params, '', null, 'publico')
    console.log('Respuesta completa:', response)

    // Extraer datos con fallbacks
    const data = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(data?.result) ? data.result : Array.isArray(data) ? data : []

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
    currentPage.value = 1
  } catch (e) {
    console.error('Error al buscar escrituras:', e)
    rows.value = []
    cols.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { cuenta: '' }
  rows.value = []
  cols.value = []
  hasSearched.value = false
  currentPage.value = 1
}

// No cargar automáticamente, esperar a que el usuario haga clic en Buscar
// reload()
</script>

