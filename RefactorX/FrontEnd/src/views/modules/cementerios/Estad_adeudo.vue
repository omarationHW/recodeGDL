<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Estadísticas de Adeudos</h1>
        <p>Cementerios - Reporte estadístico de pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card mb-3">
        <div class="municipal-card-header">
          <font-awesome-icon icon="filter" />
          Filtros
        </div>
        <div class="municipal-card-body">
          <div class="form-grid-two">
            <div class="form-group">
              <label class="municipal-form-label">Cementerio</label>
              <select v-model="filtros.cementerio" class="municipal-form-control">
                <option value="">-- Todos los Cementerios --</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.nombre }}
                </option>
              </select>
            </div>
            <div class="form-actions">
              <button @click="generarEstadisticas" class="btn-municipal-primary">
                <font-awesome-icon icon="chart-line" />
                Generar Estadísticas
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Empty State - Sin búsqueda -->
      <div v-if="estadisticas.length === 0 && !hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="chart-bar" size="3x" />
        </div>
        <h4>Estadísticas de Adeudos</h4>
        <p>Seleccione un cementerio y presione "Generar Estadísticas" para ver el reporte</p>
      </div>

      <!-- Empty State - Sin resultados -->
      <div v-else-if="estadisticas.length === 0 && hasSearched" class="empty-state">
        <div class="empty-state-icon">
          <font-awesome-icon icon="inbox" size="3x" />
        </div>
        <h4>Sin resultados</h4>
        <p>No se encontraron estadísticas con los criterios especificados</p>
      </div>

      <!-- Estadísticas -->
      <div v-else class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="chart-pie" />
            Estadísticas por Cementerio
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="estadisticas.length > 0">
              {{ estadisticas.length }} cementerios
            </span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cementerio</th>
                  <th>Total Folios</th>
                  <th>Al Corriente</th>
                  <th>Atrasados</th>
                  <th>% Al Corriente</th>
                  <th>% Atrasados</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="stat in estadisticas"
                  :key="stat.cementerio"
                  @click="selectedRow = stat"
                  :class="{ 'table-row-selected': selectedRow === stat }"
                  class="row-hover"
                >
                  <td><strong>{{ stat.nombre_cementerio }}</strong></td>
                  <td>{{ stat.total_folios }}</td>
                  <td class="text-success">{{ stat.folios_al_corriente }}</td>
                  <td class="text-danger">{{ stat.folios_atrasados }}</td>
                  <td>{{ calcularPorcentaje(stat.folios_al_corriente, stat.total_folios) }}%</td>
                  <td>{{ calcularPorcentaje(stat.folios_atrasados, stat.total_folios) }}%</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="totals-row">
                  <td><strong>TOTALES:</strong></td>
                  <td><strong>{{ calcularTotales().total }}</strong></td>
                  <td class="text-success"><strong>{{ calcularTotales().corriente }}</strong></td>
                  <td class="text-danger"><strong>{{ calcularTotales().atrasados }}</strong></td>
                  <td><strong>{{ calcularPorcentaje(calcularTotales().corriente, calcularTotales().total) }}%</strong></td>
                  <td><strong>{{ calcularPorcentaje(calcularTotales().atrasados, calcularTotales().total) }}%</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Gráfico Visual -->
          <div class="stats-visual mt-4">
            <h5>Distribución de Folios</h5>
            <div v-for="stat in estadisticas" :key="stat.cementerio" class="stat-bar">
              <div class="stat-label">{{ stat.nombre_cementerio }}</div>
              <div class="stat-progress">
                <div
                  class="stat-progress-success"
                  :style="{ width: calcularPorcentaje(stat.folios_al_corriente, stat.total_folios) + '%' }"
                >
                  {{ stat.folios_al_corriente }}
                </div>
                <div
                  class="stat-progress-danger"
                  :style="{ width: calcularPorcentaje(stat.folios_atrasados, stat.total_folios) + '%' }"
                >
                  {{ stat.folios_atrasados }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <div class="toast-content">
          <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
          <span class="toast-message">{{ toast.message }}</span>
        </div>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>

      <!-- Modal de Ayuda y Documentación -->
      <DocumentationModal
        :show="showDocModal"
        :componentName="'Estad_adeudo'"
        :moduleName="'cementerios'"
        :docType="docType"
        :title="'Estadísticas de Adeudos'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Estado
const filtros = reactive({
  cementerio: ''
})

const estadisticas = ref([])
const cementerios = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)

const generarEstadisticas = async () => {
  try {
    showLoading('Generando estadísticas...', 'Procesando información de cementerios')
    hasSearched.value = true
    selectedRow.value = null

    const params = [
      {
        nombre: 'p_cementerio',
        valor: filtros.cementerio || null,
        tipo: 'string'
      }
    ]

    const response = await execute('sp_cem_estadisticas_adeudos', 'cementerios', params,
      'padron_licencias',
      null,
      'public'
    , '', null, 'public')

    estadisticas.value = response.result || []

    hideLoading()

    if (estadisticas.value.length > 0) {
      showToast('success', 'Estadísticas generadas correctamente')
    } else {
      showToast('info', 'No se encontraron datos')
    }
  } catch (error) {
    hideLoading()
    console.error('Error al generar estadísticas:', error)
    showToast('error', 'Error al generar estadísticas')
  }
}

const cargarCementerios = async () => {
  try {
    const response = await execute('sp_cem_listar_cementerios', 'cementerios', [],
      'cementerio',
      null,
      'public'
    )
    cementerios.value = response.result || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
}

const calcularPorcentaje = (valor, total) => {
  if (!total || total === 0) return '0.00'
  return ((valor / total) * 100).toFixed(2)
}

const calcularTotales = () => {
  return {
    total: estadisticas.value.reduce((sum, s) => sum + s.total_folios, 0),
    corriente: estadisticas.value.reduce((sum, s) => sum + s.folios_al_corriente, 0),
    atrasados: estadisticas.value.reduce((sum, s) => sum + s.folios_atrasados, 0)
  }
}

onMounted(() => {
  cargarCementerios()
})
</script>
