<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="arrows-turn-right" />
      </div>
      <div class="module-view-info">
        <h1>Traslados Presupuestarios</h1>
        <p>Gestión de transferencias presupuestarias entre partidas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Búsqueda de Traslados</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group form-group-wide">
              <label class="municipal-form-label">Ejercicio / Dependencia / Partida</label>
              <input
                type="text"
                class="municipal-form-control municipal-form-control-wide"
                v-model="filters.filtro"
                placeholder="Ingrese ejercicio (año), dependencia o partida"
                @keyup.enter="reload"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading"
              @click="reload"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card" v-if="rows.length > 0 || hasSearched">
        <div class="municipal-card-header">
          <h5>Traslados Encontrados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" v-if="rows.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Ejercicio</th>
                  <th>Dependencia</th>
                  <th>Partida</th>
                  <th>Presupuesto Anual</th>
                  <th>Aplicación Auto</th>
                  <th>Trans. Aumento</th>
                  <th>Trans. Disminución</th>
                  <th>Ampliación Nueva</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td><strong>{{ r.ejercicio }}</strong></td>
                  <td><strong>{{ r.dependencia }}</strong></td>
                  <td>{{ r.partida }}</td>
                  <td class="text-right">{{ formatMoney(r.presup_anual) }}</td>
                  <td class="text-right">{{ formatMoney(r.apliacion_auto) }}</td>
                  <td class="text-right text-success">{{ formatMoney(r.trans_aumento) }}</td>
                  <td class="text-right text-danger">{{ formatMoney(r.trans_disminucion) }}</td>
                  <td class="text-right">{{ formatMoney(r.ampliacion_nva) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="empty-state">
            <font-awesome-icon icon="search" size="3x" />
            <p>No se encontraron traslados</p>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'trasladosfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Traslados Presupuestarios'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'trasladosfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Traslados Presupuestarios'"
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
const OP_LIST = 'RECAUDADORA_TRASLADOSFRM'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({
  filtro: ''
})

const rows = ref([])
const hasSearched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

// Formatear moneda
function formatMoney(value) {
  if (value === null || value === undefined) return '$0.00'
  const num = parseFloat(value)
  return '$' + num.toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}

async function reload() {
  hasSearched.value = true

  // IMPORTANTE: Usar formato español (nombre/tipo/valor)
  const params = [
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.filtro || '') }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_LIST, BASE_DB, params)
    console.log('Respuesta completa:', response)

    // Procesar la respuesta
    let arr = []
    if (response?.eResponse?.data?.result && Array.isArray(response.eResponse.data.result)) {
      arr = response.eResponse.data.result
    } else if (response?.data?.result && Array.isArray(response.data.result)) {
      arr = response.data.result
    } else if (response?.result && Array.isArray(response.result)) {
      arr = response.result
    } else if (response?.rows && Array.isArray(response.rows)) {
      arr = response.rows
    } else if (Array.isArray(response)) {
      arr = response
    }

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    currentPage.value = 1
  } catch (e) {
    console.error('Error al buscar traslados:', e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { filtro: '' }
  rows.value = []
  hasSearched.value = false
  currentPage.value = 1
}

// No cargar automáticamente, esperar a que el usuario haga clic en Buscar
// reload()
</script>

