<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="tags" />
      </div>
      <div class="module-view-info">
        <h1>Giros Comerciales</h1>
        <p>Inicio > Mercados > Catálogo de Giros</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="cargarGiros" :disabled="loading">
          <font-awesome-icon :icon="loading ? 'spinner' : 'sync'" :spin="loading" />
          Recargar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Estadísticas -->
      <div class="stats-grid mb-4">
        <div class="stat-card stat-card-primary">
          <div class="stat-icon">
            <font-awesome-icon icon="tags" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalGiros) }}</div>
            <div class="stat-label">Giros Registrados</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <font-awesome-icon icon="store" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalLocales) }}</div>
            <div class="stat-label">Locales con Giro</div>
          </div>
        </div>
        <div class="stat-card stat-card-info">
          <div class="stat-icon">
            <font-awesome-icon icon="chart-bar" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.promedio }}</div>
            <div class="stat-label">Promedio Locales/Giro</div>
          </div>
        </div>
      </div>

      <!-- Tabla de giros -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Giros
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="giros.length > 0">
              {{ giros.length }} giros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando giros...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Descripción</th>
                  <th class="text-end">Locales</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="giros.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron giros registrados</p>
                  </td>
                </tr>
                <tr v-else v-for="giro in giros" :key="giro.id_giro" class="row-hover">
                  <td>
                    <span class="badge-id">{{ giro.id_giro }}</span>
                  </td>
                  <td>
                    <font-awesome-icon icon="tag" class="icon-small text-primary" />
                    <strong>{{ giro.descripcion }}</strong>
                  </td>
                  <td class="text-end">
                    <span class="badge-count">{{ formatNumber(giro.cantidad_locales) }}</span>
                  </td>
                  <td class="text-center">
                    <button
                      class="btn-icon btn-primary"
                      @click="verLocales(giro)"
                      title="Ver locales">
                      <font-awesome-icon icon="eye" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Locales por Giro -->
    <div v-if="showModal" class="modal-backdrop" @click.self="cerrarModal">
      <div class="modal-content modal-xl">
        <div class="modal-header municipal-modal-header">
          <h5 class="modal-title">
            <font-awesome-icon icon="store" />
            Locales con Giro: {{ giroSeleccionado?.descripcion }}
          </h5>
          <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
        </div>
        <div class="modal-body">
          <!-- Loading -->
          <div v-if="loadingLocales" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando locales...</p>
          </div>

          <!-- Tabla de locales -->
          <div v-else class="table-responsive">
            <table class="table-custom">
              <thead>
                <tr>
                  <th>Control</th>
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Nombre</th>
                  <th>Arrendatario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales</p>
                  </td>
                </tr>
                <tr v-else v-for="local in locales" :key="local.id_local" class="table-row-hover">
                  <td><strong class="text-primary">{{ local.id_local }}</strong></td>
                  <td>{{ local.oficina }}</td>
                  <td>{{ local.num_mercado }}</td>
                  <td>{{ local.categoria }}</td>
                  <td>{{ local.seccion }}</td>
                  <td><span class="badge-local">{{ local.local }}</span></td>
                  <td>{{ local.letra_local || '-' }}</td>
                  <td>{{ local.nombre || 'N/A' }}</td>
                  <td>{{ local.arrendatario || 'N/A' }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'

// Estado
const loading = ref(false)
const loadingLocales = ref(false)
const error = ref('')
const giros = ref([])
const locales = ref([])
const showModal = ref(false)
const giroSeleccionado = ref(null)

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const estadisticas = computed(() => {
  const totalGiros = giros.value.length
  const totalLocales = giros.value.reduce((sum, g) => sum + parseInt(g.cantidad_locales || 0), 0)
  const promedio = totalGiros > 0 ? Math.round(totalLocales / totalGiros) : 0

  return {
    totalGiros,
    totalLocales,
    promedio
  }
})

// Métodos de UI
const mostrarAyuda = () => {
  showToast('info', 'Este catálogo muestra todos los giros comerciales registrados en los locales de mercados.')
}

const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Utilidades
const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// API
const cargarGiros = async () => {
  loading.value = true
  error.value = ''

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_giros_list',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      giros.value = response.data.eResponse.data.result || []
      if (giros.value.length > 0) {
        showToast('success', `Se cargaron ${giros.value.length} giros`)
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar giros'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al cargar giros'
    console.error('Error al cargar giros:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const verLocales = async (giro) => {
  giroSeleccionado.value = giro
  showModal.value = true
  loadingLocales.value = true
  locales.value = []

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_giros_locales',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_giro', Valor: giro.id_giro }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      locales.value = response.data.eResponse.data.result || []
    } else {
      showToast('error', 'Error al cargar locales')
    }
  } catch (err) {
    console.error('Error al cargar locales:', err)
    showToast('error', 'Error al cargar locales')
  } finally {
    loadingLocales.value = false
  }
}

const cerrarModal = () => {
  showModal.value = false
  locales.value = []
  giroSeleccionado.value = null
}

// Lifecycle
onMounted(() => {
  cargarGiros()
})
</script>

<style scoped>
/* Estadísticas */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.stat-card {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  border-left: 4px solid;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.stat-card-primary {
  border-left-color: #667eea;
}

.stat-card-success {
  border-left-color: #28a745;
}

.stat-card-info {
  border-left-color: #17a2b8;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}

.stat-card-primary .stat-icon {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.stat-card-success .stat-icon {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  color: white;
}

.stat-card-info .stat-icon {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
  color: white;
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 2rem;
  font-weight: 700;
  color: #2c3e50;
  line-height: 1;
}

.stat-label {
  font-size: 0.9rem;
  color: #6c757d;
  margin-top: 0.25rem;
}

/* Badges */
.badge-id {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-block;
}

.badge-count {
  background: #e8f5e9;
  color: #2e7d32;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
  font-weight: 600;
  font-size: 0.9rem;
  display: inline-block;
}

.badge-local {
  background: #e3f2fd;
  color: #1565c0;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
  font-size: 0.85rem;
  display: inline-block;
}

/* Modal */
.modal-backdrop {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 50px;
  z-index: 1050;
  overflow-y: auto;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 95%;
  max-width: 1000px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.modal-xl {
  max-width: 1200px;
}

.municipal-modal-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 1.5rem;
  border-radius: 12px 12px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  font-size: 1.25rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin: 0;
}

.modal-body {
  padding: 2rem;
  max-height: 60vh;
  overflow-y: auto;
}

.modal-footer {
  padding: 1.5rem;
  border-top: 1px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

/* Tabla dentro del modal */
.table-custom {
  width: 100%;
  border-collapse: separate;
  border-spacing: 0;
  font-size: 0.85rem;
}

.table-custom thead {
  background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
}

.table-custom thead th {
  padding: 0.75rem;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
  text-transform: uppercase;
  font-size: 0.75rem;
  letter-spacing: 0.5px;
}

.table-custom tbody td {
  padding: 0.75rem;
  border-bottom: 1px solid #f1f3f5;
  vertical-align: middle;
}

.table-row-hover {
  transition: all 0.2s ease;
}

.table-row-hover:hover {
  background-color: #f8f9fa;
}

/* Otros */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.row-hover:hover {
  background-color: #f8f9fa;
  cursor: pointer;
}

.icon-small {
  font-size: 0.85rem;
  margin-right: 0.35rem;
}

.btn-icon {
  width: 32px;
  height: 32px;
  padding: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-icon.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-icon.btn-primary:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 8px rgba(102, 126, 234, 0.3);
}
</style>
