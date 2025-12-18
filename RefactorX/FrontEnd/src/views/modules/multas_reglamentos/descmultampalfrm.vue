<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percent" /></div>
      <div class="module-view-info">
        <h1>Descuentos Multa Municipal</h1>
        <p>Consulta y gestión de descuentos aplicados a multas municipales por ID de multa</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Multa</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="filters.cuenta.trim() && reload()"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta.trim()"
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

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Descuentos ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Multa</th>
                  <th>Tipo Desc.</th>
                  <th>Valor</th>
                  <th>Cve. Pago</th>
                  <th>Fecha Desc.</th>
                  <th>Capturista</th>
                  <th>Autoriza</th>
                  <th>Estado</th>
                  <th>Folio</th>
                  <th>Observación</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td><code>{{ r.id_multa }}</code></td>
                  <td>{{ r.tipo_descto }}</td>
                  <td>{{ r.valor_descuento }}{{ r.tipo_descto === 'Porcentaje' ? '%' : '' }}</td>
                  <td>{{ r.cvepago }}</td>
                  <td>{{ r.fecha_descuento }}</td>
                  <td>{{ r.capturista }}</td>
                  <td>{{ r.autoriza }}</td>
                  <td><span :class="'badge badge-' + (r.estado_desc === 'Vigente' ? 'success' : r.estado_desc === 'Pagado' ? 'info' : 'secondary')">{{ r.estado_desc }}</span></td>
                  <td>{{ r.folio }}</td>
                  <td>{{ r.observacion }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="10" class="text-center text-muted">Sin registros</td>
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
const OP_LIST = 'RECAUDADORA_DESCMULTAMPALFRM'

const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])
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

async function reload() {
  currentPage.value = 1 // Reset a la primera página al buscar
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
  ]
  try {
    const response = await execute(OP_LIST, BASE_DB, params, '', null, 'publico')
    console.log('Respuesta completa:', response)

    // Extraer datos con fallbacks
    const responseData = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(responseData?.result) ? responseData.result :
                 Array.isArray(responseData?.rows) ? responseData.rows :
                 Array.isArray(responseData) ? responseData : []

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
  } catch (e) {
    console.error('Error al consultar descuentos:', e)
    rows.value = []
  }
}

function limpiar() {
  filters.value = { cuenta: '' }
  rows.value = []
  currentPage.value = 1
}
</script>
