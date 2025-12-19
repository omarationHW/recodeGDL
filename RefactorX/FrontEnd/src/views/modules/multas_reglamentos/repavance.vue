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
          <!-- Botones de reporte -->
          <div class="report-actions">
            <button class="btn-report btn-preview" @click="verReporte">
              <font-awesome-icon icon="eye" />
              <span>Ver Reporte</span>
            </button>
            <button class="btn-report btn-download" @click="descargarReporte">
              <font-awesome-icon icon="download" />
              <span>Descargar Reporte</span>
            </button>
          </div>

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
import { usePdfGenerator } from '@/composables/usePdfGenerator'

const { loading, error: apiError, execute } = useApi()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()

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

// Totales para el reporte
const totalMultas = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.cantidad_multas || 0), 0)
})

const totalMultasImporte = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_multas || 0), 0)
})

const totalGastos = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_gastos || 0), 0)
})

const totalGeneral = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_general || 0), 0)
})

function verReporte() {
  if (rows.value.length === 0) {
    console.error('No hay datos para generar el reporte')
    return
  }

  try {
    const periodo = `${filters.value.desde} al ${filters.value.hasta}`
    const opciones = {
      titulo: 'Reporte de Avance',
      subtitulo: `Reporte de Avance por Dependencia - ${periodo}`,
      ejercicio: periodo,
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'number' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' },
        { key: 'promedio_multa', header: 'Promedio', type: 'currency' },
        { key: 'porcentaje_total', header: '% Total', type: 'number' }
      ],
      totales: {
        dependencia: '',
        nombre_dependencia: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalGeneral.value,
        promedio_multa: totalMultas.value > 0 ? totalGeneral.value / totalMultas.value : 0,
        porcentaje_total: 100
      }
    }

    verReporteTabular(rows.value, opciones)
    console.log('✅ Vista previa generada exitosamente')
  } catch (e) {
    console.error('❌ Error al generar vista previa:', e)
  }
}

function descargarReporte() {
  if (rows.value.length === 0) {
    console.error('No hay datos para descargar el reporte')
    return
  }

  try {
    const periodo = `${filters.value.desde} al ${filters.value.hasta}`
    const opciones = {
      titulo: 'Reporte de Avance',
      subtitulo: `Reporte de Avance por Dependencia - ${periodo}`,
      ejercicio: periodo,
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'number' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' },
        { key: 'promedio_multa', header: 'Promedio', type: 'currency' },
        { key: 'porcentaje_total', header: '% Total', type: 'number' }
      ],
      totales: {
        dependencia: '',
        nombre_dependencia: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalGeneral.value,
        promedio_multa: totalMultas.value > 0 ? totalGeneral.value / totalMultas.value : 0,
        porcentaje_total: 100
      }
    }

    descargarReporteTabular(rows.value, opciones)
    console.log('✅ Reporte descargado exitosamente')
  } catch (e) {
    console.error('❌ Error al descargar reporte:', e)
  }
}

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

/* Estilos para botones de reporte */
.report-actions {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #dee2e6;
}

.btn-report {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.95rem;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-report:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}

.btn-report:active {
  transform: translateY(0);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.btn-preview {
  background: linear-gradient(135deg, #28a745 0%, #20963d 100%);
  color: white;
}

.btn-preview:hover {
  background: linear-gradient(135deg, #218838 0%, #1e7e34 100%);
}

.btn-download {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  color: white;
}

.btn-download:hover {
  background: linear-gradient(135deg, #0069d9 0%, #004085 100%);
}
</style>
