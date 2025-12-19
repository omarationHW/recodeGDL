<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="badge-percent" />
      </div>
      <div class="module-view-info">
        <h1>Requerimiento Promoción</h1>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          

          <!-- Búsqueda General -->
          <div class="search-section">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Cuenta / ID Descuento</label>
                <input
                  class="municipal-form-control"
                  v-model="filters.cuenta"
                  placeholder="Ingrese ID de descuento"
                  @keyup.enter="buscarGeneral"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Año</label>
                <input
                  class="municipal-form-control"
                  type="number"
                  v-model.number="filters.ejercicio"
                  placeholder="Año (opcional)"
                  @keyup.enter="buscarGeneral"
                />
              </div>
            </div>
            <div class="button-group">
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

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()
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

    const data = await execute('RECAUDADORA_REQ_PROMOCION', BASE_DB, [
      {
        nombre: 'p_clave_cuenta',
        tipo: 'string',
        valor: String(filters.value.cuenta || '')
      },
      {
        nombre: 'p_ejercicio',
        tipo: 'integer',
        valor: filters.value.ejercicio || null
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
    cvedescuento: 'ID Descuento',
    descripcion: 'Descripción',
    importe: 'Importe'
  }
  return columnNames[col] || col.toUpperCase()
}

function formatValue(value, column) {
  if (value === null || value === undefined || value === '') return '-'

  // Formato de importe
  if (column === 'importe' && !isNaN(value)) {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  }

  return value
}
</script>

<style scoped>








.search-section {
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e0e0e0;
}

.section-title {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 1rem;
  color: #333;
}

.form-row {
  display: flex;
  gap: 1rem;
  align-items: flex-end;
  flex-wrap: wrap;
}

.form-group {
  flex: 1;
  min-width: 200px;
}

.button-group {
  display: flex;
  gap: 0.5rem;
  margin-top: 1rem;
}

.btn-municipal-secondary {
  background-color: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.95rem;
  transition: background-color 0.2s;
  white-space: nowrap;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background-color: #5a6268;
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading-message {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 2rem;
  background: #f8f9fa;
  border-radius: 8px;
  margin-top: 1rem;
}

.spinner {
  width: 24px;
  height: 24px;
  border: 3px solid #e0e0e0;
  border-top-color: #007bff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to {
    transform: rotate(360deg);
  }
}

.results-header {
  margin-bottom: 1rem;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #007bff;
}

.results-header h3 {
  font-size: 1.1rem;
  color: #333;
  margin: 0;
}

.table-responsive {
  overflow-x: auto;
  margin-bottom: 1rem;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: #f8f9fa;
  border-radius: 4px;
  flex-wrap: wrap;
  gap: 1rem;
}

.pagination-info {
  font-size: 0.9rem;
  color: #666;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.btn-pagination {
  background-color: #007bff;
  color: white;
  border: none;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: background-color 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #0056b3;
}

.btn-pagination:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.page-info {
  font-size: 0.9rem;
  color: #333;
  font-weight: 500;
}

.no-results {
  text-align: center;
  padding: 3rem;
  background: #f8f9fa;
  border-radius: 8px;
  margin-top: 1rem;
}

.no-results p {
  font-size: 1rem;
  color: #666;
  margin: 0;
}

.municipal-table {
  width: 100%;
  font-size: 0.9rem;
}

.municipal-table td {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  max-width: 200px;
}
</style>
