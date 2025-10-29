<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Catálogo de Secciones</h1>
        <p>Gestión de secciones de mercados</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="th-list" /> Secciones Registradas</h5>
          <button class="btn-municipal-primary" @click="showCreate = true">
            <font-awesome-icon icon="plus" /> Agregar Sección
          </button>
        </div>
        <div class="municipal-card-body">
          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Sección</th>
                  <th>Descripción</th>
                  <th style="width: 200px">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in secciones" :key="row.seccion" class="row-hover">
                  <td><strong>{{ row.seccion }}</strong></td>
                  <td>{{ row.descripcion }}</td>
                  <td>
                    <button class="btn-municipal-warning" @click="editRow(row)">
                      <font-awesome-icon icon="edit" /> Editar
                    </button>
                    <button class="btn-municipal-danger" @click="deleteRow(row.seccion)">
                      <font-awesome-icon icon="trash" /> Eliminar
                    </button>
                  </td>
                </tr>
                <tr v-if="secciones.length === 0">
                  <td colspan="3" class="text-center">No hay secciones registradas</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div v-if="showCreate || showEdit" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEdit ? 'Editar Sección' : 'Agregar Sección' }}</h3>
          <form @submit.prevent="showEdit ? updateSeccion() : createSeccion()">
            <div class="form-group">
              <label class="municipal-form-label">Sección *</label>
              <input v-model="form.seccion" :readonly="showEdit" maxlength="2" class="municipal-form-control" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Descripción *</label>
              <input v-model="form.descripcion" maxlength="30" class="municipal-form-control" required />
            </div>
            <div class="form-group button-group">
              <button class="btn-municipal-success" type="submit">
                <font-awesome-icon icon="save" /> Guardar
              </button>
              <button class="btn-municipal-secondary" type="button" @click="closeModal">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </form>
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

const secciones = ref([])
const showCreate = ref(false)
const showEdit = ref(false)
const form = ref({
  seccion: '',
  descripcion: ''
})

const loadSecciones = async () => {
  try {
    const result = await executeStoredProcedure('mercados.secciones.list', {})
    if (result.success) {
      secciones.value = result.data || []
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  }
}

const createSeccion = async () => {
  try {
    const result = await executeStoredProcedure('mercados.secciones.create', form.value)
    if (result.success) {
      toast.success('Sección agregada correctamente')
      closeModal()
      loadSecciones()
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  }
}

const editRow = (row) => {
  form.value = { ...row }
  showEdit.value = true
  showCreate.value = false
}

const updateSeccion = async () => {
  try {
    const result = await executeStoredProcedure('mercados.secciones.update', form.value)
    if (result.success) {
      toast.success('Sección actualizada correctamente')
      closeModal()
      loadSecciones()
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  }
}

const deleteRow = async (seccion) => {
  if (!confirm('¿Está seguro de eliminar la sección ' + seccion + '?')) return
  try {
    const result = await executeStoredProcedure('mercados.secciones.delete', { seccion })
    if (result.success) {
      toast.success('Sección eliminada correctamente')
      loadSecciones()
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  }
}

const closeModal = () => {
  showCreate.value = false
  showEdit.value = false
  form.value = { seccion: '', descripcion: '' }
}

onMounted(() => {
  loadSecciones()
})
</script>
