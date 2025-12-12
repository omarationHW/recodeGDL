<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="comment-alt" />
      </div>
      <div class="module-view-info">
        <h1>Catálogo de Observaciones</h1>
        <p>Padrón de Licencias - Gestión de observaciones de trámites y licencias</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="abrirModalCrear">
          <font-awesome-icon icon="plus" />
          Nuevo
        </button>
        <button class="btn-municipal-primary" @click="buscar">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-help" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Acordeón de Filtros -->
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
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" />
                ID Observación:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.id_observacion"
                placeholder="Buscar por ID"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" />
                Número Trámite:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.num_tramite"
                placeholder="Buscar por trámite"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" />
                Tipo:
              </label>
              <select class="municipal-form-control" v-model="filtros.tipo">
                <option value="">Todos</option>
                <option value="TRAMITE">Trámite</option>
                <option value="LICENCIA">Licencia</option>
                <option value="GENERAL">General</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="search" />
                Observación:
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.observacion"
                placeholder="Buscar en texto"
              >
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="aplicarFiltrosYPaginacion">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros">
              <font-awesome-icon icon="times" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de observaciones -->
      <div v-if="observaciones.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Lista de Observaciones
          </h5>
          <span class="badge-purple">{{ totalRegistros.toLocaleString() }} registros</span>
        </div>
        <div class="municipal-card-body">
          <!-- Selector de items por página -->
          <div class="d-flex justify-content-between align-items-center mb-3">
            <div class="page-size-selector">
              <label>
                Mostrar
                <select v-model.number="itemsPerPage" @change="aplicarFiltrosYPaginacion" class="form-select-sm">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
                registros
              </label>
            </div>
          </div>

          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 8%; text-align: center;">ID</th>
                  <th style="width: 12%; text-align: center;">Trámite</th>
                  <th style="width: 35%;">Observación</th>
                  <th style="width: 12%; text-align: center;">Tipo</th>
                  <th style="width: 12%; text-align: center;">Usuario</th>
                  <th style="width: 13%; text-align: center;">Fecha</th>
                  <th style="width: 8%; text-align: center;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="obs in observaciones" :key="obs.id_observacion" class="clickable-row">
                  <td style="text-align: center;">
                    <code class="text-primary"><strong>{{ obs.id_observacion }}</strong></code>
                  </td>
                  <td style="text-align: center;">
                    <span class="badge-purple">{{ obs.num_tramite }}</span>
                  </td>
                  <td>
                    <div class="observacion-text">
                      {{ obs.observacion?.substring(0, 100) }}{{ obs.observacion?.length > 100 ? '...' : '' }}
                    </div>
                  </td>
                  <td style="text-align: center;">
                    <span class="badge" :class="getTipoBadge(obs.tipo)">
                      {{ obs.tipo }}
                    </span>
                  </td>
                  <td style="text-align: center;">
                    <span class="badge-secondary">{{ obs.usuario || 'N/A' }}</span>
                  </td>
                  <td style="text-align: center;">
                    <small class="text-muted">
                      {{ formatDate(obs.fecha_captura) }}
                    </small>
                  </td>
                  <td style="text-align: center;">
                    <div class="btn-group-actions">
                      <button class="btn-action btn-action-view" @click="verObservacion(obs)" title="Ver">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button class="btn-action btn-action-edit" @click="editarObservacion(obs)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-action btn-action-delete" @click="confirmarEliminar(obs)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ ((paginaActual - 1) * itemsPerPage) + 1 }} a {{ Math.min(paginaActual * itemsPerPage, totalRegistros) }} de {{ totalRegistros.toLocaleString() }} registros
            </div>
            <nav class="pagination-nav">
              <button
                @click="cambiarPagina(1)"
                :disabled="paginaActual === 1"
                class="pagination-button"
              >
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button
                @click="cambiarPagina(paginaActual - 1)"
                :disabled="paginaActual === 1"
                class="pagination-button"
              >
                <font-awesome-icon icon="angle-left" />
              </button>

              <button
                v-for="pagina in visiblePages"
                :key="pagina"
                @click="cambiarPagina(pagina)"
                :class="['pagination-button', { 'active': pagina === paginaActual }]"
              >
                {{ pagina }}
              </button>

              <button
                @click="cambiarPagina(paginaActual + 1)"
                :disabled="paginaActual === totalPaginas"
                class="pagination-button"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
              <button
                @click="cambiarPagina(totalPaginas)"
                :disabled="paginaActual === totalPaginas"
                class="pagination-button"
              >
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </nav>
          </div>
        </div>
      </div>

      <!-- Estado vacío -->
      <div v-if="observaciones.length === 0 && !loading" class="municipal-card">
        <div class="municipal-card-body">
          <div class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h5>No hay observaciones registradas</h5>
            <p>Presiona "Actualizar" para cargar las observaciones o "Nuevo" para crear una</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear -->
    <Modal :show="mostrarModalCrear" title="Nueva Observación" size="lg" @close="cerrarModal">
      <template #default>
        <form @submit.prevent="crearObservacion">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" />
                Número de Trámite: <span class="text-danger">*</span>
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="nuevaObservacion.num_tramite"
                placeholder="Ingrese número de trámite"
                required
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="tag" />
                Tipo: <span class="text-danger">*</span>
              </label>
              <select class="municipal-form-control" v-model="nuevaObservacion.tipo" required>
                <option value="">Seleccionar...</option>
                <option value="TRAMITE">Trámite</option>
                <option value="LICENCIA">Licencia</option>
                <option value="GENERAL">General</option>
              </select>
            </div>
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="comment" />
              Observación: <span class="text-danger">*</span>
            </label>
            <textarea
              class="municipal-form-control"
              v-model="nuevaObservacion.observacion"
              placeholder="Ingrese la observación"
              rows="5"
              required
              maxlength="1000"
            ></textarea>
            <small class="form-text">{{ nuevaObservacion.observacion.length }}/1000 caracteres</small>
          </div>
        </form>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="crearObservacion">
          <font-awesome-icon icon="save" />
          Guardar
        </button>
      </template>
    </Modal>

    <!-- Modal Editar -->
    <Modal :show="mostrarModalEditar" title="Editar Observación" size="lg" @close="cerrarModal">
      <template #default>
        <form @submit.prevent="actualizarObservacion">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Observación:</label>
              <input type="text" class="municipal-form-control" :value="observacionSeleccionada?.id_observacion" disabled>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" />
                Número de Trámite:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                :value="observacionSeleccionada?.num_tramite"
                disabled
              >
            </div>
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="tag" />
              Tipo: <span class="text-danger">*</span>
            </label>
            <select class="municipal-form-control" v-model="observacionSeleccionada.tipo" required>
              <option value="TRAMITE">Trámite</option>
              <option value="LICENCIA">Licencia</option>
              <option value="GENERAL">General</option>
            </select>
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="comment" />
              Observación: <span class="text-danger">*</span>
            </label>
            <textarea
              class="municipal-form-control"
              v-model="observacionSeleccionada.observacion"
              placeholder="Ingrese la observación"
              rows="5"
              required
              maxlength="1000"
            ></textarea>
            <small class="form-text">{{ observacionSeleccionada.observacion?.length || 0 }}/1000 caracteres</small>
          </div>
        </form>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="actualizarObservacion">
          <font-awesome-icon icon="save" />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <!-- Modal Ver -->
    <Modal :show="mostrarModalVer" title="Detalle de Observación" size="lg" @close="cerrarModal">
      <template #default>
        <div class="details-grid">
          <div class="detail-item">
            <label class="detail-label">ID Observación:</label>
            <div class="detail-value">{{ observacionSeleccionada?.id_observacion }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Número de Trámite:</label>
            <div class="detail-value">{{ observacionSeleccionada?.num_tramite }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Tipo:</label>
            <div class="detail-value">
              <span class="badge" :class="getTipoBadge(observacionSeleccionada?.tipo)">
                {{ observacionSeleccionada?.tipo }}
              </span>
            </div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Usuario:</label>
            <div class="detail-value">{{ observacionSeleccionada?.usuario || 'N/A' }}</div>
          </div>
          <div class="detail-item full-width">
            <label class="detail-label">Observación:</label>
            <div class="detail-value observacion-text">{{ observacionSeleccionada?.observacion }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Fecha de Captura:</label>
            <div class="detail-value">{{ formatDate(observacionSeleccionada?.fecha_captura) }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Última Modificación:</label>
            <div class="detail-value">{{ formatDate(observacionSeleccionada?.fecha_modificacion) || 'Sin modificar' }}</div>
          </div>
        </div>
      </template>
      <template #footer>
        <button class="btn-municipal-primary" @click="cerrarModal">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'observacionfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const loading = ref(false)
const showFilters = ref(false)
const todasObservaciones = ref([])
const observaciones = ref([])
const totalRegistros = ref(0)
const paginaActual = ref(1)
const itemsPerPage = ref(10)

const filtros = ref({
  id_observacion: null,
  num_tramite: null,
  tipo: '',
  observacion: ''
})

const mostrarModalCrear = ref(false)
const mostrarModalEditar = ref(false)
const mostrarModalVer = ref(false)
const observacionSeleccionada = ref(null)

const nuevaObservacion = ref({
  num_tramite: null,
  tipo: '',
  observacion: '',
  usuario: 'sistema'
})

// Computed
const totalPaginas = computed(() => Math.ceil(totalRegistros.value / itemsPerPage.value))

const visiblePages = computed(() => {
  const pages = []
  const current = paginaActual.value
  const total = totalPaginas.value

  let startPage = Math.max(1, current - 2)
  let endPage = Math.min(total, current + 2)

  if (current <= 3) {
    endPage = Math.min(5, total)
  }
  if (current >= total - 2) {
    startPage = Math.max(1, total - 4)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando observaciones...', 'Consultando catálogo')
  loading.value = true
  showFilters.value = false

  try {
    const response = await execute(
      'SP_OBSERVACIONES_LIST',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      todasObservaciones.value = response.result
      paginaActual.value = 1
      aplicarFiltrosYPaginacion()

      const endTime = performance.now()
      const duration = ((endTime - startTime) / 1000).toFixed(2)
      showToast('success', `${totalRegistros.value.toLocaleString()} observaciones encontradas`, `(${duration}s)`)
    } else {
      todasObservaciones.value = []
      observaciones.value = []
      totalRegistros.value = 0
      showToast('info', 'No se encontraron observaciones')
    }
  } catch (error) {
    handleApiError(error)
    todasObservaciones.value = []
    observaciones.value = []
    totalRegistros.value = 0
  } finally {
    loading.value = false
    hideLoading()
  }
}

const aplicarFiltrosYPaginacion = () => {
  let resultados = [...todasObservaciones.value]

  if (filtros.value.id_observacion) {
    resultados = resultados.filter(o => o.id_observacion === filtros.value.id_observacion)
  }
  if (filtros.value.num_tramite) {
    resultados = resultados.filter(o => o.num_tramite === filtros.value.num_tramite)
  }
  if (filtros.value.tipo) {
    resultados = resultados.filter(o => o.tipo?.toUpperCase() === filtros.value.tipo.toUpperCase())
  }
  if (filtros.value.observacion) {
    const busqueda = filtros.value.observacion.toLowerCase()
    resultados = resultados.filter(o =>
      o.observacion?.toLowerCase().includes(busqueda)
    )
  }

  totalRegistros.value = resultados.length

  const inicio = (paginaActual.value - 1) * itemsPerPage.value
  const fin = inicio + itemsPerPage.value
  observaciones.value = resultados.slice(inicio, fin)
}

const cambiarPagina = (pagina) => {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    paginaActual.value = pagina
    aplicarFiltrosYPaginacion()
  }
}

const limpiarFiltros = () => {
  filtros.value = {
    id_observacion: null,
    num_tramite: null,
    tipo: '',
    observacion: ''
  }
  paginaActual.value = 1
  aplicarFiltrosYPaginacion()
  showToast('info', 'Filtros limpiados')
}

const abrirModalCrear = () => {
  nuevaObservacion.value = {
    num_tramite: null,
    tipo: '',
    observacion: '',
    usuario: 'sistema'
  }
  mostrarModalCrear.value = true
}

const verObservacion = (obs) => {
  observacionSeleccionada.value = { ...obs }
  mostrarModalVer.value = true
}

const editarObservacion = (obs) => {
  observacionSeleccionada.value = { ...obs }
  mostrarModalEditar.value = true
}

const cerrarModal = () => {
  mostrarModalCrear.value = false
  mostrarModalEditar.value = false
  mostrarModalVer.value = false
  observacionSeleccionada.value = null
}

const crearObservacion = async () => {
  if (!nuevaObservacion.value.num_tramite || !nuevaObservacion.value.tipo || !nuevaObservacion.value.observacion.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete todos los campos obligatorios',
      confirmButtonColor: '#9363CD'
    })
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Observación?',
    html: `
      <div class="swal-content">
        <p><strong>Trámite:</strong> ${nuevaObservacion.value.num_tramite}</p>
        <p><strong>Tipo:</strong> ${nuevaObservacion.value.tipo}</p>
        <p><strong>Observación:</strong> ${nuevaObservacion.value.observacion.substring(0, 100)}...</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando observación...', 'Guardando en la base de datos')

  try {
    const response = await execute(
      'SP_OBSERVACIONES_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_num_tramite', valor: nuevaObservacion.value.num_tramite, tipo: 'integer' },
        { nombre: 'p_tipo', valor: nuevaObservacion.value.tipo, tipo: 'string' },
        { nombre: 'p_observacion', valor: nuevaObservacion.value.observacion.trim(), tipo: 'string' },
        { nombre: 'p_usuario', valor: nuevaObservacion.value.usuario, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Observación creada exitosamente')
      cerrarModal()
      await buscar()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const actualizarObservacion = async () => {
  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Observación?',
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando observación...', 'Guardando cambios')

  try {
    const response = await execute(
      'SP_OBSERVACIONES_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: observacionSeleccionada.value.id_observacion, tipo: 'integer' },
        { nombre: 'p_tipo', valor: observacionSeleccionada.value.tipo, tipo: 'string' },
        { nombre: 'p_observacion', valor: observacionSeleccionada.value.observacion.trim(), tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Observación actualizada exitosamente')
      cerrarModal()
      await buscar()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const confirmarEliminar = async (obs) => {
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Eliminar Observación?',
    text: `¿Está seguro de eliminar la observación #${obs.id_observacion}?`,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Eliminando observación...', 'Procesando')

  try {
    const response = await execute(
      'SP_OBSERVACIONES_DELETE',
      'padron_licencias',
      [{ nombre: 'p_id_observacion', valor: obs.id_observacion, tipo: 'integer' }],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result[0]?.success) {
      showToast('success', 'Observación eliminada exitosamente')
      await buscar()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const getTipoBadge = (tipo) => {
  const tipos = {
    'TRAMITE': 'badge-primary',
    'LICENCIA': 'badge-success',
    'GENERAL': 'badge-purple'
  }
  return tipos[tipo?.toUpperCase()] || 'badge-secondary'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}
</script>

