<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-ol" />
      </div>
      <div class="module-view-info">
        <h1>Lista de Diferencias</h1>
        <p>Comparativo y diferencias detectadas</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Búsqueda de Diferencias</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro de Búsqueda</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                placeholder="Ingrese término de búsqueda..."
                @keyup.enter="reload"
              />
              <small class="form-text">Presione Enter o haga clic en Buscar</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="reload"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading"/>
              {{ loading ? 'Buscando...' : 'Buscar' }}
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
            Diferencias encontradas ({{ rows.length }})
          </h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td v-for="col in columns" :key="col">{{ r[col] }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination Controls -->
          <div v-if="rows.length > 0" class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; border-top: 1px solid #dee2e6;">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
              </span>
            </div>
            <div class="pagination-controls" style="display: flex; gap: 0.5rem;">
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="goToPage(1)"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="prevPage"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span style="display: flex; align-items: center; padding: 0 1rem; font-weight: 500;">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="nextPage"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div class="municipal-card" v-else-if="searched && !error && !loading">
        <div class="municipal-card-body">
          <div class="alert-info">
            <font-awesome-icon icon="info-circle"/>
            <strong>No se encontraron diferencias con el criterio de búsqueda</strong>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_LISTA_DIFERENCIAS'

const { loading, execute } = useApi()

const filters = ref({ q: '' })
const rows = ref([])
const columns = ref([])
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

async function reload() {
  currentPage.value = 1 // Reset a la primera página al buscar
  error.value = null
  searched.value = false

  const params = [
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
  ]

  try {
    const response = await execute(OP_LIST, BASE_DB, params)
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
    columns.value = arr.length > 0 ? Object.keys(arr[0]) : []

  } catch (e) {
    searched.value = true
    error.value = e?.message || 'Error al realizar la búsqueda'
    rows.value = []
    columns.value = []
  }
}

// Cargar datos iniciales
onMounted(() => {
  reload()
})
</script>

<style scoped>
.form-text {
  color: #6c757d;
  font-size: 0.85rem;
  margin-top: 4px;
  display: block;
}

.table-container {
  overflow-x: auto;
}

.table-responsive {
  width: 100%;
  overflow-x: auto;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 0;
}

.municipal-table-header {
  background-color: #f8f9fa;
  border-bottom: 2px solid #dee2e6;
}

.municipal-table-header th {
  padding: 12px;
  text-align: left;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
}

.municipal-table tbody tr {
  border-bottom: 1px solid #dee2e6;
}

.row-hover:hover {
  background-color: #f8f9fa;
  cursor: pointer;
}

.municipal-table tbody td {
  padding: 12px;
  color: #212529;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  padding: 16px;
  color: #721c24;
}

.alert-danger svg {
  margin-right: 8px;
}

.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  border-radius: 8px;
  padding: 16px;
  color: #0c5460;
}

.alert-info svg {
  margin-right: 8px;
}
</style>
