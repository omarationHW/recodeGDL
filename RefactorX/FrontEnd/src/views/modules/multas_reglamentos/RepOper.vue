<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Operaciones</h1>
        <p>Estadísticas de operaciones por rango de fechas</p>
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
          <h5>📊 Resultados ({{ rows.length }} dependencias)</h5>
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
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx">
                  <td v-for="col in columns" :key="col">{{ row[col] }}</td>
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


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'RepOper'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Reporte de Operaciones'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'RepOper'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Reporte de Operaciones'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { usePdfGenerator } from '@/composables/usePdfGenerator'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { loading, error: apiError, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REP_OPER'

const filters = ref({
  desde: '',
  hasta: ''
})

const rows = ref([])
const columns = ref([])
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
const totalOperaciones = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_operaciones || 0), 0)
})

const totalEmitidas = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.multas_emitidas || 0), 0)
})

const totalCanceladas = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.multas_canceladas || 0), 0)
})

const totalPendientes = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.multas_pendientes || 0), 0)
})

const totalMultas = computed(() => {
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
      titulo: 'Reporte de Operaciones',
      subtitulo: `Estadísticas de Operaciones por Dependencia - ${periodo}`,
      ejercicio: periodo,
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'number' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'total_operaciones', header: 'Tot. Oper.', type: 'number' },
        { key: 'multas_emitidas', header: 'Emitidas', type: 'number' },
        { key: 'multas_canceladas', header: 'Canceladas', type: 'number' },
        { key: 'multas_pendientes', header: 'Pendientes', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' },
        { key: 'promedio_operacion', header: 'Promedio', type: 'currency' }
      ],
      totales: {
        dependencia: '',
        nombre_dependencia: 'TOTALES',
        total_operaciones: totalOperaciones.value,
        multas_emitidas: totalEmitidas.value,
        multas_canceladas: totalCanceladas.value,
        multas_pendientes: totalPendientes.value,
        total_multas: totalMultas.value,
        total_gastos: totalGastos.value,
        total_general: totalGeneral.value,
        promedio_operacion: totalOperaciones.value > 0 ? totalGeneral.value / totalOperaciones.value : 0
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
      titulo: 'Reporte de Operaciones',
      subtitulo: `Estadísticas de Operaciones por Dependencia - ${periodo}`,
      ejercicio: periodo,
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'number' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'total_operaciones', header: 'Tot. Oper.', type: 'number' },
        { key: 'multas_emitidas', header: 'Emitidas', type: 'number' },
        { key: 'multas_canceladas', header: 'Canceladas', type: 'number' },
        { key: 'multas_pendientes', header: 'Pendientes', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' },
        { key: 'promedio_operacion', header: 'Promedio', type: 'currency' }
      ],
      totales: {
        dependencia: '',
        nombre_dependencia: 'TOTALES',
        total_operaciones: totalOperaciones.value,
        multas_emitidas: totalEmitidas.value,
        multas_canceladas: totalCanceladas.value,
        multas_pendientes: totalPendientes.value,
        total_multas: totalMultas.value,
        total_gastos: totalGastos.value,
        total_general: totalGeneral.value,
        promedio_operacion: totalOperaciones.value > 0 ? totalGeneral.value / totalOperaciones.value : 0
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

  showLoading('Consultando...', 'Por favor espere')
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
    columns.value = arr.length > 0 ? Object.keys(arr[0]) : []
    currentPage.value = 1
    searched.value = true

    if (arr.length > 0) {
      success.value = `Se encontraron ${arr.length} registros`
    }
  } catch (e) {
    console.error('Error al generar reporte:', e)
    error.value = apiError.value || e.message || 'Error al ejecutar el reporte'
    rows.value = []
    columns.value = []
    searched.value = true
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = {
    desde: '',
    hasta: ''
  }
  rows.value = []
  columns.value = []
  success.value = ''
  error.value = ''
  searched.value = false
  currentPage.value = 1
}
</script>

