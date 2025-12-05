<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="diagram-project" />
      </div>
      <div class="module-view-info">
        <h1>Proyecto</h1>
        <p>Gestión de proyectos</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro de Búsqueda</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="reload"
                placeholder="Buscar..."
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="reload"
            >
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados ({{ totalRecords }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de carga -->
          <div v-if="loading" class="alert alert-info">
            Cargando datos...
          </div>

          <!-- Tabla de datos -->
          <div v-if="!loading && rows.length > 0" class="table-responsive">
            <table class="municipal-table" style="width: 100%; border: 1px solid #ddd;">
              <thead class="municipal-table-header" style="background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);">
                <tr>
                  <th v-for="col in columns" :key="col" style="padding: 10px; border: 1px solid #ddd; color: white; font-weight: bold;">
                    {{ formatColumnName(col) }}
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover" style="border-bottom: 1px solid #ddd;">
                  <td v-for="col in columns" :key="col" style="padding: 8px; border: 1px solid #ddd;">
                    {{ r[col] }}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Mensaje sin resultados -->
          <div v-if="!loading && rows.length === 0" class="alert alert-warning">
            No se encontraron resultados. Intenta con otro filtro o deja el campo vacío.
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="!loading && totalPages > 1" style="margin-top: 20px;">
            <div class="pagination-info">
              Mostrando {{ startRecord }} - {{ endRecord }} de {{ totalRecords }}
            </div>
            <div class="pagination-controls">
              <button class="btn-pagination" @click="goToPage(1)" :disabled="currentPage === 1">
                Primera
              </button>
              <button class="btn-pagination" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1">
                Anterior
              </button>
              <span class="pagination-pages">
                <button
                  v-for="page in visiblePages"
                  :key="page"
                  class="btn-pagination"
                  :class="{ active: page === currentPage }"
                  @click="goToPage(page)"
                >
                  {{ page }}
                </button>
              </span>
              <button class="btn-pagination" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages">
                Siguiente
              </button>
              <button class="btn-pagination" @click="goToPage(totalPages)" :disabled="currentPage === totalPages">
                Última
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_PROYECFRM'
const { loading, execute } = useApi()

const filters = ref({ q: '' })
const rows = ref([])
const columns = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Computed properties para paginación
const totalRecords = computed(() => rows.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage))
const startRecord = computed(() => {
  if (rows.value.length === 0) return 0
  return (currentPage.value - 1) * itemsPerPage + 1
})
const endRecord = computed(() => {
  const end = currentPage.value * itemsPerPage
  return end > totalRecords.value ? totalRecords.value : end
})

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return rows.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Funciones
function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function formatColumnName(col) {
  // Convertir nombres de columnas a formato legible
  return col.charAt(0).toUpperCase() + col.slice(1).replace(/_/g, ' ')
}

async function reload() {
  currentPage.value = 1

  // Parámetros en el formato correcto para el SP
  const params = {
    p_filtro: String(filters.value.q || '')
  }

  console.log('🔍 Ejecutando SP:', OP_LIST)
  console.log('🔍 Base de datos:', BASE_DB)
  console.log('🔍 Parámetros:', params)

  try {
    const data = await execute(OP_LIST, BASE_DB, params)
    console.log('✅ Datos recibidos completos:', data)

    // Los datos vienen en data.result como array
    let arr = []

    if (data && data.result && Array.isArray(data.result)) {
      // Estructura: { result: [...], count: X }
      arr = data.result
    } else if (Array.isArray(data)) {
      // Estructura: [...]
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      // Estructura: { rows: [...] }
      arr = data.rows
    }

    rows.value = arr

    // Obtener todas las columnas y omitir la primera
    const allColumns = arr.length ? Object.keys(arr[0]) : []
    columns.value = allColumns.length > 1 ? allColumns.slice(1) : allColumns

    console.log('📊 Registros cargados:', arr.length)
    console.log('📋 Columnas mostradas:', columns.value)

  } catch (e) {
    rows.value = []
    columns.value = []
    console.error('❌ Error cargando datos:', e)
    alert('Error cargando datos: ' + e.message)
  }
}

reload()
</script>

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
}

.municipal-card-body {
  padding: 20px;
}

.table-container {
  min-height: 200px;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table-header {
  background: #f5f5f5;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-info {
  background-color: #e3f2fd;
  border: 1px solid #90caf9;
  color: #1976d2;
}

.alert-warning {
  background-color: #fff3cd;
  border: 1px solid #ffc107;
  color: #856404;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding: 1rem;
  border-top: 1px solid #ddd;
}

.pagination-info {
  font-size: 0.9rem;
  color: #666;
}

.pagination-controls {
  display: flex;
  gap: 0.25rem;
  align-items: center;
}

.pagination-pages {
  display: flex;
  gap: 0.25rem;
  margin: 0 0.5rem;
}

.btn-pagination {
  padding: 0.4rem 0.8rem;
  border: 1px solid #ddd;
  background: white;
  cursor: pointer;
  border-radius: 4px;
  transition: all 0.2s;
  font-size: 0.9rem;
}

.btn-pagination:hover:not(:disabled) {
  background: #f5f5f5;
  border-color: #999;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-pagination.active {
  background: #0066cc;
  color: white;
  border-color: #0066cc;
}
</style>
