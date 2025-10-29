<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Trámites</h1>
        <p>Padrón de Licencias - Búsqueda avanzada y consulta de trámites</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">ID Trámite</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_tramite"
                placeholder="Número de trámite"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Trámite</label>
              <select class="municipal-form-control" v-model="filtros.tipo_tramite">
                <option value="">Todos</option>
                <option value="1">Licencia Nueva</option>
                <option value="2">Renovación</option>
                <option value="3">Cambio de Giro</option>
                <option value="4">Traspaso</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Estatus</label>
              <select class="municipal-form-control" v-model="filtros.estatus">
                <option value="">Todos</option>
                <option value="P">Pendiente</option>
                <option value="E">En Revisión</option>
                <option value="V">En Visita</option>
                <option value="A">Autorizado</option>
                <option value="R">Rechazado</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Propietario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.propietario"
                placeholder="Nombre del propietario"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_desde"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input
                type="date"
                class="municipal-form-control"
                v-model="filtros.fecha_hasta"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.rfc"
                placeholder="RFC"
                maxlength="13"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Giro</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_giro"
                placeholder="Código de giro"
              />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Calle</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.calle"
                placeholder="Nombre de calle"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Colonia</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.colonia"
                placeholder="Colonia"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Dependencia</label>
              <select class="municipal-form-control" v-model="filtros.id_dependencia">
                <option value="">Todas</option>
                <option value="1">Protección Civil</option>
                <option value="2">Ecología</option>
                <option value="3">Desarrollo Urbano</option>
                <option value="4">Salud</option>
              </select>
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarTramites"
              :disabled="loading"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="buscarTramites"
              :disabled="loading"
            >
              <font-awesome-icon icon="sync-alt" />
              Actualizar
            </button>
          </div>
        </div>
      </div>

      <!-- Panel de Estadísticas -->
      <div class="stats-grid" v-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.estatus" :class="`stat-${stat.estatus}`">
          <div class="stat-content">
            <h3 class="stat-number">{{ stat.total }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje }}%</small>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
            <span class="badge-info" v-if="totalResultados > 0">{{ totalResultados }} registros</span>
          </h5>
          <div class="button-group button-group-sm" v-if="tramites.length > 0">
            <button
              class="btn-municipal-success btn-sm"
              @click="exportarExcel"
              :disabled="loading"
            >
              <font-awesome-icon icon="file-excel" />
              Excel
            </button>
            <button
              class="btn-municipal-danger btn-sm"
              @click="exportarPDF"
              :disabled="loading"
            >
              <font-awesome-icon icon="file-pdf" />
              PDF
            </button>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Tipo</th>
                  <th>Propietario</th>
                  <th>RFC</th>
                  <th>Giro</th>
                  <th>Ubicación</th>
                  <th>Estatus</th>
                  <th>Fecha</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="tramites.length === 0 && !primeraBusqueda">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para encontrar trámites</p>
                  </td>
                </tr>
                <tr v-else-if="tramites.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron trámites con los filtros especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="tramite in tramites" :key="tramite.id_tramite" class="row-hover">
                  <td><strong class="text-primary">{{ tramite.id_tramite }}</strong></td>
                  <td>
                    <small>{{ tramite.tipo_tramite_desc || 'N/A' }}</small>
                  </td>
                  <td>{{ tramite.propietario }}</td>
                  <td><code class="text-muted">{{ tramite.rfc || 'Sin RFC' }}</code></td>
                  <td>
                    <small>{{ tramite.giro_desc || 'N/A' }}</small>
                  </td>
                  <td>
                    <small>
                      {{ tramite.calle }} {{ tramite.numero }}<br>
                      {{ tramite.colonia }}
                    </small>
                  </td>
                  <td>
                    <span class="badge" :class="getBadgeClass(tramite.estatus)">
                      <font-awesome-icon :icon="getEstatusIcon(tramite.estatus)" />
                      {{ getEstatusDesc(tramite.estatus) }}
                    </span>
                  </td>
                  <td>
                    <small class="text-muted">
                      <font-awesome-icon icon="calendar" />
                      {{ formatDate(tramite.fecha_solicitud) }}
                    </small>
                  </td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button
                        class="btn-municipal-info btn-sm"
                        @click="verDetalle(tramite)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click="verHistorial(tramite.id_tramite)"
                        title="Ver historial"
                      >
                        <font-awesome-icon icon="history" />
                      </button>
                      <button
                        v-if="tramite.estatus !== 'R' && tramite.estatus !== 'C'"
                        class="btn-municipal-secondary btn-sm"
                        @click="modificarTramite(tramite.id_tramite)"
                        title="Modificar"
                      >
                        <font-awesome-icon icon="edit" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <!-- Paginación -->
        <div class="pagination-container" v-if="totalResultados > 0 && !loading">
          <div class="pagination-info">
            <font-awesome-icon icon="info-circle" />
            Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
            a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
            de {{ totalResultados }} registros
          </div>

          <div class="pagination-controls">
            <div class="page-size-selector">
              <label>Mostrar:</label>
              <select v-model="itemsPerPage" @change="changePageSize">
                <option :value="10">10</option>
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>

            <div class="pagination-nav">
              <button
                class="pagination-button"
                @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>

              <button
                v-for="page in visiblePages"
                :key="page"
                class="pagination-button"
                :class="{ active: page === currentPage }"
                @click="goToPage(page)"
              >
                {{ page }}
              </button>

              <button
                class="pagination-button"
                @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading && tramites.length === 0" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Buscando trámites...</p>
        </div>
      </div>
    </div>

    <!-- Modal de Detalle -->
    <Modal
      :show="showDetalleModal"
      :title="`Detalle del Trámite #${tramiteSeleccionado.id_tramite || ''}`"
      size="xl"
      @close="closeDetalleModal"
      :showDefaultFooter="false"
    >
      <div v-if="tramiteSeleccionado.id_tramite" class="tramite-details">
        <div class="details-grid">
          <!-- Información General -->
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="info-circle" />
              Información General
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Tipo de Trámite:</td>
                <td>{{ tramiteSeleccionado.tipo_tramite_desc }}</td>
              </tr>
              <tr>
                <td class="label">Estatus:</td>
                <td>
                  <span class="badge" :class="getBadgeClass(tramiteSeleccionado.estatus)">
                    <font-awesome-icon :icon="getEstatusIcon(tramiteSeleccionado.estatus)" />
                    {{ getEstatusDesc(tramiteSeleccionado.estatus) }}
                  </span>
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Solicitud:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(tramiteSeleccionado.fecha_solicitud) }}
                </td>
              </tr>
              <tr>
                <td class="label">Fecha Límite:</td>
                <td>
                  <font-awesome-icon icon="calendar-times" class="text-warning" />
                  {{ formatDate(tramiteSeleccionado.fecha_limite) || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">No Pago:</td>
                <td>
                  <span :class="tramiteSeleccionado.nopago ? 'text-danger' : 'text-success'">
                    {{ tramiteSeleccionado.nopago ? 'Sí' : 'No' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>

          <!-- Datos del Propietario -->
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td>{{ tramiteSeleccionado.propietario }}</td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ tramiteSeleccionado.rfc || 'Sin RFC' }}</code></td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>{{ tramiteSeleccionado.telefono || 'Sin teléfono' }}</td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ tramiteSeleccionado.email || 'Sin email' }}</td>
              </tr>
            </table>
          </div>
        </div>

        <!-- Ubicación del Negocio -->
        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="map-marker-alt" />
            Ubicación del Negocio
          </h6>
          <p>
            <strong>Dirección:</strong><br>
            {{ tramiteSeleccionado.calle }} {{ tramiteSeleccionado.numero }}
            {{ tramiteSeleccionado.numint ? ', Int. ' + tramiteSeleccionado.numint : '' }}<br>
            {{ tramiteSeleccionado.colonia }}, C.P. {{ tramiteSeleccionado.cp }}
          </p>
          <p v-if="tramiteSeleccionado.latitud && tramiteSeleccionado.longitud">
            <strong>Coordenadas GPS:</strong><br>
            Lat: {{ tramiteSeleccionado.latitud }}, Long: {{ tramiteSeleccionado.longitud }}
          </p>
        </div>

        <!-- Giro y Actividad -->
        <div class="detail-section full-width">
          <h6 class="section-title">
            <font-awesome-icon icon="briefcase" />
            Giro y Actividad
          </h6>
          <p><strong>Giro:</strong> {{ tramiteSeleccionado.giro_desc }}</p>
          <p><strong>Actividad:</strong> {{ tramiteSeleccionado.actividad_desc }}</p>
        </div>

        <!-- Requisitos -->
        <div class="detail-section full-width" v-if="tramiteSeleccionado.total_requisitos > 0">
          <h6 class="section-title">
            <font-awesome-icon icon="clipboard-check" />
            Requisitos
          </h6>
          <p>
            <strong>Cumplidos:</strong>
            {{ tramiteSeleccionado.requisitos_cumplidos }} / {{ tramiteSeleccionado.total_requisitos }}
            <span class="ms-2">
              ({{ Math.round((tramiteSeleccionado.requisitos_cumplidos / tramiteSeleccionado.total_requisitos) * 100) }}%)
            </span>
          </p>
          <div class="progress-bar-container">
            <div
              class="progress-bar-fill"
              :class="getProgressBarClass(tramiteSeleccionado.requisitos_cumplidos, tramiteSeleccionado.total_requisitos)"
              :style="{ width: (tramiteSeleccionado.requisitos_cumplidos / tramiteSeleccionado.total_requisitos * 100) + '%' }"
            >
              {{ tramiteSeleccionado.requisitos_cumplidos }} / {{ tramiteSeleccionado.total_requisitos }}
            </div>
          </div>
        </div>

        <!-- Observaciones -->
        <div class="detail-section full-width" v-if="tramiteSeleccionado.observaciones">
          <h6 class="section-title">
            <font-awesome-icon icon="comment" />
            Observaciones
          </h6>
          <p class="observaciones-text">{{ tramiteSeleccionado.observaciones }}</p>
        </div>

        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="closeDetalleModal">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button
            v-if="tramiteSeleccionado.estatus !== 'R' && tramiteSeleccionado.estatus !== 'C'"
            class="btn-municipal-primary"
            @click="modificarTramite(tramiteSeleccionado.id_tramite); closeDetalleModal()"
          >
            <font-awesome-icon icon="edit" />
            Modificar Trámite
          </button>
        </div>
      </div>
    </Modal>

    <!-- Modal de Historial -->
    <Modal
      :show="showHistorialModal"
      :title="`Historial Completo - Trámite #${historialTramiteId || ''}`"
      size="lg"
      @close="closeHistorialModal"
      :showDefaultFooter="false"
    >
      <div v-if="loadingHistorial" class="text-center py-5">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Cargando historial...</span>
        </div>
        <p class="mt-2">Cargando historial completo...</p>
      </div>

      <div v-else class="alert alert-info">
        <font-awesome-icon icon="info-circle" />
        <strong>Funcionalidad en desarrollo</strong>
        <p class="mb-0">
          <small>Este modal mostrará: historial de estatus, revisiones, requisitos, pagos, documentos y observaciones.</small>
        </p>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="closeHistorialModal">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </Modal>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'ConsultaTramitefrm'"
    :moduleName="'padron_licencias'"
    @close="closeDocumentation"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Modal from '@/components/common/Modal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const router = useRouter()
const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const showFilters = ref(true)
const tramites = ref([])
const estadisticas = ref([])
const totalResultados = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(20)
const primeraBusqueda = ref(false)
const showDetalleModal = ref(false)
const showHistorialModal = ref(false)
const tramiteSeleccionado = ref({})
const historialTramiteId = ref(null)
const loadingHistorial = ref(false)

// Filtros
const filtros = ref({
  id_tramite: '',
  tipo_tramite: '',
  estatus: '',
  fecha_desde: '',
  fecha_hasta: '',
  propietario: '',
  rfc: '',
  id_dependencia: '',
  id_giro: '',
  calle: '',
  colonia: ''
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalResultados.value / itemsPerPage.value)
})

const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)

  for (let i = start; i <= end; i++) {
    pages.push(i)
  }
  return pages
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const buscarTramites = async () => {
  setLoading(true, 'Buscando trámites...')
  primeraBusqueda.value = true

  try {
    const params = []

    // Agregar solo filtros con valor
    if (filtros.value.id_tramite) {
      params.push({ nombre: 'p_id_tramite', valor: parseInt(filtros.value.id_tramite), tipo: 'integer' })
    }
    if (filtros.value.tipo_tramite) {
      params.push({ nombre: 'p_tipo_tramite', valor: parseInt(filtros.value.tipo_tramite), tipo: 'integer' })
    }
    if (filtros.value.estatus) {
      params.push({ nombre: 'p_estatus', valor: filtros.value.estatus, tipo: 'string' })
    }
    if (filtros.value.fecha_desde) {
      params.push({ nombre: 'p_fecha_desde', valor: filtros.value.fecha_desde, tipo: 'string' })
    }
    if (filtros.value.fecha_hasta) {
      params.push({ nombre: 'p_fecha_hasta', valor: filtros.value.fecha_hasta, tipo: 'string' })
    }
    if (filtros.value.propietario) {
      params.push({ nombre: 'p_propietario', valor: filtros.value.propietario, tipo: 'string' })
    }
    if (filtros.value.rfc) {
      params.push({ nombre: 'p_rfc', valor: filtros.value.rfc, tipo: 'string' })
    }
    if (filtros.value.id_dependencia) {
      params.push({ nombre: 'p_id_dependencia', valor: parseInt(filtros.value.id_dependencia), tipo: 'integer' })
    }
    if (filtros.value.id_giro) {
      params.push({ nombre: 'p_id_giro', valor: parseInt(filtros.value.id_giro), tipo: 'integer' })
    }
    if (filtros.value.calle) {
      params.push({ nombre: 'p_calle', valor: filtros.value.calle, tipo: 'string' })
    }
    if (filtros.value.colonia) {
      params.push({ nombre: 'p_colonia', valor: filtros.value.colonia, tipo: 'string' })
    }

    // Paginación
    params.push({ nombre: 'p_page', valor: currentPage.value, tipo: 'integer' })
    params.push({ nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' })

    const response = await execute(
      'SP_CONSULTATRAMITE_LIST',
      'padron_licencias',
      params,
      'guadalajara'
    )

    if (response && response.result) {
      tramites.value = response.result
      if (tramites.value.length > 0) {
        totalResultados.value = parseInt(tramites.value[0].total_records) || 0
      } else {
        totalResultados.value = 0
      }
      showToast('success', `Se encontraron ${totalResultados.value} trámite(s)`)
    } else {
      tramites.value = []
      totalResultados.value = 0
      showToast('info', 'No se encontraron trámites con los filtros especificados')
    }
  } catch (error) {
    handleApiError(error)
    tramites.value = []
    totalResultados.value = 0
  } finally {
    setLoading(false)
  }
}

const cargarEstadisticas = async () => {
  try {
    const response = await execute(
      'SP_CONSULTATRAMITE_ESTADISTICAS',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      estadisticas.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar estadísticas:', error)
  }
}

const limpiarFiltros = () => {
  Object.keys(filtros.value).forEach(key => {
    filtros.value[key] = ''
  })
  tramites.value = []
  totalResultados.value = 0
  currentPage.value = 1
  primeraBusqueda.value = false
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    buscarTramites()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  buscarTramites()
}

const verDetalle = (tramite) => {
  tramiteSeleccionado.value = tramite
  showDetalleModal.value = true
}

const closeDetalleModal = () => {
  showDetalleModal.value = false
  tramiteSeleccionado.value = {}
}

const verHistorial = async (idTramite) => {
  historialTramiteId.value = idTramite
  showHistorialModal.value = true
  loadingHistorial.value = true

  setTimeout(() => {
    loadingHistorial.value = false
  }, 1000)
}

const closeHistorialModal = () => {
  showHistorialModal.value = false
  historialTramiteId.value = null
}

const modificarTramite = (idTramite) => {
  router.push(`/padron-licencias/modificacion-tramites/${idTramite}`)
}

const exportarExcel = async () => {
  await Swal.fire({
    title: 'Exportar a Excel',
    text: 'Funcionalidad en desarrollo. Utilizará SP_CONSULTATRAMITE_EXPORTAR',
    icon: 'info',
    confirmButtonColor: '#ea8215'
  })
}

const exportarPDF = async () => {
  await Swal.fire({
    title: 'Exportar a PDF',
    text: 'Funcionalidad en desarrollo',
    icon: 'info',
    confirmButtonColor: '#ea8215'
  })
}

// Utilidades
const getBadgeClass = (estatus) => {
  const classes = {
    'P': 'badge-warning',
    'E': 'badge-info',
    'V': 'badge-primary',
    'A': 'badge-success',
    'R': 'badge-danger',
    'C': 'badge-secondary'
  }
  return classes[estatus] || 'badge-info'
}

const getEstatusDesc = (estatus) => {
  const desc = {
    'P': 'Pendiente',
    'E': 'En Revisión',
    'V': 'En Visita',
    'A': 'Autorizado',
    'R': 'Rechazado',
    'C': 'Cancelado'
  }
  return desc[estatus] || estatus
}

const getEstatusIcon = (estatus) => {
  const icons = {
    'P': 'clock',
    'E': 'search',
    'V': 'walking',
    'A': 'check-circle',
    'R': 'times-circle',
    'C': 'ban'
  }
  return icons[estatus] || 'info-circle'
}

const getProgressBarClass = (cumplidos, total) => {
  const porcentaje = (cumplidos / total) * 100
  if (porcentaje === 100) return 'progress-success'
  if (porcentaje >= 75) return 'progress-info'
  if (porcentaje >= 50) return 'progress-warning'
  return 'progress-danger'
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
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
  cargarEstadisticas()
})
</script>
