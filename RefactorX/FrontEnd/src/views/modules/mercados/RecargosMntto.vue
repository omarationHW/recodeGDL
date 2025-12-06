<template>
  <div class="module-view">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Recargos Mantenimiento</li>
      </ol>
    </nav>

    <!-- Título -->
    <div class="module-view-header mb-4">
      <h1>Recargos de Mantenimiento</h1>
    </div>

    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card mb-4">
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="form-row">
              <div class="form-group col-md-2">
                <label for="axo" class="municipal-form-label">Año</label>
                <input
                  type="number"
                  v-model.number="form.axo"
                  min="1994"
                  max="2999"
                  class="municipal-form-control"
                  id="axo"
                  required
                />
              </div>
              <div class="form-group col-md-2">
                <label for="periodo" class="municipal-form-label">Periodo</label>
                <input
                  type="number"
                  v-model.number="form.periodo"
                  min="1"
                  max="12"
                  class="municipal-form-control"
                  id="periodo"
                  required
                />
              </div>
              <div class="form-group col-md-3">
                <label for="porcentaje" class="municipal-form-label">Porcentaje</label>
                <input
                  type="number"
                  v-model.number="form.porcentaje"
                  step="0.01"
                  min="0.01"
                  max="99"
                  class="municipal-form-control"
                  id="porcentaje"
                  required
                />
              </div>
            </div>
            <div class="form-row mt-3">
              <button type="submit" class="btn-municipal-primary mr-2">
                {{ editMode ? 'Actualizar' : 'Agregar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="resetForm">
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Listado de Recargos -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="mb-0">Listado de Recargos</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Porcentaje</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="rec in recargos" :key="rec.axo + '-' + rec.periodo">
                  <td>{{ rec.axo }}</td>
                  <td>{{ rec.periodo }}</td>
                  <td>{{ rec.porcentaje }}</td>
                  <td>{{ formatDate(rec.fecha_alta) }}</td>
                  <td>{{ rec.usuario }}</td>
                  <td>
                    <button class="btn-municipal-info btn-sm" @click="editRecargo(rec)">
                      Editar
                    </button>
                  </td>
                </tr>
                <tr v-if="recargos.length === 0">
                  <td colspan="6" class="text-center">No hay recargos registrados.</td>
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
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const { withLoading } = useGlobalLoading()
const { showToast } = useToast()

// State
const form = ref({
  axo: new Date().getFullYear(),
  periodo: 1,
  porcentaje: null
})

const editMode = ref(false)
const recargos = ref([])
const editingKey = ref(null)

// Funciones
const formatDate = (val) => {
  if (!val) return ''
  return new Date(val).toLocaleDateString('es-MX')
}

const fetchRecargos = async () => {
  await withLoading(async () => {
    try {
      const res = await axios.post('/api/execute', { action: 'list_recargos' })
      if (res.data.success) {
        recargos.value = res.data.data
      } else {
        showToast(res.data.message || 'Error al cargar recargos', 'error')
      }
    } catch (error) {
      console.error('Error al cargar recargos:', error)
      showToast('Error al cargar recargos', 'error')
    }
  }, 'Cargando recargos...', 'Por favor espere')
}

const onSubmit = async () => {
  const action = editMode.value ? 'update_recargo' : 'insert_recargo'
  const params = { ...form.value, id_usuario: 1 }

  await withLoading(async () => {
    try {
      const res = await axios.post('/api/execute', { action, params })

      if (res.data.success) {
        showToast(
          editMode.value ? 'Recargo actualizado correctamente' : 'Recargo agregado correctamente',
          'success'
        )
        await fetchRecargos()
        resetForm()
      } else {
        showToast(res.data.message || 'Error al guardar recargo', 'error')
      }
    } catch (error) {
      console.error('Error al guardar recargo:', error)
      showToast('Error al guardar recargo', 'error')
    }
  }, editMode.value ? 'Actualizando recargo...' : 'Agregando recargo...', 'Por favor espere')
}

const editRecargo = (rec) => {
  form.value.axo = rec.axo
  form.value.periodo = rec.periodo
  form.value.porcentaje = rec.porcentaje
  editMode.value = true
  editingKey.value = rec.axo + '-' + rec.periodo
}

const resetForm = () => {
  form.value = {
    axo: new Date().getFullYear(),
    periodo: 1,
    porcentaje: null
  }
  editMode.value = false
  editingKey.value = null
}

// Lifecycle
onMounted(() => {
  fetchRecargos()
})
</script>
