<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-bill-wave" />
      </div>
      <div class="module-view-info">
        <h1>Pagos Especiales</h1>
        <p>Consulta de autorizaciones de pagos especiales</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="reload"
                placeholder="Ingrese número de cuenta"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                @keyup.enter="reload"
                placeholder="Ej: 2005"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="allRows.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados ({{ allRows.length }} registros encontrados)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>CVE Aut</th>
                  <th>Cuenta</th>
                  <th>Período Inicio</th>
                  <th>Período Fin</th>
                  <th>Fecha Autorización</th>
                  <th>Autorizado Por</th>
                  <th>CVE Pago</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td>{{ row.cveaut }}</td>
                  <td class="font-weight-bold">{{ row.cvecuenta }}</td>
                  <td>{{ formatPeriodo(row.bimestre_inicio, row.año_inicio) }}</td>
                  <td>{{ formatPeriodo(row.bimestre_fin, row.año_fin) }}</td>
                  <td>{{ formatDate(row.fecha_autorizacion) }}</td>
                  <td>{{ row.autorizado_por }}</td>
                  <td class="text-right">{{ row.cve_pago || '-' }}</td>
                  <td>
                    <span class="badge" :class="getBadgeClass(row.estado)">
                      {{ row.estado }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ allRows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="pagination-button"
                :disabled="currentPage === 1"
                @click="goToPage(currentPage - 1)"
              >
                <font-awesome-icon icon="chevron-left" />
                Anterior
              </button>
              <div class="pagination-pages">
                <button
                  v-for="page in visiblePages"
                  :key="page"
                  class="pagination-button"
                  :class="{ active: page === currentPage }"
                  @click="goToPage(page)"
                >
                  {{ page }}
                </button>
              </div>
              <button
                class="pagination-button"
                :disabled="currentPage === totalPages"
                @click="goToPage(currentPage + 1)"
              >
                Siguiente
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje sin resultados -->
      <div class="municipal-card" v-else-if="searched && allRows.length === 0">
        <div class="municipal-card-body">
          <p class="text-center text-muted">
            <font-awesome-icon icon="search" size="3x" class="mb-3" />
            <br />
            No se encontraron pagos especiales con los criterios de búsqueda
          </p>
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
const OP_LIST = 'RECAUDADORA_PAGOS_ESPE'
const { loading, execute } = useApi()

const filters = ref({
  cuenta: '',
  ejercicio: new Date().getFullYear()
})

const allRows = ref([])
const searched = ref(false)
const currentPage = ref(1)
const pageSize = 10

// Paginación computed
const totalPages = computed(() => Math.ceil(allRows.value.length / pageSize))

const startIndex = computed(() => (currentPage.value - 1) * pageSize)
const endIndex = computed(() => Math.min(currentPage.value * pageSize, allRows.value.length))

const paginatedRows = computed(() => {
  return allRows.value.slice(startIndex.value, endIndex.value)
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

async function reload() {
  searched.value = false
  currentPage.value = 1
  allRows.value = []

  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'integer', valor: filters.value.ejercicio || null }
  ]

  try {
    const data = await execute(OP_LIST, BASE_DB, params)

    // Extraer los datos de la respuesta
    let rows = []
    if (data?.result) {
      rows = data.result
    } else if (data?.rows) {
      rows = data.rows
    } else if (Array.isArray(data)) {
      rows = data
    }

    allRows.value = rows
    searched.value = true
  } catch (e) {
    console.error('Error al buscar pagos especiales:', e)
    allRows.value = []
    searched.value = true
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function formatDate(dateStr) {
  if (!dateStr) return 'N/A'
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

function formatPeriodo(bimestre, año) {
  if (!bimestre || !año) return 'N/A'
  return `Bim ${bimestre}/${año}`
}

function getBadgeClass(estado) {
  const badges = {
    'PENDIENTE': 'badge-warning',
    'PAGADO': 'badge-success',
    'CANCELADO': 'badge-danger'
  }
  return badges[estado] || 'badge-secondary'
}

// Cargar datos al iniciar
reload()
</script>

<style scoped>
.text-center {
  text-align: center;
}

.text-right {
  text-align: right;
}

.text-muted {
  color: #6c757d;
}

.font-weight-bold {
  font-weight: 600;
}

.mb-3 {
  margin-bottom: 1rem;
}

/* Badges para estados */
.badge {
  display: inline-block;
  padding: 0.25em 0.6em;
  font-size: 0.875em;
  font-weight: 600;
  line-height: 1;
  color: #fff;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0.25rem;
}

.badge-success {
  background-color: #28a745;
}

.badge-warning {
  background-color: #ffc107;
  color: #212529;
}

.badge-danger {
  background-color: #dc3545;
}

.badge-secondary {
  background-color: #6c757d;
}

/* Paginación */
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 0.875rem;
}

.pagination-controls {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

.pagination-pages {
  display: flex;
  gap: 0.25rem;
}

.pagination-button {
  padding: 0.375rem 0.75rem;
  border: 1px solid #dee2e6;
  background-color: #fff;
  color: #007bff;
  cursor: pointer;
  border-radius: 0.25rem;
  transition: all 0.2s;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.pagination-button:hover:not(:disabled) {
  background-color: #e9ecef;
  border-color: #007bff;
}

.pagination-button:disabled {
  cursor: not-allowed;
  opacity: 0.5;
  color: #6c757d;
}

.pagination-button.active {
  background-color: #007bff;
  color: #fff;
  border-color: #007bff;
}

.table-responsive {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
}

.row-hover:hover {
  background-color: #f8f9fa;
  cursor: pointer;
}

/* Responsive para móviles */
@media (max-width: 768px) {
  .pagination-container {
    flex-direction: column;
    gap: 1rem;
  }

  .pagination-controls {
    flex-direction: column;
    width: 100%;
  }

  .pagination-pages {
    justify-content: center;
  }

  .municipal-table {
    font-size: 0.875rem;
  }

  .municipal-table th,
  .municipal-table td {
    padding: 0.5rem;
  }
}
</style>

