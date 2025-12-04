<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="layer-group" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Secciones</h1>
        <p>Inicio > Mercados > Secciones</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalCrear" :disabled="loading">
          <font-awesome-icon icon="plus-circle" />
          Nueva Sección
        </button>
        <button class="btn-municipal-primary" @click="cargarSecciones" :disabled="loading">
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
            <font-awesome-icon icon="layer-group" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.totalSecciones }}</div>
            <div class="stat-label">Secciones Registradas</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon">
            <font-awesome-icon icon="store" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalLocales) }}</div>
            <div class="stat-label">Locales Clasificados</div>
          </div>
        </div>
        <div class="stat-card stat-card-info">
          <div class="stat-icon">
            <font-awesome-icon icon="chart-bar" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.promedio }}</div>
            <div class="stat-label">Promedio Locales/Sección</div>
          </div>
        </div>
      </div>

      <!-- Tabla de secciones -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Secciones
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="secciones.length > 0">
              {{ secciones.length }} secciones
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando secciones...</p>
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
                  <th>Sección</th>
                  <th>Descripción</th>
                  <th class="text-end">Locales</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="secciones.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron secciones registradas</p>
                  </td>
                </tr>
                <tr v-else v-for="seccion in secciones" :key="seccion.seccion" class="row-hover">
                  <td>
                    <span class="badge-seccion">{{ seccion.seccion }}</span>
                  </td>
                  <td>
                    <font-awesome-icon icon="layer-group" class="icon-small text-primary" />
                    <strong>{{ seccion.descripcion }}</strong>
                  </td>
                  <td class="text-end">
                    <span class="badge-count">{{ formatNumber(seccion.cantidad_locales) }}</span>
                  </td>
                  <td class="text-center">
                    <button
                      class="btn-icon btn-warning me-2"
                      @click="abrirModalEditar(seccion)"
                      title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-icon btn-danger"
                      @click="eliminarSeccion(seccion)"
                      title="Eliminar"
                      :disabled="seccion.cantidad_locales > 0">
                      <font-awesome-icon icon="trash" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Crear/Editar Sección -->
    <div v-if="showModal" class="modal-backdrop" @click.self="cerrarModal">
      <div class="modal-content modal-md">
        <div class="modal-header municipal-modal-header">
          <h5 class="modal-title">
            <font-awesome-icon :icon="modoEdicion ? 'edit' : 'plus-circle'" />
            {{ modoEdicion ? 'Editar Sección' : 'Nueva Sección' }}
          </h5>
          <button type="button" class="btn-close btn-close-white" @click="cerrarModal"></button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="guardarSeccion">
            <div class="mb-3">
              <label class="form-label">
                <font-awesome-icon icon="code" class="me-2" />
                Código de Sección <span class="text-danger">*</span>
              </label>
              <input
                type="text"
                v-model="form.seccion"
                class="form-control"
                :readonly="modoEdicion"
                maxlength="2"
                placeholder="Ej: SS, EA, PS"
                required
                @input="form.seccion = form.seccion.toUpperCase()"
              />
              <small class="text-muted">Máximo 2 caracteres</small>
            </div>

            <div class="mb-3">
              <label class="form-label">
                <font-awesome-icon icon="align-left" class="me-2" />
                Descripción <span class="text-danger">*</span>
              </label>
              <input
                type="text"
                v-model="form.descripcion"
                class="form-control"
                maxlength="50"
                placeholder="Descripción de la sección"
                required
              />
              <small class="text-muted">Máximo 50 caracteres</small>
            </div>

            <div class="alert alert-info d-flex align-items-center" v-if="modoEdicion">
              <font-awesome-icon icon="info-circle" class="me-2" />
              <small>El código de sección no puede modificarse</small>
            </div>
          </form>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button
            type="button"
            class="btn-municipal-success"
            @click="guardarSeccion"
            :disabled="guardando">
            <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
            {{ guardando ? 'Guardando...' : 'Guardar' }}
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
const guardando = ref(false)
const error = ref('')
const secciones = ref([])
const showModal = ref(false)
const modoEdicion = ref(false)
const form = ref({
  seccion: '',
  descripcion: ''
})

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Computed
const estadisticas = computed(() => {
  const totalSecciones = secciones.value.length
  const totalLocales = secciones.value.reduce((sum, s) => sum + parseInt(s.cantidad_locales || 0), 0)
  const promedio = totalSecciones > 0 ? Math.round(totalLocales / totalSecciones) : 0

  return {
    totalSecciones,
    totalLocales,
    promedio
  }
})

// Métodos de UI
const mostrarAyuda = () => {
  showToast('info', 'Las secciones permiten clasificar los locales dentro de los mercados (Ej: Tianguis, Edificio Administrativo, etc.)')
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

// Modal
const abrirModalCrear = () => {
  modoEdicion.value = false
  form.value = {
    seccion: '',
    descripcion: ''
  }
  showModal.value = true
}

const abrirModalEditar = (seccion) => {
  modoEdicion.value = true
  form.value = {
    seccion: seccion.seccion.trim(),
    descripcion: seccion.descripcion
  }
  showModal.value = true
}

const cerrarModal = () => {
  showModal.value = false
  form.value = {
    seccion: '',
    descripcion: ''
  }
}

// API
const cargarSecciones = async () => {
  loading.value = true
  error.value = ''

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_secciones_list',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      secciones.value = response.data.eResponse.data.result || []
      if (secciones.value.length > 0) {
        showToast('success', `Se cargaron ${secciones.value.length} secciones`)
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar secciones'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al cargar secciones'
    console.error('Error al cargar secciones:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const guardarSeccion = async () => {
  if (!form.value.seccion.trim() || !form.value.descripcion.trim()) {
    showToast('warning', 'Todos los campos son requeridos')
    return
  }

  guardando.value = true

  try {
    const operacion = modoEdicion.value ? 'sp_secciones_update' : 'sp_secciones_create'

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_seccion', Valor: form.value.seccion.trim().toUpperCase() },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion.trim() }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      const result = response.data.eResponse.data.result[0]

      if (result.success) {
        showToast('success', result.message)
        cerrarModal()
        await cargarSecciones()
      } else {
        showToast('error', result.message)
      }
    } else {
      showToast('error', 'Error al guardar la sección')
    }
  } catch (err) {
    console.error('Error al guardar sección:', err)
    showToast('error', err.response?.data?.eResponse?.message || 'Error al guardar la sección')
  } finally {
    guardando.value = false
  }
}

const eliminarSeccion = async (seccion) => {
  if (seccion.cantidad_locales > 0) {
    showToast('warning', `No se puede eliminar. Hay ${seccion.cantidad_locales} locales asociados`)
    return
  }

  if (!confirm(`¿Está seguro de eliminar la sección "${seccion.seccion} - ${seccion.descripcion}"?`)) {
    return
  }

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_secciones_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_seccion', Valor: seccion.seccion.trim() }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      const result = response.data.eResponse.data.result[0]

      if (result.success) {
        showToast('success', result.message)
        await cargarSecciones()
      } else {
        showToast('error', result.message)
      }
    } else {
      showToast('error', 'Error al eliminar la sección')
    }
  } catch (err) {
    console.error('Error al eliminar sección:', err)
    showToast('error', err.response?.data?.eResponse?.message || 'Error al eliminar la sección')
  }
}

// Lifecycle
onMounted(() => {
  cargarSecciones()
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
.badge-seccion {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 0.4rem 0.85rem;
  border-radius: 6px;
  font-weight: 700;
  font-size: 0.9rem;
  display: inline-block;
  font-family: 'Courier New', monospace;
  letter-spacing: 0.5px;
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
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}

.modal-md {
  max-width: 600px;
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

/* Form */
.form-label {
  font-weight: 600;
  color: #495057;
  margin-bottom: 0.5rem;
}

.form-control {
  border: 1px solid #ced4da;
  border-radius: 6px;
  padding: 0.75rem;
  font-size: 0.95rem;
  transition: border-color 0.2s ease, box-shadow 0.2s ease;
}

.form-control:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
  outline: none;
}

.form-control:readonly {
  background-color: #e9ecef;
  cursor: not-allowed;
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

.btn-icon.btn-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: white;
}

.btn-icon.btn-warning:hover {
  transform: scale(1.1);
  box-shadow: 0 4px 8px rgba(255, 193, 7, 0.3);
}

.btn-icon.btn-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
}

.btn-icon.btn-danger:hover:not(:disabled) {
  transform: scale(1.1);
  box-shadow: 0 4px 8px rgba(220, 53, 69, 0.3);
}

.btn-icon:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>
