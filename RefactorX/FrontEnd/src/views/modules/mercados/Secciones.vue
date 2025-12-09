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
        <button class="btn-municipal-primary" @click="abrirModalCrear" :disabled="loading">
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
          <div class="stat-icon-wrapper">
            <font-awesome-icon icon="layer-group" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ estadisticas.totalSecciones }}</div>
            <div class="stat-label">Secciones Registradas</div>
          </div>
        </div>
        <div class="stat-card stat-card-success">
          <div class="stat-icon-wrapper">
            <font-awesome-icon icon="store" />
          </div>
          <div class="stat-content">
            <div class="stat-value">{{ formatNumber(estadisticas.totalLocales) }}</div>
            <div class="stat-label">Locales Clasificados</div>
          </div>
        </div>
        <div class="stat-card stat-card-info">
          <div class="stat-icon-wrapper">
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
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="abrirModalEditar(seccion)"
                        title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        class="btn-municipal-danger btn-sm"
                        @click.stop="eliminarSeccion(seccion)"
                        title="Eliminar"
                        :disabled="seccion.cantidad_locales > 0">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Crear/Editar Sección -->
    <Modal
      v-if="showModal"
      :show="showModal"
      :title="modoEdicion ? 'Editar Sección' : 'Nueva Sección'"
      :icon="modoEdicion ? 'edit' : 'plus-circle'"
      size="md"
      @close="cerrarModal">
        <form @submit.prevent="guardarSeccion">
          <div class="mb-3">
            <label class="municipal-form-label">
              <font-awesome-icon icon="code" class="me-2" />
              Código de Sección <span class="text-danger">*</span>
            </label>
            <input
              type="text"
              v-model="form.seccion"
              class="municipal-form-control"
              :readonly="modoEdicion"
              maxlength="2"
              placeholder="Ej: SS, EA, PS"
              required
              @input="form.seccion = form.seccion.toUpperCase()"
            />
            <small class="text-muted">Máximo 2 caracteres</small>
          </div>

          <div class="mb-3">
            <label class="municipal-form-label">
              <font-awesome-icon icon="align-left" class="me-2" />
              Descripción <span class="text-danger">*</span>
            </label>
            <input
              type="text"
              v-model="form.descripcion"
              class="municipal-form-control"
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

      <template #footer>
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
      </template>
    </Modal>

    <!-- Modal de Confirmación de Eliminación -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="cancelarEliminacion">
      <div class="modal-dialog-confirm" @click.stop>
        <div class="modal-header-confirm">
          <font-awesome-icon icon="exclamation-triangle" class="modal-icon-warning" />
          <h5 class="modal-title-confirm">Confirmar Eliminación</h5>
        </div>
        <div class="modal-body-confirm">
          <p>¿Está seguro de eliminar la sección?</p>
          <div class="section-info" v-if="seccionAEliminar">
            <strong>{{ seccionAEliminar.seccion }}</strong> - {{ seccionAEliminar.descripcion }}
          </div>
          <p class="text-muted mt-3">Esta acción no se puede deshacer.</p>
        </div>
        <div class="modal-footer-confirm">
          <button type="button" class="btn-cancel" @click="cancelarEliminacion">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="button" class="btn-delete" @click="confirmarEliminacion">
            <font-awesome-icon icon="trash" />
            Eliminar
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'

// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const loading = ref(false)
const guardando = ref(false)
const error = ref('')
const secciones = ref([])
const showModal = ref(false)
const modoEdicion = ref(false)
const showDeleteModal = ref(false)
const seccionAEliminar = ref(null)
const form = ref({
  seccion: '',
  descripcion: ''
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
  showToast('Las secciones permiten clasificar los locales dentro de los mercados (Ej: Tianguis, Edificio Administrativo, etc.)', 'info')
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
  showLoading('Cargando secciones...')

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
        showToast(`Se cargaron ${secciones.value.length} secciones`, 'success')
      }
    } else {
      error.value = response.data.eResponse?.message || 'Error al cargar secciones'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = err.response?.data?.eResponse?.message || 'Error al cargar secciones'
    console.error('Error al cargar secciones:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const guardarSeccion = async () => {
  if (!form.value.seccion.trim() || !form.value.descripcion.trim()) {
    showToast('Todos los campos son requeridos', 'warning')
    return
  }

  guardando.value = true
  showLoading(modoEdicion.value ? 'Actualizando sección...' : 'Guardando sección...')

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
        showToast(result.message, 'success')
        cerrarModal()
        await cargarSecciones()
      } else {
        showToast(result.message, 'error')
      }
    } else {
      showToast('Error al guardar la sección', 'error')
    }
  } catch (err) {
    console.error('Error al guardar sección:', err)
    showToast(err.response?.data?.eResponse?.message || 'Error al guardar la sección', 'error')
  } finally {
    guardando.value = false
    hideLoading()
  }
}

const eliminarSeccion = (seccion) => {
  if (seccion.cantidad_locales > 0) {
    showToast(`No se puede eliminar. Hay ${seccion.cantidad_locales} locales asociados`, 'warning')
    return
  }

  seccionAEliminar.value = seccion
  showDeleteModal.value = true
}

const cancelarEliminacion = () => {
  showDeleteModal.value = false
  seccionAEliminar.value = null
}

const confirmarEliminacion = async () => {
  if (!seccionAEliminar.value) return

  showDeleteModal.value = false
  showLoading('Eliminando sección...')

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_secciones_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_seccion', Valor: seccionAEliminar.value.seccion.trim() }
        ]
      }
    })

    if (response.data.eResponse && response.data.eResponse.success === true) {
      const result = response.data.eResponse.data.result[0]

      if (result.success) {
        showToast(result.message, 'success')
        await cargarSecciones()
      } else {
        showToast(result.message, 'error')
      }
    } else {
      showToast('Error al eliminar la sección', 'error')
    }
  } catch (err) {
    console.error('Error al eliminar sección:', err)
    showToast(err.response?.data?.eResponse?.message || 'Error al eliminar la sección', 'error')
  } finally {
    hideLoading()
    seccionAEliminar.value = null
  }
}

// Lifecycle
onMounted(() => {
  cargarSecciones()
})
</script>

<style scoped>
/* Modal Overlay */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1050;
  animation: fadeIn 0.2s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

/* Modal Dialog */
.modal-dialog-confirm {
  background: white;
  border-radius: 12px;
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
  max-width: 480px;
  width: 90%;
  animation: slideDown 0.3s ease-out;
  overflow: hidden;
}

@keyframes slideDown {
  from {
    transform: translateY(-50px);
    opacity: 0;
  }
  to {
    transform: translateY(0);
    opacity: 1;
  }
}

/* Modal Header */
.modal-header-confirm {
  padding: 24px;
  background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
  color: white;
  display: flex;
  align-items: center;
  gap: 12px;
}

.modal-icon-warning {
  font-size: 28px;
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% {
    opacity: 1;
  }
  50% {
    opacity: 0.6;
  }
}

.modal-title-confirm {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

/* Modal Body */
.modal-body-confirm {
  padding: 24px;
}

.modal-body-confirm p {
  margin: 0 0 12px 0;
  color: #333;
  font-size: 15px;
}

.section-info {
  background: #f5f5f5;
  border-left: 4px solid #f44336;
  padding: 12px 16px;
  border-radius: 4px;
  margin: 16px 0;
}

.section-info strong {
  color: #f44336;
  font-size: 16px;
}

/* Modal Footer */
.modal-footer-confirm {
  padding: 16px 24px;
  background: #f8f9fa;
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  border-top: 1px solid #e9ecef;
}

/* Buttons */
.btn-cancel,
.btn-delete {
  padding: 10px 20px;
  border: none;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  gap: 8px;
  transition: all 0.2s;
}

.btn-cancel {
  background: #6c757d;
  color: white;
}

.btn-cancel:hover {
  background: #5a6268;
  transform: translateY(-1px);
  box-shadow: 0 4px 8px rgba(108, 117, 125, 0.3);
}

.btn-delete {
  background: linear-gradient(135deg, #f44336 0%, #d32f2f 100%);
  color: white;
}

.btn-delete:hover {
  background: linear-gradient(135deg, #d32f2f 0%, #c62828 100%);
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(244, 67, 54, 0.4);
}

.btn-cancel:active,
.btn-delete:active {
  transform: translateY(0);
}
</style>
