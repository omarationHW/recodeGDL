<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file" />
      </div>
      <div class="module-view-info">
        <h1>Presupuesto Devengado</h1>
        <p>Consulta de presupuesto devengado de ingresos por ejercicio</p>
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
              <label class="municipal-form-label">Buscar por Ejercicio (Año)</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="reload"
                placeholder="Ej: 2014, 2013, 2012..."
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Consultando...</span>
              <span v-else>Buscar</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Card de resultados -->
      <div class="municipal-card" v-if="allRows.length > 0">
        <div class="municipal-card-header">
          <h5>Presupuesto Devengado - {{ allRows.length }} registro(s)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Ejercicio</th>
                  <th>Título</th>
                  <th>Capítulo</th>
                  <th>Cta Aplicación</th>
                  <th>Fecha Ingreso</th>
                  <th class="text-right">Presup. Anual</th>
                  <th class="text-right">Ingreso Total</th>
                  <th class="text-right">Enero</th>
                  <th class="text-right">Febrero</th>
                  <th class="text-right">Marzo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td class="font-weight-bold">{{ row.ejercicio }}</td>
                  <td>{{ row.titulo }}</td>
                  <td>{{ row.capitulo }}</td>
                  <td>{{ row.cta_aplicacion }}</td>
                  <td>{{ formatDate(row.fecha_ingreso) }}</td>
                  <td class="text-right">${{ formatMoney(row.presup_anual) }}</td>
                  <td class="text-right font-weight-bold">${{ formatMoney(row.ingreso_total) }}</td>
                  <td class="text-right">${{ formatMoney(row.enero) }}</td>
                  <td class="text-right">${{ formatMoney(row.febrero) }}</td>
                  <td class="text-right">${{ formatMoney(row.marzo) }}</td>
                </tr>
              </tbody>
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
            No se encontraron registros
          </p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'pres'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Presupuesto Devengado'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'pres'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Presupuesto Devengado'"
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
const OP_GET = 'RECAUDADORA_PRES'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ q: '2014' }) // Valor por defecto
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
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
  ]

  try {
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP_GET, BASE_DB, params, '', null, SCHEMA)

    // Extraer los datos de la respuesta
    let arr = []
    if (data?.result) {
      arr = data.result
    } else if (data?.rows) {
      arr = data.rows
    } else if (Array.isArray(data)) {
      arr = data
    }

    allRows.value = arr
    searched.value = true
  } catch (e) {
    console.error('Error al consultar presupuesto:', e)
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

function formatDate(value) {
  if (!value) return ''
  const date = new Date(value)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// Cargar datos al iniciar con año 2014
reload()
</script>

