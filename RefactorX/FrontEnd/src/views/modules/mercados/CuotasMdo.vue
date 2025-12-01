<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="dollar-sign" />
      </div>
      <div class="module-view-info">
        <h1>Cuotas de Mercados</h1>
        <p>Inicio > Mercados > Cuotas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="openCreate">
          <font-awesome-icon icon="plus" />
          Agregar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="axo" class="municipal-form-control" min="2000" max="2100" :disabled="loading" />
            </div>
            <div class="form-group align-self-end">
              <button class="btn-municipal-primary" @click="fetchCuotas" :disabled="loading">
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Cuotas -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Cuotas
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="cuotas.length > 0">
              {{ cuotas.length }} registros
            </span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando cuotas...</p>
          </div>

          <div v-else-if="cuotas.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Categoría</th>
                  <th>Sección</th>
                  <th>Clave Cuota</th>
                  <th>Descripción</th>
                  <th class="text-end">Importe</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cuota in cuotas" :key="cuota.id_cuotas" class="row-hover">
                  <td>{{ cuota.axo }}</td>
                  <td>{{ cuota.categoria }}</td>
                  <td>{{ cuota.seccion }}</td>
                  <td>{{ cuota.clave_cuota }}</td>
                  <td>{{ cuota.descripcion }}</td>
                  <td class="text-end">{{ formatCurrency(cuota.importe_cuota) }}</td>
                  <td>{{ formatDate(cuota.fecha_alta) }}</td>
                  <td>{{ cuota.usuario }}</td>
                  <td class="text-center">
                    <button class="btn-municipal-warning btn-sm me-1" @click="editCuota(cuota)" title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button class="btn-municipal-danger btn-sm" @click="deleteCuota(cuota)" title="Eliminar">
                      <font-awesome-icon icon="trash" />
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="text-center text-muted py-4">
            <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
            <p>No hay cuotas registradas para el año seleccionado</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-container">
        <div class="modal-header">
          <h5>
            <font-awesome-icon :icon="showEdit ? 'edit' : 'plus-circle'" />
            {{ showEdit ? 'Editar Cuota' : 'Agregar Cuota' }}
          </h5>
          <button class="modal-close" @click="closeModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="showEdit ? updateCuota() : createCuota()">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Año <span class="required">*</span></label>
                <input type="number" v-model.number="form.axo" class="municipal-form-control" required min="2000" max="2100" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <select v-model="form.categoria" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                    {{ cat.categoria }} - {{ cat.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select v-model="form.seccion" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }} - {{ sec.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Clave Cuota <span class="required">*</span></label>
                <select v-model="form.clave_cuota" class="municipal-form-control" required>
                  <option value="">Seleccione...</option>
                  <option v-for="cve in clavesCuota" :key="cve.clave_cuota" :value="cve.clave_cuota">
                    {{ cve.clave_cuota }} - {{ cve.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Importe <span class="required">*</span></label>
                <input type="number" v-model.number="form.importe_cuota" class="municipal-form-control" required min="0.01" step="0.01" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Usuario <span class="required">*</span></label>
                <input type="number" v-model.number="form.id_usuario" class="municipal-form-control" required />
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn-municipal-secondary" @click="closeModal">
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
              <button type="submit" class="btn-municipal-primary" :disabled="saving">
                <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" />
                {{ showEdit ? 'Actualizar' : 'Guardar' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal Confirmar Eliminación -->
    <div v-if="showDeleteModal" class="modal-overlay" @click.self="closeDeleteModal">
      <div class="modal-container modal-sm">
        <div class="modal-header modal-header-danger">
          <h5>
            <font-awesome-icon icon="exclamation-triangle" />
            Confirmar Eliminación
          </h5>
          <button class="modal-close" @click="closeDeleteModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body text-center">
          <div class="delete-icon-wrapper">
            <font-awesome-icon icon="trash-alt" class="delete-icon" />
          </div>
          <p class="delete-message">¿Está seguro de eliminar esta cuota?</p>
          <div class="delete-details" v-if="cuotaToDelete">
            <p><strong>Año:</strong> {{ cuotaToDelete.axo }}</p>
            <p><strong>Categoría:</strong> {{ cuotaToDelete.categoria }}</p>
            <p><strong>Sección:</strong> {{ cuotaToDelete.seccion }}</p>
            <p><strong>Importe:</strong> {{ formatCurrency(cuotaToDelete.importe_cuota) }}</p>
          </div>
          <p class="text-muted small">Esta acción no se puede deshacer</p>
        </div>
        <div class="modal-footer modal-footer-centered">
          <button type="button" class="btn-municipal-secondary" @click="closeDeleteModal">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button type="button" class="btn-municipal-danger" @click="confirmDelete" :disabled="deleting">
            <font-awesome-icon :icon="deleting ? 'spinner' : 'trash'" :spin="deleting" />
            Eliminar
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
import { ref, onMounted } from 'vue'
import axios from 'axios'

// Estado
const axo = ref(new Date().getFullYear())
const cuotas = ref([])
const categorias = ref([])
const secciones = ref([])
const clavesCuota = ref([])
const showModal = ref(false)
const showEdit = ref(false)
const showDeleteModal = ref(false)
const cuotaToDelete = ref(null)
const loading = ref(false)
const saving = ref(false)
const deleting = ref(false)

const form = ref({
  id_cuotas: null,
  axo: new Date().getFullYear(),
  categoria: '',
  seccion: '',
  clave_cuota: '',
  importe_cuota: '',
  id_usuario: 1
})

// Toast
const toast = ref({ show: false, type: 'info', message: '' })

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => { toast.value.show = false }

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const formatCurrency = (val) => {
  if (val == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2
  }).format(parseFloat(val))
}

const formatDate = (val) => {
  if (!val) return ''
  return new Date(val).toLocaleDateString('es-MX')
}

const mostrarAyuda = () => {
  showToast('info', 'Administración de cuotas de mercados por año')
}

const fetchCuotas = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotasmdo_list',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: axo.value }
        ]
      }
    })
    if (res.data?.eResponse?.success) {
      cuotas.value = res.data.eResponse.data?.result || []
      showToast('success', `Se encontraron ${cuotas.value.length} cuotas`)
    }
  } catch (err) {
    showToast('error', 'Error al cargar cuotas')
  } finally {
    loading.value = false
  }
}

const fetchCategorias = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categorias_list',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (res.data?.eResponse?.success) {
      categorias.value = res.data.eResponse.data?.result || []
    }
  } catch (err) {
    console.error('Error al cargar categorías:', err)
  }
}

const fetchSecciones = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_secciones_list',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (res.data?.eResponse?.success) {
      secciones.value = res.data.eResponse.data?.result || []
    }
  } catch (err) {
    console.error('Error al cargar secciones:', err)
  }
}

const fetchClavesCuota = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_clavescuota_list',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (res.data?.eResponse?.success) {
      clavesCuota.value = res.data.eResponse.data?.result || []
    }
  } catch (err) {
    console.error('Error al cargar claves de cuota:', err)
  }
}

const openCreate = () => {
  resetForm()
  showEdit.value = false
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  showEdit.value = false
  resetForm()
}

const resetForm = () => {
  form.value = {
    id_cuotas: null,
    axo: axo.value,
    categoria: '',
    seccion: '',
    clave_cuota: '',
    importe_cuota: '',
    id_usuario: 1
  }
}

const createCuota = async () => {
  saving.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotasmdo_create',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: form.value.axo },
          { Nombre: 'p_categoria', Valor: form.value.categoria },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_clave_cuota', Valor: form.value.clave_cuota },
          { Nombre: 'p_importe_cuota', Valor: form.value.importe_cuota },
          { Nombre: 'p_id_usuario', Valor: form.value.id_usuario }
        ]
      }
    })
    if (res.data?.eResponse?.success) {
      showToast('success', 'Cuota creada correctamente')
      closeModal()
      fetchCuotas()
    } else {
      showToast('error', res.data?.eResponse?.message || 'Error al crear cuota')
    }
  } catch (err) {
    showToast('error', 'Error al crear cuota')
  } finally {
    saving.value = false
  }
}

const editCuota = (cuota) => {
  form.value = { ...cuota }
  showEdit.value = true
  showModal.value = true
}

const updateCuota = async () => {
  saving.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotasmdo_update',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_cuotas', Valor: form.value.id_cuotas },
          { Nombre: 'p_axo', Valor: form.value.axo },
          { Nombre: 'p_categoria', Valor: form.value.categoria },
          { Nombre: 'p_seccion', Valor: form.value.seccion },
          { Nombre: 'p_clave_cuota', Valor: form.value.clave_cuota },
          { Nombre: 'p_importe_cuota', Valor: form.value.importe_cuota },
          { Nombre: 'p_id_usuario', Valor: form.value.id_usuario }
        ]
      }
    })
    if (res.data?.eResponse?.success) {
      showToast('success', 'Cuota actualizada correctamente')
      closeModal()
      fetchCuotas()
    } else {
      showToast('error', res.data?.eResponse?.message || 'Error al actualizar cuota')
    }
  } catch (err) {
    showToast('error', 'Error al actualizar cuota')
  } finally {
    saving.value = false
  }
}

const deleteCuota = (cuota) => {
  cuotaToDelete.value = cuota
  showDeleteModal.value = true
}

const closeDeleteModal = () => {
  showDeleteModal.value = false
  cuotaToDelete.value = null
}

const confirmDelete = async () => {
  if (!cuotaToDelete.value) return

  deleting.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuotasmdo_delete',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_cuotas', Valor: cuotaToDelete.value.id_cuotas }
        ]
      }
    })
    if (res.data?.eResponse?.success) {
      showToast('success', 'Cuota eliminada correctamente')
      closeDeleteModal()
      fetchCuotas()
    } else {
      showToast('error', res.data?.eResponse?.message || 'Error al eliminar cuota')
    }
  } catch (err) {
    showToast('error', 'Error al eliminar cuota')
  } finally {
    deleting.value = false
  }
}

onMounted(async () => {
  await Promise.all([
    fetchCuotas(),
    fetchCategorias(),
    fetchSecciones(),
    fetchClavesCuota()
  ])
})
</script>

<style scoped>
.required {
  color: #dc3545;
}

.empty-icon {
  opacity: 0.25;
  margin-bottom: 1rem;
  color: #adb5bd;
}

.text-end {
  text-align: right !important;
}

.text-center {
  text-align: center !important;
}

.row-hover {
  cursor: pointer;
  transition: all 0.2s ease;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

/* Modal styles */
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
  z-index: 1000;
}

.modal-container {
  background: #fff;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 1.5rem;
  border-bottom: 1px solid #e9ecef;
  background: linear-gradient(135deg, #f8f9fa 0%, #ffffff 100%);
  border-radius: 12px 12px 0 0;
}

.modal-header h5 {
  margin: 0;
  font-weight: 600;
  color: #333;
}

.modal-close {
  background: none;
  border: none;
  font-size: 1.25rem;
  cursor: pointer;
  color: #6c757d;
  transition: color 0.2s;
}

.modal-close:hover {
  color: #dc3545;
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.75rem;
  padding-top: 1rem;
  margin-top: 1rem;
  border-top: 1px solid #e9ecef;
}

.btn-municipal-success {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%);
  color: white;
  border: none;
  padding: 0.65rem 1.25rem;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-municipal-success:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
}

.btn-municipal-warning {
  background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%);
  color: #212529;
  border: none;
  padding: 0.65rem 1.25rem;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-municipal-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  border: none;
  padding: 0.65rem 1.25rem;
  border-radius: 8px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-municipal-danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
}

/* Modal pequeño para confirmación */
.modal-sm {
  max-width: 420px;
}

.modal-header-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
  color: white;
  border-radius: 12px 12px 0 0;
}

.modal-header-danger h5 {
  color: white;
}

.modal-header-danger .modal-close {
  color: white;
}

.modal-header-danger .modal-close:hover {
  color: #f8d7da;
}

.delete-icon-wrapper {
  width: 80px;
  height: 80px;
  margin: 0 auto 1rem;
  background: linear-gradient(135deg, #fff5f5 0%, #ffe0e0 100%);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.delete-icon {
  font-size: 2.5rem;
  color: #dc3545;
}

.delete-message {
  font-size: 1.1rem;
  font-weight: 600;
  color: #333;
  margin-bottom: 1rem;
}

.delete-details {
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
  text-align: left;
}

.delete-details p {
  margin: 0.25rem 0;
  font-size: 0.9rem;
  color: #495057;
}

.modal-footer-centered {
  justify-content: center;
  gap: 1rem;
}

.small {
  font-size: 0.85rem;
}
</style>
