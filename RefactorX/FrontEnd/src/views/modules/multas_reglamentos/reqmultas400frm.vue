<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Requerimientos Multas 400</h1>
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
      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <!-- Tipo de Multa -->
          <div class="form-group mb-3">
            <label class="municipal-form-label">Tipo de Multa</label>
            <div class="radio-group">
              <label class="radio-label">
                <input type="radio" value="6" v-model="filters.tipo" />
                <span>Multas Federales</span>
              </label>
              <label class="radio-label">
                <input type="radio" value="5" v-model="filters.tipo" />
                <span>Multas Municipales</span>
              </label>
            </div>
          </div>

          <!-- Búsqueda General -->
          <div class="search-section">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Cuenta / Folio</label>
                <input
                  class="municipal-form-control"
                  v-model="filters.cuenta"
                  placeholder="Ingrese cuenta o folio"
                  @keyup.enter="buscarGeneral"
                />
              </div>
              <div class="button-wrapper">
                <button
                  class="btn-municipal-primary"
                  :disabled="loading"
                  @click="buscarGeneral"
                >
                  Buscar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje de carga -->
      <div v-if="loading" class="loading-message">
        <div class="spinner"></div>
        <span>Cargando datos...</span>
      </div>

      <!-- Tabla de Resultados con Paginación -->
      <div v-if="!loading && rows.length > 0" class="municipal-card">
        <div class="municipal-card-body">
          <div class="results-header">
            <h3>Resultados: {{ rows.length }} registros encontrados</h3>
          </div>

          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ formatColumnName(c) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in paginatedRows" :key="i">
                  <td v-for="c in cols" :key="c">{{ formatValue(r[c], c) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="previousPage"
              >
                ‹ Anterior
              </button>
              <span class="page-info">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="nextPage"
              >
                Siguiente ›
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div v-if="!loading && searchPerformed && rows.length === 0" class="no-results">
        <p>No se encontraron resultados para la búsqueda.</p>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'reqmultas400frm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Requerimientos Multas 400'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'reqmultas400frm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Requerimientos Multas 400'"
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

const filters = ref({
  cuenta: '',
  tipo: '6' // Default: Federal
})

const rows = ref([])
const cols = ref([])
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage)
})

const startIndex = computed(() => {
  return (currentPage.value - 1) * itemsPerPage
})

const endIndex = computed(() => {
  return Math.min(startIndex.value + itemsPerPage, rows.value.length)
})

const paginatedRows = computed(() => {
  return rows.value.slice(startIndex.value, endIndex.value)
})

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function previousPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function resetPagination() {
  currentPage.value = 1
}

// Búsqueda General
async function buscarGeneral() {
  try {
    searchPerformed.value = true
    resetPagination()

    const data = await execute('RECAUDADORA_REQMULTAS400FRM', BASE_DB, [
      {
        nombre: 'p_clave_cuenta',
        tipo: 'string',
        valor: String(filters.value.cuenta || '')
      }
    ])

    processResults(data)
  } catch (e) {
    console.error('Error en búsqueda general:', e)
    rows.value = []
    cols.value = []
  }
}

function processResults(data) {
  console.log('Data recibida:', data)

  // Intentar obtener los datos de diferentes ubicaciones posibles
  let arr = []

  if (data?.result && Array.isArray(data.result)) {
    arr = data.result
  } else if (data?.rows && Array.isArray(data.rows)) {
    arr = data.rows
  } else if (Array.isArray(data)) {
    arr = data
  }

  console.log('Array procesado:', arr)

  rows.value = arr
  cols.value = arr.length ? Object.keys(arr[0]) : []
}

function formatColumnName(col) {
  const columnNames = {
    cvelet: 'Clave Letra',
    cvenum: 'Año Acta',
    ctarfc: 'Núm. Acta',
    cveapl: 'Tipo',
    axoreq: 'Año Req',
    folreq: 'Folio Req',
    fecreq: 'Fecha Req',
    impcuo: 'Importe',
    observr: 'Observaciones',
    vigreq: 'Vigencia',
    actreq: 'Activación',
    tipo_multa: 'Tipo Multa'
  }
  return columnNames[col] || col.toUpperCase()
}

function formatValue(value, column) {
  if (value === null || value === undefined || value === '') return '-'

  // Formato de importe
  if (column === 'impcuo' && !isNaN(value)) {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  }

  // Formato de fecha (YYYYMMDD -> DD/MM/YYYY)
  if ((column === 'fecreq' || column === 'actreq') && value && value !== '0') {
    const str = String(value).padStart(8, '0')
    if (str.length === 8) {
      const year = str.substring(0, 4)
      const month = str.substring(4, 6)
      const day = str.substring(6, 8)
      return `${day}/${month}/${year}`
    }
  }

  return value
}
</script>

