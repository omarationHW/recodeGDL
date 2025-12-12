<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Listado Múltiple</h1>
        <p>Consulta general con filtros</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro</label>
              <input class="municipal-form-control" v-model="filters.q" @keyup.enter="reload" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload"><font-awesome-icon icon="search" /> Buscar</button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados ({{ totalRecords }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td v-for="col in columns" :key="col">{{ r[col] }}</td>
                </tr>
                <tr v-if="rows.length===0"><td :colspan="columns.length" class="text-center text-muted">Sin resultados</td></tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <div class="pagination-info">
              Mostrando {{ startRecord }} - {{ endRecord }} de {{ totalRecords }}
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="goToPage(1)"
              >
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-text">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)"
              >
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
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
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_LISTADO_MULTIPLE'
const OP_COUNT = 'RECAUDADORA_LISTADO_MULTIPLE_COUNT'
const SCHEMA = 'publico'

const { loading, execute } = useApi()

const filters = ref({ q: '' })
const rows = ref([])
const columns = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const totalRecords = ref(0)

const totalPages = computed(() => Math.ceil(totalRecords.value / pageSize.value))
const startRecord = computed(() => (currentPage.value - 1) * pageSize.value + 1)
const endRecord = computed(() => Math.min(currentPage.value * pageSize.value, totalRecords.value))

async function reload() {
  currentPage.value = 1
  await loadData()
}

async function loadData() {
  const offset = (currentPage.value - 1) * pageSize.value
  const params = [
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') },
    { nombre: 'p_offset', tipo: 'integer', valor: offset },
    { nombre: 'p_limit', tipo: 'integer', valor: pageSize.value }
  ]

  try {
    const response = await execute(OP_LIST, BASE_DB, params, '', null, SCHEMA)
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
    columns.value = arr.length ? Object.keys(arr[0]) : []

    // Obtener el total de registros
    await getCount()
  } catch (e) {
    rows.value = []
    columns.value = []
    totalRecords.value = 0
  }
}

async function getCount() {
  const params = [
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
  ]

  try {
    const response = await execute(OP_COUNT, BASE_DB, params, '', null, SCHEMA)
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
    totalRecords.value = arr.length > 0 ? (arr[0].total || 0) : 0
  } catch (e) {
    totalRecords.value = 0
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadData()
  }
}

reload()
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 8px;
}

.pagination-text {
  margin: 0 12px;
  color: #495057;
  font-weight: 500;
}

.btn-pagination {
  padding: 6px 12px;
  border: 1px solid #dee2e6;
  background-color: #fff;
  color: #495057;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #0d6efd;
  color: #fff;
  border-color: #0d6efd;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>

