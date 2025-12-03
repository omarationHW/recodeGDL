<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Claves para la Cuota</h1>
        <p>Inicio > Catálogos > Claves de Cuota</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalNuevo" :disabled="loading">
          <font-awesome-icon icon="plus" /> Nuevo
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Claves de Cuota</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="items.length > 0">{{ items.length }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos...</p>
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Clave Cuota</th>
                  <th>Descripción</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="items.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay claves registradas. Cree una nueva clave.</p>
                  </td>
                </tr>
                <tr v-else v-for="(item, idx) in items" :key="item.clave_cuota" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td><span class="badge-primary">{{ item.clave_cuota }}</span></td>
                  <td>{{ item.descripcion }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-sm btn-municipal-warning me-1" @click="editarItem(item)">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button class="btn-municipal-sm btn-municipal-danger" @click="confirmarEliminar(item)">
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

    <!-- Modal CRUD -->
    <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="key" />
              {{ isEdit ? 'Editar Clave de Cuota' : 'Nueva Clave de Cuota' }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal"></button>
          </div>
          <div class="modal-body">
            <div class="mb-3">
              <label class="municipal-form-label">Clave Cuota <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.clave_cuota"
                     min="1" max="5000" required :readonly="isEdit" />
            </div>
            <div class="mb-3">
              <label class="municipal-form-label">Descripción <span class="required">*</span></label>
              <input type="text" class="municipal-form-control text-uppercase" v-model="form.descripcion"
                     maxlength="60" required />
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-primary" @click="guardar" :disabled="!isFormValid || loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
              {{ isEdit ? 'Actualizar' : 'Guardar' }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Confirmación Eliminar -->
    <div v-if="showDeleteConfirm" class="modal-overlay" @click.self="cancelarEliminar">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
          <div class="modal-header bg-danger text-white">
            <h5 class="modal-title">
              <font-awesome-icon icon="exclamation-triangle" /> Confirmar Eliminación
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="cancelarEliminar"></button>
          </div>
          <div class="modal-body">
            <p>¿Está seguro de eliminar esta clave de cuota?</p>
            <div class="alert alert-warning">
              <strong>Clave:</strong> {{ itemAEliminar?.clave_cuota }}<br>
              <strong>Descripción:</strong> {{ itemAEliminar?.descripcion }}
            </div>
            <p class="text-danger"><strong>Esta acción no se puede deshacer.</strong></p>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cancelarEliminar">
              <font-awesome-icon icon="times" /> Cancelar
            </button>
            <button type="button" class="btn-municipal-danger" @click="eliminar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'trash'" :spin="loading" />
              Eliminar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast -->
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

const items = ref([])
const itemAEliminar = ref(null)
const loading = ref(false)
const showModal = ref(false)
const showDeleteConfirm = ref(false)
const isEdit = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

const form = ref({
  clave_cuota: null,
  descripcion: ''
})

const isFormValid = computed(() => {
  return form.value.clave_cuota >= 1 && form.value.clave_cuota <= 5000 && form.value.descripcion.trim().length > 0
})

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const mostrarAyuda = () => {
  showToast('info', 'Administre las claves de cuota del sistema. Puede crear, editar o eliminar claves de cuota.')
}

const cargarItems = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_cve_cuota_list', Base: 'mercados', Parametros: [] }
    })
    if (res.data.eResponse.success) {
      items.value = res.data.eResponse.data.result || []
      if (items.value.length > 0) {
        showToast('success', `Se cargaron ${items.value.length} claves`)
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al cargar claves')
    }
  } catch (err) {
    showToast('error', 'Error de conexión')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const abrirModalNuevo = () => {
  isEdit.value = false
  form.value = { clave_cuota: null, descripcion: '' }
  showModal.value = true
}

const editarItem = (item) => {
  isEdit.value = true
  form.value = { clave_cuota: item.clave_cuota, descripcion: item.descripcion }
  showModal.value = true
}

const guardar = async () => {
  if (!isFormValid.value) {
    showToast('warning', 'Complete todos los campos correctamente')
    return
  }

  loading.value = true
  try {
    const operacion = isEdit.value ? 'sp_cve_cuota_update' : 'sp_cve_cuota_insert'
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_clave_cuota', Valor: parseInt(form.value.clave_cuota) },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion.toUpperCase() }
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0][operacion.replace('sp_cve_cuota_', '')]) {
        showToast('success', isEdit.value ? 'Clave actualizada' : 'Clave creada')
        cerrarModal()
        cargarItems()
      } else {
        showToast('error', 'La clave ya existe')
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al guardar')
    }
  } catch (err) {
    showToast('error', 'Error de conexión')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const confirmarEliminar = (item) => {
  itemAEliminar.value = item
  showDeleteConfirm.value = true
}

const cancelarEliminar = () => {
  itemAEliminar.value = null
  showDeleteConfirm.value = false
}

const eliminar = async () => {
  if (!itemAEliminar.value) return

  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cve_cuota_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_clave_cuota', Valor: parseInt(itemAEliminar.value.clave_cuota) }
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0].delete) {
        showToast('success', 'Clave eliminada')
        cancelarEliminar()
        cargarItems()
      } else {
        showToast('error', 'No se pudo eliminar')
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al eliminar')
    }
  } catch (err) {
    showToast('error', 'Error de conexión')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const cerrarModal = () => {
  showModal.value = false
  isEdit.value = false
}

onMounted(() => {
  cargarItems()
})
</script>

<style scoped>
.empty-icon {
  color: #6c757d;
  opacity: 0.5;
  margin-bottom: 1rem;
}

.badge-primary {
  background: var(--municipal-blue);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
}

.btn-municipal-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

.btn-municipal-warning {
  background: linear-gradient(135deg, #ffc107 0%, #ff9800 100%);
  color: #000;
  border: none;
  transition: all 0.3s ease;
}

.btn-municipal-warning:hover {
  background: linear-gradient(135deg, #ff9800 0%, #f57c00 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(255, 152, 0, 0.3);
}

.btn-municipal-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  border: none;
  transition: all 0.3s ease;
}

.btn-municipal-danger:hover {
  background: linear-gradient(135deg, #c82333 0%, #bd2130 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
}

.required {
  color: #dc3545;
}

.bg-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%) !important;
}

.text-uppercase {
  text-transform: uppercase;
}
</style>
