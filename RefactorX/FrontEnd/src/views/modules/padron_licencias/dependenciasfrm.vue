<!-- Catálogo de Dependencias - v1.0 -->
<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Dependencias</h1>
        <p>Padrón de Licencias - Gestión de Dependencias Municipales</p>
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
            <label class="municipal-form-label">ID Dependencia:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model.number="filters.id_dependencia"
              placeholder="ID de la dependencia"
              @keyup.enter="aplicarFiltrosYPaginacion"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Nombre Dependencia:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.dependencia"
              placeholder="Buscar por nombre"
              @keyup.enter="aplicarFiltrosYPaginacion"
            />
          </div>

          <div class="form-group">
            <label class="municipal-form-label">Estado:</label>
            <select class="municipal-form-control" v-model="filters.estado">
              <option value="">Todos</option>
              <option value="A">Activo</option>
              <option value="I">Inactivo</option>
            </select>
          </div>

          <div class="form-group">
            <label class="municipal-form-label">&nbsp;</label>
            <div class="btn-group-actions">
              <button @click="aplicarFiltrosYPaginacion" class="btn-municipal-primary" :disabled="loading || todasDependencias.length === 0">
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
          Listado de Dependencias
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="totalRegistros > 0">
            {{ totalRegistros.toLocaleString() }} registros
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
                <th style="width: 40%;">
                  <font-awesome-icon icon="building" class="me-2" />
                  Dependencia
                </th>
                <th style="width: 20%; text-align: center;">
                  <font-awesome-icon icon="sitemap" class="me-1" />
                  Dep. Ref
                </th>
                <th style="width: 15%; text-align: center;">
                  <font-awesome-icon icon="toggle-on" class="me-1" />
                  Estado
                </th>
                <th style="width: 15%; text-align: center;">
                  <font-awesome-icon icon="cogs" class="me-1" />
                  Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="loading">
                <td colspan="5" class="text-center py-5">
                  <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Cargando...</span>
                  </div>
                  <p class="text-muted mt-2">Cargando dependencias...</p>
                </td>
              </tr>

              <tr v-else-if="dependencias.length === 0 && !hasSearched">
                <td colspan="5">
                  <div class="empty-state">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="building" size="3x" />
                    </div>
                    <h4>Catálogo de Dependencias</h4>
                    <p>Presiona "Actualizar" para cargar el listado de dependencias municipales</p>
                  </div>
                </td>
              </tr>

              <tr v-else-if="dependencias.length === 0 && hasSearched">
                <td colspan="5">
                  <div class="empty-state">
                    <div class="empty-state-icon">
                      <font-awesome-icon icon="inbox" size="3x" />
                    </div>
                    <h4>Sin resultados</h4>
                    <p>No se encontraron dependencias con los criterios especificados</p>
                  </div>
                </td>
              </tr>

              <tr
                v-else
                v-for="dep in dependencias"
                :key="dep.id_dependencia"
                @click="selectedRow = dep"
                :class="{ 'table-row-selected': selectedRow === dep }"
                class="row-hover"
              >
                <td style="text-align: center;">
                  <code class="text-primary"><strong>{{ dep.id_dependencia }}</strong></code>
                </td>
                <td>
                  <strong>{{ dep.dependencia?.trim() }}</strong>
                </td>
                <td style="text-align: center;">
                  <span class="badge-secondary">{{ dep.id_depref || 'N/A' }}</span>
                </td>
                <td style="text-align: center;">
                  <span class="badge" :class="dep.estado === 'A' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="dep.estado === 'A' ? 'check-circle' : 'times-circle'" />
                    {{ dep.estado === 'A' ? 'Activo' : 'Inactivo' }}
                  </span>
                </td>
                <td style="text-align: center;">
                  <div class="btn-group-actions">
                    <button class="btn-action btn-action-view" @click.stop="verDependencia(dep)" title="Ver detalles">
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button class="btn-action btn-action-edit" @click.stop="editarDependencia(dep)" title="Editar">
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button class="btn-action btn-action-delete" @click.stop="confirmarEliminar(dep)" title="Eliminar">
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación -->
        <div v-if="totalRegistros > 0 && !loading" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((paginaActual - 1) * registrosPorPagina) + 1 }}
              a {{ Math.min(paginaActual * registrosPorPagina, totalRegistros) }}
              de {{ totalRegistros.toLocaleString() }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="registrosPorPagina"
              @change="registrosPorPagina = parseInt($event.target.value); cambiarRegistrosPorPagina()"
              style="width: auto; display: inline-block;"
            >
              <option value="5">5</option>
              <option value="10">10</option>
              <option value="25">25</option>
              <option value="50">50</option>
              <option value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(1)" :disabled="paginaActual === 1">
              <font-awesome-icon icon="angle-double-left" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(paginaActual - 1)" :disabled="paginaActual === 1">
              <font-awesome-icon icon="angle-left" />
            </button>
            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === paginaActual ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="cambiarPagina(page)"
            >
              {{ page }}
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(paginaActual + 1)" :disabled="paginaActual === totalPaginas">
              <font-awesome-icon icon="angle-right" />
            </button>
            <button class="btn-municipal-secondary btn-sm" @click="cambiarPagina(totalPaginas)" :disabled="paginaActual === totalPaginas">
              <font-awesome-icon icon="angle-double-right" />
            </button>
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

    <!-- Modal de Ayuda/Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'dependenciasfrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Dependencias'"
      @close="showDocModal = false"
    />
  </div>
  <!-- /module-view-content -->

  <!-- Modal Crear -->
  <Modal
    :show="showModalCrear"
    title="Crear Nueva Dependencia"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="building" />
        <h6>Información de la Dependencia</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="hashtag" class="me-1" />
            ID Dependencia: <span class="required">*</span>
          </label>
          <input
            type="number"
            class="municipal-form-control"
            v-model.number="nuevaDependencia.id_dependencia"
            placeholder="Ej: 100"
            required
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="building" class="me-1" />
            Nombre: <span class="required">*</span>
          </label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="nuevaDependencia.dependencia"
            placeholder="Nombre de la dependencia"
            maxlength="100"
            required
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="sitemap" class="me-1" />
            Dependencia de Referencia:
          </label>
          <input
            type="number"
            class="municipal-form-control"
            v-model.number="nuevaDependencia.id_depref"
            placeholder="ID de dependencia padre (0 para ninguna)"
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="toggle-on" class="me-1" />
            Estado: <span class="required">*</span>
          </label>
          <select class="municipal-form-control" v-model="nuevaDependencia.estado" required>
            <option value="A">Activo</option>
            <option value="I">Inactivo</option>
          </select>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-success" @click="crearDependencia" :disabled="loading">
        <font-awesome-icon icon="save" />
        Crear
      </button>
    </template>
  </Modal>

  <!-- Modal Editar -->
  <Modal
    :show="showModalEditar"
    title="Editar Dependencia"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="building" />
        <h6>Información de la Dependencia</h6>
      </div>
      <div class="modal-grid-2">
        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="hashtag" class="me-1" />
            ID Dependencia:
          </label>
          <input
            type="number"
            class="municipal-form-control"
            :value="dependenciaSeleccionada?.id_dependencia"
            disabled
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="building" class="me-1" />
            Nombre: <span class="required">*</span>
          </label>
          <input
            type="text"
            class="municipal-form-control"
            v-model="dependenciaEditada.dependencia"
            placeholder="Nombre de la dependencia"
            maxlength="100"
            required
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="sitemap" class="me-1" />
            Dependencia de Referencia:
          </label>
          <input
            type="number"
            class="municipal-form-control"
            v-model.number="dependenciaEditada.id_depref"
            placeholder="ID de dependencia padre"
          />
        </div>

        <div class="form-group">
          <label class="municipal-form-label">
            <font-awesome-icon icon="toggle-on" class="me-1" />
            Estado: <span class="required">*</span>
          </label>
          <select class="municipal-form-control" v-model="dependenciaEditada.estado" required>
            <option value="A">Activo</option>
            <option value="I">Inactivo</option>
          </select>
        </div>
      </div>
    </div>

    <template #footer>
      <button class="btn-municipal-secondary" @click="cerrarModal">
        <font-awesome-icon icon="times" />
        Cancelar
      </button>
      <button class="btn-municipal-primary" @click="actualizarDependencia" :disabled="loading">
        <font-awesome-icon icon="save" />
        Guardar
      </button>
    </template>
  </Modal>

  <!-- Modal Ver -->
  <Modal
    :show="showModalVer"
    title="Detalles de la Dependencia"
    @close="cerrarModal"
    size="lg"
  >
    <div class="modal-section">
      <div class="section-header">
        <font-awesome-icon icon="info-circle" />
        <h6>Información General</h6>
      </div>
      <div class="details-grid">
        <div class="detail-item">
          <span class="label">
            <font-awesome-icon icon="hashtag" />
            ID:
          </span>
          <span class="value"><code>{{ dependenciaSeleccionada?.id_dependencia }}</code></span>
        </div>
        <div class="detail-item">
          <span class="label">
            <font-awesome-icon icon="building" />
            Dependencia:
          </span>
          <span class="value"><strong>{{ dependenciaSeleccionada?.dependencia?.trim() }}</strong></span>
        </div>
        <div class="detail-item">
          <span class="label">
            <font-awesome-icon icon="sitemap" />
            Dep. Referencia:
          </span>
          <span class="value">{{ dependenciaSeleccionada?.id_depref || 'N/A' }}</span>
        </div>
        <div class="detail-item">
          <span class="label">
            <font-awesome-icon icon="toggle-on" />
            Estado:
          </span>
          <span class="value">
            <span class="badge" :class="dependenciaSeleccionada?.estado === 'A' ? 'badge-success' : 'badge-danger'">
              {{ dependenciaSeleccionada?.estado === 'A' ? 'Activo' : 'Inactivo' }}
            </span>
          </span>
        </div>
        <div class="detail-item">
          <span class="label">
            <font-awesome-icon icon="calendar" />
            Fecha Mov:
          </span>
          <span class="value">{{ dependenciaSeleccionada?.fecha_mov || 'N/A' }}</span>
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
const dependencias = ref([])
const todasDependencias = ref([]) // Cache de todas las dependencias
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros
const showFilters = ref(false) // Inicia oculto
const filters = ref({
  id_dependencia: null,
  dependencia: '',
  estado: ''
})

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

// Modales
const showModalCrear = ref(false)
const showModalEditar = ref(false)
const showModalVer = ref(false)

// Dependencia seleccionada
const dependenciaSeleccionada = ref(null)
const nuevaDependencia = ref({
  id_dependencia: null,
  dependencia: '',
  id_depref: 0,
  estado: 'A'
})
const dependenciaEditada = ref({
  dependencia: '',
  id_depref: 0,
  estado: 'A'
})

// Funciones de filtrado y paginación
const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todasDependencias.value]

  // Filtrar por ID
  if (filters.value.id_dependencia) {
    filtered = filtered.filter(d => d.id_dependencia === filters.value.id_dependencia)
  }

  // Filtrar por nombre
  if (filters.value.dependencia) {
    const searchTerm = filters.value.dependencia.toLowerCase()
    filtered = filtered.filter(d =>
      d.dependencia?.toLowerCase().includes(searchTerm)
    )
  }

  // Filtrar por estado
  if (filters.value.estado) {
    filtered = filtered.filter(d => d.estado === filters.value.estado)
  }

  totalRegistros.value = filtered.length
  paginaActual.value = 1

  // Paginar
  const start = (paginaActual.value - 1) * registrosPorPagina.value
  const end = start + registrosPorPagina.value
  dependencias.value = filtered.slice(start, end)
}

const limpiarFiltros = () => {
  filters.value = {
    id_dependencia: null,
    dependencia: '',
    estado: ''
  }
  hasSearched.value = false
  selectedRow.value = null
  paginaActual.value = 1
  aplicarFiltrosYPaginacion()
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const cambiarPagina = (pagina) => {
  if (pagina < 1 || pagina > totalPaginas.value) return
  paginaActual.value = pagina
  selectedRow.value = null
  aplicarFiltrosYPaginacion()
}

const cambiarRegistrosPorPagina = () => {
  paginaActual.value = 1
  selectedRow.value = null
  aplicarFiltrosYPaginacion()
}

// Búsqueda principal
const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando dependencias...', 'Buscando en el catálogo')
  loading.value = true
  hasSearched.value = true
  selectedRow.value = null
  showFilters.value = false // Cerrar acordeón al actualizar

  try {
    const response = await execute(
      'SP_DEPENDENCIAS_LIST',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      todasDependencias.value = response.result
      paginaActual.value = 1
      aplicarFiltrosYPaginacion()

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      showToast('success', `${totalRegistros.value.toLocaleString()} dependencias encontradas`, `(${duration}s)`)
    } else {
      todasDependencias.value = []
      dependencias.value = []
      totalRegistros.value = 0
      showToast('info', 'No se encontraron dependencias')
    }
  } catch (error) {
    handleApiError(error)
    todasDependencias.value = []
    dependencias.value = []
    totalRegistros.value = 0
  } finally {
    loading.value = false
    hideLoading()
  }
}

// Modales
const abrirModalCrear = () => {
  nuevaDependencia.value = {
    id_dependencia: null,
    dependencia: '',
    id_depref: 0,
    estado: 'A'
  }
  showModalCrear.value = true
}

const verDependencia = (dep) => {
  dependenciaSeleccionada.value = dep
  showModalVer.value = true
}

const editarDependencia = (dep) => {
  dependenciaSeleccionada.value = dep
  dependenciaEditada.value = {
    dependencia: dep.dependencia?.trim(),
    id_depref: dep.id_depref,
    estado: dep.estado
  }
  showModalEditar.value = true
}

const crearDependencia = async () => {
  if (!nuevaDependencia.value.id_dependencia || !nuevaDependencia.value.dependencia) {
    showToast('error', 'Por favor complete todos los campos obligatorios')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Dependencia?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${nuevaDependencia.value.id_dependencia}</p>
        <p><strong>Nombre:</strong> ${nuevaDependencia.value.dependencia}</p>
        <p><strong>Estado:</strong> ${nuevaDependencia.value.estado === 'A' ? 'Activo' : 'Inactivo'}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando dependencia...', 'Guardando en la base de datos')

  try {
    const response = await execute(
      'SP_DEPENDENCIAS_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: nuevaDependencia.value.id_dependencia, tipo: 'integer' },
        { nombre: 'p_dependencia', valor: nuevaDependencia.value.dependencia, tipo: 'string' },
        { nombre: 'p_id_depref', valor: nuevaDependencia.value.id_depref || 0, tipo: 'integer' },
        { nombre: 'p_estado', valor: nuevaDependencia.value.estado, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Dependencia creada exitosamente')
      cerrarModal()
      await buscar()
    } else {
      const errorMsg = response?.result?.[0]?.message || 'Error desconocido al crear dependencia'
      showToast('error', errorMsg)
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const actualizarDependencia = async () => {
  if (!dependenciaEditada.value.dependencia) {
    showToast('error', 'Por favor complete todos los campos obligatorios')
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Dependencia?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${dependenciaSeleccionada.value.id_dependencia}</p>
        <p><strong>Nombre:</strong> ${dependenciaEditada.value.dependencia}</p>
        <p><strong>Estado:</strong> ${dependenciaEditada.value.estado === 'A' ? 'Activo' : 'Inactivo'}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando dependencia...', 'Guardando cambios')

  try {
    const response = await execute(
      'SP_DEPENDENCIAS_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: dependenciaSeleccionada.value.id_dependencia, tipo: 'integer' },
        { nombre: 'p_dependencia', valor: dependenciaEditada.value.dependencia, tipo: 'string' },
        { nombre: 'p_id_depref', valor: dependenciaEditada.value.id_depref, tipo: 'integer' },
        { nombre: 'p_estado', valor: dependenciaEditada.value.estado, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Dependencia actualizada exitosamente')
      cerrarModal()
      await buscar()
    } else {
      const errorMsg = response?.result?.[0]?.message || 'Error desconocido al actualizar dependencia'
      showToast('error', errorMsg)
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const confirmarEliminar = async (dep) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar Dependencia?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${dep.id_dependencia}</p>
        <p><strong>Nombre:</strong> ${dep.dependencia?.trim()}</p>
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

  showLoading('Eliminando dependencia...', 'Procesando solicitud')

  try {
    const response = await execute(
      'SP_DEPENDENCIAS_DELETE',
      'padron_licencias',
      [
        { nombre: 'p_id_dependencia', valor: dep.id_dependencia, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Dependencia eliminada exitosamente')
      await buscar()
    } else {
      const errorMsg = response?.result?.[0]?.message || 'Error desconocido al eliminar dependencia'
      showToast('error', errorMsg)
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const cerrarModal = () => {
  showModalCrear.value = false
  showModalEditar.value = false
  showModalVer.value = false
  dependenciaSeleccionada.value = null
}

// NO auto-load on mount
onMounted(() => {
  // Usuario debe presionar "Actualizar" manualmente
})
</script>
