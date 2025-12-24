<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="leaf" />
      </div>
      <div class="module-view-info">
        <h1>Formatos de Ecología</h1>
        <p>Padrón de Licencias - Generación de Formatos Ecológicos para Trámites</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-success"
          @click="generarReporte"
          :disabled="tramites.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          Generar Reporte
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
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Fecha de Captura <span class="required">*</span></label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fecha"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">ID Trámite (Búsqueda Directa)</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.id_tramite"
              placeholder="Buscar por ID específico"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchTramites"
            :disabled="loading || (!filters.fecha && !filters.id_tramite)"
          >
            <font-awesome-icon icon="search" />
            Buscar Trámites
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            v-if="filters.id_tramite"
            class="btn-municipal-info"
            @click="buscarPorId"
            :disabled="loading || !filters.id_tramite"
          >
            <font-awesome-icon icon="search-plus" />
            Buscar por ID
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Trámites Capturados
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="tramites.length > 0">
            {{ formatNumber(tramites.length) }} trámites
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="tramites.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="leaf" size="3x" />
          </div>
          <h4>Formatos de Ecología</h4>
          <p>Seleccione una fecha o ingrese un ID de trámite para buscar</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="tramites.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron trámites con los criterios especificados</p>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID Trámite</th>
                <th>Folio</th>
                <th>Tipo</th>
                <th>Actividad</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Zona/Subzona</th>
                <th>Fecha Captura</th>
                <th>Estatus</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="tramite in paginatedTramites"
                :key="tramite.id_tramite"
                @click="selectedRow = tramite"
                @dblclick="viewTramite(tramite)"
                :class="{ 'table-row-selected': selectedRow === tramite }"
                class="row-hover"
              >
                <td><strong class="text-primary">{{ tramite.id_tramite }}</strong></td>
                <td><code class="text-muted">{{ tramite.folio }}</code></td>
                <td>
                  <span class="badge-secondary">{{ tramite.tipo_tramite || 'N/A' }}</span>
                </td>
                <td>
                  <small>{{ tramite.actividad?.trim() || 'N/A' }}</small>
                </td>
                <td>{{ tramite.propietarionvo?.trim() || tramite.propietario?.trim() || 'N/A' }}</td>
                <td>
                  <small class="text-muted">{{ tramite.domcompleto?.trim() || tramite.ubicacion?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <span class="badge-purple">Z: {{ tramite.zona || tramite.zona_1 || 'N/A' }}</span>
                    <span class="badge-purple">SZ: {{ tramite.subzona || tramite.subzona_1 || 'N/A' }}</span>
                  </div>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(tramite.feccap) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getEstatusBadgeClass(tramite.estatus)">
                    {{ tramite.estatus || 'N/A' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="viewTramite(tramite)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="verCruceCalles(tramite.id_tramite)"
                      title="Ver cruce de calles"
                    >
                      <font-awesome-icon icon="road" />
                    </button>
                    <button
                      class="btn-municipal-success btn-sm"
                      @click.stop="generarFormato(tramite)"
                      title="Generar formato"
                    >
                      <font-awesome-icon icon="file-alt" />
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Controles de Paginación -->
        <div v-if="tramites.length > 0" class="pagination-controls">
          <div class="pagination-info">
            <span class="text-muted">
              Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
              a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
              de {{ formatNumber(totalRecords) }} registros
            </span>
          </div>

          <div class="pagination-size">
            <label class="municipal-form-label me-2">Registros por página:</label>
            <select
              class="municipal-form-control form-control-sm"
              :value="itemsPerPage"
              @change="changePageSize($event.target.value)"
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

    <!-- Modal de visualización de trámite -->
    <Modal
      :show="showViewModal"
      :title="`Detalle del Trámite ${selectedTramite?.id_tramite}`"
      size="xl"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedTramite" class="user-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="file-alt" />
              Información del Trámite
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">ID Trámite:</td>
                <td><code>{{ selectedTramite.id_tramite }}</code></td>
              </tr>
              <tr>
                <td class="label">Folio:</td>
                <td>{{ selectedTramite.folio }}</td>
              </tr>
              <tr>
                <td class="label">Tipo Trámite:</td>
                <td>{{ selectedTramite.tipo_tramite || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Actividad:</td>
                <td>{{ selectedTramite.actividad?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Giro:</td>
                <td>{{ selectedTramite.id_giro || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Estatus:</td>
                <td>
                  <span class="badge" :class="getEstatusBadgeClass(selectedTramite.estatus)">
                    {{ selectedTramite.estatus || 'N/A' }}
                  </span>
                </td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Datos del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Nombre:</td>
                <td><strong>{{ selectedTramite.propietarionvo?.trim() || selectedTramite.propietario?.trim() || 'N/A' }}</strong></td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td>{{ selectedTramite.rfc?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CURP:</td>
                <td>{{ selectedTramite.curp?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Teléfono:</td>
                <td>
                  <font-awesome-icon icon="phone" class="text-info" />
                  {{ selectedTramite.telefono_prop?.trim() || 'N/A' }}
                </td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ selectedTramite.email?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label" colspan="2">Domicilio Completo:</td>
              </tr>
              <tr>
                <td colspan="2">
                  <div class="observaciones-box">
                    {{ selectedTramite.domcompleto?.trim() || selectedTramite.ubicacion?.trim() || 'N/A' }}
                  </div>
                </td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedTramite.colonia_ubic?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">CP:</td>
                <td>{{ selectedTramite.cp || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Zona:</td>
                <td><span class="badge-secondary">{{ selectedTramite.zona || selectedTramite.zona_1 || 'N/A' }}</span></td>
              </tr>
              <tr>
                <td class="label">Subzona:</td>
                <td><span class="badge-secondary">{{ selectedTramite.subzona || selectedTramite.subzona_1 || 'N/A' }}</span></td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="tools" />
              Datos Técnicos
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Sup. Construida:</td>
                <td>{{ selectedTramite.sup_construida || 'N/A' }} m²</td>
              </tr>
              <tr>
                <td class="label">Sup. Autorizada:</td>
                <td>{{ selectedTramite.sup_autorizada || 'N/A' }} m²</td>
              </tr>
              <tr>
                <td class="label">Num. Cajones:</td>
                <td>{{ selectedTramite.num_cajones || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Num. Empleados:</td>
                <td>{{ selectedTramite.num_empleados || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Aforo:</td>
                <td>{{ selectedTramite.aforo || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Inversión:</td>
                <td>{{ formatCurrency(selectedTramite.inversion) }}</td>
              </tr>
              <tr>
                <td class="label">Fecha Captura:</td>
                <td>
                  <font-awesome-icon icon="calendar-plus" class="text-success" />
                  {{ formatDate(selectedTramite.feccap) }}
                </td>
              </tr>
              <tr>
                <td class="label">Capturista:</td>
                <td>{{ selectedTramite.capturista?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="verCruceCalles(selectedTramite.id_tramite)">
            <font-awesome-icon icon="road" />
            Ver Cruce de Calles
          </button>
          <button class="btn-municipal-success" @click="generarFormato(selectedTramite)">
            <font-awesome-icon icon="file-alt" />
            Generar Formato
          </button>
        </div>
      </div>
    </Modal>

    <!-- Modal de cruce de calles -->
    <Modal
      :show="showCruceModal"
      :title="`Cruce de Calles - Trámite ${selectedIdTramite}`"
      size="lg"
      @close="showCruceModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="cruceCalles.length > 0">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Calle 1</th>
                <th>Calle 2</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(cruce, index) in cruceCalles" :key="index">
                <td>{{ cruce.calle }}</td>
                <td>{{ cruce.calle_1 }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else class="text-center text-muted py-4">
        <font-awesome-icon icon="road" size="2x" class="empty-icon" />
        <p>No hay cruces de calles registrados para este trámite</p>
      </div>
      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="showCruceModal = false">
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

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'formatosEcologiafrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Formatos de Ecología'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

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

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const tramites = ref([])
const selectedTramite = ref(null)
const selectedRow = ref(null)
const selectedIdTramite = ref(null)
const cruceCalles = ref([])
const showViewModal = ref(false)
const showCruceModal = ref(false)
const hasSearched = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => tramites.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedTramites = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return tramites.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)
  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }
  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }
  return pages
})

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedRow.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedRow.value = null
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Filtros
const filters = ref({
  fecha: '',
  id_tramite: null
})

// Métodos
const loadTramitesByFecha = async () => {
  if (!filters.value.fecha) {
    showToast('warning', 'Por favor seleccione una fecha')
    return
  }

  showLoading('Cargando trámites...', 'Consultando base de datos')
  hasSearched.value = true
  currentPage.value = 1
  selectedRow.value = null

  try {
    const startTime = performance.now()
    const response = await execute(
      'sp_get_tramites_by_fecha',
      'padron_licencias',
      [
        { nombre: 'p_fecha', valor: filters.value.fecha, tipo: 'string' }
      ],
      'guadalajara'
    )
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      tramites.value = response.result
      toast.value.duration = durationText
      showToast('success', `Se encontraron ${tramites.value.length} trámites`)
    } else {
      tramites.value = []
      showToast('info', 'No se encontraron trámites para la fecha seleccionada')
    }
  } catch (error) {
    handleApiError(error)
    tramites.value = []
  } finally {
    hideLoading()
  }
}

const loadTramiteById = async () => {
  if (!filters.value.id_tramite) {
    showToast('warning', 'Por favor ingrese un ID de trámite')
    return
  }

  showLoading('Buscando trámite...', 'Consultando base de datos')
  hasSearched.value = true
  currentPage.value = 1
  selectedRow.value = null

  try {
    const startTime = performance.now()
    const response = await execute(
      'sp_get_tramite_by_id',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(filters.value.id_tramite), tipo: 'integer' }
      ],
      'guadalajara'
    )
    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      tramites.value = response.result
      toast.value.duration = durationText
      showToast('success', 'Trámite encontrado')
    } else {
      tramites.value = []
      showToast('warning', 'No se encontró el trámite con ese ID')
    }
  } catch (error) {
    handleApiError(error)
    tramites.value = []
  } finally {
    hideLoading()
  }
}

const searchTramites = () => {
  if (filters.value.id_tramite) {
    loadTramiteById()
  } else if (filters.value.fecha) {
    loadTramitesByFecha()
  } else {
    showToast('warning', 'Por favor seleccione una fecha o ingrese un ID de trámite')
  }
}

const buscarPorId = () => {
  loadTramiteById()
}

const clearFilters = () => {
  filters.value = {
    fecha: '',
    id_tramite: null
  }
  tramites.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

const viewTramite = (tramite) => {
  selectedTramite.value = tramite
  showViewModal.value = true
}

const verCruceCalles = async (id_tramite) => {
  selectedIdTramite.value = id_tramite
  showLoading('Cargando cruce de calles...', 'Por favor espere')

  try {
    const response = await execute(
      'sp_get_cruce_calles_by_tramite',
      'padron_licencias',
      [
        { nombre: 'p_id_tramite', valor: parseInt(id_tramite), tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      cruceCalles.value = response.result
      showCruceModal.value = true
    } else {
      cruceCalles.value = []
      showCruceModal.value = true
    }
  } catch (error) {
    handleApiError(error)
    cruceCalles.value = []
  } finally {
    hideLoading()
  }
}

const generarFormato = async (tramite) => {
  await Swal.fire({
    icon: 'info',
    title: 'Generar Formato de Ecología',
    html: `
      <div class="swal-confirmation-text">
        <p><strong>Trámite:</strong> ${tramite.id_tramite}</p>
        <p><strong>Propietario:</strong> ${tramite.propietarionvo || tramite.propietario}</p>
        <p><strong>Actividad:</strong> ${tramite.actividad}</p>
        <p style="margin-top: 15px;">La funcionalidad de generación de formato está en desarrollo.</p>
      </div>
    `,
    confirmButtonColor: '#ea8215'
  })
}

const generarReporte = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Generar Reporte',
    text: `Se generará un reporte con ${tramites.value.length} trámites. Funcionalidad en desarrollo.`,
    confirmButtonColor: '#ea8215'
  })
}

// Utilidades
const getEstatusBadgeClass = (estatus) => {
  const classes = {
    'T': 'badge-warning',
    'A': 'badge-success',
    'R': 'badge-danger',
    'P': 'badge-purple'
  }
  return classes[estatus] || 'badge-secondary'
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

const formatCurrency = (value) => {
  if (!value) return 'N/A'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return value
  }
}

// Lifecycle
onMounted(() => {
  // Establecer fecha actual por defecto
  const today = new Date()
  filters.value.fecha = today.toISOString().split('T')[0]
})

onBeforeUnmount(() => {
  showViewModal.value = false
  showCruceModal.value = false
})
</script>
