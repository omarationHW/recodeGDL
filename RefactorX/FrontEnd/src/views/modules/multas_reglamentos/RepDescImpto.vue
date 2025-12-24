<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Descuento de Impuesto</h1>
        <p>Multas por dependencia por ejercicio</p>
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
      <!-- Formulario -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>📅 Parámetros</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio (Año) *</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                placeholder="Ej: 2025"
                min="2000"
                max="2050"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.ejercicio"
              @click="generar"
            >
              <font-awesome-icon icon="chart-bar" v-if="!loading" />
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
            <small>* Campo requerido. Ingrese el año del ejercicio a consultar.</small>
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
          <h5>📊 Resultados - Ejercicio {{ filters.ejercicio }} ({{ rows.length }} dependencias)</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Resumen -->
          <div class="summary-box">
            <div class="summary-item">
              <strong>Ejercicio:</strong>
              <span>{{ filters.ejercicio }}</span>
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
                  <th>Cantidad Multas</th>
                  <th>Total Multas</th>
                  <th>Total Gastos</th>
                  <th>Total General</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx">
                  <td>{{ row.dependencia }}</td>
                  <td><strong>{{ row.nombre_dependencia }}</strong></td>
                  <td class="text-right">{{ formatNumber(row.cantidad_multas) }}</td>
                  <td class="text-right">{{ formatCurrency(row.total_multas) }}</td>
                  <td class="text-right">{{ formatCurrency(row.total_gastos) }}</td>
                  <td class="text-right"><strong>{{ formatCurrency(row.total_general) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="2"><strong>TOTALES</strong></td>
                  <td class="text-right"><strong>{{ formatNumber(totalMultas) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalMultasImporte) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalGastos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalRecaudado) }}</strong></td>
                </tr>
              </tfoot>
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
            <strong>ℹ️ Info:</strong> No se encontraron registros para el ejercicio {{ filters.ejercicio }}.
          </div>
        </div>
      </div>
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'RepDescImpto'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Reporte Descuento de Impuesto'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'RepDescImpto'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Reporte Descuento de Impuesto'"
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
const OP = 'RECAUDADORA_REP_DESC_IMPTO'

const filters = ref({
  ejercicio: new Date().getFullYear()
})

const rows = ref([])
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

const totalMultas = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.cantidad_multas || 0), 0)
})

const totalMultasImporte = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_multas || 0), 0)
})

const totalGastos = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_gastos || 0), 0)
})

const totalRecaudado = computed(() => {
  return rows.value.reduce((sum, row) => sum + Number(row.total_general || 0), 0)
})

async function generar() {
  error.value = ''
  success.value = ''
  searched.value = false

  if (!filters.value.ejercicio) {
    error.value = 'Por favor ingrese el ejercicio (año)'
    return
  }

  if (filters.value.ejercicio < 2000 || filters.value.ejercicio > 2050) {
    error.value = 'El ejercicio debe estar entre 2000 y 2050'
    return
  }

  showLoading('Consultando...', 'Por favor espere')
  try {
    const params = [
      { nombre: 'p_ejercicio', valor: Number(filters.value.ejercicio || 0), tipo: 'integer' }
    ]

    console.log('Ejecutando:', OP, 'con parámetros:', params)

    const data = await execute(OP, BASE_DB, params)

    console.log('Respuesta del servidor:', data)

    // Extraer el array de resultados
    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
        ? data.rows
        : Array.isArray(data)
          ? data
          : []

    rows.value = arr
    currentPage.value = 1
    searched.value = true

    if (arr.length > 0) {
      success.value = `Se encontraron ${arr.length} dependencias para el ejercicio ${filters.value.ejercicio}`
    }
  } catch (e) {
    console.error('Error al generar reporte:', e)
    error.value = apiError.value || e.message || 'Error al ejecutar el reporte'
    rows.value = []
    searched.value = true
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = {
    ejercicio: new Date().getFullYear()
  }
  rows.value = []
  success.value = ''
  error.value = ''
  searched.value = false
  currentPage.value = 1
}

function formatNumber(value) {
  if (!value && value !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(value)
}

function formatCurrency(value) {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

function verReporte() {
  if (rows.value.length === 0) {
    error.value = 'No hay datos para generar el reporte'
    return
  }

  try {
    const opciones = {
      titulo: 'Reporte de Descuento de Impuesto',
      subtitulo: 'Multas por Dependencia',
      ejercicio: filters.value.ejercicio.toString(),
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'text' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad Multas', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' }
      ],
      totales: {
        nombre_dependencia: '', // Primera columna vacía para "TOTALES"
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalRecaudado.value
      }
    }

    verReporteTabular(rows.value, opciones)
    success.value = 'Reporte generado exitosamente'
  } catch (e) {
    error.value = e.message || 'Error al generar el reporte PDF'
    console.error('Error al generar reporte:', e)
  }
}

function descargarReporte() {
  if (rows.value.length === 0) {
    error.value = 'No hay datos para descargar el reporte'
    return
  }

  try {
    const opciones = {
      titulo: 'Reporte de Descuento de Impuesto',
      subtitulo: 'Multas por Dependencia',
      ejercicio: filters.value.ejercicio.toString(),
      columnas: [
        { key: 'dependencia', header: 'Dep.', type: 'text' },
        { key: 'nombre_dependencia', header: 'Nombre Dependencia', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad Multas', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' }
      ],
      totales: {
        nombre_dependencia: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalRecaudado.value
      }
    }

    descargarReporteTabular(rows.value, opciones)
    success.value = 'Reporte descargado exitosamente'
  } catch (e) {
    error.value = e.message || 'Error al descargar el reporte PDF'
    console.error('Error al descargar reporte:', e)
  }
}
</script>

