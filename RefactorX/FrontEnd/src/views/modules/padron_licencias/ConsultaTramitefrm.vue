<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Trámites</h1>
        <p>Padrón de Licencias - Búsqueda avanzada y consulta de trámites</p>
      </div>
      <div class="button-group ms-auto">
        <button
          v-if="tramites.length > 0"
          class="btn-municipal-success"
          @click="exportarExcel"
        >
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button
          v-if="tramites.length > 0"
          class="btn-municipal-danger"
          @click="exportarPDF"
        >
          <font-awesome-icon icon="file-pdf" />
          PDF
        </button>
        <button
          v-if="primeraBusqueda"
          class="btn-municipal-secondary"
          @click="limpiarBusqueda"
          title="Limpiar filtros y resultados"
        >
          <font-awesome-icon icon="eraser" />
          Limpiar
        </button>
        <button
          class="btn-municipal-primary"
          @click="buscarTramites"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button
          class="btn-municipal-success"
          @click="nuevoTramite"
        >
          <font-awesome-icon icon="plus" />
          Nuevo Trámite
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
      <!-- Panel de Estadísticas -->

      <!-- Loading skeleton para estadísticas -->
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
            <div class="skeleton-percentage"></div>
          </div>
        </div>
      </div>

      <!-- Cards de estadísticas con datos -->
      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.estatus" :class="`stat-${stat.estatus}`">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon :icon="getEstatusIcon(stat.estatus)" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stat.total) }}</h3>
            <p class="stat-label">{{ stat.descripcion }}</p>
            <small class="stat-percentage">{{ stat.porcentaje }}%</small>
          </div>
        </div>
      </div>

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
              <label class="municipal-form-label">ID Licencia</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_licencia"
                placeholder="Número de licencia"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Trámite</label>
              <select class="municipal-form-control" v-model="filtros.tipo_tramite">
                <option value="">Todos</option>
                <option value="LN">Licencia Nueva</option>
                <option value="RE">Renovación</option>
                <option value="CG">Cambio de Giro</option>
                <option value="TR">Traspaso</option>
                <option value="AN">Anuncio</option>
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
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Propietario</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filtros.propietario"
                placeholder="Nombre del propietario"
              />
            </div>
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
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Giro</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model="filtros.id_giro"
                placeholder="Código de giro"
              />
            </div>
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
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
            <button
              class="btn-municipal-secondary"
              @click="limpiarFiltros"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <div class="header-with-badge">
            <h5>
              <font-awesome-icon icon="list" />
              Resultados de Búsqueda
            </h5>
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registros totales
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Licencia</th>
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
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para encontrar trámites</p>
                  </td>
                </tr>
                <tr v-else-if="tramites.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron trámites con los filtros especificados</p>
                  </td>
                </tr>
                <tr
                  v-else
                  v-for="tramite in tramites"
                  :key="tramite.id_tramite"
                  @click="tramiteSeleccionado = tramite"
                  @dblclick="verDetalle(tramite)"
                  :class="{ 'row-hover': true, 'selected-row': tramiteSeleccionado?.id_tramite === tramite.id_tramite }"
                  style="cursor: pointer;"
                >
                  <td><strong class="text-primary">{{ tramite.id_tramite }}</strong></td>
                  <td>
                    <span v-if="tramite.id_licencia" class="badge badge-purple">
                      <font-awesome-icon icon="file-alt" />
                      {{ tramite.id_licencia }}
                    </span>
                    <span v-else class="text-muted">
                      <small>Sin licencia</small>
                    </span>
                  </td>
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
                        @click.stop="verDetalle(tramite)"
                        title="Ver detalles"
                      >
                        <font-awesome-icon icon="eye" />
                      </button>
                      <button
                        class="btn-municipal-primary btn-sm"
                        @click.stop="verHistorial(tramite)"
                        title="Ver historial"
                      >
                        <font-awesome-icon icon="history" />
                      </button>
                      <button
                        v-if="tramite.estatus !== 'R' && tramite.estatus !== 'C'"
                        class="btn-municipal-secondary btn-sm"
                        @click.stop="modificarTramite(tramite)"
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

        <!-- Controles de Paginación -->
        <div v-if="tramites.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalResultados) }}
              de {{ totalResultados }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              v-model="itemsPerPage"
              @change="changePageSize"
              style="width: auto; display: inline-block;"
            >
              <option :value="10">10</option>
              <option :value="20">20</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
            </select>
          </div>

          <div class="pagination-buttons">
            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(1)"
              :disabled="currentPage === 1"
              title="Primera página"
            >
              <font-awesome-icon icon="angle-double-left" />
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(currentPage - 1)"
              :disabled="currentPage === 1"
              title="Página anterior"
            >
              <font-awesome-icon icon="angle-left" />
            </button>

            <button
              v-for="page in visiblePages"
              :key="page"
              class="btn-sm"
              :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
              @click="goToPage(page)"
            >
              {{ page }}
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(currentPage + 1)"
              :disabled="currentPage === totalPages"
              title="Página siguiente"
            >
              <font-awesome-icon icon="angle-right" />
            </button>

            <button
              class="btn-municipal-secondary btn-sm"
              @click="goToPage(totalPages)"
              :disabled="currentPage === totalPages"
              title="Última página"
            >
              <font-awesome-icon icon="angle-double-right" />
            </button>
          </div>
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
                <td class="label">ID Licencia:</td>
                <td><strong class="text-primary">{{ tramiteSeleccionado.id_licencia || 'N/A' }}</strong></td>
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
            v-if="tramiteSeleccionado.id_licencia"
            class="btn-municipal-success"
            @click="verLicencia(tramiteSeleccionado.id_licencia)"
          >
            <font-awesome-icon icon="file-alt" />
            Ver Licencia
          </button>
          <button
            v-if="tramiteSeleccionado.estatus !== 'R' && tramiteSeleccionado.estatus !== 'C'"
            class="btn-municipal-primary"
            @click="modificarTramite(tramiteSeleccionado); closeDetalleModal()"
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const nuevoTramite = () => {
  router.push('/padron-licencias/registro-solicitud')
}

const router = useRouter()
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Constante para caché
const CACHE_KEY = 'consulta_tramites_cache'

// Estado
const showFilters = ref(false)
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
const loadingEstadisticas = ref(true)

// Filtros
const filtros = ref({
  id_tramite: '',
  id_licencia: '',
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

// Métodos de Caché
const guardarCacheConsulta = () => {
  try {
    const cache = {
      filtros: filtros.value,
      tramites: tramites.value,
      totalResultados: totalResultados.value,
      currentPage: currentPage.value,
      primeraBusqueda: primeraBusqueda.value,
      timestamp: new Date().getTime()
    }
    sessionStorage.setItem(CACHE_KEY, JSON.stringify(cache))
  } catch (error) {
    console.error('Error al guardar caché:', error)
  }
}

const cargarCacheConsulta = () => {
  try {
    const cached = sessionStorage.getItem(CACHE_KEY)
    if (cached) {
      const cache = JSON.parse(cached)

      // Verificar que el cache no sea muy antiguo (máximo 1 hora)
      const ahora = new Date().getTime()
      const tiempoTranscurrido = ahora - cache.timestamp
      const unaHora = 60 * 60 * 1000

      if (tiempoTranscurrido < unaHora) {
        // Restaurar datos desde el caché
        filtros.value = cache.filtros
        tramites.value = cache.tramites
        totalResultados.value = cache.totalResultados
        currentPage.value = cache.currentPage
        primeraBusqueda.value = cache.primeraBusqueda

        console.log('✅ Caché cargado exitosamente')
        return true
      } else {
        // Cache expirado, limpiar
        sessionStorage.removeItem(CACHE_KEY)
        console.log('⏰ Caché expirado, se limpió')
      }
    }
  } catch (error) {
    console.error('Error al cargar caché:', error)
  }
  return false
}

const limpiarCacheConsulta = () => {
  try {
    sessionStorage.removeItem(CACHE_KEY)
    console.log('🗑️ Caché limpiado')
  } catch (error) {
    console.error('Error al limpiar caché:', error)
  }
}

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const limpiarBusqueda = () => {
  // Limpiar caché
  limpiarCacheConsulta()

  // Resetear filtros
  filtros.value = {
    id_tramite: '',
    id_licencia: '',
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
  }

  // Resetear resultados
  tramites.value = []
  totalResultados.value = 0
  currentPage.value = 1
  primeraBusqueda.value = false

  // Establecer fechas por defecto
  establecerFechasPorDefecto()

  showToast('info', 'Filtros y resultados limpiados')
}

const buscarTramites = async () => {
  // Limpiar localStorage antes de nueva búsqueda
  localStorage.removeItem('tramites_consulta')

  showLoading('Buscando trámites...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false  // Contraer acordeón al buscar

  try {
    // IMPORTANTE: Enviar TODOS los parámetros en orden posicional (14 total)
    const params = [
      // 1. p_id_tramite
      {
        nombre: 'p_id_tramite',
        valor: filtros.value.id_tramite ? parseInt(filtros.value.id_tramite) : null,
        tipo: 'integer'
      },
      // 2. p_id_licencia
      {
        nombre: 'p_id_licencia',
        valor: filtros.value.id_licencia ? parseInt(filtros.value.id_licencia) : null,
        tipo: 'integer'
      },
      // 3. p_tipo_tramite
      {
        nombre: 'p_tipo_tramite',
        valor: filtros.value.tipo_tramite || null,
        tipo: 'string'
      },
      // 4. p_estatus
      {
        nombre: 'p_estatus',
        valor: filtros.value.estatus || null,
        tipo: 'string'
      },
      // 5. p_fecha_desde
      {
        nombre: 'p_fecha_desde',
        valor: filtros.value.fecha_desde || null,
        tipo: 'date'
      },
      // 6. p_fecha_hasta
      {
        nombre: 'p_fecha_hasta',
        valor: filtros.value.fecha_hasta || null,
        tipo: 'date'
      },
      // 7. p_propietario
      {
        nombre: 'p_propietario',
        valor: filtros.value.propietario || null,
        tipo: 'string'
      },
      // 8. p_rfc
      {
        nombre: 'p_rfc',
        valor: filtros.value.rfc || null,
        tipo: 'string'
      },
      // 9. p_id_dependencia
      {
        nombre: 'p_id_dependencia',
        valor: filtros.value.id_dependencia ? parseInt(filtros.value.id_dependencia) : null,
        tipo: 'integer'
      },
      // 10. p_id_giro
      {
        nombre: 'p_id_giro',
        valor: filtros.value.id_giro ? parseInt(filtros.value.id_giro) : null,
        tipo: 'integer'
      },
      // 11. p_calle
      {
        nombre: 'p_calle',
        valor: filtros.value.calle || null,
        tipo: 'string'
      },
      // 12. p_colonia
      {
        nombre: 'p_colonia',
        valor: filtros.value.colonia || null,
        tipo: 'string'
      },
      // 13. p_page
      {
        nombre: 'p_page',
        valor: currentPage.value,
        tipo: 'integer'
      },
      // 14. p_limit
      {
        nombre: 'p_limit',
        valor: itemsPerPage.value,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'consulta_tramites_list',
      'padron_licencias',
      params,
      'padron_licencias',
      null,
      'comun'
    )

    hideLoading()

    if (response && response.result) {
      tramites.value = response.result
      if (tramites.value.length > 0) {
        totalResultados.value = parseInt(tramites.value[0].total_records) || 0
      } else {
        totalResultados.value = 0
      }
      showToast('success', `Se encontraron ${totalResultados.value} trámite(s)`)

      // Guardar en caché después de una búsqueda exitosa
      guardarCacheConsulta()
    } else {
      tramites.value = []
      totalResultados.value = 0
      showToast('info', 'No se encontraron trámites con los filtros especificados')

      // Guardar en caché incluso si no hay resultados
      guardarCacheConsulta()
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    tramites.value = []
    totalResultados.value = 0
  }
}

const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(
      'consulta_tramites_estadisticas',
      'padron_licencias',
      [],
      'guadalajara',
      null,
      'comun'
    )

    if (response && response.result) {
      estadisticas.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar estadísticas:', error)
  } finally {
    loadingEstadisticas.value = false
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

const verHistorial = async (tramite) => {
  const idTramite = tramite?.id_tramite || tramite
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

const modificarTramite = (tramite) => {
  const idTramite = tramite?.id_tramite || tramite
  // Guardar el ID en sessionStorage para pasarlo de forma segura
  sessionStorage.setItem('tramite_a_modificar', idTramite.toString())
  // Navegar sin exponer el ID en la URL
  router.push('/padron-licencias/modificacion-tramites')
}

const verLicencia = (idLicencia) => {
  // Navegar al módulo de consulta de licencias con el ID específico
  router.push({
    path: '/padron-licencias/consulta-licencias',
    query: { id_licencia: idLicencia }
  })
}

const exportarExcel = async () => {
  showLoading('Exportando a Excel...', 'Generando archivo')

  try {
    // TODO: Implementar exportación real
    await new Promise(resolve => setTimeout(resolve, 800))

    hideLoading()

    await Swal.fire({
      title: 'Exportar a Excel',
      text: 'Funcionalidad en desarrollo. Utilizará SP_CONSULTATRAMITE_EXPORTAR',
      icon: 'info',
      confirmButtonColor: '#ea8215'
    })
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const exportarPDF = async () => {
  showLoading('Exportando a PDF...', 'Generando documento')

  try {
    // TODO: Implementar exportación real
    await new Promise(resolve => setTimeout(resolve, 800))

    hideLoading()

    await Swal.fire({
      title: 'Exportar a PDF',
      text: 'Funcionalidad en desarrollo',
      icon: 'info',
      confirmButtonColor: '#ea8215'
    })
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

// Utilidades
const getBadgeClass = (estatus) => {
  const classes = {
    'P': 'badge-warning',
    'E': 'badge-purple',
    'V': 'badge-primary',
    'A': 'badge-success',
    'R': 'badge-danger',
    'C': 'badge-secondary'
  }
  return classes[estatus] || 'badge-purple'
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
    'C': 'ban',
    'T': 'file-alt',
    'N': 'question-circle'
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

const formatNumber = (num) => {
  return new Intl.NumberFormat('es-MX').format(num)
}

// Lifecycle
// Establecer fechas por defecto (últimos 6 meses)
const establecerFechasPorDefecto = () => {
  const hoy = new Date()
  const seisMesesAtras = new Date()
  seisMesesAtras.setMonth(seisMesesAtras.getMonth() - 6)

  // Formatear a YYYY-MM-DD para inputs tipo date
  filtros.value.fecha_hasta = hoy.toISOString().split('T')[0]
  filtros.value.fecha_desde = seisMesesAtras.toISOString().split('T')[0]
}

onMounted(() => {
  // Intentar cargar desde caché primero
  const cacheLoaded = cargarCacheConsulta()

  // Si no hay caché, establecer fechas por defecto
  if (!cacheLoaded) {
    establecerFechasPorDefecto()
  }

  // Siempre cargar estadísticas
  cargarEstadisticas()
})
</script>
