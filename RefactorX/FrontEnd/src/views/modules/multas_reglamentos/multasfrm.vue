<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Consulta General de Multas</h1>
        <p>Búsqueda por contribuyente, folio, domicilio o giro</p>
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
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Búsqueda General</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="reload"
                placeholder="Ingrese nombre, folio, domicilio o giro..."
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

      <div class="municipal-card" v-if="rows.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Folio</th>
                  <th>Año</th>
                  <th>Fecha</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Giro</th>
                  <th>Licencia</th>
                  <th>Total</th>
                  <th>Estatus</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_multa" class="row-hover">
                  <td><code>{{ r.id_multa }}</code></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.anio }}</td>
                  <td>{{ formatDate(r.fecha_acta) }}</td>
                  <td>{{ r.contribuyente }}</td>
                  <td>{{ r.domicilio }}</td>
                  <td>{{ r.giro }}</td>
                  <td>{{ r.licencia || 'N/A' }}</td>
                  <td class="text-end">{{ formatCurrency(r.total) }}</td>
                  <td>
                    <span
                      :class="getStatusClass(r.estatus)"
                      class="status-badge"
                    >
                      {{ r.estatus }}
                    </span>
                  </td>
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

      <div class="municipal-card" v-else-if="rows.length === 0 && searched">
        <div class="municipal-card-body">
          <p class="text-center text-muted">No se encontraron resultados para la búsqueda.</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'multasfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Consulta General de Multas'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'multasfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Consulta General de Multas'"
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
const OP = 'RECAUDADORA_MULTASFRM'
const SCHEMA = 'publico'

const filters = ref({ q: '' })
const rows = ref([])
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

async function reload() {
  try {
    showLoading('Consultando...', 'Por favor espere')
    currentPage.value = 1
    searched.value = true
    const data = await execute(OP, BASE_DB, [
      { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
    ], '', null, SCHEMA)
    const arr = Array.isArray(data?.result) ? data.result : Array.isArray(data) ? data : []
    rows.value = arr
  } catch (e) {
    rows.value = []
    console.error('Error al cargar datos:', e)
  } finally {
    hideLoading()
  }
}

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

function formatCurrency(v) {
  return Number(v || 0).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
}

function formatDate(d) {
  if (!d) return 'N/A'
  const date = new Date(d)
  return date.toLocaleDateString('es-MX')
}

function getStatusClass(status) {
  switch (status) {
    case 'PAGADA':
      return 'status-success'
    case 'CANCELADA':
      return 'status-danger'
    case 'PENDIENTE':
      return 'status-warning'
    default:
      return 'status-secondary'
  }
}
</script>

