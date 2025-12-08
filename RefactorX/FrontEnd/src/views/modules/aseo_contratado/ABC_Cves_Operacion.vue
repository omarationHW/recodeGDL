<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="key" />
      </div>
      <div class="module-view-info">
        <h1>Catalogo de Claves de Operacion</h1>
        <p>Aseo Contratado - Administracion de claves de operacion</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="openCreateModal" :disabled="loading">
          <font-awesome-icon icon="plus" /> Nueva Clave
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Filtros -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Filtros de Busqueda</h3>
            <span class="section-subtitle">Buscar claves por descripcion</span>
          </div>
        </div>
        <div class="section-body">
          <div class="filter-row">
            <div class="filter-field">
              <label class="municipal-form-label">Buscar</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="search" /></span>
                <input type="text" class="municipal-form-control with-icon" v-model="searchQuery"
                  placeholder="Descripcion o clave..." @keyup.enter="handleSearch" />
              </div>
            </div>
            <div class="filter-actions">
              <button class="btn-municipal-primary" @click="handleSearch" :disabled="loading">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="clearSearch" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
              <button class="btn-municipal-secondary" @click="loadClaves" :disabled="loading">
                <font-awesome-icon icon="sync-alt" :spin="loading" /> Actualizar
              </button>
              <button class="btn-municipal-success" @click="exportToExcel" :disabled="loading || claves.length === 0">
                <font-awesome-icon icon="file-excel" /> Exportar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Tabla -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="list" /></div>
          <div class="section-title-group">
            <h3>Claves Registradas</h3>
            <span class="section-subtitle">{{ totalRecords }} registros encontrados</span>
          </div>
        </div>
        <div class="section-body">
          <div v-if="claves.length === 0 && !loading" class="empty-state">
            <font-awesome-icon icon="inbox" size="3x" />
            <p>No se encontraron claves de operacion</p>
          </div>
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Clave</th>
                  <th>Descripcion</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="clave in paginatedData" :key="clave.ctrol_operacion">
                  <td><code class="id-code">{{ clave.ctrol_operacion }}</code></td>
                  <td><span class="badge-primary">{{ clave.cve_operacion }}</span></td>
                  <td>{{ clave.descripcion }}</td>
                  <td class="text-center">
                    <div class="action-buttons">
                      <button class="btn-action btn-view" @click="openViewModal(clave)" title="Ver detalles">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button class="btn-action btn-edit" @click="openEditModal(clave)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-action btn-delete" @click="confirmDelete(clave)" title="Eliminar">
                        <font-awesome-icon icon="trash-alt" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Paginacion -->
            <div class="pagination-container" v-if="totalPages > 1">
              <div class="pagination-info">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} - {{ Math.min(currentPage * itemsPerPage, totalRecords) }} de {{ totalRecords }}
              </div>
              <div class="pagination-controls">
                <button @click="goToPage(1)" :disabled="currentPage === 1" class="btn-page">
                  <font-awesome-icon icon="angle-double-left" />
                </button>
                <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" class="btn-page">
                  <font-awesome-icon icon="angle-left" />
                </button>
                <span class="page-indicator">{{ currentPage }} / {{ totalPages }}</span>
                <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" class="btn-page">
                  <font-awesome-icon icon="angle-right" />
                </button>
                <button @click="goToPage(totalPages)" :disabled="currentPage === totalPages" class="btn-page">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <div v-if="showCreateModal" class="modal-overlay" @click.self="closeCreateModal">
      <div class="modal-container">
        <div class="modal-header">
          <h4><font-awesome-icon icon="plus-circle" /> Nueva Clave de Operacion</h4>
          <button class="modal-close" @click="closeCreateModal"><font-awesome-icon icon="times" /></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="municipal-form-label">Clave <span class="required">*</span></label>
            <input type="text" v-model="formData.cve_operacion" class="municipal-form-control"
              maxlength="1" placeholder="Ej: A" />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripcion <span class="required">*</span></label>
            <input type="text" v-model="formData.descripcion" class="municipal-form-control"
              maxlength="80" placeholder="Descripcion de la clave" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeCreateModal">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button class="btn-municipal-primary" @click="createClave" :disabled="guardando">
            <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
            {{ guardando ? 'Guardando...' : 'Guardar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Editar -->
    <div v-if="showEditModal" class="modal-overlay" @click.self="closeEditModal">
      <div class="modal-container">
        <div class="modal-header">
          <h4><font-awesome-icon icon="edit" /> Editar Clave de Operacion</h4>
          <button class="modal-close" @click="closeEditModal"><font-awesome-icon icon="times" /></button>
        </div>
        <div class="modal-body">
          <div class="form-group">
            <label class="municipal-form-label">ID</label>
            <input type="text" :value="formData.ctrol_operacion" class="municipal-form-control" disabled />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Clave</label>
            <input type="text" v-model="formData.cve_operacion" class="municipal-form-control" disabled />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripcion <span class="required">*</span></label>
            <input type="text" v-model="formData.descripcion" class="municipal-form-control"
              maxlength="80" />
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeEditModal">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button class="btn-municipal-primary" @click="updateClave" :disabled="guardando">
            <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
            {{ guardando ? 'Guardando...' : 'Guardar Cambios' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal Ver Detalle -->
    <div v-if="showViewModal" class="modal-overlay" @click.self="closeViewModal">
      <div class="modal-container">
        <div class="modal-header modal-header-info">
          <h4><font-awesome-icon icon="eye" /> Detalle de la Clave</h4>
          <button class="modal-close" @click="closeViewModal"><font-awesome-icon icon="times" /></button>
        </div>
        <div class="modal-body">
          <div class="detail-grid">
            <div class="detail-item">
              <label class="detail-label">ID</label>
              <p class="detail-value"><code class="id-code">{{ viewData.ctrol_operacion }}</code></p>
            </div>
            <div class="detail-item">
              <label class="detail-label">Clave</label>
              <p class="detail-value"><span class="badge-primary">{{ viewData.cve_operacion }}</span></p>
            </div>
            <div class="detail-item full-width">
              <label class="detail-label">Descripcion</label>
              <p class="detail-value">{{ viewData.descripcion }}</p>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeViewModal">
            <font-awesome-icon icon="times" /> Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editFromView">
            <font-awesome-icon icon="edit" /> Editar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - Claves de Operacion">
      <h3>Catalogo de Claves de Operacion</h3>
      <p>Administracion de claves de operacion para el modulo de aseo contratado.</p>
      <h4>Funcionalidades:</h4>
      <ul>
        <li><strong>Crear:</strong> Agregar nuevas claves de operacion</li>
        <li><strong>Editar:</strong> Modificar descripcion de claves existentes</li>
        <li><strong>Eliminar:</strong> Dar de baja claves no utilizadas (solo si no tienen pagos asociados)</li>
        <li><strong>Buscar:</strong> Filtrar por descripcion o clave</li>
        <li><strong>Exportar:</strong> Descargar listado en formato CSV</li>
      </ul>
      <h4>Campos:</h4>
      <ul>
        <li><strong>Clave:</strong> Codigo de 1 caracter (ej: A, B, C)</li>
        <li><strong>Descripcion:</strong> Descripcion de la operacion (max 80 caracteres)</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ABC_Cves_Operacion'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'

const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

const { execute } = useApi()
const { isLoading: loading, showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Estado
const claves = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)
const searchQuery = ref('')
const guardando = ref(false)

// Modales
const showDocumentation = ref(false)
const showTechDocs = ref(false)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)

// Formulario
const formData = ref({ ctrol_operacion: null, cve_operacion: '', descripcion: '' })
const viewData = ref({})

// Computed
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const filteredData = computed(() => {
  if (!searchQuery.value) return claves.value
  const query = searchQuery.value.toLowerCase()
  return claves.value.filter(c =>
    c.descripcion?.toLowerCase().includes(query) ||
    c.cve_operacion?.toLowerCase().includes(query)
  )
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return filteredData.value.slice(start, start + itemsPerPage.value)
})

// Cargar datos
async function loadClaves() {
  showLoading('Cargando...', 'Obteniendo claves de operacion')
  currentPage.value = 1
  try {
    const params = []
    const resp = await execute('sp_cves_operacion_list', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.result || resp || []
    claves.value = Array.isArray(data) ? data : []
    totalRecords.value = claves.value.length

    if (claves.value.length === 0) {
      showToast('No se encontraron claves', 'info')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
    claves.value = []
  } finally {
    hideLoading()
  }
}

function handleSearch() {
  currentPage.value = 1
  totalRecords.value = filteredData.value.length
}

function clearSearch() {
  searchQuery.value = ''
  totalRecords.value = claves.value.length
  currentPage.value = 1
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

// CRUD - Crear
function openCreateModal() {
  formData.value = { ctrol_operacion: null, cve_operacion: '', descripcion: '' }
  showCreateModal.value = true
}

function closeCreateModal() {
  showCreateModal.value = false
}

async function createClave() {
  if (!formData.value.cve_operacion?.trim() || !formData.value.descripcion?.trim()) {
    showToast('Complete todos los campos obligatorios', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: 'Crear Clave',
    html: `<p>¿Desea crear la clave <strong>${formData.value.cve_operacion}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Si, crear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Creando...', 'Guardando nueva clave')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_cve_operacion', valor: formData.value.cve_operacion.trim().toUpperCase(), tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]
    await execute('sp_cves_operacion_insert', BASE_DB, params, '', null, SCHEMA)
    showToast('Clave creada correctamente', 'success')
    closeCreateModal()
    await loadClaves()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

// CRUD - Editar
function openEditModal(clave) {
  formData.value = { ...clave }
  showEditModal.value = true
}

function closeEditModal() {
  showEditModal.value = false
}

async function updateClave() {
  if (!formData.value.descripcion?.trim()) {
    showToast('La descripcion es requerida', 'warning')
    return
  }

  const confirmResult = await Swal.fire({
    title: 'Actualizar Clave',
    html: `<p>¿Desea actualizar la clave <strong>${formData.value.cve_operacion}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Si, actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Actualizando...', 'Guardando cambios')
  guardando.value = true

  try {
    const params = [
      { nombre: 'p_ctrol_operacion', valor: formData.value.ctrol_operacion, tipo: 'integer' },
      { nombre: 'p_cve_operacion', valor: formData.value.cve_operacion, tipo: 'string' },
      { nombre: 'p_descripcion', valor: formData.value.descripcion.trim(), tipo: 'string' }
    ]
    await execute('sp_cves_operacion_update', BASE_DB, params, '', null, SCHEMA)
    showToast('Clave actualizada correctamente', 'success')
    closeEditModal()
    await loadClaves()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

// CRUD - Ver
function openViewModal(clave) {
  viewData.value = { ...clave }
  showViewModal.value = true
}

function closeViewModal() {
  showViewModal.value = false
}

function editFromView() {
  closeViewModal()
  openEditModal(viewData.value)
}

// CRUD - Eliminar
async function confirmDelete(clave) {
  const confirmResult = await Swal.fire({
    title: 'Eliminar Clave',
    html: `<p>¿Esta seguro de eliminar la clave:</p>
           <p><strong>${clave.cve_operacion} - ${clave.descripcion}</strong>?</p>
           <p class="text-danger">Esta accion no se puede deshacer.</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Si, eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) return

  showLoading('Eliminando...', 'Procesando eliminacion')

  try {
    const params = [
      { nombre: 'p_ctrol_operacion', valor: clave.ctrol_operacion, tipo: 'integer' }
    ]
    await execute('sp_cves_operacion_delete', BASE_DB, params, '', null, SCHEMA)
    showToast('Clave eliminada correctamente', 'success')
    await loadClaves()
  } catch (e) {
    hideLoading()
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Exportar
function exportToExcel() {
  if (claves.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  const headers = ['ID', 'Clave', 'Descripcion']
  const rows = claves.value.map(c => [c.ctrol_operacion, c.cve_operacion, c.descripcion])

  let csv = headers.join(',') + '\n'
  rows.forEach(row => {
    csv += row.map(val => `"${val || ''}"`).join(',') + '\n'
  })

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `claves_operacion_${new Date().toISOString().split('T')[0]}.csv`
  link.click()

  showToast('Archivo exportado correctamente', 'success')
}

// Documentacion
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

onMounted(() => {
  loadClaves()
})
</script>

