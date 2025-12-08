<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-tie" /></div>
      <div class="module-view-info">
        <h1>Inspectores/Vigilantes</h1>
        <p>Catálogo de inspectores</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="openModal('create')">
          <font-awesome-icon icon="plus" /> Nuevo Inspector
        </button>
        <button class="btn-municipal-secondary" :disabled="loading" @click="load">
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="users" class="me-2" />Listado de Inspectores</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status"></div>
            <p class="mt-2 text-muted">Cargando inspectores...</p>
          </div>
          <div class="table-responsive" v-else>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Inspector</th>
                  <th class="text-center" style="width: 120px;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="i in paginatedRows" :key="i.id_esta_persona">
                  <td>{{ i.id_esta_persona }}</td>
                  <td>{{ i.inspector }}</td>
                  <td class="text-center">
                    <div class="action-buttons">
                      <button class="btn-action btn-action-edit" @click="openModal('edit', i)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-action btn-action-delete" @click="confirmDelete(i)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
                <tr v-if="rows.length===0">
                  <td colspan="3">
                    <div class="empty-table-state">
                      <font-awesome-icon icon="user-tie" class="empty-table-icon" />
                      <p>No se encontraron inspectores registrados</p>
                      <button class="btn-municipal-primary btn-sm mt-2" @click="openModal('create')">
                        <font-awesome-icon icon="plus" /> Agregar primer inspector
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-footer">
            <div class="text-muted">
              <font-awesome-icon icon="list" class="me-1" />
              Mostrando <strong>{{ startRecord }}</strong> a <strong>{{ endRecord }}</strong> de <strong>{{ rows.length }}</strong> registros
            </div>
            <nav>
              <ul class="pagination mb-0">
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" href="#" @click.prevent="currentPage = 1">
                    <font-awesome-icon icon="angles-left" />
                  </a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === 1 }">
                  <a class="page-link" href="#" @click.prevent="currentPage--">
                    <font-awesome-icon icon="angle-left" />
                  </a>
                </li>
                <li class="page-item" v-for="page in visiblePages" :key="page" :class="{ active: page === currentPage }">
                  <a class="page-link" href="#" @click.prevent="currentPage = page">{{ page }}</a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" href="#" @click.prevent="currentPage++">
                    <font-awesome-icon icon="angle-right" />
                  </a>
                </li>
                <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                  <a class="page-link" href="#" @click.prevent="currentPage = totalPages">
                    <font-awesome-icon icon="angles-right" />
                  </a>
                </li>
              </ul>
            </nav>
            <div class="pagination-size">
              <select v-model.number="pageSize" class="municipal-form-control">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear/Editar -->
    <div v-if="showModal" class="modal-overlay" @click.self="closeModal">
      <div class="modal-container">
        <div class="modal-header">
          <h5>
            <font-awesome-icon :icon="modalMode === 'create' ? 'plus' : 'edit'" class="me-2" />
            {{ modalMode === 'create' ? 'Nuevo Inspector' : 'Editar Inspector' }}
          </h5>
          <button class="modal-close" @click="closeModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Nombre</label>
              <input type="text" class="municipal-form-control" v-model="form.nombre" placeholder="Nombre(s)" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Apellido Paterno</label>
              <input type="text" class="municipal-form-control" v-model="form.ap_pater" placeholder="Apellido paterno" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Apellido Materno</label>
              <input type="text" class="municipal-form-control" v-model="form.ap_mater" placeholder="Apellido materno" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input type="text" class="municipal-form-control" v-model="form.rfc" placeholder="RFC" maxlength="13" />
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeModal">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button class="btn-municipal-primary" @click="saveInspector" :disabled="saving">
            <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" />
            {{ saving ? 'Guardando...' : 'Guardar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - InspectoresPublicos"
    >
      <h3>Inspectores Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'InspectoresPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted, computed, watch, nextTick } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const rows = ref([])

// Modal
const showModal = ref(false)
const modalMode = ref('create')
const saving = ref(false)
const selectedId = ref(null)
const form = ref({
  nombre: '',
  ap_pater: '',
  ap_mater: '',
  rfc: ''
})

// Paginación
const currentPage = ref(1)
const pageSize = ref(25)

const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value))

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value
  const end = start + pageSize.value
  return rows.value.slice(start, end)
})

const startRecord = computed(() => {
  if (rows.value.length === 0) return 0
  return (currentPage.value - 1) * pageSize.value + 1
})

const endRecord = computed(() => {
  const end = currentPage.value * pageSize.value
  return end > rows.value.length ? rows.value.length : end
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start + 1 < maxVisible) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

watch(pageSize, () => {
  currentPage.value = 1
})

// CRUD Functions
async function load() {
  showLoading('Cargando...', 'Obteniendo inspectores')
  rows.value = []
  currentPage.value = 1
  try {
    const resp = await execute('sp_get_inspectors', BASE_DB, [], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length === 0) {
      showToast('info', 'No se encontraron inspectores registrados')
    } else {
      showToast('success', `Se cargaron ${rows.value.length} inspectores`)
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function openModal(mode, inspector = null) {
  modalMode.value = mode
  if (mode === 'edit' && inspector) {
    selectedId.value = inspector.id_esta_persona
    loadInspectorDetails(inspector.id_esta_persona)
  } else {
    selectedId.value = null
    form.value = { nombre: '', ap_pater: '', ap_mater: '', rfc: '' }
  }
  showModal.value = true
}

function closeModal() {
  showModal.value = false
  form.value = { nombre: '', ap_pater: '', ap_mater: '', rfc: '' }
  selectedId.value = null
}

async function loadInspectorDetails(id) {
  try {
    const params = [{ nombre: 'p_id', valor: id, tipo: 'integer' }]
    const resp = await execute('sp_get_inspector_by_id', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data
    if (r) {
      form.value = {
        nombre: r.out_nombre || '',
        ap_pater: r.out_ap_pater || '',
        ap_mater: r.out_ap_mater || '',
        rfc: r.out_rfc || ''
      }
    }
  } catch (e) {
    handleApiError(e)
  }
}

async function saveInspector() {
  if (!form.value.nombre?.trim() || !form.value.ap_pater?.trim()) {
    showToast('warning', 'Nombre y apellido paterno son requeridos')
    return
  }

  const nombreCompleto = `${form.value.nombre.trim()} ${form.value.ap_pater.trim()} ${form.value.ap_mater?.trim() || ''}`.trim()

  const confirmacion = await Swal.fire({
    icon: 'question',
    title: modalMode.value === 'create' ? 'Confirmar Creación' : 'Confirmar Actualización',
    html: `<p>¿${modalMode.value === 'create' ? 'Crear' : 'Actualizar'} inspector?</p>
      <p><strong>${nombreCompleto.toUpperCase()}</strong></p>`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmacion.isConfirmed) return

  saving.value = true
  try {
    let resp
    if (modalMode.value === 'create') {
      const params = [
        { nombre: 'p_nombre', valor: form.value.nombre.trim().toUpperCase(), tipo: 'string' },
        { nombre: 'p_ap_pater', valor: form.value.ap_pater.trim().toUpperCase(), tipo: 'string' },
        { nombre: 'p_ap_mater', valor: form.value.ap_mater?.trim().toUpperCase() || '', tipo: 'string' },
        { nombre: 'p_rfc', valor: form.value.rfc?.trim().toUpperCase() || null, tipo: 'string' }
      ]
      resp = await execute('sp_insert_inspector', BASE_DB, params, '', null, SCHEMA)
    } else {
      const params = [
        { nombre: 'p_id', valor: selectedId.value, tipo: 'integer' },
        { nombre: 'p_nombre', valor: form.value.nombre.trim().toUpperCase(), tipo: 'string' },
        { nombre: 'p_ap_pater', valor: form.value.ap_pater.trim().toUpperCase(), tipo: 'string' },
        { nombre: 'p_ap_mater', valor: form.value.ap_mater?.trim().toUpperCase() || '', tipo: 'string' },
        { nombre: 'p_rfc', valor: form.value.rfc?.trim().toUpperCase() || null, tipo: 'string' }
      ]
      resp = await execute('sp_update_inspector', BASE_DB, params, '', null, SCHEMA)
    }

    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data

    closeModal()
    await nextTick()

    await Swal.fire({
      icon: 'success',
      title: modalMode.value === 'create' ? 'Inspector Creado' : 'Inspector Actualizado',
      text: r?.out_mensaje || 'Operación exitosa',
      timer: 2000,
      timerProgressBar: true,
      showConfirmButton: false
    })

    load()
  } catch (e) {
    handleApiError(e)
  } finally {
    saving.value = false
  }
}

async function confirmDelete(inspector) {
  const result = await Swal.fire({
    icon: 'warning',
    title: 'Confirmar Eliminación',
    html: `<p>¿Está seguro de eliminar al inspector?</p>
      <p><strong>${inspector.inspector}</strong></p>`,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    deleteInspector(inspector.id_esta_persona)
  }
}

async function deleteInspector(id) {
  showLoading('Eliminando...', 'Procesando solicitud')
  try {
    const params = [{ nombre: 'p_id', valor: id, tipo: 'integer' }]
    const resp = await execute('sp_delete_inspector', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    const r = Array.isArray(data) ? data[0] : data

    hideLoading()
    await nextTick()

    if (r?.out_success) {
      await Swal.fire({
        icon: 'success',
        title: 'Eliminado',
        text: r.out_mensaje || 'Inspector eliminado correctamente',
        timer: 2000,
        timerProgressBar: true,
        showConfirmButton: false
      })
      load()
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: r?.out_mensaje || 'No se pudo eliminar el inspector',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (e) {
    handleApiError(e)
    hideLoading()
  }
}

onMounted(load)

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

