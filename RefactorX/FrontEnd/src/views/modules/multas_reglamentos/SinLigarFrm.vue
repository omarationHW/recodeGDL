<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="unlink" />
      </div>
      <div class="module-view-info">
        <h1>Sin Ligar</h1>
        <p>Control de ligaduras de pagos</p>
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
          <h5>Búsqueda de Ligaduras</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group form-group-wide">
              <label class="municipal-form-label">Filtro</label>
              <input
                type="text"
                class="municipal-form-control municipal-form-control-wide"
                v-model="filters.q"
                placeholder="Clave de pago, cuenta, usuario, tipo..."
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
          <h5>Ligaduras de Pagos ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive" v-if="rows.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Control</th>
                  <th>Clave Pago</th>
                  <th>Clave Cuenta</th>
                  <th>Usuario</th>
                  <th>Fecha</th>
                  <th>Tipo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="r.id_control" class="row-hover">
                  <td><strong>{{ r.id_control }}</strong></td>
                  <td>{{ r.cvepago }}</td>
                  <td>{{ r.cvecta }}</td>
                  <td>{{ r.usuario }}</td>
                  <td>{{ formatDate(r.fecha_act) }}</td>
                  <td><span class="badge badge-info">{{ r.tipo }}</span></td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="empty-state">
            <font-awesome-icon icon="search" size="3x" />
            <p>No se encontraron ligaduras</p>
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
      :component-name="'SinLigarFrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Sin Ligar'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'SinLigarFrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Sin Ligar'"
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
const OP_LIST = 'RECAUDADORA_SINLIGARFRM'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({
  q: ''
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

// Formatear fecha
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

async function reload() {
  hasSearched.value = true

  // IMPORTANTE: Usar formato español (nombre/tipo/valor)
  const params = [
    { nombre: 'p_filtro', tipo: 'string', valor: String(filters.value.q || '') }
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
    console.error('Error al buscar ligaduras:', e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { q: '' }
  rows.value = []
  hasSearched.value = false
  currentPage.value = 1
}

// No cargar automáticamente, esperar a que el usuario haga clic en Buscar
// reload()
</script>

