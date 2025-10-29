<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cog" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Categorías</h1>
        <p>Administración y actualización del catálogo de categorías</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="edit" />
            Agregar / Modificar Categoría
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <input type="number" v-model.number="form.categoria" id="categoria" class="municipal-form-control" min="1" max="12" :disabled="formMode==='edit'" required />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Descripción <span class="required">*</span></label>
                <input type="text" v-model="form.descripcion" id="descripcion" class="municipal-form-control" maxlength="30" required style="text-transform:uppercase" />
              </div>
            </div>
            <div class="button-group">
              <button type="submit" class="btn-municipal-primary">
                <font-awesome-icon :icon="formMode==='edit' ? 'sync' : 'plus'" />
                {{ formMode==='edit' ? 'Actualizar' : 'Agregar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="resetForm">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </form>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
          <div v-if="success" class="alert alert-success">{{ success }}</div>
        </div>
      </div>

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
                  <th style="width:150px">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cat in categorias" :key="cat.categoria" class="row-hover">
                  <td><strong>{{ cat.categoria }}</strong></td>
                  <td>{{ cat.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-info btn-sm" @click="editCategoria(cat)">
                        <font-awesome-icon icon="edit" /> Editar
                      </button>
                      <button class="btn-municipal-danger btn-sm" @click="deleteCategoria(cat)">
                        <font-awesome-icon icon="trash" /> Eliminar
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="categorias.length===0">
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
const form = ref({
  categoria: '',
  descripcion: ''
})
const formMode = ref('add') // 'add' | 'edit'
const error = ref('')
const success = ref('')

const loadCategorias = async () => {
  error.value = ''
  try {
    const result = await executeStoredProcedure('categoria.list', {})
    if (result.success) {
      categorias.value = result.data || []
    } else {
      error.value = result.message || 'Error al cargar categorías'
    }
  } catch (e) {
    handleError(e)
  }
}

const onSubmit = async () => {
  error.value = ''
  success.value = ''
  if (!form.value.categoria || !form.value.descripcion) {
    error.value = 'Todos los campos son obligatorios'
    return
  }
  let action = formMode.value === 'edit' ? 'categoria.update' : 'categoria.create'
  try {
    const result = await executeStoredProcedure(action, {
      categoria: form.value.categoria,
      descripcion: form.value.descripcion
    })
    if (result.success) {
      success.value = formMode.value === 'edit' ? 'Categoría actualizada correctamente' : 'Categoría agregada correctamente'
      toast.success(success.value)
      resetForm()
      loadCategorias()
    } else {
      error.value = result.message || 'Error en la operación'
    }
  } catch (e) {
    handleError(e)
  }
}

const editCategoria = (cat) => {
  form.value.categoria = cat.categoria
  form.value.descripcion = cat.descripcion
  formMode.value = 'edit'
  error.value = ''
  success.value = ''
}

const deleteCategoria = async (cat) => {
  if (!confirm('¿Está seguro de eliminar la categoría ' + cat.categoria + '?')) return
  try {
    const result = await executeStoredProcedure('categoria.delete', { categoria: cat.categoria })
    if (result.success) {
      success.value = 'Categoría eliminada correctamente'
      toast.success(success.value)
      loadCategorias()
    } else {
      error.value = result.message || 'Error al eliminar'
    }
  } catch (e) {
    handleError(e)
  }
}

const resetForm = () => {
  form.value = { categoria: '', descripcion: '' }
  formMode.value = 'add'
  error.value = ''
  success.value = ''
}

onMounted(() => {
  loadCategorias()
})
</script>
