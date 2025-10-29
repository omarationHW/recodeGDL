<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="upload" />
      </div>
      <div class="module-view-info">
        <h1>Carga de Datos Catastrales</h1>
        <p>Padrón de Licencias - Importación y Procesamiento de Información Catastral</p></div>
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

    <!-- Panel de control de carga -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="file-import" />
          Panel de Control de Carga
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Tipo de Datos</label>
            <select class="municipal-form-control" v-model="tipoDatos">
              <option value="avaluos">Avalúos</option>
              <option value="construcciones">Construcciones</option>
              <option value="area_carto">Área Cartográfica</option>
              <option value="general">Datos Generales</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID de Carga</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="cargaId"
              placeholder="ID de proceso de carga"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Estado</label>
            <select class="municipal-form-control" v-model="filtroEstado">
              <option value="">Todos</option>
              <option value="pendiente">Pendiente</option>
              <option value="procesando">Procesando</option>
              <option value="completado">Completado</option>
              <option value="error">Error</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="consultarDatos"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Consultar Datos
          </button>
          <button
            class="btn-municipal-success"
            @click="iniciarCarga"
            :disabled="loading || !tipoDatos"
          >
            <font-awesome-icon icon="play" />
            Iniciar Carga
          </button>
          <button
            class="btn-municipal-danger"
            @click="cerrarCarga"
            :disabled="loading || !cargaId"
          >
            <font-awesome-icon icon="stop" />
            Cerrar Carga
          </button>
        </div>
      </div>
    </div>

    <!-- Pestañas de datos -->
    <div class="municipal-card">
      <div class="tabs-container">
        <button
          class="tab-button"
          :class="{ active: activeTab === 'avaluos' }"
          @click="activeTab = 'avaluos'; cargarAvaluos()"
        >
          <font-awesome-icon icon="money-bill-wave" />
          Avalúos
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'construcciones' }"
          @click="activeTab = 'construcciones'; cargarConstrucciones()"
        >
          <font-awesome-icon icon="home" />
          Construcciones
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'area_carto' }"
          @click="activeTab = 'area_carto'; cargarAreaCarto()"
        >
          <font-awesome-icon icon="map" />
          Área Cartográfica
        </button>
        <button
          class="tab-button"
          :class="{ active: activeTab === 'procesamiento' }"
          @click="activeTab = 'procesamiento'"
        >
          <font-awesome-icon icon="cogs" />
          Procesamiento
        </button>
      </div>
    </div>

    <!-- Tab: Avalúos -->
    <div v-show="activeTab === 'avaluos'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="money-bill-wave" />
          Datos de Avalúos
          <span class="badge-info" v-if="avaluos.length > 0">{{ avaluos.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID Avalúo</th>
                <th>Cuenta</th>
                <th>Clave Catastral</th>
                <th>Valor Terreno</th>
                <th>Valor Construcción</th>
                <th>Valor Total</th>
                <th>Fecha</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="avaluo in avaluos" :key="avaluo.id" class="row-hover">
                <td><strong>{{ avaluo.id }}</strong></td>
                <td>{{ avaluo.cuenta || 'N/A' }}</td>
                <td><code>{{ avaluo.clave_catastral || 'N/A' }}</code></td>
                <td>${{ formatCurrency(avaluo.valor_terreno) }}</td>
                <td>${{ formatCurrency(avaluo.valor_construccion) }}</td>
                <td><strong>${{ formatCurrency(avaluo.valor_total) }}</strong></td>
                <td>{{ formatDate(avaluo.fecha) }}</td>
                <td>
                  <span class="badge" :class="getBadgeClass(avaluo.estado)">
                    {{ avaluo.estado }}
                  </span>
                </td>
              </tr>
              <tr v-if="avaluos.length === 0">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No hay datos de avalúos disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Construcciones -->
    <div v-show="activeTab === 'construcciones'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="home" />
          Datos de Construcciones
          <span class="badge-info" v-if="construcciones.length > 0">{{ construcciones.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Cuenta</th>
                <th>Tipo Construcción</th>
                <th>Superficie</th>
                <th>Año Construcción</th>
                <th>Uso</th>
                <th>Calidad</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="construccion in construcciones" :key="construccion.id" class="row-hover">
                <td><strong>{{ construccion.id }}</strong></td>
                <td>{{ construccion.cuenta || 'N/A' }}</td>
                <td>{{ construccion.tipo_construccion || 'N/A' }}</td>
                <td>{{ construccion.superficie }} m²</td>
                <td>{{ construccion.anio_construccion || 'N/A' }}</td>
                <td>{{ construccion.uso || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">{{ construccion.calidad || 'N/A' }}</span>
                </td>
                <td>
                  <span class="badge" :class="getBadgeClass(construccion.estado)">
                    {{ construccion.estado }}
                  </span>
                </td>
              </tr>
              <tr v-if="construcciones.length === 0">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No hay datos de construcciones disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Área Cartográfica -->
    <div v-show="activeTab === 'area_carto'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="map" />
          Datos de Área Cartográfica
          <span class="badge-info" v-if="areasCarto.length > 0">{{ areasCarto.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Cuenta</th>
                <th>Superficie Catastral</th>
                <th>Superficie Gráfica</th>
                <th>Diferencia</th>
                <th>Coordenadas</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="area in areasCarto" :key="area.id" class="row-hover">
                <td><strong>{{ area.id }}</strong></td>
                <td>{{ area.cuenta || 'N/A' }}</td>
                <td>{{ area.superficie_catastral }} m²</td>
                <td>{{ area.superficie_grafica }} m²</td>
                <td>
                  <span :class="area.diferencia > 0 ? 'text-danger' : 'text-success'">
                    {{ area.diferencia }} m²
                  </span>
                </td>
                <td>
                  <code v-if="area.coordenadas">{{ area.coordenadas }}</code>
                  <span v-else class="text-muted">N/A</span>
                </td>
                <td>
                  <span class="badge" :class="getBadgeClass(area.estado)">
                    {{ area.estado }}
                  </span>
                </td>
              </tr>
              <tr v-if="areasCarto.length === 0">
                <td colspan="7" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No hay datos de área cartográfica disponibles</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab: Procesamiento -->
    <div v-show="activeTab === 'procesamiento'" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="cogs" />
          Estado del Procesamiento
        </h5>
      </div>
      <div class="municipal-card-body">
        <div v-if="procesamiento" class="processing-info">
          <div class="info-grid">
            <div class="info-card">
              <div class="info-icon">
                <font-awesome-icon icon="database" size="2x" />
              </div>
              <div class="info-content">
                <h6>Total de Registros</h6>
                <p class="info-value">{{ procesamiento.total_registros || 0 }}</p>
              </div>
            </div>
            <div class="info-card">
              <div class="info-icon success">
                <font-awesome-icon icon="check-circle" size="2x" />
              </div>
              <div class="info-content">
                <h6>Procesados</h6>
                <p class="info-value">{{ procesamiento.procesados || 0 }}</p>
              </div>
            </div>
            <div class="info-card">
              <div class="info-icon warning">
                <font-awesome-icon icon="clock" size="2x" />
              </div>
              <div class="info-content">
                <h6>Pendientes</h6>
                <p class="info-value">{{ procesamiento.pendientes || 0 }}</p>
              </div>
            </div>
            <div class="info-card">
              <div class="info-icon danger">
                <font-awesome-icon icon="exclamation-triangle" size="2x" />
              </div>
              <div class="info-content">
                <h6>Errores</h6>
                <p class="info-value">{{ procesamiento.errores || 0 }}</p>
              </div>
            </div>
          </div>

          <!-- Barra de progreso -->
          <div class="progress-section">
            <h6>Progreso de Carga</h6>
            <div class="progress-bar-container">
              <div
                class="progress-bar"
                :style="{ width: progresoPercentage + '%' }"
                :class="progresoClass"
              >
                {{ progresoPercentage }}%
              </div>
            </div>
            <p class="progress-text">
              {{ procesamiento.procesados || 0 }} de {{ procesamiento.total_registros || 0 }} registros procesados
            </p>
          </div>

          <!-- Información adicional -->
          <div class="additional-info">
            <div class="info-row">
              <span class="label">Estado General:</span>
              <span class="badge" :class="getBadgeClass(procesamiento.estado)">
                {{ procesamiento.estado || 'N/A' }}
              </span>
            </div>
            <div class="info-row">
              <span class="label">Fecha Inicio:</span>
              <span>{{ formatDateTime(procesamiento.fecha_inicio) }}</span>
            </div>
            <div class="info-row">
              <span class="label">Fecha Fin:</span>
              <span>{{ formatDateTime(procesamiento.fecha_fin) }}</span>
            </div>
            <div class="info-row">
              <span class="label">Usuario:</span>
              <span>{{ procesamiento.usuario || 'Sistema' }}</span>
            </div>
          </div>
        </div>
        <div v-else class="text-center text-muted">
          <font-awesome-icon icon="info-circle" size="3x" class="empty-icon" />
          <p>No hay información de procesamiento disponible</p>
          <p>Seleccione un ID de carga o inicie un nuevo proceso</p>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando datos...</p>
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
      :componentName="'cargadatosfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
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
const activeTab = ref('avaluos')
const tipoDatos = ref('avaluos')
const cargaId = ref(null)
const filtroEstado = ref('')
const avaluos = ref([])
const construcciones = ref([])
const areasCarto = ref([])
const procesamiento = ref(null)

// Computed
const progresoPercentage = computed(() => {
  if (!procesamiento.value || !procesamiento.value.total_registros) return 0
  const total = procesamiento.value.total_registros
  const procesados = procesamiento.value.procesados || 0
  return Math.round((procesados / total) * 100)
})

const progresoClass = computed(() => {
  const percentage = progresoPercentage.value
  if (percentage >= 100) return 'success'
  if (percentage >= 50) return 'info'
  if (percentage >= 25) return 'warning'
  return 'danger'
})

// Métodos
const consultarDatos = async () => {
  if (!cargaId.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese un ID de carga',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_CARGADATOS',
      'padron_licencias',
      [
        { nombre: 'p_carga_id', valor: cargaId.value },
        { nombre: 'p_tipo', valor: tipoDatos.value },
        { nombre: 'p_estado', valor: filtroEstado.value || null }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      procesamiento.value = response.result[0] || null
      showToast('success', 'Datos consultados correctamente')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const iniciarCarga = async () => {
  const result = await Swal.fire({
    title: 'Iniciar proceso de carga',
    text: `¿Desea iniciar la carga de ${tipoDatos.value}?`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, iniciar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  setLoading(true)
  try {
    const response = await execute(
      'SP_SAVE_CARGADATOS',
      'padron_licencias',
      [
        { nombre: 'p_tipo', valor: tipoDatos.value },
        { nombre: 'p_usuario', valor: 'sistema' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      cargaId.value = response.result[0].carga_id
      procesamiento.value = response.result[0]

      await Swal.fire({
        icon: 'success',
        title: 'Carga iniciada',
        text: `ID de carga: ${cargaId.value}`,
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Proceso de carga iniciado')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cerrarCarga = async () => {
  if (!cargaId.value) {
    showToast('warning', 'No hay proceso de carga activo')
    return
  }

  const result = await Swal.fire({
    title: 'Cerrar proceso de carga',
    text: '¿Está seguro de cerrar el proceso de carga actual?',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cerrar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  setLoading(true)
  try {
    const response = await execute(
      'SP_CLOSE_CARGADATOS',
      'padron_licencias',
      [
        { nombre: 'p_carga_id', valor: cargaId.value }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: 'Proceso cerrado',
        text: 'El proceso de carga ha sido cerrado',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Proceso de carga cerrado')
      cargaId.value = null
      procesamiento.value = null
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarAvaluos = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_AVALUOS',
      'padron_licencias',
      [
        { nombre: 'p_carga_id', valor: cargaId.value || null }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      avaluos.value = response.result
      showToast('success', 'Avalúos cargados')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarConstrucciones = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_CONSTRUCCIONES',
      'padron_licencias',
      [
        { nombre: 'p_carga_id', valor: cargaId.value || null }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      construcciones.value = response.result
      showToast('success', 'Construcciones cargadas')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cargarAreaCarto = async () => {
  setLoading(true)
  try {
    const response = await execute(
      'SP_GET_AREA_CARTO',
      'padron_licencias',
      [
        { nombre: 'p_carga_id', valor: cargaId.value || null }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      areasCarto.value = response.result
      showToast('success', 'Áreas cartográficas cargadas')
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

// Utilidades
const getBadgeClass = (estado) => {
  const classes = {
    completado: 'badge-success',
    procesando: 'badge-info',
    pendiente: 'badge-warning',
    error: 'badge-danger'
  }
  return classes[estado?.toLowerCase()] || 'badge-secondary'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatDateTime = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

// Lifecycle
onMounted(() => {
  // Inicialización
})
</script>

<style scoped>
.tabs-container {
  display: flex;
  gap: 0;
  border-bottom: 2px solid #ddd;
  padding: 0;
}

.tab-button {
  padding: 12px 24px;
  background: transparent;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.3s ease;
  color: #666;
}

.tab-button:hover {
  background: #f8f9fa;
  color: #ea8215;
}

.tab-button.active {
  color: #ea8215;
  border-bottom-color: #ea8215;
  background: #fff;
}

.processing-info {
  padding: 20px;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 20px;
  margin-bottom: 30px;
}

.info-card {
  background: #f8f9fa;
  border: 1px solid #dee2e6;
  border-radius: 8px;
  padding: 20px;
  display: flex;
  align-items: center;
  gap: 15px;
}

.info-icon {
  color: #6c757d;
}

.info-icon.success {
  color: #28a745;
}

.info-icon.warning {
  color: #ffc107;
}

.info-icon.danger {
  color: #dc3545;
}

.info-content h6 {
  margin: 0 0 5px 0;
  color: #6c757d;
  font-size: 14px;
}

.info-value {
  font-size: 24px;
  font-weight: bold;
  margin: 0;
  color: #495057;
}

.progress-section {
  margin-bottom: 30px;
}

.progress-section h6 {
  margin-bottom: 10px;
  color: #495057;
}

.progress-bar-container {
  background: #e9ecef;
  border-radius: 4px;
  overflow: hidden;
  height: 30px;
  margin-bottom: 10px;
}

.progress-bar {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: bold;
  transition: width 0.3s ease;
}

.progress-bar.success {
  background-color: #28a745;
}

.progress-bar.info {
  background-color: #17a2b8;
}

.progress-bar.warning {
  background-color: #ffc107;
}

.progress-bar.danger {
  background-color: #dc3545;
}

.progress-text {
  text-align: center;
  color: #6c757d;
  margin: 0;
}

.additional-info {
  background: #fff;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  padding: 20px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  padding: 10px 0;
  border-bottom: 1px solid #e9ecef;
}

.info-row:last-child {
  border-bottom: none;
}

.info-row .label {
  font-weight: bold;
  color: #495057;
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
