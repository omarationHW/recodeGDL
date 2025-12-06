<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Mantenimiento a Secciones</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h4>Mantenimiento a Secciones</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="seccion" class="form-label">Sección</label>
              <input v-model="form.seccion" id="seccion" maxlength="2" class="form-control" :disabled="mode==='edit'" required />
            </div>
            <div class="col-md-8">
              <label for="descripcion" class="form-label">Descripción</label>
              <input v-model="form.descripcion" id="descripcion" maxlength="30" class="form-control" required />
            </div>
          </div>
          <div class="mb-3">
            <button type="submit" class="btn btn-primary me-2">{{ mode==='edit' ? 'Actualizar' : 'Agregar' }}</button>
            <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
          </div>
        </form>
        <hr />
        <h5>Listado de Secciones</h5>
        <table class="table table-striped">
          <thead>
            <tr>
              <th>Sección</th>
              <th>Descripción</th>
              <th style="width:120px">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in secciones" :key="item.seccion">
              <td>{{ item.seccion }}</td>
              <td>{{ item.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-info me-1" @click="editSeccion(item)">Editar</button>
              </td>
            </tr>
            <tr v-if="secciones.length===0">
              <td colspan="3" class="text-center">No hay secciones registradas.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const globalLoading = useGlobalLoading()
const { showToast } = useToast()

// Estado reactivo
const secciones = ref([])
const form = ref({
  seccion: '',
  descripcion: ''
})
const mode = ref('add') // 'add' or 'edit'

/**
 * Carga todas las secciones desde el servidor
 */
const loadSecciones = async () => {
  await globalLoading.withLoading(async () => {
    try {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getAllSecciones' })
      })
      const json = await res.json()

      if (json.success) {
        secciones.value = json.data
      } else {
        showToast(json.message || 'Error al cargar secciones', 'error')
      }
    } catch (e) {
      showToast('Error de red al cargar secciones', 'error')
      console.error('Error al cargar secciones:', e)
    }
  }, 'Cargando secciones...', 'Por favor espere')
}

/**
 * Maneja el envío del formulario (agregar o actualizar sección)
 */
const onSubmit = async () => {
  if (!form.value.seccion || !form.value.descripcion) {
    showToast('Todos los campos son obligatorios', 'warning')
    return
  }

  const action = mode.value === 'edit' ? 'updateSeccion' : 'insertSeccion'
  const payload = {
    action,
    data: {
      seccion: form.value.seccion.trim().toUpperCase(),
      descripcion: form.value.descripcion.trim().toUpperCase()
    }
  }

  await globalLoading.withLoading(async () => {
    try {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      })
      const json = await res.json()

      if (json.success) {
        const successMessage = json.message || (mode.value === 'edit' ? 'Sección actualizada' : 'Sección agregada')
        showToast(successMessage, 'success')
        resetForm()
        await loadSecciones()
      } else {
        showToast(json.message || 'Error en la operación', 'error')
      }
    } catch (e) {
      showToast('Error de red en la operación', 'error')
      console.error('Error en operación:', e)
    }
  }, mode.value === 'edit' ? 'Actualizando sección...' : 'Agregando sección...', 'Por favor espere')
}

/**
 * Prepara el formulario para editar una sección
 */
const editSeccion = (item) => {
  form.value.seccion = item.seccion
  form.value.descripcion = item.descripcion
  mode.value = 'edit'
}

/**
 * Resetea el formulario a su estado inicial
 */
const resetForm = () => {
  form.value.seccion = ''
  form.value.descripcion = ''
  mode.value = 'add'
}

// Lifecycle hooks
onMounted(() => {
  loadSecciones()
})
</script>
