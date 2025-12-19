<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-alt" />
      </div>
      <div class="module-view-info">
        <h1>Relación Mensual</h1>
        <p>Multas por dependencia</p>
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
              <label class="municipal-form-label">Mes (opcional)</label>
              <select class="municipal-form-control" v-model="filters.mes">
                <option value="">Todo el año</option>
                <option value="1">Enero</option>
                <option value="2">Febrero</option>
                <option value="3">Marzo</option>
                <option value="4">Abril</option>
                <option value="5">Mayo</option>
                <option value="6">Junio</option>
                <option value="7">Julio</option>
                <option value="8">Agosto</option>
                <option value="9">Septiembre</option>
                <option value="10">Octubre</option>
                <option value="11">Noviembre</option>
                <option value="12">Diciembre</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año *</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.anio"
                placeholder="Ej: 2025"
                min="1900"
                :max="new Date().getFullYear() + 1"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.anio"
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
            <small>* Campo requerido. Dejar "Mes" vacío para obtener resumen anual.</small>
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
      <div class="municipal-card" v-if="todosResultados.length > 0">
        <div class="municipal-card-header">
          <h5>📊 Resultados ({{ todosResultados.length }} dependencias)</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Resumen -->
          <div class="summary-box">
            <div class="summary-item">
              <strong>Período:</strong>
              <span>{{ filters.mes ? nombreMes(filters.mes) : 'Año completo' }} {{ filters.anio }}</span>
            </div>
            <div class="summary-item">
              <strong>Total Multas:</strong>
              <span>{{ formatNumber(totalMultas) }}</span>
            </div>
            <div class="summary-item">
              <strong>Total Recaudado:</strong>
              <span>{{ formatCurrency(totalRecaudado) }}</span>
            </div>
          </div>

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
                  <th>Dep.</th>
                  <th>Nombre Dependencia</th>
                  <th>Cantidad</th>
                  <th>Total Multas</th>
                  <th>Total Gastos</th>
                  <th>Total General</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in resultadosPaginados" :key="idx" class="row-hover">
                  <td style="font-weight: 600;">{{ row.dependencia }}</td>
                  <td>{{ row.nombre_dependencia }}</td>
                  <td style="text-align: right;">{{ formatNumber(row.cantidad_multas) }}</td>
                  <td style="text-align: right;">{{ formatCurrency(row.total_multas) }}</td>
                  <td style="text-align: right;">{{ formatCurrency(row.total_gastos) }}</td>
                  <td style="text-align: right; font-weight: bold;">{{ formatCurrency(row.total_general) }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="2" style="font-weight: bold;">TOTALES</td>
                  <td style="text-align: right; font-weight: bold;">{{ formatNumber(totalMultas) }}</td>
                  <td style="text-align: right; font-weight: bold;">{{ formatCurrency(totalMultasImporte) }}</td>
                  <td style="text-align: right; font-weight: bold;">{{ formatCurrency(totalGastos) }}</td>
                  <td style="text-align: right; font-weight: bold;">{{ formatCurrency(totalRecaudado) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPaginas > 1">
            <div class="pagination-info">
              Mostrando {{ rangoInicio }}-{{ rangoFin }} de {{ todosResultados.length }} registros
            </div>

            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="paginaActual === 1"
                @click="cambiarPagina(1)"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button
                class="btn-pagination"
                :disabled="paginaActual === 1"
                @click="cambiarPagina(paginaActual - 1)"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <span class="pagination-text">
                Página {{ paginaActual }} de {{ totalPaginas }}
              </span>

              <button
                class="btn-pagination"
                :disabled="paginaActual === totalPaginas"
                @click="cambiarPagina(paginaActual + 1)"
              >
                <font-awesome-icon icon="angle-right" />
              </button>

              <button
                class="btn-pagination"
                :disabled="paginaActual === totalPaginas"
                @click="cambiarPagina(totalPaginas)"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div class="municipal-card" v-if="!loading && todosResultados.length === 0 && buscado">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <strong>Sin resultados:</strong> No se encontraron multas para el período especificado.
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

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_RELMES'
const { loading, execute } = useApi()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()

const filters = ref({
  mes: '',
  anio: new Date().getFullYear()
})

const todosResultados = ref([])
const paginaActual = ref(1)
const registrosPorPagina = 10
const success = ref(null)
const error = ref(null)
const buscado = ref(false)

// Computed para paginación
const totalPaginas = computed(() => {
  return Math.ceil(todosResultados.value.length / registrosPorPagina)
})

const resultadosPaginados = computed(() => {
  const inicio = (paginaActual.value - 1) * registrosPorPagina
  const fin = inicio + registrosPorPagina
  return todosResultados.value.slice(inicio, fin)
})

const rangoInicio = computed(() => {
  if (todosResultados.value.length === 0) return 0
  return (paginaActual.value - 1) * registrosPorPagina + 1
})

const rangoFin = computed(() => {
  const fin = paginaActual.value * registrosPorPagina
  return fin > todosResultados.value.length ? todosResultados.value.length : fin
})

// Computed para totales
const totalMultas = computed(() => {
  return todosResultados.value.reduce((sum, row) => sum + Number(row.cantidad_multas || 0), 0)
})

const totalMultasImporte = computed(() => {
  return todosResultados.value.reduce((sum, row) => sum + Number(row.total_multas || 0), 0)
})

const totalGastos = computed(() => {
  return todosResultados.value.reduce((sum, row) => sum + Number(row.total_gastos || 0), 0)
})

const totalRecaudado = computed(() => {
  return todosResultados.value.reduce((sum, row) => sum + Number(row.total_general || 0), 0)
})

async function generar() {
  error.value = null
  success.value = null
  buscado.value = true
  paginaActual.value = 1

  if (!filters.value.anio) {
    error.value = 'El año es requerido'
    return
  }

  try {
    console.log('📊 Generando reporte:', OP)
    console.log('📊 Filtros:', filters.value)

    const params = [
      {
        nombre: 'p_mes',
        valor: String(filters.value.mes || ''),
        tipo: 'string'
      },
      {
        nombre: 'p_anio',
        valor: Number(filters.value.anio || 0),
        tipo: 'integer'
      }
    ]

    const data = await execute(OP, BASE_DB, params)

    console.log('✅ Resultado:', data)

    let arr = []
    if (data && data.result && Array.isArray(data.result)) {
      arr = data.result
    } else if (Array.isArray(data)) {
      arr = data
    } else if (data && data.rows && Array.isArray(data.rows)) {
      arr = data.rows
    }

    todosResultados.value = arr

    if (arr.length > 0) {
      const periodo = filters.value.mes ? `${nombreMes(filters.value.mes)} ${filters.value.anio}` : `Año ${filters.value.anio}`
      success.value = `Reporte generado: ${arr.length} dependencias en ${periodo}`
    } else {
      error.value = 'No se encontraron datos para el período especificado'
    }

  } catch (e) {
    error.value = e.message || 'Error al generar el reporte'
    console.error('❌ Error:', e)
    todosResultados.value = []
  }
}

function limpiar() {
  filters.value = {
    mes: '',
    anio: new Date().getFullYear()
  }
  todosResultados.value = []
  paginaActual.value = 1
  success.value = null
  error.value = null
  buscado.value = false
}

function cambiarPagina(nuevaPagina) {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
  }
}

function nombreMes(mes) {
  const meses = {
    '1': 'Enero', '2': 'Febrero', '3': 'Marzo', '4': 'Abril',
    '5': 'Mayo', '6': 'Junio', '7': 'Julio', '8': 'Agosto',
    '9': 'Septiembre', '10': 'Octubre', '11': 'Noviembre', '12': 'Diciembre'
  }
  return meses[String(mes)] || `Mes ${mes}`
}

function formatNumber(num) {
  if (!num && num !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(num)
}

function formatCurrency(amount) {
  if (!amount && amount !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(amount)
}

function verReporte() {
  console.log('📄 Generando vista previa del reporte')
  error.value = null
  try {
    const periodo = filters.value.mes ? `${nombreMes(filters.value.mes)} ${filters.value.anio}` : `Año ${filters.value.anio}`

    const opciones = {
      titulo: 'Relación Mensual de Multas por Dependencia',
      subtitulo: periodo,
      ejercicio: periodo,
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'number' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' }
      ],
      totales: {
        dependencia: '',
        nombre_dependencia: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalRecaudado.value
      }
    }

    verReporteTabular(todosResultados.value, opciones)
    console.log('✅ Vista previa generada exitosamente')
  } catch (e) {
    console.error('❌ Error al generar vista previa:', e)
    error.value = `Error al generar vista previa del PDF: ${e.message}`
  }
}

function descargarReporte() {
  console.log('⬇️ Descargando reporte PDF')
  error.value = null
  try {
    const periodo = filters.value.mes ? `${nombreMes(filters.value.mes)} ${filters.value.anio}` : `Año ${filters.value.anio}`

    const opciones = {
      titulo: 'Relación Mensual de Multas por Dependencia',
      subtitulo: periodo,
      ejercicio: periodo,
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'number' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' }
      ],
      totales: {
        dependencia: '',
        nombre_dependencia: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalRecaudado.value
      }
    }

    descargarReporteTabular(todosResultados.value, opciones)
    const nombreArchivo = `relacion_mensual_${filters.value.mes || 'anual'}_${filters.value.anio}.pdf`
    success.value = `Reporte listo para descargar: ${nombreArchivo}`
    console.log('✅ Reporte descargado exitosamente')
  } catch (e) {
    console.error('❌ Error al descargar reporte:', e)
    error.value = `Error al descargar el PDF: ${e.message}`
  }
}
</script>

<style scoped>
.municipal-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  margin-bottom: 20px;
}

.municipal-card-header {
  padding: 15px 20px;
  border-bottom: 1px solid #e0e0e0;
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
  border-radius: 8px 8px 0 0;
}

.municipal-card-header h5 {
  margin: 0;
  color: white;
}

.municipal-card-body {
  padding: 20px;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 15px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.municipal-form-label {
  font-weight: 600;
  margin-bottom: 5px;
  color: #333;
}

.municipal-form-control {
  width: 100%;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.button-group {
  display: flex;
  gap: 10px;
  margin-top: 15px;
}

.btn-municipal-secondary {
  background: #6c757d;
  color: white;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.3s ease;
}

.btn-municipal-secondary:hover:not(:disabled) {
  background: #5a6268;
  transform: translateY(-1px);
}

.btn-municipal-secondary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.help-text {
  margin-top: 10px;
  color: #666;
}

.summary-box {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 15px;
  margin-bottom: 20px;
  padding: 15px;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid #ea8215;
}

.summary-item {
  display: flex;
  flex-direction: column;
}

.summary-item strong {
  color: #666;
  font-size: 0.85rem;
  margin-bottom: 5px;
}

.summary-item span {
  color: #333;
  font-size: 1.1rem;
  font-weight: 600;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

.municipal-table-header {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
}

.municipal-table-footer {
  background: linear-gradient(135deg, #ea8215 0%, #d67512 100%);
  color: white;
  font-weight: bold;
}

.municipal-table th,
.municipal-table td {
  padding: 10px;
  border: 1px solid #ddd;
  text-align: left;
  font-size: 0.9rem;
}

.municipal-table th {
  font-weight: bold;
  color: white;
}

.municipal-table-footer td {
  color: white;
}

.row-hover:hover {
  background-color: #f9f9f9;
}

.table-responsive {
  overflow-x: auto;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-top: 15px;
  border-top: 2px solid #ea8215;
}

.pagination-info {
  color: #666;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  gap: 8px;
  align-items: center;
}

.btn-pagination {
  background: white;
  border: 1px solid #ddd;
  padding: 6px 12px;
  border-radius: 4px;
  cursor: pointer;
  transition: all 0.3s ease;
  color: #ea8215;
}

.btn-pagination:hover:not(:disabled) {
  background: #ea8215;
  color: white;
  border-color: #ea8215;
}

.btn-pagination:disabled {
  opacity: 0.4;
  cursor: not-allowed;
}

.pagination-text {
  color: #333;
  font-weight: 600;
  padding: 0 10px;
}

.alert {
  padding: 12px 20px;
  border-radius: 4px;
  margin-bottom: 15px;
}

.alert-success {
  background-color: #d4edda;
  border: 1px solid #c3e6cb;
  color: #155724;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c2c7;
  color: #842029;
}

.alert-info {
  background-color: #cfe2ff;
  border: 1px solid #b6d4fe;
  color: #084298;
}

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

.btn-preview {
  background: linear-gradient(135deg, #28a745 0%, #20963d 100%);
  color: white;
}

.btn-preview:hover {
  background: linear-gradient(135deg, #218838 0%, #1c7430 100%);
}

.btn-download {
  background: linear-gradient(135deg, #007bff 0%, #0056b3 100%);
  color: white;
}

.btn-download:hover {
  background: linear-gradient(135deg, #0069d9 0%, #004085 100%);
}

.btn-report svg {
  font-size: 1rem;
}
</style>
