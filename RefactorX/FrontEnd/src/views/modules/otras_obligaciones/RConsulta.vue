<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Consulta</h1>
        <p>Otras Obligaciones - Consulta de información de contratos</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tarjeta de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Control
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="handleBuscar">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  Control <span class="required">*</span>
                </label>
                <div class="control-input-group">
                  <input
                    type="text"
                    v-model="formData.numero"
                    class="municipal-form-control control-numero"
                    placeholder="Número"
                    maxlength="10"
                    required
                  />
                  <span class="control-separator">-</span>
                  <input
                    type="text"
                    v-model="formData.letra"
                    class="municipal-form-control control-letra"
                    placeholder="Letra"
                    maxlength="5"
                  />
                </div>
              </div>
            </div>

            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                {{ loading ? 'Buscando...' : 'Buscar' }}
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiarFormulario"
                :disabled="loading"
              >
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Stats cards (cuando hay datos) -->
      <div class="stats-cards" v-if="datosLocal.control">
        <div class="stat-card stat-card-primary">
          <div class="stat-card-icon">
            <font-awesome-icon icon="id-card" />
          </div>
          <div class="stat-card-content">
            <span class="stat-card-value">{{ datosLocal.control }}</span>
            <span class="stat-card-label">Control</span>
          </div>
        </div>

        <div class="stat-card stat-card-success" v-if="datosLocal.statusregistro === 'VIGENTE'">
          <div class="stat-card-icon">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-card-content">
            <span class="stat-card-value">{{ datosLocal.statusregistro }}</span>
            <span class="stat-card-label">Status</span>
          </div>
        </div>

        <div class="stat-card stat-card-danger" v-else-if="datosLocal.statusregistro === 'CANCELADO'">
          <div class="stat-card-icon">
            <font-awesome-icon icon="times-circle" />
          </div>
          <div class="stat-card-content">
            <span class="stat-card-value">{{ datosLocal.statusregistro }}</span>
            <span class="stat-card-label">Status</span>
          </div>
        </div>

        <div class="stat-card stat-card-warning" v-else>
          <div class="stat-card-icon">
            <font-awesome-icon icon="exclamation-circle" />
          </div>
          <div class="stat-card-content">
            <span class="stat-card-value">{{ datosLocal.statusregistro || 'Desconocido' }}</span>
            <span class="stat-card-label">Status</span>
          </div>
        </div>

        <div class="stat-card stat-card-purple">
          <div class="stat-card-icon">
            <font-awesome-icon icon="file-contract" />
          </div>
          <div class="stat-card-content">
            <span class="stat-card-value">{{ datosLocal.licencia || 'N/A' }}</span>
            <span class="stat-card-label">Licencia</span>
          </div>
        </div>
      </div>

      <!-- Tarjeta de información del local -->
      <div class="municipal-card" v-if="datosLocal.control">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Local
          </h5>
          <button
            class="btn-municipal-success"
            @click="handleExportar"
            :disabled="loading"
          >
            <font-awesome-icon icon="file-excel" />
            Exportar Excel
          </button>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>
                <font-awesome-icon icon="id-card" />
                Control:
              </label>
              <span class="badge-purple">{{ datosLocal.control }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="user" />
                Concesionario:
              </label>
              <span>{{ datosLocal.concesionario }}</span>
            </div>
            <div class="info-item full-width">
              <label>
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación:
              </label>
              <span>{{ datosLocal.ubicacion }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="ruler-combined" />
                Superficie:
              </label>
              <span>{{ datosLocal.superficie }} m²</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="file-contract" />
                Licencia:
              </label>
              <span>{{ datosLocal.licencia }}</span>
            </div>
            <div class="info-item">
              <label>
                <font-awesome-icon icon="clipboard-check" />
                Status:
              </label>
              <span :class="getStatusClass()">{{ datosLocal.statusregistro }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.nomcomercial">
              <label>
                <font-awesome-icon icon="store" />
                Nombre Comercial:
              </label>
              <span>{{ datosLocal.nomcomercial }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.lugar">
              <label>
                <font-awesome-icon icon="location-arrow" />
                Lugar:
              </label>
              <span>{{ datosLocal.lugar }}</span>
            </div>
            <div class="info-item full-width" v-if="datosLocal.obs">
              <label>
                <font-awesome-icon icon="comment-dots" />
                Observaciones:
              </label>
              <span>{{ datosLocal.obs }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.recaudadora">
              <label>
                <font-awesome-icon icon="building" />
                Recaudadora:
              </label>
              <span>{{ datosLocal.recaudadora }}</span>
            </div>
            <div class="info-item" v-if="datosLocal.fechainicio">
              <label>
                <font-awesome-icon icon="calendar-alt" />
                Fecha Inicio:
              </label>
              <span>{{ formatDate(datosLocal.fechainicio) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>{{ loadingMessage }}</p>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'RConsulta'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import * as XLSX from 'xlsx'

// Router
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado local de loading
const loading = ref(false)
const loadingMessage = ref('Cargando...')

// Estado
const datosLocal = ref({})
const formData = reactive({
  numero: '',
  letra: ''
})

// Métodos
const handleBuscar = async () => {
  if (!formData.numero) {
    showToast('warning', 'Debe ingresar el número de control', null)
    return
  }

  const startTime = performance.now()
  loading.value = true
  loadingMessage.value = 'Buscando control...'
  showLoading('Consultando datos...', 'Procesando búsqueda')

  try {
    const control = `${formData.numero}${formData.letra ? '-' + formData.letra : ''}`

    const response = await execute(
      'sp_otras_oblig_buscar_cont',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: 3, tipo: 'integer' },
        { nombre: 'par_control', valor: control, tipo: 'varchar' }
      ],
      '',
      null,
      'public'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1
      ? `${(duration * 1000).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.status === 1) {
        showToast('warning', 'No se encontró el control especificado', timeMessage)
        datosLocal.value = {}
      } else {
        datosLocal.value = resultado
        showToast('success', 'Control encontrado correctamente', timeMessage)
      }
    } else {
      showToast('warning', 'No se encontró el control', timeMessage)
      datosLocal.value = {}
    }
  } catch (error) {
    handleApiError(error)
    datosLocal.value = {}
  } finally {
    loading.value = false
    hideLoading()
  }
}

const handleExportar = () => {
  if (!datosLocal.value.control) {
    showToast('warning', 'No hay datos para exportar', null)
    return
  }

  try {
    const dataExport = [{
      'Control': datosLocal.value.control,
      'Concesionario': datosLocal.value.concesionario,
      'Ubicación': datosLocal.value.ubicacion,
      'Nombre Comercial': datosLocal.value.nomcomercial,
      'Lugar': datosLocal.value.lugar,
      'Superficie': datosLocal.value.superficie,
      'Licencia': datosLocal.value.licencia,
      'Status': datosLocal.value.statusregistro,
      'Recaudadora': datosLocal.value.recaudadora,
      'Fecha Inicio': formatDate(datosLocal.value.fechainicio),
      'Observaciones': datosLocal.value.obs
    }]

    const ws = XLSX.utils.json_to_sheet(dataExport)
    const wb = XLSX.utils.book_new()
    XLSX.utils.book_append_sheet(wb, ws, 'Consulta')

    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19)
    XLSX.writeFile(wb, `RConsulta_${datosLocal.value.control}_${timestamp}.xlsx`)

    showToast('success', 'Archivo exportado correctamente', null)
  } catch (error) {
    console.error('Error al exportar:', error)
    showToast('error', 'Error al exportar el archivo', null)
  }
}

const limpiarFormulario = () => {
  formData.numero = ''
  formData.letra = ''
  datosLocal.value = {}
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

const getStatusClass = () => {
  if (!datosLocal.value.statusregistro) return 'badge-secondary'

  const status = datosLocal.value.statusregistro.toUpperCase()

  if (status === 'VIGENTE') return 'badge-success'
  if (status === 'CANCELADO') return 'badge-danger'
  if (status === 'SUSPENSION' || status === 'SUSPENDIDO') return 'badge-warning'

  return 'badge-secondary'
}
</script>

<style scoped>
/* Control input group */
.control-input-group {
  display: flex;
  align-items: center;
  gap: 8px;
}

.control-numero {
  flex: 0 0 120px;
  max-width: 120px;
}

.control-letra {
  flex: 0 0 100px;
  max-width: 100px;
}

.control-separator {
  font-weight: bold;
  font-size: 1.2rem;
  color: #666;
}

/* Stats cards */
.stats-cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1.5rem;
}

.stat-card {
  background: white;
  border-radius: 8px;
  padding: 1rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  border-left: 4px solid #ea8215;
}

.stat-card-primary { border-left-color: #ea8215; }
.stat-card-success { border-left-color: #28a745; }
.stat-card-danger { border-left-color: #dc3545; }
.stat-card-warning { border-left-color: #ffc107; }
.stat-card-purple { border-left-color: #6f42c1; }

.stat-card-icon {
  font-size: 2rem;
  color: #ea8215;
  flex-shrink: 0;
}

.stat-card-primary .stat-card-icon { color: #ea8215; }
.stat-card-success .stat-card-icon { color: #28a745; }
.stat-card-danger .stat-card-icon { color: #dc3545; }
.stat-card-warning .stat-card-icon { color: #ffc107; }
.stat-card-purple .stat-card-icon { color: #6f42c1; }

.stat-card-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.stat-card-value {
  font-size: 1.25rem;
  font-weight: 600;
  color: #2c3e50;
}

.stat-card-label {
  font-size: 0.875rem;
  color: #666;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Info grid improvements */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 0.75rem;
  background: #f8f9fa;
  border-radius: 6px;
}

.info-item.full-width {
  grid-column: 1 / -1;
}

.info-item label {
  font-weight: 600;
  color: #495057;
  font-size: 0.875rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.info-item label svg {
  color: #ea8215;
}

.info-item span {
  color: #2c3e50;
  font-size: 0.9375rem;
}

/* Required field indicator */
.required {
  color: #dc3545;
  font-weight: bold;
  margin-left: 2px;
}
</style>
