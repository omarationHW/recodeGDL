<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="tasks" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Actividades</h1>
        <p>Padrón de Licencias - Gestión de Actividades Comerciales</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-success"
          @click="abrirModalNuevo"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nuevo
        </button>
        <button
          class="btn-municipal-primary"
          @click="buscar"
          :disabled="loading"
        >
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

        <!-- Filtros - Basado en Delphi: c_actividades_lic -->
        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Actividad:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filters.id_actividad"
                placeholder="ID"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">ID Giro:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filters.id_giro"
                placeholder="ID del giro"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Descripción:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.descripcion"
                placeholder="Buscar por descripción"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <div class="btn-group-actions">
                <button @click="buscar" class="btn-municipal-primary" :disabled="loading">
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
            Listado de Actividades
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
              <!-- Basado en Delphi: DBGridActividades con columnas de c_actividades_lic -->
              <thead class="municipal-table-header">
                <tr>
                  <th class="th-center th-w-10">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    ID
                  </th>
                  <th class="th-center th-w-10">
                    <font-awesome-icon icon="layer-group" class="me-1" />
                    Giro
                  </th>
                  <th class="th-w-45">
                    <font-awesome-icon icon="align-left" class="me-2" />
                    Descripción
                  </th>
                  <th class="th-center th-w-10">
                    <font-awesome-icon icon="toggle-on" class="me-1" />
                    Vigente
                  </th>
                  <th class="th-center th-w-15">
                    <font-awesome-icon icon="cogs" class="me-1" />
                    Acciones
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="actividades.length === 0 && !hasSearched">
                  <td colspan="5">
                    <div class="empty-state">
                      <div class="empty-state-icon">
                        <font-awesome-icon icon="tasks" size="3x" />
                      </div>
                      <h4>Catálogo de Actividades</h4>
                      <p>Utiliza el botón "Buscar" o "Actualizar" para consultar el catálogo completo de actividades comerciales</p>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="actividades.length === 0 && hasSearched">
                  <td colspan="5">
                    <div class="empty-state">
                      <div class="empty-state-icon">
                        <font-awesome-icon icon="inbox" size="3x" />
                      </div>
                      <h4>Sin resultados</h4>
                      <p>No se encontraron actividades con los criterios especificados</p>
                    </div>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="actividad in actividades"
                  :key="actividad.id_actividad"
                  @click="selectedRow = actividad"
                  :class="{ 'table-row-selected': selectedRow === actividad }"
                  class="row-hover"
                >
                  <td class="text-center">
                    <span class="badge badge-light-secondary">{{ actividad.id_actividad }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-light-info">{{ actividad.id_giro || '-' }}</span>
                  </td>
                  <td>
                    <div class="giro-name">
                      <font-awesome-icon icon="file-alt" class="giro-icon" />
                      <span class="giro-text">{{ actividad.descripcion }}</span>
                    </div>
                  </td>
                  <td class="text-center">
                    <span :class="actividad.vigente === 'V' ? 'badge badge-success' : 'badge badge-secondary'">
                      {{ actividad.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <div class="btn-group-actions">
                      <button @click.stop="verDetalle(actividad)" class="btn-table btn-table-info" title="Ver detalle">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button @click.stop="editarActividad(actividad)" class="btn-table btn-table-primary" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button
                        v-if="actividad.vigente === 'V'"
                        @click.stop="confirmarEliminar(actividad)"
                        class="btn-table btn-table-danger"
                        title="Cancelar"
                      >
                        <font-awesome-icon icon="ban" />
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
              de {{ totalRegistros }} registros
            </div>

            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model="registrosPorPagina" @change="cambiarTamanioPagina">
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
        :componentName="'CatalogoActividadesFrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Catálogo de Actividades'"
        @close="showDocModal = false"
      />
    </div>

    <!-- Modal para detalle/edición/creación -->
    <Modal
      :show="mostrarModal"
      size="lg"
      @close="cerrarModal"
    >
      <template #header>
        <h5 class="modal-title">
          <font-awesome-icon
            :icon="modoEdicion === 'crear' ? 'plus-circle' : modoEdicion === 'editar' ? 'edit' : 'eye'"
            class="me-2"
            :class="{
              'text-success': modoEdicion === 'crear',
              'text-primary': modoEdicion === 'editar',
              'text-info': modoEdicion === 'ver'
            }"
          />
          {{ modalTitle }}
        </h5>
      </template>
      <!-- Basado en Delphi: PanelCampos con EditActividad, EditObservaciones, DBComboBoxGiro, ComboBoxEstatus -->
      <template #default>
        <div class="giro-modal-content">
          <!-- Sección: Datos de la Actividad -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="file-alt" class="section-icon" />
              <h6 class="section-title">Datos de la Actividad</h6>
            </div>

            <div class="modal-grid-2">
              <div class="form-group-modal" v-if="modoEdicion !== 'crear'">
                <label class="form-label-modal">
                  <font-awesome-icon icon="hashtag" class="label-icon" />
                  ID Actividad
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="actividadForm.id_actividad"
                  readonly
                  disabled
                />
              </div>

              <div class="form-group-modal">
                <label class="form-label-modal">
                  <font-awesome-icon icon="layer-group" class="label-icon" />
                  Giro
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="actividadForm.id_giro"
                  :readonly="modoEdicion === 'ver'"
                  :disabled="modoEdicion === 'ver'"
                  placeholder="ID del giro"
                />
                <div class="form-hint">Código del giro asociado (opcional)</div>
              </div>

              <div class="form-group-modal" style="grid-column: 1 / -1;">
                <label class="form-label-modal">
                  <font-awesome-icon icon="align-left" class="label-icon" />
                  Actividad (Descripción) <span class="text-danger">*</span>
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="actividadForm.descripcion"
                  :readonly="modoEdicion === 'ver'"
                  :disabled="modoEdicion === 'ver'"
                  placeholder="Descripción de la actividad"
                  maxlength="250"
                />
              </div>

              <div class="form-group-modal" style="grid-column: 1 / -1;">
                <label class="form-label-modal">
                  <font-awesome-icon icon="comment-alt" class="label-icon" />
                  Observaciones
                </label>
                <input
                  type="text"
                  class="form-input-modal"
                  v-model="actividadForm.observaciones"
                  :readonly="modoEdicion === 'ver'"
                  :disabled="modoEdicion === 'ver'"
                  placeholder="Observaciones adicionales"
                  maxlength="100"
                />
              </div>

              <div class="form-group-modal">
                <label class="form-label-modal">
                  <font-awesome-icon icon="toggle-on" class="label-icon" />
                  Estatus <span class="text-danger">*</span>
                </label>
                <select
                  class="form-input-modal"
                  v-model="actividadForm.vigente"
                  :disabled="modoEdicion === 'ver'"
                >
                  <option value="V">Vigente</option>
                  <option value="C">Cancelado</option>
                </select>
              </div>
            </div>
          </div>

          <!-- Sección: Información del Sistema (solo en modo ver) -->
          <div v-if="modoEdicion === 'ver'" class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="info-circle" class="section-icon" />
              <h6 class="section-title">Información del Sistema</h6>
            </div>

            <div class="info-grid">
              <div class="info-item">
                <div class="info-label">
                  <font-awesome-icon icon="toggle-on" class="me-1" />
                  Estado
                </div>
                <div class="info-value">
                  <span :class="actividadForm.vigente === 'V' ? 'badge badge-success' : 'badge badge-secondary'">
                    {{ actividadForm.vigente === 'V' ? 'Vigente' : 'Cancelado' }}
                  </span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-label">
                  <font-awesome-icon icon="database" class="me-1" />
                  Tabla
                </div>
                <div class="info-value">
                  <span class="badge badge-light-info">
                    publico.c_actividades_lic
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </template>
      <template #footer>
        <button
          @click="cerrarModal"
          class="btn-municipal-secondary"
          :disabled="loading"
        >
          <font-awesome-icon icon="times" />
          {{ modoEdicion === 'ver' ? 'Cerrar' : 'Cancelar' }}
        </button>
        <button
          v-if="modoEdicion === 'crear'"
          @click="guardarActividad"
          class="btn-municipal-success"
          :disabled="loading"
        >
          <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
          Crear Actividad
        </button>
        <button
          v-if="modoEdicion === 'editar'"
          @click="guardarActividad"
          class="btn-municipal-primary"
          :disabled="loading"
        >
          <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
          Guardar Cambios
        </button>
      </template>
    </Modal>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

// Composables
const { execute } = useApi()
const { handleApiError, showToast, hideToast, getToastIcon, toast } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado reactivo
const actividades = ref([])
const todasLasActividades = ref([]) // Cache de todos los datos
const loading = ref(false)
const showFilters = ref(false)
const mostrarModal = ref(false)
const modoEdicion = ref('ver') // 'ver', 'editar', 'crear'
const totalRegistros = ref(0)
const paginaActual = ref(1)
const registrosPorPagina = ref(10)
const selectedRow = ref(null)
const hasSearched = ref(false)

// Filtros - Basado en Delphi: c_actividades_lic
const filters = ref({
  id_actividad: null,
  id_giro: null,
  descripcion: ''
})

// Formulario de actividad - Basado en Delphi: c_actividades_lic
const actividadForm = ref({
  id_actividad: null,
  id_giro: null,
  descripcion: '',
  observaciones: '',
  vigente: 'V'
})

// Computed
const totalPaginas = computed(() => {
  return Math.ceil(totalRegistros.value / registrosPorPagina.value)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, paginaActual.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPaginas.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

const modalTitle = computed(() => {
  if (modoEdicion.value === 'crear') return 'Nueva Actividad'
  if (modoEdicion.value === 'editar') return 'Editar Actividad'
  return 'Detalle de Actividad'
})

// Métodos
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

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todasLasActividades.value]

  // Aplicar filtros - Basado en Delphi: c_actividades_lic
  if (filters.value.id_actividad) {
    filtered = filtered.filter(a => a.id_actividad === filters.value.id_actividad)
  }
  if (filters.value.id_giro) {
    filtered = filtered.filter(a => a.id_giro === filters.value.id_giro)
  }
  if (filters.value.descripcion) {
    const desc = filters.value.descripcion.toLowerCase()
    filtered = filtered.filter(a => a.descripcion?.toLowerCase().includes(desc))
  }

  totalRegistros.value = filtered.length

  // Aplicar paginación
  const start = (paginaActual.value - 1) * registrosPorPagina.value
  const end = start + registrosPorPagina.value
  actividades.value = filtered.slice(start, end)
}

const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando actividades...', 'Buscando en el catálogo')
  hasSearched.value = true
  selectedRow.value = null
  loading.value = true

  try {
    // El SP no recibe parámetros, siempre trae todo
    const response = await execute(
      'sp_catalogo_actividades_list',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      // Guardar todos los datos en cache
      todasLasActividades.value = response.result

      // Resetear a página 1
      paginaActual.value = 1

      // Aplicar filtros y paginación
      aplicarFiltrosYPaginacion()

      showToast('success', `${totalRegistros.value.toLocaleString()} actividades encontradas`, timeMessage)
    } else {
      todasLasActividades.value = []
      actividades.value = []
      totalRegistros.value = 0
      showToast('info', 'No se encontraron actividades', timeMessage)
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar actividades')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  filters.value = {
    id_actividad: null,
    id_giro: null,
    descripcion: ''
  }
  actividades.value = []
  todasLasActividades.value = []
  hasSearched.value = false
  paginaActual.value = 1
  selectedRow.value = null
  totalRegistros.value = 0
}

const cambiarPagina = (nuevaPagina) => {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
    selectedRow.value = null
    // Solo aplicar paginación sobre los datos ya cargados
    aplicarFiltrosYPaginacion()
  }
}

const cambiarTamanioPagina = () => {
  paginaActual.value = 1
  selectedRow.value = null
  // Solo aplicar paginación sobre los datos ya cargados
  aplicarFiltrosYPaginacion()
}

const verDetalle = async (actividad) => {
  // Basado en Delphi: c_actividades_lic
  actividadForm.value = {
    id_actividad: actividad.id_actividad,
    id_giro: actividad.id_giro,
    descripcion: actividad.descripcion?.trim() || '',
    observaciones: actividad.observaciones?.trim() || '',
    vigente: actividad.vigente || 'V'
  }
  modoEdicion.value = 'ver'
  mostrarModal.value = true
}

const editarActividad = async (actividad) => {
  // Basado en Delphi: BtnModificarClick
  actividadForm.value = {
    id_actividad: actividad.id_actividad,
    id_giro: actividad.id_giro,
    descripcion: actividad.descripcion?.trim() || '',
    observaciones: actividad.observaciones?.trim() || '',
    vigente: actividad.vigente || 'V'
  }
  modoEdicion.value = 'editar'
  mostrarModal.value = true
}

const abrirModalNuevo = () => {
  // Basado en Delphi: BtnAgregarClick
  actividadForm.value = {
    id_actividad: null,
    id_giro: null,
    descripcion: '',
    observaciones: '',
    vigente: 'V'
  }
  modoEdicion.value = 'crear'
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
  actividadForm.value = {
    id_actividad: null,
    id_giro: null,
    descripcion: '',
    observaciones: '',
    vigente: 'V'
  }
}

const guardarActividad = async () => {
  if (modoEdicion.value === 'crear') {
    await crearActividad()
  } else if (modoEdicion.value === 'editar') {
    await actualizarActividad()
  }
}

const crearActividad = async () => {
  // Validar campos requeridos - Basado en Delphi: RevisarCampos
  if (!actividadForm.value.descripcion?.trim()) {
    showToast('warning', 'Favor de llenar la actividad')
    return
  }
  if (!actividadForm.value.vigente) {
    showToast('warning', 'Favor de seleccionar un estatus')
    return
  }

  // Confirmar antes de crear
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Nueva Actividad?',
    html: `
      <div class="swal-selection-content">
        <p><strong>Descripción:</strong> ${actividadForm.value.descripcion}</p>
        <p><strong>Giro:</strong> ${actividadForm.value.id_giro || 'Sin asignar'}</p>
        <p><strong>Estatus:</strong> ${actividadForm.value.vigente === 'V' ? 'Vigente' : 'Cancelado'}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando actividad...', 'Guardando información')

  try {
    // Basado en Delphi: BtnAceptarClick en modo Insert
    const response = await execute(
      'sp_catalogo_actividades_create',
      'padron_licencias',
      [
        { nombre: 'p_id_giro', valor: actividadForm.value.id_giro, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: actividadForm.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_observaciones', valor: actividadForm.value.observaciones || '', tipo: 'string' },
        { nombre: 'p_vigente', valor: actividadForm.value.vigente, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      const nueva = response.result[0]
      showToast('success', `Actividad "${actividadForm.value.descripcion}" creada con ID #${nueva.id_actividad}`)
      cerrarModal()
      buscar() // Recargar lista
    } else {
      showToast('error', 'Error al crear la actividad')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al crear actividad')
  }
}

const actualizarActividad = async () => {
  // Validar campos requeridos
  if (!actividadForm.value.descripcion?.trim()) {
    showToast('warning', 'La descripción es requerida')
    return
  }

  // Confirmar antes de actualizar
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Guardar Cambios?',
    html: `
      <div class="swal-selection-content">
        <p><strong>ID:</strong> ${actividadForm.value.id_actividad}</p>
        <p><strong>Descripción:</strong> ${actividadForm.value.descripcion}</p>
        <p><strong>Estatus:</strong> ${actividadForm.value.vigente === 'V' ? 'Vigente' : 'Cancelado'}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando actividad...', 'Guardando cambios')

  try {
    // Basado en Delphi: BtnAceptarClick en modo Edit
    const response = await execute(
      'sp_catalogo_actividades_update',
      'padron_licencias',
      [
        { nombre: 'p_id_actividad', valor: actividadForm.value.id_actividad, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: actividadForm.value.id_giro, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: actividadForm.value.descripcion.trim(), tipo: 'string' },
        { nombre: 'p_observaciones', valor: actividadForm.value.observaciones || '', tipo: 'string' },
        { nombre: 'p_vigente', valor: actividadForm.value.vigente, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      showToast('success', 'Actividad actualizada exitosamente')
      cerrarModal()
      buscar() // Recargar lista
    } else {
      showToast('error', 'Error al actualizar la actividad')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al actualizar actividad')
  }
}

const confirmarEliminar = async (actividad) => {
  // En Delphi original el botón Borrar está deshabilitado
  // Implementamos como cancelación (cambiar vigente a 'C')
  const result = await Swal.fire({
    title: '¿Cancelar Actividad?',
    html: `
      <div class="text-start">
        <p><strong>ID:</strong> ${actividad.id_actividad}</p>
        <p><strong>Descripción:</strong> ${actividad.descripcion}</p>
        <p class="text-warning mt-2">Nota: La actividad será marcada como Cancelada</p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, cancelar',
    cancelButtonText: 'No'
  })

  if (result.isConfirmed) {
    await cancelarActividad(actividad)
  }
}

const cancelarActividad = async (actividad) => {
  showLoading('Cancelando actividad...', 'Procesando')

  try {
    // Usar el SP update para cambiar vigente a 'C' (Cancelado)
    const response = await execute(
      'sp_catalogo_actividades_update',
      'padron_licencias',
      [
        { nombre: 'p_id_actividad', valor: actividad.id_actividad, tipo: 'integer' },
        { nombre: 'p_id_giro', valor: actividad.id_giro, tipo: 'integer' },
        { nombre: 'p_descripcion', valor: actividad.descripcion, tipo: 'string' },
        { nombre: 'p_observaciones', valor: actividad.observaciones || '', tipo: 'string' },
        { nombre: 'p_vigente', valor: 'C', tipo: 'string' },
        { nombre: 'p_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result.length > 0) {
      showToast('success', 'Actividad cancelada exitosamente')
      buscar() // Recargar lista
    } else {
      showToast('error', 'Error al cancelar la actividad')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al cancelar actividad')
  }
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente - el usuario debe presionar "Buscar" o "Actualizar"
})
</script>
