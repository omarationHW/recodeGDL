<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="database" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Categorías</h1>
        <p>Administración de categorías del sistema</p>
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
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Categorías</h5>
          <button class="btn-municipal-primary" @click="openAddModal">
            <font-awesome-icon icon="plus" /> Agregar
          </button>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Descripción</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cat in categorias" :key="cat.categoria" class="row-hover">
                  <td><code>{{ cat.categoria }}</code></td>
                  <td>{{ cat.descripcion }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-primary btn-sm" @click="editCategoria(cat)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="categorias.length === 0">
                  <td colspan="3" class="text-center text-muted">Sin registros</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

    <Modal :show="showModal" :title="modalTitle" @close="closeModal" :showDefaultFooter="true" @confirm="saveCategoria">
      <div class="form-row">
        <div class="form-group full-width">
          <label class="municipal-form-label">Descripción</label>
          <input v-model="form.descripcion" class="municipal-form-control" required />
        </div>
      </div>
    </Modal>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando...</p>
      </div>
    </div>

    <DocumentationModal :show="showAyuda" :component-name="'ModuloBD'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Catálogo de Categorías'" @close="showAyuda = false" />
    <DocumentationModal :show="showDocumentacion" :component-name="'ModuloBD'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Catálogo de Categorías'" @close="showDocumentacion = false" />
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
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)

const BASE_DB = 'mercados'
const SCHEMA = 'publico'

const { loading, execute } = useApi()

const categorias = ref([])
const showModal = ref(false)
const modalTitle = ref('Agregar Categoría')
const form = ref({ categoria: null, descripcion: '' })
const isEditing = ref(false)

async function fetchCategorias() {
  try {
    const response = await execute('sp_categoria_list', BASE_DB, [], '', null, SCHEMA)
    const data = response?.result || response || []
    categorias.value = Array.isArray(data) ? data : []
  } catch (error) {
    console.error('Error al cargar categorías:', error)
    categorias.value = []
  }
}

function openAddModal() {
  isEditing.value = false
  modalTitle.value = 'Agregar Categoría'
  form.value = { categoria: null, descripcion: '' }
  showModal.value = true
}

function editCategoria(cat) {
  isEditing.value = true
  modalTitle.value = 'Editar Categoría'
  form.value = { ...cat }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
}

async function saveCategoria() {
  try {
    const sp = isEditing.value ? 'sp_categoria_update' : 'sp_categoria_create'
    const params = [
      { nombre: 'p_descripcion', tipo: 'string', valor: form.value.descripcion }
    ]
    if (isEditing.value) {
      params.unshift({ nombre: 'p_categoria', tipo: 'integer', valor: form.value.categoria })
    }

    await execute(sp, BASE_DB, params, '', null, SCHEMA)
    closeModal()
    await fetchCategorias()
  } catch (error) {
    console.error('Error al guardar:', error)
    alert('Error al guardar: ' + error.message)
  }
}

onMounted(() => {
  fetchCategorias()
})
</script>
