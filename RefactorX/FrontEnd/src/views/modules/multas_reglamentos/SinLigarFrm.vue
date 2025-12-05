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
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_SINLIGARFRM'

const { loading, execute } = useApi()

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

<style scoped>
.form-row {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group-wide {
  width: 100%;
  max-width: 800px;
}

.municipal-form-label {
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #495057;
}

.municipal-form-control {
  padding: 0.5rem;
  border: 1px solid #ced4da;
  border-radius: 0.25rem;
  font-size: 1rem;
  transition: border-color 0.15s ease-in-out;
}

.municipal-form-control-wide {
  width: 100%;
  min-width: 400px;
}

.municipal-form-control:focus {
  outline: none;
  border-color: #80bdff;
  box-shadow: 0 0 0 0.2rem rgba(0, 123, 255, 0.25);
}

.button-group {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}

.btn-municipal-primary {
  padding: 0.5rem 1rem;
  border: 1px solid #007bff;
  border-radius: 0.25rem;
  background-color: #007bff;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-primary:hover:not(:disabled) {
  background-color: #0056b3;
  border-color: #0056b3;
}

.btn-municipal-primary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.btn-municipal-secondary {
  padding: 0.5rem 1rem;
  border: 1px solid #6c757d;
  border-radius: 0.25rem;
  background-color: #6c757d;
  color: #fff;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background-color: #5a6268;
  border-color: #545b62;
}

.btn-municipal-secondary:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.badge {
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 500;
}

.badge-info {
  background-color: #17a2b8;
  color: #fff;
}

.empty-state {
  text-align: center;
  padding: 3rem;
  color: #6c757d;
}

.empty-state svg {
  color: #dee2e6;
  margin-bottom: 1rem;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding: 15px;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 14px;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 15px;
}

.pagination-page {
  color: #495057;
  font-weight: 500;
}

.btn-pagination {
  padding: 8px 16px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: #fff;
  color: #495057;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .button-group {
    flex-direction: column;
  }

  .municipal-form-control-wide {
    min-width: 100%;
  }

  .form-group-wide {
    max-width: 100%;
  }
}
</style>
