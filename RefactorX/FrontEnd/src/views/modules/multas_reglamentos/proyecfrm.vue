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
        </div>

        <div class="municipal-card-body table-container">

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
          <div class="pagination-controls mt-3" v-if="!loading && totalPages > 1">
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'proyecfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Proyecto'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'proyecfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Proyecto'"
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
const OP_LIST = 'RECAUDADORA_PROYECFRM'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

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
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP_LIST, BASE_DB, params, '', null, SCHEMA)
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
  } finally {
    hideLoading()
  }
}

reload()
</script>

