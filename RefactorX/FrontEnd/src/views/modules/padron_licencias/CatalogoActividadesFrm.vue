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
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
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
              <label class="municipal-form-label">Genérico:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filters.generico"
                placeholder="Código genérico"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Uso:</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filters.uso"
                placeholder="Código de uso"
                @keyup.enter="buscar"
              />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Concepto:</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.concepto"
                placeholder="Buscar por concepto"
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
              <thead class="municipal-table-header">
                <tr>
                  <th class="th-center th-w-10">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    Genérico
                  </th>
                  <th class="th-center th-w-10">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    Uso
                  </th>
                  <th class="th-center th-w-10">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    Actividad
                  </th>
                  <th class="th-w-55">
                    <font-awesome-icon icon="align-left" class="me-2" />
                    Concepto
                  </th>
                  <th class="th-center th-w-15">
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
                <tr v-else-if="actividades.length === 0">
                  <td colspan="5" class="empty-state">
                    <div class="empty-state-content">
                      <font-awesome-icon icon="inbox" class="empty-state-icon" />
                      <p class="empty-state-text">No se encontraron actividades con los filtros seleccionados</p>
                      <p class="empty-state-hint">Intenta ajustar los filtros de búsqueda o presiona "Actualizar"</p>
                    </div>
                  </td>
                </tr>
                <tr v-else v-for="actividad in actividades" :key="`${actividad.generico}-${actividad.uso}-${actividad.actividad}`" class="clickable-row">
                  <td class="text-center">
                    <span class="badge badge-light-secondary">{{ actividad.generico }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-light-info">{{ actividad.uso }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge badge-light-primary">{{ actividad.actividad }}</span>
                  </td>
                  <td>
                    <div class="giro-name">
                      <font-awesome-icon icon="file-alt" class="giro-icon" />
                      <span class="giro-text">{{ actividad.concepto }}</span>
                    </div>
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
                        @click.stop="confirmarEliminar(actividad)"
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
      <template #default>
        <div class="giro-modal-content">
          <!-- Sección: Códigos de Clasificación -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="hashtag" class="section-icon" />
              <h6 class="section-title">Códigos de Clasificación</h6>
            </div>

            <div class="modal-grid-3">
              <div class="form-group-modal">
                <label class="form-label-modal">
                  <font-awesome-icon icon="layer-group" class="label-icon" />
                  Genérico <span class="text-danger">*</span>
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="actividadForm.generico"
                  :readonly="modoEdicion !== 'crear'"
                  :disabled="modoEdicion !== 'crear'"
                  placeholder="Código genérico"
                />
                <div class="form-hint" v-if="modoEdicion === 'crear'">Código de categoría genérica</div>
              </div>

              <div class="form-group-modal">
                <label class="form-label-modal">
                  <font-awesome-icon icon="th-large" class="label-icon" />
                  Uso <span class="text-danger">*</span>
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="actividadForm.uso"
                  :readonly="modoEdicion !== 'crear'"
                  :disabled="modoEdicion !== 'crear'"
                  placeholder="Código de uso"
                />
                <div class="form-hint" v-if="modoEdicion === 'crear'">Código de tipo de uso</div>
              </div>

              <div class="form-group-modal">
                <label class="form-label-modal">
                  <font-awesome-icon icon="tag" class="label-icon" />
                  Actividad <span class="text-danger">*</span>
                </label>
                <input
                  type="number"
                  class="form-input-modal"
                  v-model.number="actividadForm.actividad"
                  :readonly="modoEdicion !== 'crear'"
                  :disabled="modoEdicion !== 'crear'"
                  placeholder="Código de actividad"
                />
                <div class="form-hint" v-if="modoEdicion === 'crear'">Código específico de actividad</div>
              </div>
            </div>
          </div>

          <!-- Sección: Descripción -->
          <div class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="file-alt" class="section-icon" />
              <h6 class="section-title">Descripción de la Actividad</h6>
            </div>

            <div class="form-group-modal">
              <label class="form-label-modal">
                <font-awesome-icon icon="align-left" class="label-icon" />
                Concepto <span class="text-danger">*</span>
              </label>
              <textarea
                class="form-input-modal"
                v-model="actividadForm.concepto"
                :readonly="modoEdicion === 'ver'"
                :disabled="modoEdicion === 'ver'"
                placeholder="Descripción completa del concepto de la actividad comercial o industrial"
                rows="5"
                maxlength="120"
              ></textarea>
              <div class="form-hint">
                <span>Máximo 120 caracteres</span>
                <span class="float-end">
                  <strong>{{ actividadForm.concepto.length }}</strong>/120
                </span>
              </div>
            </div>
          </div>

          <!-- Sección: Información Adicional (solo en modo ver) -->
          <div v-if="modoEdicion === 'ver'" class="modal-section">
            <div class="section-header">
              <font-awesome-icon icon="info-circle" class="section-icon" />
              <h6 class="section-title">Información del Sistema</h6>
            </div>

            <div class="info-grid">
              <div class="info-item">
                <div class="info-label">
                  <font-awesome-icon icon="barcode" class="me-1" />
                  Código Completo
                </div>
                <div class="info-value">
                  <span class="badge badge-light-primary">
                    {{ actividadForm.generico }}.{{ actividadForm.uso }}.{{ actividadForm.actividad }}
                  </span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-label">
                  <font-awesome-icon icon="calendar-alt" class="me-1" />
                  Estado
                </div>
                <div class="info-value">
                  <span class="badge badge-success">
                    ✅ Activo en el Sistema
                  </span>
                </div>
              </div>

              <div class="info-item">
                <div class="info-label">
                  <font-awesome-icon icon="database" class="me-1" />
                  Esquema
                </div>
                <div class="info-value">
                  <span class="badge badge-light-info">
                    comun.c_actividades
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

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <div class="toast-content">
        <span class="toast-message">{{ toast.message }}</span>
        <span v-if="toast.duration" class="toast-duration">
          <font-awesome-icon icon="clock" />
          {{ toast.duration }}
        </span>
      </div>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
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

// Filtros
const filters = ref({
  generico: null,
  uso: null,
  concepto: ''
})

// Formulario de actividad
const actividadForm = ref({
  generico: null,
  uso: null,
  actividad: null,
  concepto: ''
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
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const openDocumentation = () => {
  window.open('/docs/padron_licencias/CatalogoActividades.md', '_blank')
}

const aplicarFiltrosYPaginacion = () => {
  let filtered = [...todasLasActividades.value]

  // Aplicar filtros
  if (filters.value.generico) {
    filtered = filtered.filter(a => a.generico === filters.value.generico)
  }
  if (filters.value.uso) {
    filtered = filtered.filter(a => a.uso === filters.value.uso)
  }
  if (filters.value.concepto) {
    const concepto = filters.value.concepto.toLowerCase()
    filtered = filtered.filter(a => a.concepto.toLowerCase().includes(concepto))
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
    generico: null,
    uso: null,
    concepto: ''
  }
  paginaActual.value = 1

  // Si ya hay datos en cache, solo aplicar filtros y paginación
  if (todasLasActividades.value.length > 0) {
    aplicarFiltrosYPaginacion()
  }
}

const cambiarPagina = (nuevaPagina) => {
  if (nuevaPagina >= 1 && nuevaPagina <= totalPaginas.value) {
    paginaActual.value = nuevaPagina
    // Solo aplicar paginación sobre los datos ya cargados
    aplicarFiltrosYPaginacion()
  }
}

const cambiarTamanioPagina = () => {
  paginaActual.value = 1
  // Solo aplicar paginación sobre los datos ya cargados
  aplicarFiltrosYPaginacion()
}

const verDetalle = async (actividad) => {
  actividadForm.value = {
    generico: actividad.generico,
    uso: actividad.uso,
    actividad: actividad.actividad,
    concepto: actividad.concepto.trim()
  }
  modoEdicion.value = 'ver'
  mostrarModal.value = true
}

const editarActividad = async (actividad) => {
  actividadForm.value = {
    generico: actividad.generico,
    uso: actividad.uso,
    actividad: actividad.actividad,
    concepto: actividad.concepto.trim()
  }
  modoEdicion.value = 'editar'
  mostrarModal.value = true
}

const abrirModalNuevo = () => {
  actividadForm.value = {
    generico: null,
    uso: null,
    actividad: null,
    concepto: ''
  }
  modoEdicion.value = 'crear'
  mostrarModal.value = true
}

const cerrarModal = () => {
  mostrarModal.value = false
  actividadForm.value = {
    generico: null,
    uso: null,
    actividad: null,
    concepto: ''
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
  // Confirmar antes de crear
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Nueva Actividad?',
    html: `
      <div class="swal-selection-content">
        <p><strong>Genérico:</strong> ${actividadForm.value.generico}</p>
        <p><strong>Uso:</strong> ${actividadForm.value.uso}</p>
        <p><strong>Actividad:</strong> ${actividadForm.value.actividad}</p>
        <p><strong>Concepto:</strong> ${actividadForm.value.concepto}</p>
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
  // NO modificar loading.value para que la tabla NO se oculte

  try {
    const response = await execute(
      'sp_catalogo_actividades_create',
      'padron_licencias',
      [
        { nombre: 'p_generico', valor: actividadForm.value.generico, tipo: 'integer' },
        { nombre: 'p_uso', valor: actividadForm.value.uso, tipo: 'integer' },
        { nombre: 'p_actividad', valor: actividadForm.value.actividad, tipo: 'integer' },
        { nombre: 'p_concepto', valor: actividadForm.value.concepto, tipo: 'character varying' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Actividad creada exitosamente')
      cerrarModal()
      // NO refrescar la consulta automáticamente
    } else {
      const message = response?.result?.[0]?.message || 'Error desconocido'
      showToast('error', message)
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al crear actividad')
  }
}

const actualizarActividad = async () => {
  // Confirmar antes de actualizar
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Guardar Cambios?',
    html: `
      <div class="swal-selection-content">
        <p><strong>Código:</strong> ${actividadForm.value.generico}.${actividadForm.value.uso}.${actividadForm.value.actividad}</p>
        <p><strong>Concepto Nuevo:</strong> ${actividadForm.value.concepto}</p>
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
  // NO modificar loading.value para que la tabla NO se oculte

  try {
    const response = await execute(
      'sp_catalogo_actividades_update',
      'padron_licencias',
      [
        { nombre: 'p_generico', valor: actividadForm.value.generico, tipo: 'integer' },
        { nombre: 'p_uso', valor: actividadForm.value.uso, tipo: 'integer' },
        { nombre: 'p_actividad', valor: actividadForm.value.actividad, tipo: 'integer' },
        { nombre: 'p_concepto', valor: actividadForm.value.concepto, tipo: 'character varying' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Actividad actualizada exitosamente')
      cerrarModal()
      // NO refrescar la consulta automáticamente
    } else {
      const message = response?.result?.[0]?.message || 'Error desconocido'
      showToast('error', message)
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al actualizar actividad')
  }
}

const confirmarEliminar = async (actividad) => {
  const result = await Swal.fire({
    title: '¿Confirmar eliminación?',
    html: `
      <div class="text-start">
        <p><strong>Genérico:</strong> ${actividad.generico}</p>
        <p><strong>Uso:</strong> ${actividad.uso}</p>
        <p><strong>Actividad:</strong> ${actividad.actividad}</p>
        <p><strong>Concepto:</strong> ${actividad.concepto}</p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await eliminarActividad(actividad)
  }
}

const eliminarActividad = async (actividad) => {
  showLoading('Eliminando actividad...', 'Procesando')
  // NO modificar loading.value para que la tabla NO se oculte

  try {
    const response = await execute(
      'sp_catalogo_actividades_delete',
      'padron_licencias',
      [
        { nombre: 'p_generico', valor: actividad.generico, tipo: 'integer' },
        { nombre: 'p_uso', valor: actividad.uso, tipo: 'integer' },
        { nombre: 'p_actividad', valor: actividad.actividad, tipo: 'integer' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Actividad eliminada exitosamente')
      // NO refrescar la consulta automáticamente
    } else {
      const message = response?.result?.[0]?.message || 'Error desconocido'
      showToast('error', message)
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al eliminar actividad')
  }
}

// Lifecycle
onMounted(() => {
  // No cargar datos automáticamente - el usuario debe presionar "Buscar" o "Actualizar"
})
</script>
