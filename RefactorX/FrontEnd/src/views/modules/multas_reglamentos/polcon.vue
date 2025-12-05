<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="shield" />
      </div>
      <div class="module-view-info">
        <h1>Póliza Diaria Consolidada</h1>
        <p>Reporte de pólizas de las recaudadoras agrupado por cuenta de aplicación</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fecha_desde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filters.fecha_hasta"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="consultar">
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Generando reporte...</span>
              <span v-else>Generar Reporte</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="allRows.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados - {{ allRows.length }} registros encontrados</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta de Aplicación</th>
                  <th>Concepto</th>
                  <th class="text-right">Total Partidas</th>
                  <th class="text-right">Suma</th>
                  <th class="text-center">Movimientos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td class="font-weight-bold">{{ row.cvectaapl }}</td>
                  <td>{{ row.ctaaplicacion || 'Sin concepto' }}</td>
                  <td class="text-right">{{ formatNumber(row.totpar) }}</td>
                  <td class="text-right">${{ formatMoney(row.suma) }}</td>
                  <td class="text-center">{{ formatNumber(row.num_movimientos) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="2" class="font-weight-bold">TOTALES</td>
                  <td class="text-right font-weight-bold">{{ formatNumber(totalPartidas) }}</td>
                  <td class="text-right font-weight-bold">${{ formatMoney(totalSuma) }}</td>
                  <td class="text-center font-weight-bold">{{ formatNumber(totalMovimientos) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
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
            No se encontraron pólizas para el rango de fechas seleccionado
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_GET = 'RECAUDADORA_POLCON'
const { loading, execute } = useApi()

// Inicializar con el año 2012 que tiene datos
const filters = ref({
  fecha_desde: '2012-01-01',
  fecha_hasta: '2012-12-31'
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

// Totales computed
const totalPartidas = computed(() => {
  return allRows.value.reduce((sum, row) => sum + Number(row.totpar || 0), 0)
})

const totalSuma = computed(() => {
  return allRows.value.reduce((sum, row) => sum + Number(row.suma || 0), 0)
})

const totalMovimientos = computed(() => {
  return allRows.value.reduce((sum, row) => sum + Number(row.num_movimientos || 0), 0)
})

async function consultar() {
  searched.value = false
  currentPage.value = 1
  allRows.value = []

  const params = [
    { nombre: 'p_fecha_desde', tipo: 'date', valor: filters.value.fecha_desde || null },
    { nombre: 'p_fecha_hasta', tipo: 'date', valor: filters.value.fecha_hasta || null }
  ]

  try {
    const data = await execute(OP_GET, BASE_DB, params)

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
    console.error('Error al consultar pólizas:', e)
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

function formatNumber(value) {
  if (!value) return '0'
  return Number(value).toLocaleString('es-MX')
}

// Cargar datos al iniciar con fechas por defecto
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

/* Footer de tabla */
.municipal-table-footer tr {
  background-color: #f8f9fa;
  font-weight: 600;
  border-top: 2px solid #dee2e6;
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
