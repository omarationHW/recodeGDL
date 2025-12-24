<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="th-list" />
      </div>
      <div class="module-view-info">
        <h1>Mantenimiento de Secciones</h1>
        <p>Administración de secciones del sistema</p>
      </div>
      <div class="header-actions">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card mb-4">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="edit" /> Formulario de Secciones</h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <input v-model="form.seccion" maxlength="2" class="municipal-form-control" :disabled="mode==='edit'" required />
              </div>
              <div class="form-group" style="flex: 3">
                <label class="municipal-form-label">Descripción <span class="required">*</span></label>
                <input v-model="form.descripcion" maxlength="30" class="municipal-form-control" required />
              </div>
            </div>
            <div class="button-group">
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <font-awesome-icon :icon="mode==='edit' ? 'save' : 'plus'" />
                {{ mode==='edit' ? 'Actualizar' : 'Agregar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="resetForm">
                <font-awesome-icon icon="times" /> Cancelar
              </button>
            </div>
          </form>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Listado de Secciones</h5>
          <span class="badge-purple" v-if="secciones.length > 0">{{ secciones.length }} registros</span>
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
                  <td colspan="4" class="text-center text-muted">No hay secciones registradas.</td>
                </tr>
                <tr v-else v-for="(item, idx) in secciones" :key="item.seccion" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td><code>{{ item.seccion }}</code></td>
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

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando...</p>
      </div>
    </div>

    <DocumentationModal :show="showAyuda" :component-name="'SeccionesMntto'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mantenimiento de Secciones'" @close="showAyuda = false" />
    <DocumentationModal :show="showDocumentacion" :component-name="'SeccionesMntto'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mantenimiento de Secciones'" @close="showDocumentacion = false" />
  </div>
</template>

<script setup>
import Swal from 'sweetalert2'

// Helpers de confirmación SweetAlert
const confirmarAccion = async (titulo, texto, confirmarTexto = 'Sí, continuar') => {
  const result = await Swal.fire({
    title: titulo,
    text: texto,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#3085d6',
    cancelButtonColor: '#d33',
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
    cancelButtonColor: '#3085d6',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })
  return result.isConfirmed
}
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)

const BASE_DB = 'mercados'
const SCHEMA = 'publico'

const { loading, execute } = useApi()

const secciones = ref([])
const form = ref({ seccion: '', descripcion: '' })
const mode = ref('add')

async function loadSecciones() {
  try {
    const response = await execute('sp_secciones_list', BASE_DB, [], '', null, SCHEMA)
    const data = response?.result || response || []
    secciones.value = Array.isArray(data) ? data : []
  } catch (error) {
    console.error('Error al cargar secciones:', error)
    secciones.value = []
  }
}

async function onSubmit() {
  if (!form.value.seccion || !form.value.descripcion) {
    alert('Todos los campos son obligatorios')
    return
  }

  try {
    const sp = mode.value === 'edit' ? 'sp_secciones_update' : 'sp_secciones_create'
    const params = [
      { nombre: 'p_seccion', tipo: 'string', valor: form.value.seccion.trim().toUpperCase() },
      { nombre: 'p_descripcion', tipo: 'string', valor: form.value.descripcion.trim().toUpperCase() }
    ]

    await execute(sp, BASE_DB, params, '', null, SCHEMA)
    resetForm()
    await loadSecciones()
  } catch (error) {
    console.error('Error en operación:', error)
    alert('Error: ' + error.message)
  }
}

function editSeccion(item) {
  form.value.seccion = item.seccion
  form.value.descripcion = item.descripcion
  mode.value = 'edit'
}

function resetForm() {
  form.value.seccion = ''
  form.value.descripcion = ''
  mode.value = 'add'
}

onMounted(() => {
  loadSecciones()
})
</script>
