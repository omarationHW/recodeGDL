<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Avance</h1>
        <p>Consulta de avance por rango de fechas</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>📅 Parámetros</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Desde *</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="filters.desde"
                :max="filters.hasta || undefined"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Hasta *</label>
              <input
                class="municipal-form-control"
                type="date"
                v-model="filters.hasta"
                :min="filters.desde || undefined"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.desde || !filters.hasta"
              @click="generar"
            >
              <font-awesome-icon icon="chart-line" v-if="!loading" />
              <span v-if="loading">Generando...</span>
              <span v-else>Generar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>

          <div class="help-text">
            <small>* Campos requeridos. Seleccione el rango de fechas para el reporte.</small>
          </div>
        </div>
      </div>

      <!-- Mensaje de éxito -->
      <div class="municipal-card" v-if="success">
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <strong>✅ Éxito:</strong> {{ success }}
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>❌ Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="rows.length > 0">
        <div class="municipal-card-header">
          <h5>📊 Resultados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in cols" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx">
                  <td v-for="col in cols" :key="col">{{ row[col] }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <button
              class="btn-pagination"
              @click="currentPage = 1"
              :disabled="currentPage === 1"
            >
              Primera
            </button>
            <button
              class="btn-pagination"
              @click="currentPage--"
              :disabled="currentPage === 1"
            >
              Anterior
            </button>
            <span class="pagination-info">
              Página {{ currentPage }} de {{ totalPages }}
            </span>
            <button
              class="btn-pagination"
              @click="currentPage++"
              :disabled="currentPage === totalPages"
            >
              Siguiente
            </button>
            <button
              class="btn-pagination"
              @click="currentPage = totalPages"
              :disabled="currentPage === totalPages"
            >
              Última
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay resultados -->
      <div class="municipal-card" v-if="searched && rows.length === 0">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <strong>ℹ️ Info:</strong> No se encontraron resultados para el rango de fechas seleccionado.
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, error: apiError, execute } = useApi()

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REPAVANCE'

const filters = ref({
  desde: '',
  hasta: ''
})

const rows = ref([])
const cols = ref([])
const success = ref('')
const error = ref('')
const searched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage)
})

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return rows.value.slice(start, end)
})

async function generar() {
  error.value = ''
  success.value = ''
  searched.value = false

  if (!filters.value.desde || !filters.value.hasta) {
    error.value = 'Por favor seleccione ambas fechas (Desde y Hasta)'
    return
  }

  try {
    const params = [
      { nombre: 'p_desde', valor: String(filters.value.desde || ''), tipo: 'date' },
      { nombre: 'p_hasta', valor: String(filters.value.hasta || ''), tipo: 'date' }
    ]

    console.log('Ejecutando:', OP, 'con parámetros:', params)

    const data = await execute(OP, BASE_DB, params)

    console.log('Respuesta del servidor:', data)

    // Extraer el array de resultados de la respuesta
    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
        ? data.rows
        : Array.isArray(data)
          ? data
          : []

    rows.value = arr
    cols.value = arr.length > 0 ? Object.keys(arr[0]) : []
    currentPage.value = 1
    searched.value = true

    if (arr.length > 0) {
      success.value = `Se encontraron ${arr.length} registros`
    }
  } catch (e) {
    console.error('Error al generar reporte:', e)
    error.value = apiError.value || e.message || 'Error al ejecutar el reporte'
    rows.value = []
    cols.value = []
    searched.value = true
  }
}

function limpiar() {
  filters.value = {
    desde: '',
    hasta: ''
  }
  rows.value = []
  cols.value = []
  success.value = ''
  error.value = ''
  searched.value = false
  currentPage.value = 1
}
</script>

<style scoped>
.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.municipal-form-label {
  font-weight: 600;
  color: #2c3e50;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
}

.municipal-form-control {
  padding: 0.5rem;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 0.9rem;
  transition: border-color 0.2s;
}

.municipal-form-control:focus {
  outline: none;
  border-color: #ea8215;
  box-shadow: 0 0 0 2px rgba(234, 130, 21, 0.1);
}

.button-group {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.btn-municipal-primary,
.btn-municipal-secondary {
  padding: 0.6rem 1.5rem;
  border: none;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-municipal-primary {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.btn-municipal-primary:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(234, 130, 21, 0.3);
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
}

.btn-municipal-primary:disabled,
.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.help-text {
  color: #6c757d;
  font-size: 0.85rem;
}

.alert {
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  color: #721c24;
}

.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  color: #0c5460;
}

.table-responsive {
  overflow-x: auto;
  margin-bottom: 1rem;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.municipal-table-header {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.municipal-table th,
.municipal-table td {
  padding: 0.75rem;
  text-align: left;
  border-bottom: 1px solid #dee2e6;
}

.municipal-table tbody tr:hover {
  background-color: #f8f9fa;
}

.pagination-container {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 0.5rem;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #dee2e6;
}

.btn-pagination {
  padding: 0.4rem 0.8rem;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.2s;
  font-size: 0.85rem;
}

.btn-pagination:hover:not(:disabled) {
  background: #ea8215;
  color: white;
  border-color: #ea8215;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.pagination-info {
  padding: 0 1rem;
  font-weight: 500;
  color: #495057;
}
</style>
