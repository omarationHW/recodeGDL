<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="th-list" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Secciones</h1>
        <p>Inicio > Catálogos > Secciones</p>
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
          <h5><font-awesome-icon icon="edit" /> Formulario de Secciones</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="row mb-3">
              <div class="col-md-2">
                <label for="seccion" class="municipal-form-label">Sección <span class="required">*</span></label>
                <input v-model="form.seccion" id="seccion" maxlength="2" class="municipal-form-control" :disabled="mode==='edit'" required />
              </div>
              <div class="col-md-8">
                <label for="descripcion" class="municipal-form-label">Descripción <span class="required">*</span></label>
                <input v-model="form.descripcion" id="descripcion" maxlength="30" class="municipal-form-control" required />
              </div>
            </div>
            <div class="mb-3">
              <button type="submit" class="btn-municipal-primary me-2">
                <font-awesome-icon :icon="mode==='edit' ? 'save' : 'plus'" />
                {{ mode==='edit' ? 'Actualizar' : 'Agregar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="resetForm">
                <font-awesome-icon icon="times" />
                Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Listado -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list" /> Listado de Secciones</h5>
          <div class="header-right">
            <span class="badge-purple" v-if="secciones.length > 0">{{ secciones.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Sección</th>
                  <th>Descripción</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="secciones.length === 0">
                  <td colspan="4" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No hay secciones registradas.</p>
                  </td>
                </tr>
                <tr v-else v-for="(item, idx) in secciones" :key="item.seccion" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td><span class="badge-primary">{{ item.seccion }}</span></td>
                  <td>{{ item.descripcion }}</td>
                  <td class="text-center">
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="editSeccion(item)" title="Editar">
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
 * Muestra ayuda
 */
const mostrarAyuda = () => {
  showToast('Administre las secciones del sistema. Puede crear o editar secciones.', 'info')
}

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
