<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="percentage" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Recargos</h1>
        <p>Inicio > Catálogos > Recargos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario -->
      <div class="municipal-card mb-4">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="edit" /> Formulario de Recargos</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="row">
              <div class="col-md-3 mb-3">
                <label for="axo" class="municipal-form-label">Año <span class="required">*</span></label>
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
              <div class="col-md-3 mb-3">
                <label for="periodo" class="municipal-form-label">Periodo <span class="required">*</span></label>
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
              <div class="col-md-3 mb-3">
                <label for="porcentaje" class="municipal-form-label">Porcentaje <span class="required">*</span></label>
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
            <div class="row mt-3">
              <div class="col-12">
                <button type="submit" class="btn-municipal-primary me-2">
                  <font-awesome-icon :icon="editMode ? 'save' : 'plus'" />
                  {{ editMode ? 'Actualizar' : 'Agregar' }}
                </button>
                <button type="button" class="btn-municipal-secondary" @click="resetForm">
                  <font-awesome-icon icon="times" />
                  Cancelar
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Listado de Recargos -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Recargos</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="recargos.length > 0">{{ recargos.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Porcentaje</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="recargos.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay recargos registrados.</p>
                  </td>
                </tr>
                <tr v-else v-for="(rec, idx) in recargos" :key="rec.axo + '-' + rec.periodo" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td>{{ rec.axo }}</td>
                  <td class="text-center"><span class="badge-primary">{{ rec.periodo }}</span></td>
                  <td>{{ rec.porcentaje }}%</td>
                  <td>{{ formatDate(rec.fecha_alta) }}</td>
                  <td>{{ rec.usuario }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="editRecargo(rec)" title="Editar">
                        <font-awesome-icon icon="edit" />
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
const mostrarAyuda = () => {
  showToast('Administre los porcentajes de recargos por año y periodo. Puede crear o editar recargos.', 'info')
}

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

<style scoped>
.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}

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

.required {
  color: #dc3545;
}
</style>
