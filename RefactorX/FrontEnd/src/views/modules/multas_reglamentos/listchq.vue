<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="money-check" />
      </div>
      <div class="module-view-info">
        <h1>Listado de Cheques</h1>
        <p>Búsqueda y consulta de cheques registrados</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Buscar</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="buscar"
                placeholder="Buscar por cheque, banco, cuenta, folio..."
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="buscar"
            >
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
          <h5>Resultados ({{ allRows.length }} cheques encontrados)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th>Banco</th>
                  <th>Cheque</th>
                  <th>Cuenta</th>
                  <th>Importe</th>
                  <th>Tipo Pago</th>
                  <th>Folio</th>
                  <th>Rec</th>
                  <th>Caja</th>
                  <th>Operación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td>{{ formatDate(row.fecha) }}</td>
                  <td>{{ row.banco }}</td>
                  <td class="text-right">{{ row.cheque }}</td>
                  <td>{{ row.cuenta }}</td>
                  <td class="text-right font-weight-bold">{{ formatMoney(row.importe) }}</td>
                  <td>
                    <span class="badge" :class="getBadgeClass(row.tipo_pag)">
                      {{ row.tipo_pag }}
                    </span>
                  </td>
                  <td class="text-mono">{{ row.folio_completo }}</td>
                  <td class="text-center">{{ row.id_rec }}</td>
                  <td class="text-center">{{ row.caja }}</td>
                  <td class="text-right">{{ row.operacion }}</td>
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
            No se encontraron cheques con los criterios de búsqueda
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

const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_LISTCHQ'

const filters = ref({ q: '' })
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

async function buscar() {
  searched.value = false
  currentPage.value = 1
  allRows.value = []

  try {
    const data = await execute(OP, BASE_DB, [
      { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
    ])

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
    console.error('Error al buscar cheques:', e)
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

function formatMoney(value) {
  if (!value) return '$0.00'
  return Number(value).toLocaleString('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

function getBadgeClass(tipo) {
  const badges = {
    'Efectivo': 'badge-success',
    'Cheque': 'badge-primary',
    'Tarjeta': 'badge-info',
    'Transferencia': 'badge-warning'
  }
  return badges[tipo] || 'badge-secondary'
}

// Cargar datos al iniciar
buscar()
</script>

<style scoped>
.text-right {
  text-align: right;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.text-mono {
  font-family: 'Courier New', monospace;
  font-size: 0.9em;
}

.font-weight-bold {
  font-weight: 600;
}

.mb-3 {
  margin-bottom: 1rem;
}

/* Badges para tipos de pago */
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

.badge-primary {
  background-color: #007bff;
}

.badge-info {
  background-color: #17a2b8;
}

.badge-warning {
  background-color: #ffc107;
  color: #212529;
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
