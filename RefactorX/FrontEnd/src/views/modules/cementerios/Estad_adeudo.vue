<template>
  <div class="module-container">
    <div class="module-header">
      <h1 class="module-title">
        <i class="fas fa-chart-bar"></i>
        Estadísticas de Adeudos
      </h1>
      <DocumentationModal
        title="Ayuda - Estadísticas de Adeudos"
        :sections="helpSections"
      />
    </div>

    <!-- Filtros -->
    <div class="card mb-3">
      <div class="card-header">
        <i class="fas fa-filter"></i>
        Filtros
      </div>
      <div class="card-body">
        <div class="form-grid-two">
          <div class="form-group">
            <label class="form-label">Cementerio</label>
            <select v-model="filtros.cementerio" class="form-control">
              <option value="">-- Todos los Cementerios --</option>
              <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                {{ cem.nombre }}
              </option>
            </select>
          </div>
          <div class="form-actions">
            <button @click="generarEstadisticas" class="btn-municipal-primary">
              <i class="fas fa-chart-line"></i>
              Generar Estadísticas
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Estadísticas -->
    <div v-if="estadisticas.length > 0" class="card">
      <div class="card-header">
        <i class="fas fa-chart-pie"></i>
        Estadísticas por Cementerio
      </div>
      <div class="card-body">
        <div class="table-responsive">
          <table class="data-table">
            <thead>
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
      <i class="fas fa-info-circle"></i>
      No se encontraron estadísticas
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const api = useApi()
const toast = useToast()

const filtros = reactive({
  cementerio: ''
})

const estadisticas = ref([])
const cementerios = ref([])
const busquedaRealizada = ref(false)

const helpSections = [
  {
    title: 'Estadísticas de Adeudos',
    content: `
      <p>Genera estadísticas y reportes de adeudos por cementerio.</p>
      <h4>Información Mostrada:</h4>
      <ul>
        <li><strong>Total Folios:</strong> Cantidad total de folios registrados</li>
        <li><strong>Al Corriente:</strong> Folios con pagos al día</li>
        <li><strong>Atrasados:</strong> Folios con pagos pendientes</li>
        <li><strong>Porcentajes:</strong> Distribución porcentual</li>
      </ul>
    `
  }
]

const generarEstadisticas = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_ESTADISTICAS_ADEUDOS', {
      p_cementerio: filtros.cementerio || null
    })

    estadisticas.value = response.data || []
    busquedaRealizada.value = true

    if (estadisticas.value.length > 0) {
      toast.success('Estadísticas generadas correctamente')
    } else {
      toast.info('No se encontraron datos')
    }
  } catch (error) {
    console.error('Error al generar estadísticas:', error)
    toast.error('Error al generar estadísticas')
  }
}

const cargarCementerios = async () => {
  try {
    const response = await api.callStoredProcedure('SP_CEM_LISTAR_CEMENTERIOS', {})
    cementerios.value = response.data || []
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

<style scoped>
.text-success {
  color: var(--color-success);
  font-weight: bold;
}

.text-danger {
  color: var(--color-danger);
  font-weight: bold;
}

.totals-row {
  background-color: var(--color-bg-secondary);
  font-weight: bold;
}

.stats-visual {
  margin-top: 2rem;
}

.stat-bar {
  margin-bottom: 1.5rem;
}

.stat-label {
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: var(--color-text-primary);
}

.stat-progress {
  display: flex;
  height: 40px;
  background-color: var(--color-bg-secondary);
  border-radius: 0.375rem;
  overflow: hidden;
}

.stat-progress-success {
  background-color: var(--color-success);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  transition: width 0.3s ease;
}

.stat-progress-danger {
  background-color: var(--color-danger);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
  transition: width 0.3s ease;
}
</style>
