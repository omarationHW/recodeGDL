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
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
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
            <label class="municipal-form-label">ID (Req):</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filters.req"
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
        <div class="header-right">
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
              <tr v-else-if="requisitos.length === 0 && !hasSearched">
                <td colspan="3">
                  <div class="empty-state">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="clipboard-list" size="3x" />
                    </div>
                    <h4>Catálogo de Requisitos</h4>
                    <p>Presiona "Actualizar" para cargar los requisitos registrados en el sistema</p>
                  </div>
                </td>
              </tr>
              <tr v-else-if="requisitos.length === 0 && hasSearched">
                <td colspan="3">
                  <div class="empty-state">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="inbox" size="3x" />
                    </div>
                    <h4>Sin resultados</h4>
                    <p>No se encontraron requisitos con los criterios especificados</p>
                  </div>
                </td>
              </tr>
              <tr
                v-else
                v-for="requisito in requisitos"
                :key="requisito.req"
                @click="selectedRow = requisito"
                :class="{ 'table-row-selected': selectedRow === requisito }"
                class="row-hover"
              >
                <td style="text-align: center;">
                  <span class="badge badge-light-secondary">
                    <font-awesome-icon icon="hashtag" />
                    {{ requisito.req }}
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
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'CatRequisitos'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Catálogo de Requisitos'"
      @close="showDocModal = false"
    />
  </div>
  <!-- /module-view-content -->

  </div>
  <!-- /module-view -->

  <!-- Modal de Creación - Basado en Delphi: c_girosreq solo tiene req (autogenerado) y descripcion -->
  <Modal
    :show="showModalCrear"
    title="Crear Nuevo Requisito"
    @close="cerrarModal"
    size="md"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="clipboard-list" />
        <h6>Información del Requisito</h6>
      </div>
      <div class="modal-grid-1">
        <div class="form-field">
          <label class="form-label-modal">Descripción <span class="text-danger">*</span></label>
          <input
            type="text"
            class="form-input-modal"
            v-model="nuevoRequisito.descripcion"
            maxlength="255"
            placeholder="Descripción del requisito"
          >
          <small class="form-text text-muted">El ID se genera automáticamente</small>
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

  <!-- Modal de Edición - Basado en Delphi: solo descripcion es editable -->
  <Modal
    :show="showModalEditar"
    :title="`Editar Requisito #${requisitoSeleccionado?.req || ''}`"
    @close="cerrarModal"
    size="md"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="clipboard-list" />
        <h6>Información del Requisito</h6>
      </div>
      <div class="modal-grid-1">
        <div class="form-field">
          <label class="form-label-modal">ID (Req)</label>
          <input
            type="number"
            class="form-input-modal"
            :value="requisitoSeleccionado?.req"
            disabled
          >
        </div>
        <div class="form-field">
          <label class="form-label-modal">Descripción <span class="text-danger">*</span></label>
          <input
            type="text"
            class="form-input-modal"
            v-model="requisitoEditado.descripcion"
            maxlength="255"
          >
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

  <!-- Modal de Vista - Basado en Delphi: solo req y descripcion -->
  <Modal
    :show="showModalVer"
    :title="`Requisito #${requisitoSeleccionado?.req || ''}`"
    @close="cerrarModal"
    size="md"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="info-circle" />
        <h6>Información del Requisito</h6>
      </div>
      <div class="details-grid">
        <div class="detail-row">
          <span class="detail-label">ID (Req):</span>
          <span class="detail-value">{{ requisitoSeleccionado?.req }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Descripción:</span>
          <span class="detail-value">{{ requisitoSeleccionado?.descripcion?.trim() }}</span>
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

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

// Estado
const loading = ref(false)
const requisitos = ref([])
const todosRequisitos = ref([]) // Cache
const requisitoSeleccionado = ref(null)
const showModalCrear = ref(false)
const showModalEditar = ref(false)
const showModalVer = ref(false)
const showFilters = ref(false) // Acordeón de filtros - inicia oculto
const selectedRow = ref(null)
const hasSearched = ref(false)

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

// Filtros - Basado en Delphi: columnas req, descripcion
const filters = ref({
  req: null,
  descripcion: ''
})

// Formularios - Basado en Delphi: c_girosreq solo tiene req y descripcion
const nuevoRequisito = ref({
  descripcion: ''  // req es autogenerado (serial)
})

const requisitoEditado = ref({
  descripcion: ''
})

// Métodos
const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todosRequisitos.value]

  // Aplicar filtros - Basado en Delphi: columna req
  if (filters.value.req !== null && filters.value.req !== '') {
    filtered = filtered.filter(r => r.req === filters.value.req)
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
  hasSearched.value = true
  selectedRow.value = null
  loading.value = true
  showFilters.value = false // Cerrar acordeón al actualizar

  try {
    // Basado en Delphi: select * from c_girosreq order by req
    const response = await execute(
      'sp_catrequisitos_list',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
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
    req: null,
    descripcion: ''
  }
  requisitos.value = []
  hasSearched.value = false
  paginaActual.value = 1
  selectedRow.value = null
  if (todosRequisitos.value.length > 0) {
    aplicarFiltrosYPaginacion()
  }
}

const cambiarPagina = (nuevaPagina) => {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
    selectedRow.value = null
    aplicarFiltrosYPaginacion()
  }
}

const cambiarRegistrosPorPagina = () => {
  paginaActual.value = 1
  selectedRow.value = null
  aplicarFiltrosYPaginacion()
}

const abrirModalCrear = () => {
  // Basado en Delphi: req es autogenerado, solo se captura descripcion
  nuevoRequisito.value = {
    descripcion: ''
  }
  showModalCrear.value = true
}

const crearRequisito = async () => {
  // Basado en Delphi: solo descripcion es requerido, req es autogenerado
  if (!nuevoRequisito.value.descripcion?.trim()) {
    showToast('warning', 'La descripción es requerida')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Nuevo Requisito?',
    html: `
      <div class="swal-content">
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
    // Basado en Delphi: insert into c_girosreq (descripcion) values (:descripcion)
    // El req se genera automáticamente (serial)
    const response = await execute(
      'sp_catrequisitos_create',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: nuevoRequisito.value.descripcion.trim(), tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const nuevoReq = response.result[0]
      await Swal.fire({
        icon: 'success',
        title: '¡Requisito Creado!',
        text: `Requisito #${nuevoReq.req} creado exitosamente`,
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Requisito creado exitosamente')
      cerrarModal()
      buscar() // Recargar lista
    } else {
      showToast('error', 'Error al crear el requisito')
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
  // Basado en Delphi: solo descripcion es editable
  requisitoEditado.value = {
    descripcion: requisito.descripcion?.trim() || ''
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
        <p><strong>ID:</strong> ${requisitoSeleccionado.value.req}</p>
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
    // Basado en Delphi: update c_girosreq set descripcion = :descripcion where req = :req
    const response = await execute(
      'sp_catrequisitos_update',
      'padron_licencias',
      [
        { nombre: 'p_req', valor: requisitoSeleccionado.value.req, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: requisitoEditado.value.descripcion.trim(), tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
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
      buscar() // Recargar lista
    } else {
      showToast('error', 'Error al actualizar el requisito')
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
        <p><strong>ID:</strong> ${requisito.req}</p>
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
    // Basado en Delphi: delete from c_girosreq where req = :req
    const response = await execute(
      'sp_catrequisitos_delete',
      'padron_licencias',
      [
        { nombre: 'p_req', valor: requisito.req, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
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
      buscar() // Recargar lista
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
