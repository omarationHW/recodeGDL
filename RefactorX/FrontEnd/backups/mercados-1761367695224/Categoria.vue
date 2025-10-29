<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="tags" />
      </div>
      <div class="module-view-info">
        <h1>Categorías</h1>
        <p>Gestión del catálogo de categorías de mercados</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="showCreateModal = true">
          <font-awesome-icon icon="plus" />
          Agregar Categoría
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Listado de Categorías
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Categoría</th>
                  <th>Descripción</th>
                  <th style="width: 200px">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cat in categorias" :key="cat.categoria" class="row-hover">
                  <td><strong>{{ cat.categoria }}</strong></td>
                  <td>{{ cat.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-warning btn-sm" @click="editCategoria(cat)">
                        <font-awesome-icon icon="edit" /> Editar
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click="deleteCategoria(cat.categoria)">
                        <font-awesome-icon icon="trash" /> Eliminar
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="categorias.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay categorías registradas</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div v-if="showCreateModal || showEditModal" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content-custom">
          <div class="modal-header-custom">
            <h5>{{ showEditModal ? 'Editar' : 'Agregar' }} Categoría</h5>
            <button type="button" class="close-button" @click="closeModal">
              <font-awesome-icon icon="times" />
            </button>
          </div>
          <div class="modal-body-custom">
            <form @submit.prevent="showEditModal ? updateCategoria() : createCategoria()">
              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <input type="number" v-model.number="form.categoria" :disabled="showEditModal" class="municipal-form-control" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Descripción <span class="required">*</span></label>
                <input type="text" v-model="form.descripcion" maxlength="30" class="municipal-form-control" required />
              </div>
              <div class="modal-footer-custom">
                <button type="button" class="btn-municipal-secondary" @click="closeModal">
                  <font-awesome-icon icon="times" /> Cancelar
                </button>
                <button type="submit" class="btn-municipal-primary">
                  <font-awesome-icon icon="save" /> Guardar
                </button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <div v-if="message" class="toast-notification toast-info">
      <font-awesome-icon icon="info-circle" class="toast-icon" />
      <span class="toast-message">{{ message }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from 'vue-toastification'

const { executeStoredProcedure } = useApi()
const { handleError } = useLicenciasErrorHandler()
const toast = useToast()

const categorias = ref([])
const showCreateModal = ref(false)
const showEditModal = ref(false)
const form = ref({
  categoria: '',
  descripcion: ''
})
const message = ref('')

const fetchCategorias = async () => {
  try {
    const result = await executeStoredProcedure('categoria.list', {})
    if (result.success) {
      categorias.value = result.data || []
    } else {
      message.value = result.message || 'Error al cargar categorías'
    }
  } catch (error) {
    handleError(error)
  }
}

const createCategoria = async () => {
  try {
    const result = await executeStoredProcedure('categoria.create', {
      categoria: form.value.categoria,
      descripcion: form.value.descripcion
    })
    if (result.success) {
      toast.success('Categoría agregada correctamente')
      closeModal()
      fetchCategorias()
    } else {
      message.value = result.message || 'Error al crear categoría'
    }
  } catch (error) {
    handleError(error)
  }
}

const editCategoria = (cat) => {
  form.value = { ...cat }
  showEditModal.value = true
}

const updateCategoria = async () => {
  try {
    const result = await executeStoredProcedure('categoria.update', {
      categoria: form.value.categoria,
      descripcion: form.value.descripcion
    })
    if (result.success) {
      toast.success('Categoría actualizada correctamente')
      closeModal()
      fetchCategorias()
    } else {
      message.value = result.message || 'Error al actualizar categoría'
    }
  } catch (error) {
    handleError(error)
  }
}

const deleteCategoria = async (categoria) => {
  if (!confirm('¿Está seguro de eliminar la categoría?')) return
  try {
    const result = await executeStoredProcedure('categoria.delete', { categoria })
    if (result.success) {
      toast.success('Categoría eliminada correctamente')
      fetchCategorias()
    } else {
      message.value = result.message || 'Error al eliminar categoría'
    }
  } catch (error) {
    handleError(error)
  }
}

const closeModal = () => {
  showCreateModal.value = false
  showEditModal.value = false
  form.value = { categoria: '', descripcion: '' }
}

onMounted(() => {
  fetchCategorias()
})
</script>
