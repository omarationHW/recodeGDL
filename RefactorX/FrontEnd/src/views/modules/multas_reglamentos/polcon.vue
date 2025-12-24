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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'polcon'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Póliza Diaria Consolidada'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'polcon'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Póliza Diaria Consolidada'"
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
const OP_GET = 'RECAUDADORA_POLCON'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

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
    showLoading('Consultando...', 'Por favor espere')
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
    console.error('Error al consultar pólizas:', e)
    allRows.value = []
    searched.value = true
  } finally {
    hideLoading()
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

