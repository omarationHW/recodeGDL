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
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

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

    <!-- Estadísticas -->
    <div v-if="estadisticas.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="chart-pie" />
        Estadísticas por Cementerio
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
              <tr v-for="stat in estadisticas" :key="stat.cementerio">
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

    <div v-else-if="busquedaRealizada" class="alert-info">
      <font-awesome-icon icon="info-circle" />
      No se encontraron estadísticas
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Estad_adeudo'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
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

// Estado
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const filtros = reactive({
  cementerio: ''
})

const estadisticas = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const generarEstadisticas = async () => {
  try {
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
    busquedaRealizada.value = true

    if (estadisticas.value.length > 0) {
      showToast('success', 'Estadísticas generadas correctamente')
    } else {
      showToast('info', 'No se encontraron datos')
    }
  } catch (error) {
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
