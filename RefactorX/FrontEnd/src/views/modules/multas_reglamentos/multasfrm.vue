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

      <div class="municipal-card" v-else-if="rows.length === 0 && searched">
        <div class="municipal-card-body">
          <p class="text-center text-muted">No se encontraron resultados para la búsqueda.</p>
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

const { loading, execute } = useApi()
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

<style scoped>
.status-badge {
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 0.875rem;
  font-weight: 500;
}

.status-success {
  background-color: #d4edda;
  color: #155724;
}

.status-danger {
  background-color: #f8d7da;
  color: #721c24;
}

.status-warning {
  background-color: #fff3cd;
  color: #856404;
}

.status-secondary {
  background-color: #e2e3e5;
  color: #383d41;
}

.text-end {
  text-align: right;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.row-hover:hover {
  background-color: #f8f9fa;
}
</style>
