<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header module-header-relative">
      <div class="module-view-icon">
        <font-awesome-icon icon="traffic-light" />
      </div>
      <div class="module-view-info">
        <h1>Sistema de Semáforo</h1>
        <p>Padrón de Licencias - Generador de Colores Aleatorios y Estadísticas</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Panel principal del semáforo -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="play-circle" />
          Panel de Control del Semáforo
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="semaforo-container">
          <!-- Visualización del semáforo -->
          <div class="semaforo-display">
            <div class="semaforo-lights">
              <div
                class="semaforo-light rojo"
                :class="{ active: colorActual === 'ROJO' }"
              >
                <span v-if="colorActual === 'ROJO'">{{ numeroGenerado }}</span>
              </div>
              <div
                class="semaforo-light verde"
                :class="{ active: colorActual === 'VERDE' }"
              >
                <span v-if="colorActual === 'VERDE'">{{ numeroGenerado }}</span>
              </div>
            </div>
            <div class="semaforo-info">
              <h3 v-if="colorActual" :class="colorActual === 'ROJO' ? 'text-danger' : 'text-success'">
                {{ colorActual }}
              </h3>
              <p v-if="numeroGenerado">Número generado: <strong>{{ numeroGenerado }}</strong></p>
              <p v-if="colorActual" class="color-description">
                {{ getColorDescription() }}
              </p>
            </div>
          </div>

          <!-- Controles -->
          <div class="semaforo-controls">
            <button
              class="btn-municipal-primary btn-lg"
              @click="generarColor"
              :disabled="loading"
            >
              <font-awesome-icon icon="random" />
              Generar Color Aleatorio
            </button>
            <button
              class="btn-municipal-success btn-lg"
              @click="guardarResultado"
              :disabled="loading || !colorActual"
            >
              <font-awesome-icon icon="save" />
              Guardar Resultado
            </button>
            <button
              class="btn-municipal-secondary btn-lg"
              @click="reiniciar"
              :disabled="loading"
            >
              <font-awesome-icon icon="redo" />
              Reiniciar
            </button>
          </div>

          <!-- Instrucciones -->
          <div class="instructions-panel">
            <h6>
              <font-awesome-icon icon="info-circle" />
              Cómo funciona
            </h6>
            <ul>
              <li>Se genera un número aleatorio entre 1 y 100</li>
              <li>Si el número es menor o igual a 10: <span class="text-danger">ROJO</span></li>
              <li>Si el número es mayor a 10: <span class="text-success">VERDE</span></li>
              <li>Probabilidad de ROJO: 10%</li>
              <li>Probabilidad de VERDE: 90%</li>
            </ul>
          </div>
        </div>
      </div>
    </div>

    <!-- Estadísticas -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="chart-bar" />
          Estadísticas
        </h5>
        <button
          class="btn-municipal-secondary btn-sm"
          @click="cargarEstadisticas"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
      <div class="municipal-card-body">
        <div v-if="estadisticas" class="stats-container">
          <div class="stats-grid">
            <div class="stat-card total">
              <div class="stat-icon">
                <font-awesome-icon icon="calculator" size="2x" />
              </div>
              <div class="stat-content">
                <h3>{{ estadisticas.total || 0 }}</h3>
                <p>Total de Intentos</p>
              </div>
            </div>
            <div class="stat-card rojo">
              <div class="stat-icon">
                <font-awesome-icon icon="stop-circle" size="2x" />
              </div>
              <div class="stat-content">
                <h3>{{ estadisticas.rojos || 0 }}</h3>
                <p>Rojos ({{ calcularPorcentaje(estadisticas.rojos, estadisticas.total) }}%)</p>
              </div>
            </div>
            <div class="stat-card verde">
              <div class="stat-icon">
                <font-awesome-icon icon="check-circle" size="2x" />
              </div>
              <div class="stat-content">
                <h3>{{ estadisticas.verdes || 0 }}</h3>
                <p>Verdes ({{ calcularPorcentaje(estadisticas.verdes, estadisticas.total) }}%)</p>
              </div>
            </div>
            <div class="stat-card promedio">
              <div class="stat-icon">
                <font-awesome-icon icon="percentage" size="2x" />
              </div>
              <div class="stat-content">
                <h3>{{ estadisticas.promedio || 0 }}</h3>
                <p>Número Promedio</p>
              </div>
            </div>
          </div>

          <!-- Gráfico de distribución visual -->
          <div class="distribution-chart">
            <h6>Distribución de Resultados</h6>
            <div class="chart-bars">
              <div class="chart-bar-container">
                <div class="chart-label">ROJO</div>
                <div class="chart-bar rojo" :style="{ width: calcularPorcentaje(estadisticas.rojos, estadisticas.total) + '%' }">
                  {{ estadisticas.rojos || 0 }}
                </div>
              </div>
              <div class="chart-bar-container">
                <div class="chart-label">VERDE</div>
                <div class="chart-bar verde" :style="{ width: calcularPorcentaje(estadisticas.verdes, estadisticas.total) + '%' }">
                  {{ estadisticas.verdes || 0 }}
                </div>
              </div>
            </div>
          </div>
        </div>
        <div v-else class="text-center text-muted">
          <font-awesome-icon icon="chart-bar" size="3x" class="empty-icon" />
          <p>No hay estadísticas disponibles</p>
          <p>Genera algunos colores para ver las estadísticas</p>
        </div>
      </div>
    </div>

    <!-- Historial de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="history" />
          Historial de Resultados
          <span class="badge-purple" v-if="historial.length > 0">{{ historial.length }} registros</span>
        </h5>
        <button
          class="btn-municipal-secondary btn-sm"
          @click="cargarHistorial"
          :disabled="loading"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>#</th>
                <th>Número Generado</th>
                <th>Color</th>
                <th>Fecha y Hora</th>
                <th>Usuario</th>
                <th>Observaciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(registro, index) in historial" :key="index" class="clickable-row">
                <td><strong>{{ index + 1 }}</strong></td>
                <td>
                  <span class="numero-badge">{{ registro.numero }}</span>
                </td>
                <td>
                  <span class="badge" :class="registro.color === 'ROJO' ? 'badge-danger' : 'badge-success'">
                    <font-awesome-icon :icon="registro.color === 'ROJO' ? 'stop-circle' : 'check-circle'" />
                    {{ registro.color }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="clock" />
                    {{ formatDateTime(registro.fecha) }}
                  </small>
                </td>
                <td>{{ registro.usuario || 'Sistema' }}</td>
                <td>{{ registro.observaciones || '-' }}</td>
              </tr>
              <tr v-if="historial.length === 0">
                <td colspan="6" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No hay registros en el historial</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Generando color...</p>
      </div>
    </div>

    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Semaforo'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const colorActual = ref(null)
const numeroGenerado = ref(null)
const estadisticas = ref(null)
const historial = ref([])

// Métodos
const generarColor = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'sp_semaforo_get_random_color',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      colorActual.value = response.result[0].color
      numeroGenerado.value = response.result[0].numcolor

      // Animación de cambio
      showToast('info', `Número generado: ${numeroGenerado.value} - Color: ${colorActual.value}`)

      // Registrar automáticamente el resultado
      await registrarColor()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const registrarColor = async () => {
  if (!colorActual.value || !numeroGenerado.value) return

  try {
    await execute(
      'sp_semaforo_register_color_result',
      'padron_licencias',
      [
        { nombre: 'p_numero', valor: numeroGenerado.value },
        { nombre: 'p_color', valor: colorActual.value },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )
  } catch (error) {
  }
}

const guardarResultado = async () => {
  if (!colorActual.value || !numeroGenerado.value) {
    showToast('warning', 'Genere un color primero')
    return
  }

  const { value: observaciones } = await Swal.fire({
    title: 'Guardar Resultado',
    input: 'textarea',
    inputLabel: 'Observaciones (opcional)',
    inputPlaceholder: 'Ingrese observaciones sobre este resultado...',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Guardar',
    cancelButtonText: 'Cancelar'
  })

  if (observaciones === undefined) return

  setLoading(true)
  try {
    const response = await execute(
      'sp_semaforo_save',
      'padron_licencias',
      [
        { nombre: 'p_numero', valor: numeroGenerado.value },
        { nombre: 'p_color', valor: colorActual.value },
        { nombre: 'p_observaciones', valor: observaciones || null },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: 'Resultado guardado',
        text: 'El resultado ha sido guardado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Resultado guardado')
      cargarHistorial()
      cargarEstadisticas()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarEstadisticas = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'sp_semaforo_get_stats',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      estadisticas.value = response.result[0]
      showToast('success', 'Estadísticas actualizadas')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarHistorial = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'sp_semaforo_history',
      'padron_licencias',
      [
        { nombre: 'p_limit', valor: 50 }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      historial.value = response.result
      showToast('success', 'Historial actualizado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const reiniciar = () => {
  colorActual.value = null
  numeroGenerado.value = null
  showToast('info', 'Semáforo reiniciado')
}

const getColorDescription = () => {
  if (!colorActual.value) return ''

  if (colorActual.value === 'ROJO') {
    return `¡ALTO! El número ${numeroGenerado.value} está en el rango de ROJO (1-10)`
  } else {
    return `¡ADELANTE! El número ${numeroGenerado.value} está en el rango de VERDE (11-100)`
  }
}

const calcularPorcentaje = (valor, total) => {
  if (!total || total === 0) return 0
  return Math.round((valor / total) * 100)
}

// Utilidades
const formatDateTime = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(() => {
  cargarEstadisticas()
  cargarHistorial()
})
</script>

.semaforo-container {
  display: flex;
  flex-direction: column;
  gap: 30px;
  padding: 20px;
}

.semaforo-display {
  display: flex;
  gap: 40px;
  align-items: center;
  justify-content: center;
  padding: 30px;
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
  border-radius: 8px;
}

.semaforo-lights {
  background: #2c3e50;
  padding: 20px;
  border-radius: 15px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.semaforo-light {
  width: 120px;
  height: 120px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  color: #2c3e50;
  transition: all 0.3s ease;
  box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.3);
}

.semaforo-light.rojo {
  background: #d32f2f;
  opacity: 0.3;
}

.semaforo-light.verde {
  background: #388e3c;
  opacity: 0.3;
}

.semaforo-light.active {
  opacity: 1;
  box-shadow: 0 0 30px currentColor, inset 0 0 10px rgba(255, 255, 255, 0.3);
  animation: pulse 1s infinite;
}

@keyframes pulse {
  0%, 100% {
    transform: scale(1);
  }
  50% {
    transform: scale(1.05);
  }
}

.semaforo-info {
  text-align: center;
  flex: 1;
}

.semaforo-info h3 {
  font-size: 48px;
  font-weight: bold;
  margin: 0 0 15px 0;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
}

.semaforo-info p {
  font-size: 18px;
  color: #495057;
  margin: 10px 0;
}

.color-description {
  font-style: italic;
  color: #6c757d;
}

.semaforo-controls {
  display: flex;
  gap: 15px;
  justify-content: center;
  flex-wrap: wrap;
}

.btn-lg {
  padding: 15px 30px;
  font-size: 18px;
}

.instructions-panel {
  background: #e7f3ff;
  border: 1px solid #b3d9ff;
  border-radius: 4px;
  padding: 20px;
}

.instructions-panel h6 {
  margin-top: 0;
  color: #0056b3;
}

.instructions-panel ul {
  margin: 10px 0 0 20px;
  color: #495057;
}

.instructions-panel li {
  margin: 5px 0;
}

.stats-container {
  padding: 20px;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.stat-card {
  background: #f8f9fa;
  border: 2px solid #dee2e6;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
  transition: transform 0.2s;
}

.stat-card:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.stat-card.total {
  border-color: #007bff;
}

.stat-card.rojo {
  border-color: #dc3545;
}

.stat-card.rojo .stat-icon {
  color: #dc3545;
}

.stat-card.verde {
  border-color: #28a745;
}

.stat-card.verde .stat-icon {
  color: #28a745;
}

.stat-card.promedio {
  border-color: #ffc107;
}

.stat-card.promedio .stat-icon {
  color: #ffc107;
}

.stat-icon {
  color: #6c757d;
}

.stat-content h3 {
  font-size: 32px;
  font-weight: bold;
  margin: 0;
  color: #495057;
}

.stat-content p {
  margin: 5px 0 0 0;
  color: #6c757d;
  font-size: 14px;
}

.distribution-chart {
  background: #fff;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 20px;
}

.distribution-chart h6 {
  margin-top: 0;
  color: #495057;
}

.chart-bars {
  margin-top: 20px;
}

.chart-bar-container {
  margin-bottom: 15px;
}

.chart-label {
  font-weight: bold;
  margin-bottom: 5px;
  color: #495057;
}

.chart-bar {
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: flex-end;
  padding-right: 10px;
  color: white;
  font-weight: bold;
  border-radius: 4px;
  transition: width 0.5s ease;
  min-width: 50px;
}

.chart-bar.rojo {
  background: linear-gradient(90deg, #dc3545 0%, #c82333 100%);
}

.chart-bar.verde {
  background: linear-gradient(90deg, #28a745 0%, #218838 100%);
}

.numero-badge {
  background: #007bff;
  color: white;
  padding: 5px 15px;
  border-radius: 20px;
  font-weight: bold;
  font-size: 16px;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.empty-icon {
  margin-bottom: 15px;
  opacity: 0.5;
}
</style>
