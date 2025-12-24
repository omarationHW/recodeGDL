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
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="abrirModalNuevo">
          <font-awesome-icon icon="plus" /> Nuevo
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
          <div class="table-responsive">
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
    <Modal
      :show="showModal"
      :title="isEdit ? 'Editar Clave de Cuota' : 'Nueva Clave de Cuota'"
      @close="cerrarModal"
      size="md"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="key" />
          {{ isEdit ? 'Editar Clave de Cuota' : 'Nueva Clave de Cuota' }}
        </h5>
      
  <DocumentationModal :show="showAyuda" :component-name="'CveCuotaMntto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - CveCuotaMntto'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'CveCuotaMntto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - CveCuotaMntto'" @close="showDocumentacion = false" />
</template>

      <div class="mb-3">
        <label class="municipal-form-label">Clave Cuota <span class="required">*</span></label>
        <input
          type="number"
          class="municipal-form-control"
          v-model.number="form.clave_cuota"
          min="1"
          max="5000"
          required
          :readonly="isEdit"
        />
      </div>
      <div class="mb-3">
        <label class="municipal-form-label">Descripción <span class="required">*</span></label>
        <input
          type="text"
          class="municipal-form-control text-uppercase"
          v-model="form.descripcion"
          maxlength="60"
          required
        />
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
      @close="cancelarEliminar"
      size="md"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon icon="exclamation-triangle" /> Confirmar Eliminación
        </h5>
      </template>

      <p>¿Está seguro de eliminar esta clave de cuota?</p>
      <div class="alert alert-warning">
        <strong>Clave:</strong> {{ itemAEliminar?.clave_cuota }}<br>
        <strong>Descripción:</strong> {{ itemAEliminar?.descripcion }}
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
import Swal from 'sweetalert2'

const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#6c757d',
    confirmButtonText: confirmarTexto,
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}

const mostrarConfirmacionEliminar = async (texto) => {
  const result = await Swal.fire({
    title: '¿Eliminar registro?',
    text: texto,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

const items = ref([])
const itemAEliminar = ref(null)
const showModal = ref(false)
const showDeleteConfirm = ref(false)
const isEdit = ref(false)

const form = ref({
  clave_cuota: null,
  descripcion: ''
})

const isFormValid = computed(() => {
  return form.value.clave_cuota >= 1 && form.value.clave_cuota <= 5000 && form.value.descripcion.trim().length > 0
})

const mostrarAyuda = () => {
  showToast('Administre las claves de cuota del sistema. Puede crear, editar o eliminar claves de cuota.', 'info')
}

const cargarItems = async () => {
  showLoading('Cargando claves de cuota', 'Por favor espere...')
  try {
    const res = await apiService.execute(
          'sp_cve_cuota_list',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      items.value = res.data.result || []
      if (items.value.length > 0) {
        showToast(`Se cargaron ${items.value.length} claves`, 'success')
      }
    } else {
      showToast(res.message || 'Error al cargar claves', 'error')
    }
  } catch (err) {
    showToast('Error de conexión', 'error')
    console.error(err)
  } finally {
    hideLoading()
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
    showToast('Complete todos los campos correctamente', 'warning')
    return
  }

  showLoading(isEdit.value ? 'Actualizando clave' : 'Guardando clave', 'Por favor espere...')
  try {
    const operacion = isEdit.value ? 'sp_cve_cuota_update' : 'sp_cve_cuota_insert'
    const res = await apiService.execute(
      operacion,
      'mercados',
      [
        { nombre: 'p_clave_cuota', valor: parseInt(form.value.clave_cuota), tipo: 'integer' },
        { nombre: 'p_descripcion', valor: form.value.descripcion.toUpperCase(), tipo: 'string' }
      ],
      '',
      null,
      'publico'
    )

    if (res.success) {
      const result = res.data.result
      if (result && result.length > 0 && result[0][operacion.replace('sp_cve_cuota_', '')]) {
        showToast(isEdit.value ? 'Clave actualizada' : 'Clave creada', 'success')
        cerrarModal()
        cargarItems()
      } else {
        showToast('La clave ya existe', 'error')
      }
    } else {
      showToast(res.message || 'Error al guardar', 'error')
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
    const res = await apiService.execute(
          'sp_cve_cuota_delete',
          'mercados',
          [
          { nombre: 'p_clave_cuota', valor: parseInt(itemAEliminar.value.clave_cuota) }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      const result = res.data.result
      if (result && result.length > 0 && result[0].delete) {
        showToast('Clave eliminada', 'success')
        cancelarEliminar()
        cargarItems()
      } else {
        showToast('No se pudo eliminar', 'error')
      }
    } else {
      showToast(res.message || 'Error al eliminar', 'error')
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
})
</script>
