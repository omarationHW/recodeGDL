<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar" />
      </div>
      <div class="module-view-info">
        <h1>Período Inicial</h1>
        <p>Consulta de parámetros del sistema por ejercicio</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio (Año)</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                @keyup.enter="consultar"
                placeholder="Ej: 2024"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="consultar">
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Consultando...</span>
              <span v-else>Consultar</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="allRows.length > 0">
        <div class="municipal-card-header">
          <h5>Parámetros del Sistema</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Municipio</th>
                  <th>Ejercicio</th>
                  <th>Período Inicial</th>
                  <th>Período Final</th>
                  <th>Director</th>
                  <th>Tesorero</th>
                  <th>Presidente</th>
                  <th>Salario Mínimo</th>
                  <th>Aplica Desc/Rec</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td class="font-weight-bold">{{ row.municipio }}</td>
                  <td class="text-center">{{ row.ejercicio }}</td>
                  <td>Bim {{ row.bimestre_inicial }}/{{ row.año_inicial }}</td>
                  <td>Bim {{ row.bimestre_final }}/{{ row.año_final }}</td>
                  <td>{{ row.director }}</td>
                  <td>{{ row.tesorero }}</td>
                  <td>{{ row.presidente }}</td>
                  <td class="text-right">${{ formatMoney(row.salario) }}</td>
                  <td class="text-center">
                    <span class="badge" :class="row.aplica_descuento_recargo === 'S' ? 'badge-success' : 'badge-secondary'">
                      {{ row.aplica_descuento_recargo === 'S' ? 'Sí' : 'No' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación (aunque sea solo 1 registro, por consistencia) -->
          <div class="pagination-container" v-if="totalPages > 1">
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
            No se encontraron parámetros para el ejercicio {{ filters.ejercicio }}
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
const OP_GET = 'RECAUDADORA_PERIODO_INICIAL'
const SCHEMA = 'publico'
const { loading, execute } = useApi()

const filters = ref({ ejercicio: new Date().getFullYear() })
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

async function consultar() {
  searched.value = false
  currentPage.value = 1
  allRows.value = []

  const params = [
    { nombre: 'p_ejercicio', tipo: 'integer', valor: filters.value.ejercicio || null }
  ]

  try {
    const data = await execute(OP_GET, BASE_DB, params, '', null, SCHEMA)

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
    console.error('Error al consultar período inicial:', e)
    allRows.value = []
    searched.value = true
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

function formatMoney(value) {
  if (!value) return '0.00'
  return Number(value).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

// Cargar datos al iniciar
consultar()
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

/* Badges */
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
