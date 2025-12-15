<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Tipos de Bloqueo</h1>
        <p>Padrón de Licencias - Gestión de tipos de bloqueo</p>
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
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">ID</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filters.id"
              placeholder="ID del tipo"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Descripción</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.descripcion"
              placeholder="Descripción del tipo"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Selección/Consulta</label>
            <select class="municipal-form-control" v-model="filters.sel_cons">
              <option value="">Todos</option>
              <option value="S">Sí (S)</option>
              <option value="N">No (N)</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="aplicarFiltrosYPaginacion"
            :disabled="loading || todosTiposBloqueo.length === 0"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de catálogo -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Catálogo de Tipos de Bloqueo
        </h5>
        <div class="ms-auto d-flex align-items-center gap-3">
          <span class="badge-purple" v-if="totalRegistros > 0">
            {{ totalRegistros.toLocaleString() }} registro{{ totalRegistros !== 1 ? 's' : '' }}
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th style="width: 80px;">ID</th>
                <th>Descripción</th>
                <th style="width: 150px;">Sel/Cons</th>
                <th style="width: 220px;">Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="tipo in tiposBloqueo" :key="tipo.id" class="clickable-row">
                <td>
                  <span class="badge-secondary">
                    <font-awesome-icon icon="tag" />
                    {{ tipo.id }}
                  </span>
                </td>
                <td><strong class="text-primary">{{ tipo.descripcion?.trim() }}</strong></td>
                <td>
                  <span class="badge" :class="tipo.sel_cons === 'S' ? 'badge-success' : 'badge-secondary'">
                    {{ tipo.sel_cons === 'S' ? 'Sí (S)' : tipo.sel_cons === 'N' ? 'No (N)' : 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="btn-group-table">
                    <button
                      class="btn-table btn-table-info"
                      @click="verTipo(tipo)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-table btn-table-primary"
                      @click="editarTipo(tipo)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-table btn-table-danger"
                      @click="eliminarTipo(tipo)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="tiposBloqueo.length === 0 && !loading">
                <td colspan="4" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron tipos de bloqueo. Presione "Actualizar" para cargar los datos.</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div class="pagination-container" v-if="totalRegistros > 0">
          <div class="pagination-info">
            Mostrando {{ ((paginaActual - 1) * registrosPorPagina) + 1 }} a
            {{ Math.min(paginaActual * registrosPorPagina, totalRegistros) }} de
            {{ totalRegistros.toLocaleString() }} registros
          </div>

          <div class="pagination-controls">
            <label class="pagination-label">
              Registros por página:
              <select v-model.number="registrosPorPagina" @change="cambiarRegistrosPorPagina" class="pagination-select">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </label>

            <div class="pagination-buttons">
              <button
                @click="cambiarPagina(1)"
                :disabled="paginaActual === 1"
                class="btn-pagination"
                title="Primera página"
              >
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                @click="cambiarPagina(paginaActual - 1)"
                :disabled="paginaActual === 1"
                class="btn-pagination"
                title="Página anterior"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <span class="pagination-info-pages">
                Página {{ paginaActual }} de {{ totalPaginas }}
              </span>

              <button
                @click="cambiarPagina(paginaActual + 1)"
                :disabled="paginaActual === totalPaginas"
                class="btn-pagination"
                title="Página siguiente"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                @click="cambiarPagina(totalPaginas)"
                :disabled="paginaActual === totalPaginas"
                class="btn-pagination"
                title="Última página"
              >
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="text-muted mt-2">Cargando tipos de bloqueo...</p>
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
    title="Crear Nuevo Tipo de Bloqueo"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="ban" />
        <h6>Información del Tipo</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">Descripción <span class="text-danger">*</span></label>
          <input
            type="text"
            class="form-input-modal"
            v-model="nuevoTipo.descripcion"
            maxlength="30"
            placeholder="Descripción del tipo de bloqueo"
          >
        </div>
        <div class="form-field">
          <label class="form-label-modal">Selección/Consulta <span class="text-danger">*</span></label>
          <select class="form-input-modal" v-model="nuevoTipo.sel_cons">
            <option value="S">Sí (S)</option>
            <option value="N">No (N)</option>
          </select>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="crearTipo">
        <font-awesome-icon icon="save" />
        Crear
      </button>
    </template>
  </Modal>

  <!-- Modal de Edición -->
  <Modal
    :show="showModalEditar"
    :title="`Editar Tipo: ${tipoSeleccionado?.descripcion || ''}`"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="ban" />
        <h6>Información del Tipo</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-field">
          <label class="form-label-modal">ID (no editable)</label>
          <input
            type="number"
            class="form-input-modal"
            :value="tipoSeleccionado?.id"
            disabled
          >
        </div>
        <div class="form-field">
          <label class="form-label-modal">Descripción <span class="text-danger">*</span></label>
          <input
            type="text"
            class="form-input-modal"
            v-model="tipoEditado.descripcion"
            maxlength="30"
          >
        </div>
        <div class="form-field">
          <label class="form-label-modal">Selección/Consulta <span class="text-danger">*</span></label>
          <select class="form-input-modal" v-model="tipoEditado.sel_cons">
            <option value="S">Sí (S)</option>
            <option value="N">No (N)</option>
          </select>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="actualizarTipo">
        <font-awesome-icon icon="save" />
        Guardar
      </button>
    </template>
  </Modal>

  <!-- Modal de Vista -->
  <Modal
    :show="showModalVer"
    :title="`Detalles del Tipo: ${tipoSeleccionado?.descripcion || ''}`"
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
          <span class="detail-value">{{ tipoSeleccionado?.id }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Descripción:</span>
          <span class="detail-value">{{ tipoSeleccionado?.descripcion?.trim() }}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Selección/Consulta:</span>
          <span class="detail-value">
            <span class="badge" :class="tipoSeleccionado?.sel_cons === 'S' ? 'badge-success' : 'badge-secondary'">
              {{ tipoSeleccionado?.sel_cons === 'S' ? 'Sí (S)' : tipoSeleccionado?.sel_cons === 'N' ? 'No (N)' : 'N/A' }}
            </span>
          </span>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cerrar
      </button>
      <button class="btn-municipal-primary" @click="editarTipo(tipoSeleccionado); showModalVer = false">
        <font-awesome-icon icon="edit" />
        Editar
      </button>
    </template>
  </Modal>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'tipobloqueofrm'"
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
const tiposBloqueo = ref([])
const todosTiposBloqueo = ref([]) // Cache de todos los datos
const tipoSeleccionado = ref(null)
const showModalCrear = ref(false)
const showModalEditar = ref(false)
const showModalVer = ref(false)

// Paginación
const paginaActual = ref(1)
const registrosPorPagina = ref(10)
const totalRegistros = ref(0)

const totalPaginas = computed(() => {
  return Math.ceil(totalRegistros.value / registrosPorPagina.value)
})

// Filtros
const filters = ref({
  id: null,
  descripcion: '',
  sel_cons: ''
})

// Formularios
const nuevoTipo = ref({
  descripcion: '',
  sel_cons: 'S'
})

const tipoEditado = ref({
  descripcion: '',
  sel_cons: 'S'
})

// Métodos
const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todosTiposBloqueo.value]

  // Aplicar filtros
  if (filters.value.id !== null && filters.value.id !== '') {
    filtered = filtered.filter(t => t.id === filters.value.id)
  }

  if (filters.value.descripcion) {
    const desc = filters.value.descripcion.toLowerCase()
    filtered = filtered.filter(t =>
      t.descripcion?.toLowerCase().includes(desc)
    )
  }

  if (filters.value.sel_cons) {
    filtered = filtered.filter(t => t.sel_cons === filters.value.sel_cons)
  }

  // Actualizar total
  totalRegistros.value = filtered.length

  // Aplicar paginación
  const start = (paginaActual.value - 1) * registrosPorPagina.value
  const end = start + registrosPorPagina.value
  tiposBloqueo.value = filtered.slice(start, end)
}

const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando tipos de bloqueo...', 'Buscando en el catálogo')
  loading.value = true

  try {
    const response = await execute(
      'SP_TIPOBLOQUEO_LIST',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      todosTiposBloqueo.value = response.result
      paginaActual.value = 1
      aplicarFiltrosYPaginacion()

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      const timeMessage = `(${duration}s)`

      showToast('success', `${totalRegistros.value.toLocaleString()} tipos de bloqueo encontrados`, timeMessage)
    } else {
      todosTiposBloqueo.value = []
      tiposBloqueo.value = []
      totalRegistros.value = 0
      showToast('info', 'No se encontraron tipos de bloqueo')
    }
  } catch (error) {
    handleApiError(error)
    todosTiposBloqueo.value = []
    tiposBloqueo.value = []
    totalRegistros.value = 0
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = {
    id: null,
    descripcion: '',
    sel_cons: ''
  }
  paginaActual.value = 1
  if (todosTiposBloqueo.value.length > 0) {
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
  nuevoTipo.value = {
    descripcion: '',
    sel_cons: 'S'
  }
  showModalCrear.value = true
}

const crearTipo = async () => {
  if (!nuevoTipo.value.descripcion?.trim()) {
    showToast('warning', 'La descripción es requerida')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Nuevo Tipo de Bloqueo?',
    html: `
      <div class="swal-content">
        <p><strong>Descripción:</strong> ${nuevoTipo.value.descripcion}</p>
        <p><strong>Sel/Cons:</strong> ${nuevoTipo.value.sel_cons}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando tipo de bloqueo...', 'Guardando información')

  try {
    const response = await execute(
      'SP_TIPOBLOQUEO_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: nuevoTipo.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_sel_cons', valor: nuevoTipo.value.sel_cons, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.success !== false) {
      await Swal.fire({
        icon: 'success',
        title: '¡Tipo Creado!',
        text: 'El tipo de bloqueo ha sido creado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Tipo de bloqueo creado exitosamente')
      cerrarModal()
    } else {
      showToast('error', response.message || 'Error al crear el tipo')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const verTipo = (tipo) => {
  tipoSeleccionado.value = tipo
  showModalVer.value = true
}

const editarTipo = (tipo) => {
  tipoSeleccionado.value = tipo
  tipoEditado.value = {
    descripcion: tipo.descripcion?.trim() || '',
    sel_cons: tipo.sel_cons || 'S'
  }
  showModalEditar.value = true
  showModalVer.value = false
}

const actualizarTipo = async () => {
  if (!tipoEditado.value.descripcion?.trim()) {
    showToast('warning', 'La descripción es requerida')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Tipo de Bloqueo?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${tipoSeleccionado.value.id}</p>
        <p><strong>Descripción:</strong> ${tipoEditado.value.descripcion}</p>
        <p><strong>Sel/Cons:</strong> ${tipoEditado.value.sel_cons}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando tipo de bloqueo...', 'Guardando cambios')

  try {
    const response = await execute(
      'SP_TIPOBLOQUEO_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: tipoSeleccionado.value.id, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: tipoEditado.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_sel_cons', valor: tipoEditado.value.sel_cons, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.success !== false) {
      await Swal.fire({
        icon: 'success',
        title: '¡Tipo Actualizado!',
        text: 'El tipo de bloqueo ha sido actualizado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Tipo de bloqueo actualizado exitosamente')
      cerrarModal()
    } else {
      showToast('error', response.message || 'Error al actualizar el tipo')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const eliminarTipo = async (tipo) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar Tipo de Bloqueo?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${tipo.id}</p>
        <p><strong>Descripción:</strong> ${tipo.descripcion?.trim()}</p>
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

  showLoading('Eliminando tipo de bloqueo...', 'Procesando')

  try {
    const response = await execute(
      'SP_TIPOBLOQUEO_DELETE',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: tipo.id, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.success !== false) {
      await Swal.fire({
        icon: 'success',
        title: '¡Tipo Eliminado!',
        text: 'El tipo de bloqueo ha sido eliminado exitosamente',
        confirmButtonColor: '#9363CD',
        timer: 2000,
        showConfirmButton: false
      })

      showToast('success', 'Tipo de bloqueo eliminado exitosamente')
    } else {
      showToast('error', response.message || 'Error al eliminar el tipo')
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
  tipoSeleccionado.value = null
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente - el usuario debe presionar "Actualizar"
})
</script>
