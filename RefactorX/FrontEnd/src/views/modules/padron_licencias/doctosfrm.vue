<!-- Catálogo de Documentos - v1.0 -->
<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Documentos</h1>
        <p>Padrón de Licencias - Gestión de Tipos de Documentos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalCrear" :disabled="loading">
          <font-awesome-icon icon="plus" />
          Nuevo
        </button>
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header clickable-header" @click="toggleFilters">
        <h5>
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
        </h5>
      </div>

      <div v-show="showFilters" class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Clave Documento:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filters.cvedocto"
              placeholder="Clave del documento"
              @keyup.enter="aplicarFiltrosYPaginacion"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Nombre Documento:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.documento"
              placeholder="Buscar por nombre"
              @keyup.enter="aplicarFiltrosYPaginacion"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">&nbsp;</label>
            <div class="btn-group-actions">
              <button @click="aplicarFiltrosYPaginacion" class="btn-municipal-primary" :disabled="loading || todosDocumentos.length === 0">
                <font-awesome-icon icon="search" /> Buscar
              </button>
              <button @click="limpiarFiltros" class="btn-municipal-secondary" :disabled="loading">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Documentos Registrados
        </h5>
        <div class="ms-auto d-flex align-items-center gap-3">
          <span class="badge-purple" v-if="totalRegistros > 0">
            {{ totalRegistros.toLocaleString() }} registro{{ totalRegistros !== 1 ? 's' : '' }}
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 10%; text-align: center;">
                  <font-awesome-icon icon="hashtag" class="me-1" />
                  Clave
                </th>
                <th style="width: 55%;">
                  <font-awesome-icon icon="align-left" class="me-2" />
                  Documento
                </th>
                <th style="width: 15%; text-align: center;">
                  <font-awesome-icon icon="calendar" class="me-1" />
                  Fecha
                </th>
                <th style="width: 15%; text-align: center;">
                  <font-awesome-icon icon="user" class="me-1" />
                  Usuario
                </th>
                <th style="width: 15%; text-align: center;">
                  <font-awesome-icon icon="cogs" class="me-1" />
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="5" class="text-center py-4">
                  <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Cargando...</span>
                  </div>
                </td>
              </tr>
              <tr v-else-if="documentos.length === 0">
                <td colspan="5" class="empty-state">
                  <div class="empty-state-content">
                    <font-awesome-icon icon="inbox" class="empty-state-icon" />
                    <p class="empty-state-text">No se encontraron documentos con los filtros seleccionados</p>
                    <p class="empty-state-hint">Intenta ajustar los filtros de búsqueda o presiona "Actualizar"</p>
                  </div>
                </td>
              </tr>
              <tr v-else v-for="doc in documentos" :key="doc.cvedocto" class="clickable-row">
                <td style="text-align: center;">
                  <span class="badge badge-light-secondary">
                    <font-awesome-icon icon="hashtag" />
                    {{ doc.cvedocto }}
                  </span>
                </td>
                <td>
                  <div class="giro-name">
                    <font-awesome-icon icon="file-alt" class="giro-icon" />
                    <span class="giro-text">{{ doc.documento?.trim() }}</span>
                  </div>
                </td>
                <td style="text-align: center;">
                  <small class="text-muted">
                    {{ formatDate(doc.feccap) }}
                  </small>
                </td>
                <td style="text-align: center;">
                  <span class="badge badge-light-info">
                    {{ doc.capturista?.trim() || 'N/A' }}
                  </span>
                </td>
                <td style="text-align: center;">
                  <div class="btn-group-actions">
                    <button
                      @click.stop="verDocumento(doc)"
                      class="btn-table btn-table-info"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      @click.stop="editarDocumento(doc)"
                      class="btn-table btn-table-primary"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      @click.stop="eliminarDocumento(doc)"
                      class="btn-table btn-table-danger"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div class="pagination-container" v-if="totalRegistros > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((paginaActual - 1) * registrosPorPagina) + 1 }}
            a {{ Math.min(paginaActual * registrosPorPagina, totalRegistros) }}
            de {{ totalRegistros.toLocaleString() }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model.number="registrosPorPagina" @change="cambiarRegistrosPorPagina">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="cambiarPagina(paginaActual - 1)"
                :disabled="paginaActual === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-button"
                :class="{ active: page === paginaActual }"
                @click="cambiarPagina(page)"
              >
                {{ page }}
              </button>

              <button
                class="pagination-button"
                @click="cambiarPagina(paginaActual + 1)"
                :disabled="paginaActual === totalPaginas"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" class="toast-duration-icon" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view-content -->

  <!-- Modal Crear -->
  <Modal
    :show="showModalCrear"
    title="Crear Nuevo Documento"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="file-alt" />
        <h6>Información del Documento</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">Clave Documento <span class="text-danger">*</span></label>
          <input type="number" class="form-input-modal" v-model.number="nuevoDocumento.cvedocto" required>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Nombre Documento <span class="text-danger">*</span></label>
          <input type="text" class="form-input-modal" v-model="nuevoDocumento.documento" maxlength="30" required>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="crearDocumento">
        <font-awesome-icon icon="save" />
        Crear
      </button>
    </template>
  </Modal>

  <!-- Modal Editar -->
  <Modal
    :show="showModalEditar"
    title="Editar Documento"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="file-alt" />
        <h6>Información del Documento</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">Clave Documento</label>
          <input type="number" class="form-input-modal" :value="documentoSeleccionado?.cvedocto" disabled>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Nombre Documento <span class="text-danger">*</span></label>
          <input type="text" class="form-input-modal" v-model="documentoEditado.documento" maxlength="30" required>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Fecha Captura</label>
          <input type="text" class="form-input-modal" :value="formatDate(documentoSeleccionado?.feccap)" disabled>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Usuario</label>
          <input type="text" class="form-input-modal" :value="documentoSeleccionado?.capturista" disabled>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="actualizarDocumento">
        <font-awesome-icon icon="save" />
        Guardar
      </button>
    </template>
  </Modal>

  <!-- Modal Ver -->
  <Modal
    :show="showModalVer"
    title="Detalle del Documento"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="file-alt" />
        <h6>Información del Documento</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">Clave Documento</label>
          <input type="text" class="form-input-modal" :value="documentoSeleccionado?.cvedocto" disabled>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Nombre Documento</label>
          <input type="text" class="form-input-modal" :value="documentoSeleccionado?.documento" disabled>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Fecha Captura</label>
          <input type="text" class="form-input-modal" :value="formatDate(documentoSeleccionado?.feccap)" disabled>
        </div>
        <div class="form-field">
          <label class="form-label-modal">Usuario</label>
          <input type="text" class="form-input-modal" :value="documentoSeleccionado?.capturista" disabled>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cerrar
      </button>
    </template>
  </Modal>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'doctosfrm'"
    :moduleName="'padron_licencias'"
    @close="closeDocumentation"
  />
</div>
<!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Documentation
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

// Estado
const loading = ref(false)
const documentos = ref([])
const todosDocumentos = ref([]) // Cache
const documentoSeleccionado = ref(null)
const showModalCrear = ref(false)
const showModalEditar = ref(false)
const showModalVer = ref(false)
const showFilters = ref(false) // Acordeón de filtros - inicia oculto

// Paginación
const paginaActual = ref(1)
const registrosPorPagina = ref(10)
const totalRegistros = ref(0)

const totalPaginas = computed(() => {
  return Math.ceil(totalRegistros.value / registrosPorPagina.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, paginaActual.value - 2)
  const end = Math.min(totalPaginas.value, paginaActual.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Filtros
const filters = ref({
  cvedocto: null,
  documento: ''
})

// Formularios
const nuevoDocumento = ref({
  cvedocto: null,
  documento: ''
})

const documentoEditado = ref({
  documento: ''
})

// Métodos
const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todosDocumentos.value]

  // Aplicar filtros
  if (filters.value.cvedocto !== null && filters.value.cvedocto !== '') {
    filtered = filtered.filter(d => d.cvedocto === filters.value.cvedocto)
  }

  if (filters.value.documento) {
    const doc = filters.value.documento.toLowerCase()
    filtered = filtered.filter(d =>
      d.documento?.toLowerCase().includes(doc)
    )
  }

  totalRegistros.value = filtered.length

  // Aplicar paginación
  const start = (paginaActual.value - 1) * registrosPorPagina.value
  const end = start + registrosPorPagina.value
  documentos.value = filtered.slice(start, end)
}

const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando documentos...', 'Buscando en el catálogo')
  loading.value = true
  showFilters.value = false // Cerrar acordeón al actualizar

  try {
    const response = await execute(
      'SP_DOCTOS_LIST',
      'padron_licencias',
      [],
      '',      // tenant
      null,    // pagination
      'publico' // esquema
    )

    if (response && response.result && response.result.length > 0) {
      todosDocumentos.value = response.result
      paginaActual.value = 1
      aplicarFiltrosYPaginacion()

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      showToast('success', `${totalRegistros.value.toLocaleString()} documentos encontrados`, `(${duration}s)`)
    } else {
      todosDocumentos.value = []
      documentos.value = []
      totalRegistros.value = 0
      showToast('info', 'No se encontraron documentos')
    }
  } catch (error) {
    handleApiError(error)
    todosDocumentos.value = []
    documentos.value = []
    totalRegistros.value = 0
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    cvedocto: null,
    documento: ''
  }
  paginaActual.value = 1
  if (todosDocumentos.value.length > 0) {
    aplicarFiltrosYPaginacion()
  }
}

const cambiarPagina = (pagina) => {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    paginaActual.value = pagina
    aplicarFiltrosYPaginacion()
  }
}

const cambiarRegistrosPorPagina = () => {
  paginaActual.value = 1
  aplicarFiltrosYPaginacion()
}

const abrirModalCrear = () => {
  nuevoDocumento.value = {
    cvedocto: null,
    documento: ''
  }
  showModalCrear.value = true
}

const verDocumento = (doc) => {
  documentoSeleccionado.value = doc
  showModalVer.value = true
}

const editarDocumento = (doc) => {
  documentoSeleccionado.value = doc
  documentoEditado.value = {
    documento: doc.documento?.trim()
  }
  showModalEditar.value = true
}

const crearDocumento = async () => {
  if (!nuevoDocumento.value.cvedocto || !nuevoDocumento.value.documento) {
    showToast('error', 'Por favor complete todos los campos obligatorios')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Documento?',
    html: `
      <div class="swal-content">
        <p><strong>Clave:</strong> ${nuevoDocumento.value.cvedocto}</p>
        <p><strong>Documento:</strong> ${nuevoDocumento.value.documento}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando documento...', 'Guardando en la base de datos')

  try {
    const response = await execute(
      'SP_DOCTOS_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_cvedocto', valor: nuevoDocumento.value.cvedocto, tipo: 'integer' },
        { nombre: 'p_documento', valor: nuevoDocumento.value.documento, tipo: 'string' }
      ],
      '',      // tenant
      null,    // pagination
      'publico' // esquema
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Documento Creado!',
        text: 'El documento ha sido creado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Documento creado exitosamente')
      cerrarModal()
      await buscar()  // Recargar datos
    } else {
      showToast('error', response.result?.[0]?.message || 'Error al crear el documento')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const actualizarDocumento = async () => {
  if (!documentoEditado.value.documento) {
    showToast('error', 'Por favor complete todos los campos obligatorios')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Documento?',
    html: `
      <div class="swal-content">
        <p><strong>Clave:</strong> ${documentoSeleccionado.value.cvedocto}</p>
        <p><strong>Nuevo nombre:</strong> ${documentoEditado.value.documento}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando documento...', 'Guardando cambios')

  try {
    const response = await execute(
      'SP_DOCTOS_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_cvedocto', valor: documentoSeleccionado.value.cvedocto, tipo: 'integer' },
        { nombre: 'p_documento', valor: documentoEditado.value.documento, tipo: 'string' }
      ],
      '',      // tenant
      null,    // pagination
      'publico' // esquema
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Documento Actualizado!',
        text: 'El documento ha sido actualizado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Documento actualizado exitosamente')
      cerrarModal()
      await buscar()  // Recargar datos
    } else {
      showToast('error', response.result?.[0]?.message || 'Error al actualizar el documento')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const eliminarDocumento = async (doc) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar Documento?',
    html: `
      <div class="swal-content">
        <p><strong>Clave:</strong> ${doc.cvedocto}</p>
        <p><strong>Documento:</strong> ${doc.documento?.trim()}</p>
        <p class="text-danger mt-3">Esta acción no se puede deshacer</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Eliminando documento...', 'Procesando')

  try {
    const response = await execute(
      'SP_DOCTOS_DELETE',
      'padron_licencias',
      [
        { nombre: 'p_cvedocto', valor: doc.cvedocto, tipo: 'integer' }
      ],
      '',      // tenant
      null,    // pagination
      'publico' // esquema
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Documento Eliminado!',
        text: 'El documento ha sido eliminado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Documento eliminado exitosamente')
      await buscar()  // Recargar datos
    } else {
      showToast('error', response.result?.[0]?.message || 'Error al eliminar el documento')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const cerrarModal = () => {
  showModalCrear.value = false
  showModalEditar.value = false
  showModalVer.value = false
  documentoSeleccionado.value = null
}

// Toggle filtros
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente - el usuario debe presionar "Actualizar"
})
</script>
