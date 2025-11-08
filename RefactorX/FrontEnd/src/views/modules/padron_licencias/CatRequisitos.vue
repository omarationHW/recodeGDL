<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Requisitos</h1>
        <p>Padrón de Licencias - Gestión de Requisitos para Trámites</p>
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
            <label class="municipal-form-label">ID Requisito:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filters.id_requisito"
              placeholder="ID del requisito"
              @keyup.enter="aplicarFiltrosYPaginacion"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Descripción:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Buscar por descripción"
              @keyup.enter="aplicarFiltrosYPaginacion"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">&nbsp;</label>
            <div class="btn-group-actions">
              <button @click="aplicarFiltrosYPaginacion" class="btn-municipal-primary" :disabled="loading || todosRequisitos.length === 0">
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
          Requisitos Registrados
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
                  ID
                </th>
                <th style="width: 75%;">
                  <font-awesome-icon icon="align-left" class="me-2" />
                  Descripción
                </th>
                <th style="width: 15%; text-align: center;">
                  <font-awesome-icon icon="cogs" class="me-1" />
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="3" class="text-center py-4">
                  <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Cargando...</span>
                  </div>
                </td>
              </tr>
              <tr v-else-if="requisitos.length === 0">
                <td colspan="3" class="empty-state">
                  <div class="empty-state-content">
                    <font-awesome-icon icon="inbox" class="empty-state-icon" />
                    <p class="empty-state-text">No se encontraron requisitos con los filtros seleccionados</p>
                    <p class="empty-state-hint">Intenta ajustar los filtros de búsqueda o presiona "Actualizar"</p>
                  </div>
                </td>
              </tr>
              <tr v-else v-for="requisito in requisitos" :key="requisito.id_requisito" class="clickable-row">
                <td style="text-align: center;">
                  <span class="badge badge-light-secondary">
                    <font-awesome-icon icon="hashtag" />
                    {{ requisito.id_requisito }}
                  </span>
                </td>
                <td>
                  <div class="giro-name">
                    <font-awesome-icon icon="file-alt" class="giro-icon" />
                    <span class="giro-text">{{ requisito.descripcion?.trim() }}</span>
                  </div>
                </td>
                <td style="text-align: center;">
                  <div class="btn-group-actions">
                    <button
                      @click.stop="verRequisito(requisito)"
                      class="btn-table btn-table-info"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      @click.stop="editarRequisito(requisito)"
                      class="btn-table btn-table-primary"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      @click.stop="eliminarRequisito(requisito)"
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

  </div>
  <!-- /module-view -->

  <!-- Modal de Creación -->
  <Modal
    :show="showModalCrear"
    title="Crear Nuevo Requisito"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="clipboard-list" />
        <h6>Información del Requisito</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">ID Requisito <span class="text-danger">*</span></label>
          <input
            type="number"
            class="form-input-modal"
            v-model.number="nuevoRequisito.id_requisito"
            placeholder="ID del requisito"
          >
        </div>
        <div class="form-field" style="grid-column: 1 / -1;">
          <label class="form-label-modal">Descripción <span class="text-danger">*</span></label>
          <input
            type="text"
            class="form-input-modal"
            v-model="nuevoRequisito.descripcion"
            maxlength="200"
            placeholder="Descripción breve"
          >
        </div>
        <div class="form-field" style="grid-column: 1 / -1;">
          <label class="form-label-modal">Requisitos Detallados</label>
          <textarea
            class="form-input-modal"
            v-model="nuevoRequisito.requisitos"
            rows="6"
            placeholder="Descripción detallada de los requisitos..."
          ></textarea>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="crearRequisito">
        <font-awesome-icon icon="save" />
        Crear
      </button>
    </template>
  </Modal>

  <!-- Modal de Edición -->
  <Modal
    :show="showModalEditar"
    :title="`Editar Requisito: ${requisitoSeleccionado?.descripcion?.trim() || ''}`"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="clipboard-list" />
        <h6>Información del Requisito</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">ID (no editable)</label>
          <input
            type="number"
            class="form-input-modal"
            :value="requisitoSeleccionado?.id_requisito"
            disabled
          >
        </div>
        <div class="form-field" style="grid-column: 1 / -1;">
          <label class="form-label-modal">Descripción <span class="text-danger">*</span></label>
          <input
            type="text"
            class="form-input-modal"
            v-model="requisitoEditado.descripcion"
            maxlength="200"
          >
        </div>
        <div class="form-field" style="grid-column: 1 / -1;">
          <label class="form-label-modal">Requisitos Detallados</label>
          <textarea
            class="form-input-modal"
            v-model="requisitoEditado.requisitos"
            rows="6"
          ></textarea>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="actualizarRequisito">
        <font-awesome-icon icon="save" />
        Guardar
      </button>
    </template>
  </Modal>

  <!-- Modal de Vista -->
  <Modal
    :show="showModalVer"
    :title="`Detalles del Requisito: ${requisitoSeleccionado?.descripcion?.trim() || ''}`"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="info-circle" />
        <h6>Información Completa</h6>
      </div>
      <div class="details-grid">
        <div class="detail-row">
          <span class="detail-label">ID:</span>
          <span class="detail-value">{{ requisitoSeleccionado?.id_requisito }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Descripción:</span>
          <span class="detail-value">{{ requisitoSeleccionado?.descripcion?.trim() }}</span>
        </div>
        <div class="detail-row" style="grid-column: 1 / -1;">
          <span class="detail-label">Requisitos Detallados:</span>
          <span class="detail-value"><pre style="white-space: pre-wrap; font-family: inherit;">{{ requisitoSeleccionado?.requisitos || 'N/A' }}</pre></span>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cerrar
      </button>
      <button class="btn-municipal-primary" @click="editarRequisito(requisitoSeleccionado); showModalVer = false">
        <font-awesome-icon icon="edit" />
        Editar
      </button>
    </template>
  </Modal>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'CatRequisitos'"
    :moduleName="'padron_licencias'"
    @close="closeDocumentation"
  />
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
const requisitos = ref([])
const todosRequisitos = ref([]) // Cache
const requisitoSeleccionado = ref(null)
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
  id_requisito: null,
  descripcion: ''
})

// Formularios
const nuevoRequisito = ref({
  id_requisito: null,
  descripcion: '',
  requisitos: ''
})

const requisitoEditado = ref({
  descripcion: '',
  requisitos: ''
})

// Métodos
const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todosRequisitos.value]

  // Aplicar filtros
  if (filters.value.id_requisito !== null && filters.value.id_requisito !== '') {
    filtered = filtered.filter(r => r.id_requisito === filters.value.id_requisito)
  }

  if (filters.value.descripcion) {
    const desc = filters.value.descripcion.toLowerCase()
    filtered = filtered.filter(r =>
      r.descripcion?.toLowerCase().includes(desc)
    )
  }

  // Actualizar total
  totalRegistros.value = filtered.length

  // Aplicar paginación
  const start = (paginaActual.value - 1) * registrosPorPagina.value
  const end = start + registrosPorPagina.value
  requisitos.value = filtered.slice(start, end)
}

const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando requisitos...', 'Buscando en el catálogo')
  loading.value = true
  showFilters.value = false // Cerrar acordeón al actualizar

  try {
    const response = await execute(
      'sp_catrequisitos_list',
      'licencias',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      todosRequisitos.value = response.result
      paginaActual.value = 1
      aplicarFiltrosYPaginacion()

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const timeMessage = `(${duration}s)`

      showToast('success', `${totalRegistros.value.toLocaleString()} requisitos encontrados`, timeMessage)
    } else {
      todosRequisitos.value = []
      requisitos.value = []
      totalRegistros.value = 0
      showToast('info', 'No se encontraron requisitos')
    }
  } catch (error) {
    handleApiError(error)
    todosRequisitos.value = []
    requisitos.value = []
    totalRegistros.value = 0
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    id_requisito: null,
    descripcion: ''
  }
  paginaActual.value = 1
  if (todosRequisitos.value.length > 0) {
    aplicarFiltrosYPaginacion()
  }
}

const cambiarPagina = (nuevaPagina) => {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
    aplicarFiltrosYPaginacion()
  }
}

const cambiarRegistrosPorPagina = () => {
  paginaActual.value = 1
  aplicarFiltrosYPaginacion()
}

const abrirModalCrear = () => {
  nuevoRequisito.value = {
    id_requisito: null,
    descripcion: '',
    requisitos: ''
  }
  showModalCrear.value = true
}

const crearRequisito = async () => {
  if (!nuevoRequisito.value.id_requisito || !nuevoRequisito.value.descripcion?.trim()) {
    showToast('warning', 'ID y Descripción son requeridos')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Nuevo Requisito?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${nuevoRequisito.value.id_requisito}</p>
        <p><strong>Descripción:</strong> ${nuevoRequisito.value.descripcion}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando requisito...', 'Guardando información')

  try {
    const response = await execute(
      'sp_catrequisitos_create',
      'licencias',
      [
        { nombre: 'p_id_requisito', valor: nuevoRequisito.value.id_requisito, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: nuevoRequisito.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_requisitos', valor: nuevoRequisito.value.requisitos || '', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Requisito Creado!',
        text: 'El requisito ha sido creado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Requisito creado exitosamente')
      cerrarModal()
    } else {
      showToast('error', response.result?.[0]?.message || 'Error al crear el requisito')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const verRequisito = (requisito) => {
  requisitoSeleccionado.value = requisito
  showModalVer.value = true
}

const editarRequisito = (requisito) => {
  requisitoSeleccionado.value = requisito
  requisitoEditado.value = {
    descripcion: requisito.descripcion?.trim() || '',
    requisitos: requisito.requisitos || ''
  }
  showModalEditar.value = true
  showModalVer.value = false
}

const actualizarRequisito = async () => {
  if (!requisitoEditado.value.descripcion?.trim()) {
    showToast('warning', 'La descripción es requerida')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Requisito?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${requisitoSeleccionado.value.id_requisito}</p>
        <p><strong>Descripción:</strong> ${requisitoEditado.value.descripcion}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando requisito...', 'Guardando cambios')

  try {
    const response = await execute(
      'sp_catrequisitos_update',
      'licencias',
      [
        { nombre: 'p_id_requisito', valor: requisitoSeleccionado.value.id_requisito, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: requisitoEditado.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_requisitos', valor: requisitoEditado.value.requisitos || '', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Requisito Actualizado!',
        text: 'El requisito ha sido actualizado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Requisito actualizado exitosamente')
      cerrarModal()
    } else {
      showToast('error', response.result?.[0]?.message || 'Error al actualizar el requisito')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const eliminarRequisito = async (requisito) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar Requisito?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${requisito.id_requisito}</p>
        <p><strong>Descripción:</strong> ${requisito.descripcion?.trim()}</p>
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

  showLoading('Eliminando requisito...', 'Procesando')

  try {
    const response = await execute(
      'sp_catrequisitos_delete',
      'licencias',
      [
        { nombre: 'p_id_requisito', valor: requisito.id_requisito, tipo: 'integer' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: '¡Requisito Eliminado!',
        text: 'El requisito ha sido eliminado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Requisito eliminado exitosamente')
    } else {
      showToast('error', response.result?.[0]?.message || 'Error al eliminar el requisito')
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
  requisitoSeleccionado.value = null
}

// Toggle filtros
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente - el usuario debe presionar "Actualizar"
})
</script>
