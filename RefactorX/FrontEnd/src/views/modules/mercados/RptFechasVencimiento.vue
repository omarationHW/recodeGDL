<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-times" />
      </div>
      <div class="module-view-info">
        <h1>Fechas de Vencimiento</h1>
        <p>Inicio > Mercados > Configuración de Fechas Límite</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalNuevo" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nueva Fecha
        </button>
        <button class="btn-municipal-primary" @click="cargarFechas" :disabled="loading">
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
            <font-awesome-icon icon="calendar" />
          </div>
          <div class="stat-content">
            <div class="stat-value">12</div>
            <div class="stat-label">Meses del Año</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <font-awesome-icon icon="check-circle" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.configurados }}</div>
            <div class="stat-label">Configurados</div>
          </div>
        </div>
        <div class="stat-card stat-card-warning">
          <div class="stat-icon">
            <font-awesome-icon icon="exclamation-circle" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.pendientes }}</div>
            <div class="stat-label">Pendientes</div>
          </div>
        </div>
      </div>

      <!-- Tabla de fechas -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Fechas de Vencimiento Configuradas
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="fechas.length > 0">
              {{ fechas.length }} meses
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando fechas de vencimiento...</p>
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
                  <th>Mes</th>
                  <th>Día Vencimiento</th>
                  <th>Fecha Descuento</th>
                  <th>Fecha Recargo</th>
                  <th>Usuario</th>
                  <th>Última Modificación</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="fechas.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay fechas de vencimiento configuradas</p>
                  </td>
                </tr>
                <tr v-else v-for="fecha in fechas" :key="fecha.mes" class="row-hover">
                  <td>
                    <span class="badge-month">{{ getMesNombre(fecha.mes) }}</span>
                  </td>
                  <td>
                    <span class="badge-day">Día {{ fecha.dia_vencimiento || 'N/A' }}</span>
                  </td>
                  <td>
                    <font-awesome-icon icon="calendar-check" class="icon-small text-success" />
                    {{ formatFecha(fecha.fecha_descuento) }}
                  </td>
                  <td>
                    <font-awesome-icon icon="calendar-times" class="icon-small text-danger" />
                    {{ formatFecha(fecha.fecha_recargo) }}
                  </td>
                  <td>
                    <font-awesome-icon icon="user" class="icon-small text-muted" />
                    {{ fecha.usuario || 'N/A' }}
                  </td>
                  <td>{{ formatFecha(fecha.fecha_modif) }}</td>
                  <td class="text-center">
                    <button class="btn-icon btn-primary" @click="editarFecha(fecha)" title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Edición -->
    <div v-if="showModal" class="modal-backdrop" @click.self="cerrarModal">
      <div class="modal-content">
        <div class="modal-header municipal-modal-header">
          <h5 class="modal-title">
            <font-awesome-icon icon="calendar-edit" />
            {{ modalTitle }}
          </h5>
          <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="guardar">
            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <select
                class="municipal-form-control"
                v-model.number="formData.mes"
                :disabled="isEditMode"
                required>
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Día de Vencimiento <span class="required">*</span></label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formData.dia_vencimiento"
                required
                min="1"
                max="31"
                placeholder="Día del mes (1-31)">
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Descuento <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="formData.fecha_descuento"
                required>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Recargo <span class="required">*</span></label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="formData.fecha_recargo"
                required>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="cerrarModal" :disabled="saving">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="button" class="btn-municipal-primary" @click="guardar" :disabled="saving">
            <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" />
            Guardar
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
const saving = ref(false)
const error = ref('')
const fechas = ref([])
const showModal = ref(false)
const isEditMode = ref(false)

// Formulario
const formData = ref({
  mes: 1,
  dia_vencimiento: null,
  fecha_descuento: '',
  fecha_recargo: ''
})

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const estadisticas = computed(() => {
  const configurados = fechas.value.filter(f => f.dia_vencimiento != null).length
  return {
    configurados,
    pendientes: 12 - configurados
  }
})

const modalTitle = computed(() => {
  return isEditMode.value
    ? `Editar Vencimiento - ${getMesNombre(formData.value.mes)}`
    : 'Nueva Fecha de Vencimiento'
})

// Métodos de UI
const mostrarAyuda = () => {
  showToast('info', 'Configure los días de vencimiento y fechas de descuento/recargo para cada mes del año.')
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
const getMesNombre = (m) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[m - 1] || m
}

const formatFecha = (fecha) => {
  if (!fecha) return 'No configurado'
  try {
    return new Date(fecha).toLocaleDateString('es-MX')
  } catch (e) {
    return fecha
  }
}

// API
const cargarFechas = async () => {
  loading.value = true
  error.value = ''

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_fechas_vencimiento',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      fechas.value = response.data.eResponse.data.result || []
      if (fechas.value.length > 0) {
        showToast('success', `Se cargaron ${fechas.value.length} meses`)
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar fechas'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al cargar fechas'
    console.error('Error al cargar fechas:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const abrirModalNuevo = () => {
  isEditMode.value = false
  formData.value = {
    mes: 1,
    dia_vencimiento: null,
    fecha_descuento: '',
    fecha_recargo: ''
  }
  showModal.value = true
}

const editarFecha = (fecha) => {
  isEditMode.value = true
  formData.value = {
    mes: fecha.mes,
    dia_vencimiento: fecha.dia_vencimiento,
    fecha_descuento: fecha.fecha_descuento ? fecha.fecha_descuento.split('T')[0] : '',
    fecha_recargo: fecha.fecha_recargo ? fecha.fecha_recargo.split('T')[0] : ''
  }
  showModal.value = true
}

const cerrarModal = () => {
  showModal.value = false
  formData.value = {
    mes: 1,
    dia_vencimiento: null,
    fecha_descuento: '',
    fecha_recargo: ''
  }
}

const guardar = async () => {
  if (!formData.value.dia_vencimiento || !formData.value.fecha_descuento || !formData.value.fecha_recargo) {
    showToast('warning', 'Por favor complete todos los campos requeridos')
    return
  }

  saving.value = true

  try {
    const sp = isEditMode.value ? 'sp_update_fecha_vencimiento' : 'sp_insert_fecha_vencimiento'

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: sp,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_mes', Valor: formData.value.mes },
          { Nombre: 'p_dia_vencimiento', Valor: formData.value.dia_vencimiento },
          { Nombre: 'p_fecha_descuento', Valor: formData.value.fecha_descuento },
          { Nombre: 'p_fecha_recargo', Valor: formData.value.fecha_recargo }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      showToast('success', isEditMode.value ? 'Fecha actualizada correctamente' : 'Fecha creada correctamente')
      cerrarModal()
      await cargarFechas()
    } else {
      showToast('error', response.data.eResponse?.message || 'Error al guardar')
    }
  } catch (err) {
    showToast('error', err.response?.data?.eResponse?.message || 'Error al guardar')
    console.error('Error al guardar:', err)
  } finally {
    saving.value = false
  }
}

// Lifecycle
onMounted(() => {
  cargarFechas()
})
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
/* Estilos específicos del componente */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
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

.stat-card-warning {
  border-left-color: #ffc107;
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

.stat-card-warning .stat-icon {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
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
.badge-month {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 8px;
  font-weight: 600;
  font-size: 0.9rem;
  display: inline-block;
}

.badge-day {
  background: #e3f2fd;
  color: #1565c0;
  padding: 0.35rem 0.75rem;
  border-radius: 6px;
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
  align-items: center;
  z-index: 1050;
}

.modal-content {
  background: white;
  border-radius: 12px;
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
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
}

.modal-footer {
  padding: 1.5rem;
  border-top: 1px solid #dee2e6;
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}

/* Otros */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.required {
  color: #dc3545;
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
