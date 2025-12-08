<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="balance-scale" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Claves de Diferencias</h1>
        <p>Inicio > Catálogos > Claves de Diferencias por Cobrar</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalNuevo">
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
          <h5><font-awesome-icon icon="list" /> Listado de Claves de Diferencias</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="items.length > 0">{{ items.length }} registros</span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Clave</th>
                  <th>Descripción</th>
                  <th>Cuenta Ingreso</th>
                  <th>Fecha Actualización</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="items.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay claves de diferencias registradas.</p>
                  </td>
                </tr>
                <tr v-else v-for="(item, idx) in paginatedItems" :key="item.clave_diferencia" class="row-hover">
                  <td class="text-center">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                  <td><span class="badge-primary">{{ item.clave_diferencia }}</span></td>
                  <td>{{ item.descripcion }}</td>
                  <td><span class="badge-info">{{ item.cuenta_ingreso }}</span></td>
                  <td>{{ formatDate(item.fecha_actual) }}</td>
                  <td>{{ item.usuario }}</td>
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

          <!-- Paginación -->
          <div v-if="items.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ (currentPage - 1) * itemsPerPage + 1 }} a
              {{ Math.min(currentPage * itemsPerPage, items.length) }} de
              {{ items.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-municipal-sm btn-municipal-secondary"
                @click="currentPage = 1"
                :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                class="btn-municipal-sm btn-municipal-secondary"
                @click="currentPage--"
                :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-municipal-sm btn-municipal-secondary"
                @click="currentPage++"
                :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                class="btn-municipal-sm btn-municipal-secondary"
                @click="currentPage = totalPages"
                :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
            <div class="pagination-size">
              <select class="municipal-form-control" v-model.number="itemsPerPage" @change="currentPage = 1">
                <option :value="5">5 por página</option>
                <option :value="10">10 por página</option>
                <option :value="25">25 por página</option>
                <option :value="50">50 por página</option>
                <option :value="100">100 por página</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal CRUD -->
    <Modal
      :show="showModal"
      :title="isEdit ? 'Editar Clave de Diferencia' : 'Nueva Clave de Diferencia'"
      size="lg"
      @close="cerrarModal">
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="balance-scale" />
          {{ isEdit ? 'Editar Clave de Diferencia' : 'Nueva Clave de Diferencia' }}
        </h5>
      </template>

      <div class="row">
        <div class="col-md-3 mb-3">
          <label class="municipal-form-label">Clave Diferencia <span class="required">*</span></label>
          <input type="number" class="municipal-form-control" v-model.number="form.clave_diferencia"
                 min="1" max="5000" required :readonly="isEdit" />
        </div>
        <div class="col-md-9 mb-3">
          <label class="municipal-form-label">Descripción <span class="required">*</span></label>
          <input type="text" class="municipal-form-control text-uppercase" v-model="form.descripcion"
                 maxlength="60" required />
        </div>
      </div>

      <div class="row">
        <div class="col-md-4 mb-3">
          <label class="municipal-form-label">Cuenta Ingreso <span class="required">*</span></label>
          <input type="number" class="municipal-form-control" v-model.number="form.cuenta_ingreso"
                 min="1" max="999999" required />
        </div>
        <div class="col-md-4 mb-3">
          <label class="municipal-form-label">ID Usuario <span class="required">*</span></label>
          <input type="number" class="municipal-form-control" v-model.number="form.id_usuario"
                 min="1" required />
        </div>
      </div>

      <!-- Catálogo de Cuentas -->
      <div class="mb-3">
        <label class="municipal-form-label">
          <font-awesome-icon icon="list" /> Catálogo de Cuentas de Ingreso (clic para seleccionar)
        </label>
        <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Cuenta</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="cuenta in cuentas" :key="cuenta.cta_aplicacion"
                  @click="seleccionarCuenta(cuenta.cta_aplicacion)"
                  :class="{'table-active': form.cuenta_ingreso === cuenta.cta_aplicacion}"
                  style="cursor: pointer;">
                <td><span class="badge-info">{{ cuenta.cta_aplicacion }}</span></td>
                <td>{{ cuenta.descripcion }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" /> Cancelar
        </button>
        <button type="button" class="btn-municipal-primary" @click="guardar" :disabled="!isFormValid">
          <font-awesome-icon icon="save" />
          {{ isEdit ? 'Actualizar' : 'Guardar' }}
        </button>
      </template>
    </Modal>

    <!-- Modal Confirmación Eliminar -->
    <Modal
      :show="showDeleteConfirm"
      title="Confirmar Eliminación"
      size="md"
      @close="cancelarEliminar"
      @confirm="eliminar">
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="exclamation-triangle" class="text-danger" /> Confirmar Eliminación
        </h5>
      </template>

      <p>¿Está seguro de eliminar esta clave de diferencia?</p>
      <div class="alert alert-warning">
        <strong>Clave:</strong> {{ itemAEliminar?.clave_diferencia }}<br>
        <strong>Descripción:</strong> {{ itemAEliminar?.descripcion }}<br>
        <strong>Cuenta:</strong> {{ itemAEliminar?.cuenta_ingreso }}
      </div>
      <p class="text-danger"><strong>Esta acción no se puede deshacer.</strong></p>

      <template #footer>
        <button type="button" class="btn-municipal-secondary" @click="cancelarEliminar">
          <font-awesome-icon icon="times" /> Cancelar
        </button>
        <button type="button" class="btn-municipal-danger" @click="eliminar">
          <font-awesome-icon icon="trash" />
          Eliminar
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'

const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

const items = ref([])
const cuentas = ref([])
const itemAEliminar = ref(null)
const showModal = ref(false)
const showDeleteConfirm = ref(false)
const isEdit = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

const form = ref({
  clave_diferencia: null,
  descripcion: '',
  cuenta_ingreso: null,
  id_usuario: null
})

const isFormValid = computed(() => {
  return form.value.clave_diferencia >= 1 &&
         form.value.clave_diferencia <= 5000 &&
         form.value.descripcion.trim().length > 0 &&
         form.value.cuenta_ingreso >= 1 &&
         form.value.id_usuario >= 1
})

const totalPages = computed(() => {
  return Math.ceil(items.value.length / itemsPerPage.value)
})

const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return items.value.slice(start, end)
})

const formatDate = (dateStr) => {
  if (!dateStr) return 'N/A'
  return dateStr.substr(0, 19).replace('T', ' ')
}

const mostrarAyuda = () => {
  showToast('Administre las claves de diferencias por cobrar del sistema.', 'info')
}

const cargarItems = async () => {
  showLoading('Cargando claves de diferencias', 'Por favor espere...')
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_cve_diferencia_list', Base: 'mercados', Parametros: [] }
    })
    if (res.data.eResponse.success) {
      items.value = res.data.eResponse.data.result || []
      if (items.value.length > 0) {
        showToast(`Se cargaron ${items.value.length} claves`, 'success')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al cargar claves', 'error')
    }
  } catch (err) {
    showToast('Error de conexión', 'error')
    console.error(err)
  } finally {
    hideLoading()
  }
}

const cargarCuentas = async () => {
  showLoading('Cargando catálogo de cuentas', 'Por favor espere...')
  try {
    const res = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_cuentas_ingreso', Base: 'mercados', Parametros: [] }
    })
    if (res.data.eResponse.success) {
      cuentas.value = res.data.eResponse.data.result || []
    } else {
      showToast('Error al cargar catálogo de cuentas', 'error')
    }
  } catch (err) {
    console.error('Error cargando cuentas:', err)
  } finally {
    hideLoading()
  }
}

const seleccionarCuenta = (cta) => {
  form.value.cuenta_ingreso = cta
}

const abrirModalNuevo = () => {
  isEdit.value = false
  form.value = { clave_diferencia: null, descripcion: '', cuenta_ingreso: null, id_usuario: null }
  showModal.value = true
}

const editarItem = (item) => {
  isEdit.value = true
  form.value = {
    clave_diferencia: item.clave_diferencia,
    descripcion: item.descripcion,
    cuenta_ingreso: item.cuenta_ingreso,
    id_usuario: item.id_usuario
  }
  showModal.value = true
}

const guardar = async () => {
  if (!isFormValid.value) {
    showToast('Complete todos los campos correctamente', 'warning')
    return
  }

  showLoading(isEdit.value ? 'Actualizando clave' : 'Guardando clave', 'Por favor espere...')
  try {
    const operacion = isEdit.value ? 'sp_update_cve_diferencia' : 'sp_insert_cve_diferencia'
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_clave_diferencia', Valor: parseInt(form.value.clave_diferencia) },
          { Nombre: 'p_descripcion', Valor: form.value.descripcion.toUpperCase() },
          { Nombre: 'p_cuenta_ingreso', Valor: parseInt(form.value.cuenta_ingreso) },
          { Nombre: 'p_id_usuario', Valor: parseInt(form.value.id_usuario) }
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0][operacion.replace('sp_', '').replace('_cve_diferencia', '')]) {
        showToast(isEdit.value ? 'Clave actualizada' : 'Clave creada', 'success')
        cerrarModal()
        cargarItems()
      } else {
        showToast('La clave ya existe o no se pudo guardar', 'error')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al guardar', 'error')
    }
  } catch (err) {
    showToast('Error de conexión', 'error')
    console.error(err)
  } finally {
    hideLoading()
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

  showLoading('Eliminando clave', 'Por favor espere...')
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_delete_cve_diferencia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_clave_diferencia', Valor: parseInt(itemAEliminar.value.clave_diferencia) }
        ]
      }
    })

    if (res.data.eResponse.success) {
      const result = res.data.eResponse.data.result
      if (result && result.length > 0 && result[0].delete) {
        showToast('Clave eliminada', 'success')
        cancelarEliminar()
        cargarItems()
      } else {
        showToast('No se pudo eliminar', 'error')
      }
    } else {
      showToast(res.data.eResponse.message || 'Error al eliminar', 'error')
    }
  } catch (err) {
    showToast('Error de conexión', 'error')
    console.error(err)
  } finally {
    hideLoading()
  }
}

const cerrarModal = () => {
  showModal.value = false
  isEdit.value = false
}

onMounted(() => {
  cargarItems()
  cargarCuentas()
})
</script>
