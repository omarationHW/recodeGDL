<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Fechas de Seguimiento</h1>
        <p>Padrón de Licencias - Gestión de fechas de seguimiento de trámites</p>
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
        <button class="btn-municipal-purple" @click="openDocumentation">
          <font-awesome-icon icon="question-circle" />
          Ayuda
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
                <font-awesome-icon icon="calendar-alt" />
                Fecha Inicio:
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_inicio"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" />
                Fecha Fin:
              </label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_fin"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" />
                ID:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.id"
                placeholder="ID de seguimiento"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" />
                ID Documento:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.t42_doctos_id"
                placeholder="ID documento"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" />
                ID Centro:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.t42_centros_id"
                placeholder="ID centro"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" />
                Usuario Seguimiento:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.usuario_seg"
                placeholder="ID usuario"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="flag" />
                ID Status:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="filtros.t42_statusseg_id"
                placeholder="ID status"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="comment" />
                Observación:
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.observacion"
                placeholder="Buscar en observaciones"
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

      <!-- Tabla de fechas -->
      <div v-if="fechas.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Lista de Fechas de Seguimiento
          </h5>
          <span class="badge-purple">{{ totalRegistros.toLocaleString() }} registros</span>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 6%; text-align: center;">ID</th>
                  <th style="width: 8%; text-align: center;">Docto</th>
                  <th style="width: 8%; text-align: center;">Centro</th>
                  <th style="width: 8%; text-align: center;">Usuario</th>
                  <th style="width: 13%; text-align: center;">Fecha Seg</th>
                  <th style="width: 7%; text-align: center;">Status</th>
                  <th style="width: 32%;">Observación</th>
                  <th style="width: 8%; text-align: center;">Usuario Mov</th>
                  <th style="width: 10%; text-align: center;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="fecha in fechas" :key="fecha.id" class="clickable-row">
                  <td style="text-align: center;">
                    <code class="text-primary"><strong>{{ fecha.id }}</strong></code>
                  </td>
                  <td style="text-align: center;">
                    <span class="badge-purple">{{ fecha.t42_doctos_id || '-' }}</span>
                  </td>
                  <td style="text-align: center;">
                    <span class="badge-purple">{{ fecha.t42_centros_id || '-' }}</span>
                  </td>
                  <td style="text-align: center;">
                    <small>{{ fecha.usuario_seg || '-' }}</small>
                  </td>
                  <td style="text-align: center;">
                    <small class="text-muted">{{ formatearFecha(fecha.fec_seg) }}</small>
                  </td>
                  <td style="text-align: center;">
                    <small>{{ fecha.t42_statusseg_id || '-' }}</small>
                  </td>
                  <td>
                    <small>{{ (fecha.observacion || '-').substring(0, 80) }}{{ (fecha.observacion || '').length > 80 ? '...' : '' }}</small>
                  </td>
                  <td style="text-align: center;">
                    <span class="badge-secondary">{{ fecha.usuario_mov ? fecha.usuario_mov.trim() : '-' }}</span>
                  </td>
                  <td style="text-align: center;">
                    <div class="btn-group-actions">
                      <button class="btn-action btn-action-view" @click="verFecha(fecha)" title="Ver">
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button class="btn-action btn-action-edit" @click="editarFecha(fecha)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-action btn-action-delete" @click="confirmarEliminar(fecha)" title="Eliminar">
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
              <font-awesome-icon icon="info-circle" />
              Mostrando {{ ((paginaActual - 1) * itemsPerPage) + 1 }} a {{ Math.min(paginaActual * itemsPerPage, totalRegistros) }} de {{ totalRegistros.toLocaleString() }} registros
            </div>

            <div class="pagination-controls">
              <div class="page-size-selector">
                <label>Mostrar:</label>
                <select v-model.number="itemsPerPage" @change="aplicarFiltrosYPaginacion">
                  <option :value="10">10</option>
                  <option :value="25">25</option>
                  <option :value="50">50</option>
                  <option :value="100">100</option>
                </select>
              </div>

              <div class="pagination-nav">
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
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Estado vacío -->
      <div v-if="fechas.length === 0 && !loading" class="municipal-card">
        <div class="municipal-card-body">
          <div class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h5>No hay fechas de seguimiento registradas</h5>
            <p>Presiona "Actualizar" para cargar las fechas o "Nuevo" para crear una</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ver -->
    <Modal :show="modalVer" title="Detalle de Fecha de Seguimiento" size="lg" @close="modalVer = false">
      <template #default>
        <div class="details-grid">
          <div class="detail-item">
            <label class="detail-label">ID:</label>
            <div class="detail-value">{{ fechaSeleccionada?.id }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">ID Documento:</label>
            <div class="detail-value">{{ fechaSeleccionada?.t42_doctos_id || '-' }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">ID Centro:</label>
            <div class="detail-value">{{ fechaSeleccionada?.t42_centros_id || '-' }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Usuario Seguimiento:</label>
            <div class="detail-value">{{ fechaSeleccionada?.usuario_seg || '-' }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Fecha Seguimiento:</label>
            <div class="detail-value">{{ formatearFechaCompleta(fechaSeleccionada?.fec_seg) }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">ID Status:</label>
            <div class="detail-value">{{ fechaSeleccionada?.t42_statusseg_id || '-' }}</div>
          </div>
          <div class="detail-item">
            <label class="detail-label">Usuario Movimiento:</label>
            <div class="detail-value">{{ fechaSeleccionada?.usuario_mov ? fechaSeleccionada.usuario_mov.trim() : '-' }}</div>
          </div>
          <div class="detail-item full-width">
            <label class="detail-label">Observación:</label>
            <div class="detail-value">{{ fechaSeleccionada?.observacion || 'Sin observación' }}</div>
          </div>
        </div>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="modalVer = false">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </template>
    </Modal>

    <!-- Modal Editar -->
    <Modal :show="modalEditar" title="Editar Fecha de Seguimiento" size="lg" @close="cancelarEdicion">
      <template #default>
        <form @submit.prevent="guardarEdicion">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" />
                ID Documento:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaEditando.t42_doctos_id"
                placeholder="ID documento"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" />
                ID Centro:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaEditando.t42_centros_id"
                placeholder="ID centro"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" />
                Usuario Seguimiento:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaEditando.usuario_seg"
                placeholder="ID usuario"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" />
                Fecha Seguimiento: <span class="text-danger">*</span>
              </label>
              <input
                type="datetime-local"
                class="municipal-form-control"
                v-model="fechaEditando.fec_seg"
                required
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="flag" />
                ID Status:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaEditando.t42_statusseg_id"
                placeholder="ID status"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user-edit" />
                Usuario Movimiento:
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="fechaEditando.usuario_mov"
                placeholder="Usuario movimiento"
                maxlength="10"
              >
            </div>
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="comment" />
              Observación:
            </label>
            <textarea
              class="municipal-form-control"
              v-model="fechaEditando.observacion"
              placeholder="Observaciones (opcional)"
              rows="3"
              maxlength="255"
            ></textarea>
          </div>
        </form>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="cancelarEdicion">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-primary" @click="guardarEdicion">
          <font-awesome-icon icon="save" />
          Guardar Cambios
        </button>
      </template>
    </Modal>

    <!-- Modal Crear -->
    <Modal :show="modalCrear" title="Nueva Fecha de Seguimiento" size="lg" @close="cancelarCreacion">
      <template #default>
        <form @submit.prevent="guardarNuevo">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" />
                ID Documento:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaNueva.t42_doctos_id"
                placeholder="ID documento"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" />
                ID Centro:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaNueva.t42_centros_id"
                placeholder="ID centro"
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user" />
                Usuario Seguimiento:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaNueva.usuario_seg"
                placeholder="ID usuario"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-check" />
                Fecha Seguimiento: <span class="text-danger">*</span>
              </label>
              <input
                type="datetime-local"
                class="municipal-form-control"
                v-model="fechaNueva.fec_seg"
                required
              >
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="flag" />
                ID Status:
              </label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="fechaNueva.t42_statusseg_id"
                placeholder="ID status"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">
                <font-awesome-icon icon="user-edit" />
                Usuario Movimiento:
              </label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="fechaNueva.usuario_mov"
                placeholder="Usuario movimiento"
                maxlength="10"
              >
            </div>
          </div>
          <div class="form-group full-width">
            <label class="municipal-form-label">
              <font-awesome-icon icon="comment" />
              Observación:
            </label>
            <textarea
              class="municipal-form-control"
              v-model="fechaNueva.observacion"
              placeholder="Observaciones (opcional)"
              rows="3"
              maxlength="255"
            ></textarea>
          </div>
        </form>
      </template>
      <template #footer>
        <button class="btn-municipal-secondary" @click="cancelarCreacion">
          <font-awesome-icon icon="times" />
          Cancelar
        </button>
        <button class="btn-municipal-success" @click="guardarNuevo">
          <font-awesome-icon icon="save" />
          Crear Registro
        </button>
      </template>
    </Modal>

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
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

const { execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Funciones helper para fechas
const obtenerFechaHoy = () => {
  const hoy = new Date()
  return hoy.toISOString().split('T')[0]
}

const obtenerFechaMenosMeses = (meses) => {
  const fecha = new Date()
  fecha.setMonth(fecha.getMonth() - meses)
  return fecha.toISOString().split('T')[0]
}

// Función para obtener fechas por defecto con datos reales
const obtenerFechaInicioPorDefecto = () => {
  return '2020-01-01' // Inicio de últimos 2 años con datos
}

const obtenerFechaFinPorDefecto = () => {
  return '2021-12-31' // Fin del último año con datos
}

const loading = ref(false)
const showFilters = ref(false)
const todasFechas = ref([])
const paginaActual = ref(1)
const itemsPerPage = ref(10)

const modalVer = ref(false)
const modalEditar = ref(false)
const modalCrear = ref(false)
const fechaSeleccionada = ref(null)
const fechaEditando = ref({})
const fechaNueva = ref({})

const filtros = ref({
  fecha_inicio: obtenerFechaInicioPorDefecto(),
  fecha_fin: obtenerFechaFinPorDefecto(),
  id: null,
  t42_doctos_id: null,
  t42_centros_id: null,
  usuario_seg: null,
  t42_statusseg_id: null,
  observacion: ''
})

const fechasFiltradas = computed(() => {
  let resultado = [...todasFechas.value]

  if (filtros.value.id) {
    resultado = resultado.filter(f => f.id === filtros.value.id)
  }
  if (filtros.value.t42_doctos_id) {
    resultado = resultado.filter(f => f.t42_doctos_id === filtros.value.t42_doctos_id)
  }
  if (filtros.value.t42_centros_id) {
    resultado = resultado.filter(f => f.t42_centros_id === filtros.value.t42_centros_id)
  }
  if (filtros.value.usuario_seg) {
    resultado = resultado.filter(f => f.usuario_seg === filtros.value.usuario_seg)
  }
  if (filtros.value.t42_statusseg_id) {
    resultado = resultado.filter(f => f.t42_statusseg_id === filtros.value.t42_statusseg_id)
  }
  if (filtros.value.observacion) {
    const obs = filtros.value.observacion.toLowerCase()
    resultado = resultado.filter(f =>
      (f.observacion || '').toLowerCase().includes(obs)
    )
  }

  return resultado
})

const totalRegistros = computed(() => fechasFiltradas.value.length)
const totalPaginas = computed(() => Math.ceil(totalRegistros.value / itemsPerPage.value))

const fechas = computed(() => {
  const inicio = (paginaActual.value - 1) * itemsPerPage.value
  const fin = inicio + itemsPerPage.value
  return fechasFiltradas.value.slice(inicio, fin)
})

const visiblePages = computed(() => {
  const paginas = []
  const maxVisible = 5
  let start = Math.max(1, paginaActual.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPaginas.value, start + maxVisible - 1)

  if (end - start < maxVisible - 1) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
    paginas.push(i)
  }
  return paginas
})

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const limpiarFiltros = () => {
  filtros.value = {
    fecha_inicio: obtenerFechaInicioPorDefecto(),
    fecha_fin: obtenerFechaFinPorDefecto(),
    id: null,
    t42_doctos_id: null,
    t42_centros_id: null,
    usuario_seg: null,
    t42_statusseg_id: null,
    observacion: ''
  }
  paginaActual.value = 1
}

const aplicarFiltrosYPaginacion = () => {
  paginaActual.value = 1
}

const cambiarPagina = (pagina) => {
  if (pagina >= 1 && pagina <= totalPaginas.value) {
    paginaActual.value = pagina
  }
}

const buscar = async () => {
  const startTime = performance.now()
  showLoading('Cargando fechas de seguimiento...', 'Consultando catálogo')
  loading.value = true
  showFilters.value = false

  try {
    // Construir parámetros con formato de timestamp (NULL si vacío)
    const fechaInicio = filtros.value.fecha_inicio ? `${filtros.value.fecha_inicio} 00:00:00` : null
    const fechaFin = filtros.value.fecha_fin ? `${filtros.value.fecha_fin} 23:59:59` : null

    const response = await execute(
      'SP_FECHASEG_LIST',
      'padron_licencias',
      [
        { nombre: 'p_fecha_inicio', valor: fechaInicio, tipo: 'timestamp' },
        { nombre: 'p_fecha_fin', valor: fechaFin, tipo: 'timestamp' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      todasFechas.value = response.result
      paginaActual.value = 1
      showToast('success', `${totalRegistros.value.toLocaleString()} fechas de seguimiento encontradas`, `(${duration}s)`)
    } else {
      todasFechas.value = []
      showToast('info', 'No se encontraron fechas de seguimiento en el rango especificado', `(${duration}s)`)
    }
  } catch (error) {
    handleApiError(error)
    todasFechas.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const verFecha = (fecha) => {
  fechaSeleccionada.value = { ...fecha }
  modalVer.value = true
}

const editarFecha = (fecha) => {
  fechaEditando.value = {
    id: fecha.id,
    t42_doctos_id: fecha.t42_doctos_id,
    t42_centros_id: fecha.t42_centros_id,
    usuario_seg: fecha.usuario_seg,
    fec_seg: fecha.fec_seg ? formatearFechaISO(fecha.fec_seg) : '',
    t42_statusseg_id: fecha.t42_statusseg_id,
    observacion: fecha.observacion || '',
    usuario_mov: fecha.usuario_mov ? fecha.usuario_mov.trim() : ''
  }
  modalEditar.value = true
}

const cancelarEdicion = () => {
  fechaEditando.value = {}
  modalEditar.value = false
}

const guardarEdicion = async () => {
  if (!fechaEditando.value.fec_seg) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La fecha de seguimiento es requerida',
      confirmButtonColor: '#9363CD'
    })
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Actualizar Fecha de Seguimiento?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${fechaEditando.value.id}</p>
        <p><strong>Fecha:</strong> ${formatearFecha(fechaEditando.value.fec_seg)}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, actualizar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Actualizando fecha de seguimiento...', 'Guardando cambios')

  try {
    const response = await execute(
      'SP_FECHASEG_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_id', valor: fechaEditando.value.id, tipo: 'integer' },
        { nombre: 'p_t42_doctos_id', valor: fechaEditando.value.t42_doctos_id || null, tipo: 'integer' },
        { nombre: 'p_t42_centros_id', valor: fechaEditando.value.t42_centros_id || null, tipo: 'integer' },
        { nombre: 'p_usuario_seg', valor: fechaEditando.value.usuario_seg || null, tipo: 'integer' },
        { nombre: 'p_fec_seg', valor: fechaEditando.value.fec_seg, tipo: 'string' },
        { nombre: 'p_t42_statusseg_id', valor: fechaEditando.value.t42_statusseg_id || null, tipo: 'integer' },
        { nombre: 'p_observacion', valor: fechaEditando.value.observacion || null, tipo: 'string' },
        { nombre: 'p_usuario_mov', valor: fechaEditando.value.usuario_mov || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.success) {
        showToast('success', 'Fecha de seguimiento actualizada exitosamente')
        modalEditar.value = false
        fechaEditando.value = {}
        await buscar()
      } else {
        showToast('error', resultado.message || 'Error al actualizar')
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const abrirModalCrear = () => {
  fechaNueva.value = {
    t42_doctos_id: null,
    t42_centros_id: null,
    usuario_seg: null,
    fec_seg: '',
    t42_statusseg_id: null,
    observacion: '',
    usuario_mov: ''
  }
  modalCrear.value = true
}

const cancelarCreacion = () => {
  fechaNueva.value = {}
  modalCrear.value = false
}

const guardarNuevo = async () => {
  if (!fechaNueva.value.fec_seg) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'La fecha de seguimiento es requerida',
      confirmButtonColor: '#9363CD'
    })
    return
  }

  const result = await Swal.fire({
    icon: 'question',
    title: '¿Crear Fecha de Seguimiento?',
    html: `
      <div class="swal-content">
        <p><strong>Fecha:</strong> ${formatearFecha(fechaNueva.value.fec_seg)}</p>
        <p><strong>Observación:</strong> ${fechaNueva.value.observacion || 'Sin observación'}</p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  showLoading('Creando fecha de seguimiento...', 'Guardando en la base de datos')

  try {
    const response = await execute(
      'SP_FECHASEG_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_t42_doctos_id', valor: fechaNueva.value.t42_doctos_id || null, tipo: 'integer' },
        { nombre: 'p_t42_centros_id', valor: fechaNueva.value.t42_centros_id || null, tipo: 'integer' },
        { nombre: 'p_usuario_seg', valor: fechaNueva.value.usuario_seg || null, tipo: 'integer' },
        { nombre: 'p_fec_seg', valor: fechaNueva.value.fec_seg, tipo: 'string' },
        { nombre: 'p_t42_statusseg_id', valor: fechaNueva.value.t42_statusseg_id || null, tipo: 'integer' },
        { nombre: 'p_observacion', valor: fechaNueva.value.observacion || null, tipo: 'string' },
        { nombre: 'p_usuario_mov', valor: fechaNueva.value.usuario_mov || null, tipo: 'string' }
      ],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.success) {
        showToast('success', `Fecha de seguimiento creada exitosamente (ID: ${resultado.id})`)
        modalCrear.value = false
        fechaNueva.value = {}
        await buscar()
      } else {
        showToast('error', resultado.message || 'Error al crear')
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const confirmarEliminar = async (fecha) => {
  const result = await Swal.fire({
    title: '¿Confirmar eliminación?',
    html: `
      <div class="swal-content">
        <p><strong>ID:</strong> ${fecha.id}</p>
        <p><strong>Fecha:</strong> ${formatearFecha(fecha.fec_seg)}</p>
        <p style="margin-top: 15px; color: #d32f2f;">Esta acción no se puede deshacer.</p>
      </div>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#9363CD',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar',
    reverseButtons: true
  })

  if (result.isConfirmed) {
    await eliminarFecha(fecha.id)
  }
}

const eliminarFecha = async (id) => {
  showLoading('Eliminando...', 'Eliminando fecha de seguimiento')

  try {
    const response = await execute(
      'SP_FECHASEG_DELETE',
      'padron_licencias',
      [{ nombre: 'p_id', valor: id, tipo: 'integer' }],
      'guadalajara',
      null,
      'publico'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]
      if (resultado.success) {
        showToast('success', 'Fecha de seguimiento eliminada exitosamente')
        await buscar()
      } else {
        showToast('error', resultado.message || 'Error al eliminar')
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const formatearFecha = (fecha) => {
  if (!fecha) return '-'
  try {
    const date = new Date(fecha)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch {
    return fecha
  }
}

const formatearFechaCompleta = (fecha) => {
  if (!fecha) return '-'
  try {
    const date = new Date(fecha)
    return date.toLocaleDateString('es-MX', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch {
    return fecha
  }
}

const formatearFechaISO = (fecha) => {
  if (!fecha) return ''
  try {
    const date = new Date(fecha)
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    return `${year}-${month}-${day}T${hours}:${minutes}`
  } catch {
    return ''
  }
}

const openDocumentation = () => {
  window.open('/docs/padron_licencias/fechasegfrm.html', '_blank')
}

// Cargar datos al montar el componente
onMounted(() => {
  buscar()
})
</script>
