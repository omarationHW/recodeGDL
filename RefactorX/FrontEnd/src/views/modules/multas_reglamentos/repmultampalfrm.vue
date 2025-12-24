<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info"><h1>Reporte Multa Municipal</h1></div>
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
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="generar">Generar</button>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-body table-container">
          <!-- Botones de reporte -->
          <div class="report-actions" v-if="rows.length > 0">
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
                <tr><th v-for="c in cols" :key="c">{{ c }}</th></tr>
              </thead>
              <tbody>
                <tr v-for="(r,i) in paginatedRows" :key="i">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
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
    </div>


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'repmultampalfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Reporte Multa Municipal'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'repmultampalfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Reporte Multa Municipal'"
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


const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { verReporteTabular, descargarReporteTabular } = usePdfGenerator()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REPMULTAMPALFRM'

const filters = ref({
  ejercicio: new Date().getFullYear()
})

const rows = ref([])
const cols = ref([])
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

async function generar() {
  showLoading('Consultando...', 'Por favor espere')
  try {
    const data = await execute(OP, BASE_DB, [
      { nombre: 'p_ejercicio', valor: Number(filters.value.ejercicio || 0), tipo: 'integer' }
    ])

    // Extraer el array de resultados de la respuesta
    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
        ? data.rows
        : Array.isArray(data)
          ? data
          : []

    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
    currentPage.value = 1
  } catch (e) {
    console.error('Error al generar reporte:', e)
    rows.value = []
    cols.value = []
  } finally {
    hideLoading()
  }
}

function verReporte() {
  if (rows.value.length === 0) {
    console.error('No hay datos para generar el reporte')
    return
  }

  try {
    const opciones = {
      titulo: 'Reporte Multa Municipal',
      subtitulo: `Reporte Mensual - Ejercicio ${filters.value.ejercicio}`,
      ejercicio: filters.value.ejercicio.toString(),
      columnas: [
        { key: 'mes', header: 'Mes', type: 'number' },
        { key: 'nombre_mes', header: 'Nombre Mes', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad Multas', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' },
        { key: 'promedio_multa', header: 'Promedio', type: 'currency' }
      ],
      totales: {
        mes: '',
        nombre_mes: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalGeneral.value,
        promedio_multa: totalMultas.value > 0 ? totalGeneral.value / totalMultas.value : 0
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
    const opciones = {
      titulo: 'Reporte Multa Municipal',
      subtitulo: `Reporte Mensual - Ejercicio ${filters.value.ejercicio}`,
      ejercicio: filters.value.ejercicio.toString(),
      columnas: [
        { key: 'mes', header: 'Mes', type: 'number' },
        { key: 'nombre_mes', header: 'Nombre Mes', type: 'text' },
        { key: 'cantidad_multas', header: 'Cantidad Multas', type: 'number' },
        { key: 'total_multas', header: 'Total Multas', type: 'currency' },
        { key: 'total_gastos', header: 'Total Gastos', type: 'currency' },
        { key: 'total_general', header: 'Total General', type: 'currency' },
        { key: 'promedio_multa', header: 'Promedio', type: 'currency' }
      ],
      totales: {
        mes: '',
        nombre_mes: '',
        cantidad_multas: totalMultas.value,
        total_multas: totalMultasImporte.value,
        total_gastos: totalGastos.value,
        total_general: totalGeneral.value,
        promedio_multa: totalMultas.value > 0 ? totalGeneral.value / totalMultas.value : 0
      }
    }

    descargarReporteTabular(rows.value, opciones)
    console.log('✅ Reporte descargado exitosamente')
  } catch (e) {
    console.error('❌ Error al descargar reporte:', e)
  }
}
</script>

