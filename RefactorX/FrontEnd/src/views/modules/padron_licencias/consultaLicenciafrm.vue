<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="id-card" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Licencias</h1>
        <p>Padrón de Licencias - Búsqueda avanzada y consulta de licencias comerciales</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-success"
          @click="nuevaLicencia"
        >
          <font-awesome-icon icon="plus-circle" />
          Nueva Licencia
        </button>
        <button
          v-if="licencias.length > 0"
          class="btn-municipal-success"
          @click="exportarExcel"
        >
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button
          v-if="licencias.length > 0"
          class="btn-municipal-danger"
          @click="exportarPDF"
        >
          <font-awesome-icon icon="file-pdf" />
          PDF
        </button>
        <button
          class="btn-municipal-primary"
          @click="buscarLicencias"
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

    <!-- Loading skeleton para estadísticas -->
    <div class="stats-grid" v-if="loadingEstadisticas">
      <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
        <div class="stat-content">
          <div class="skeleton-icon"></div>
          <div class="skeleton-number"></div>
          <div class="skeleton-label"></div>
          <div class="skeleton-percentage"></div>
        </div>
      </div>
    </div>

    <!-- Cards de estadísticas -->
    <div class="stats-grid" v-else-if="estadisticas.length > 0">
      <div
        class="stat-card"
        v-for="stat in estadisticas"
        :key="stat.vigente"
        :class="`stat-${stat.vigente}`"
      >
        <div class="stat-content">
          <div class="stat-icon">
            <font-awesome-icon :icon="getVigenteIcon(stat.vigente)" />
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
            <label class="municipal-form-label">ID Licencia</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filtros.id_licencia"
              placeholder="Número de ID"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Número de Licencia</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filtros.licencia"
              placeholder="Número de licencia"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigente</label>
            <select class="municipal-form-control" v-model="filtros.vigente">
              <option value="">Todas</option>
              <option value="V">Vigente</option>
              <option value="C">Cancelado</option>
              <option value="A">Alta</option>
              <option value="B">Baja</option>
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
            <label class="municipal-form-label">Actividad</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filtros.actividad"
              placeholder="Actividad comercial"
            />
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Ubicación</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filtros.ubicacion"
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
        </div>

        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarLicencias"
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
                <th>Vigente</th>
                <th>Propietario</th>
                <th>RFC</th>
                <th>Giro</th>
                <th>Actividad</th>
                <th>Ubicación</th>
                <th>Empleados</th>
                <th>Fecha Otorg.</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-if="licencias.length === 0 && !primeraBusqueda">
                <td colspan="11" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>Utiliza los filtros de búsqueda para encontrar licencias</p>
                </td>
              </tr>
              <tr v-else-if="licencias.length === 0">
                <td colspan="11" class="text-center text-muted">
                  <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                  <p>No se encontraron licencias con los filtros especificados</p>
                </td>
              </tr>
              <tr
                v-else
                v-for="lic in licencias"
                :key="lic.id_licencia"
                @click="licenciaSeleccionada = lic"
                @dblclick="verDetalle(lic)"
                :class="{ 'row-hover': true, 'selected-row': licenciaSeleccionada?.id_licencia === lic.id_licencia }"
                style="cursor: pointer;"
              >
                <td><strong class="text-primary">{{ lic.id_licencia }}</strong></td>
                <td>{{ lic.licencia }}</td>
                <td>
                  <span class="badge" :class="getBadgeClass(lic.vigente)">
                    <font-awesome-icon :icon="getVigenteIcon(lic.vigente)" />
                    {{ getVigenteTexto(lic.vigente) }}
                  </span>
                </td>
                <td>{{ lic.propietario }}</td>
                <td><code class="text-muted">{{ lic.rfc || 'Sin RFC' }}</code></td>
                <td>
                  <small>{{ lic.descripcion_giro || 'N/A' }}</small>
                </td>
                <td>
                  <small>{{ lic.actividad || 'N/A' }}</small>
                </td>
                <td>
                  <small>
                    {{ lic.ubicacion }} {{ lic.numext_ubic }}<br>
                    {{ lic.colonia_ubic }}
                  </small>
                </td>
                <td>{{ lic.num_empleados || 'N/A' }}</td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(lic.fecha_otorgamiento) }}
                  </small>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click.stop="verDetalle(lic)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click.stop="verHistorial(lic)"
                      title="Ver historial"
                    >
                      <font-awesome-icon icon="history" />
                    </button>
                    <button
                      v-if="lic.vigente === 'V'"
                      class="btn-municipal-secondary btn-sm"
                      @click.stop="modificarLicencia(lic)"
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
      <div v-if="licencias.length > 0" class="pagination-controls">
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
  </div>

  <!-- Modal de Detalle -->
  <Modal
    :show="showDetalleModal"
    :title="`Detalle de la Licencia #${licenciaSeleccionada.id_licencia || ''}`"
    size="xl"
    @close="closeDetalleModal"
    :showDefaultFooter="false"
  >
    <div v-if="licenciaSeleccionada.id_licencia" class="licencia-details">
      <div class="details-grid">
        <!-- Información General -->
        <div class="detail-section">
          <h6 class="section-title">
            <font-awesome-icon icon="info-circle" />
            Información General
          </h6>
          <table class="detail-table">
            <tr>
              <td class="label">Número de Licencia:</td>
              <td><strong>{{ licenciaSeleccionada.licencia }}</strong></td>
            </tr>
            <tr>
              <td class="label">Estatus:</td>
              <td>
                <span class="badge" :class="getBadgeClass(licenciaSeleccionada.vigente)">
                  <font-awesome-icon :icon="getVigenteIcon(licenciaSeleccionada.vigente)" />
                  {{ getVigenteTexto(licenciaSeleccionada.vigente) }}
                </span>
              </td>
            </tr>
            <tr>
              <td class="label">Fecha Otorgamiento:</td>
              <td>
                <font-awesome-icon icon="calendar-plus" class="text-success" />
                {{ formatDate(licenciaSeleccionada.fecha_otorgamiento) }}
              </td>
            </tr>
            <tr v-if="licenciaSeleccionada.fecha_baja">
              <td class="label">Fecha Baja:</td>
              <td>
                <font-awesome-icon icon="calendar-times" class="text-danger" />
                {{ formatDate(licenciaSeleccionada.fecha_baja) }}
              </td>
            </tr>
            <tr>
              <td class="label">Bloqueado:</td>
              <td>
                <span :class="licenciaSeleccionada.bloqueado > 0 ? 'text-danger' : 'text-success'">
                  {{ licenciaSeleccionada.bloqueado > 0 ? 'Sí' : 'No' }}
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
              <td>{{ licenciaSeleccionada.propietario }} {{ licenciaSeleccionada.primer_ap }} {{ licenciaSeleccionada.segundo_ap }}</td>
            </tr>
            <tr>
              <td class="label">RFC:</td>
              <td><code>{{ licenciaSeleccionada.rfc || 'Sin RFC' }}</code></td>
            </tr>
            <tr>
              <td class="label">CURP:</td>
              <td><code>{{ licenciaSeleccionada.curp || 'Sin CURP' }}</code></td>
            </tr>
            <tr>
              <td class="label">Teléfono:</td>
              <td>{{ licenciaSeleccionada.telefono_prop || 'Sin teléfono' }}</td>
            </tr>
            <tr>
              <td class="label">Email:</td>
              <td>{{ licenciaSeleccionada.email || 'Sin email' }}</td>
            </tr>
          </table>
        </div>
      </div>

      <!-- Domicilio del Propietario -->
      <div class="detail-section full-width">
        <h6 class="section-title">
          <font-awesome-icon icon="home" />
          Domicilio del Propietario
        </h6>
        <p>
          <strong>Dirección:</strong><br>
          {{ licenciaSeleccionada.domicilio }} {{ licenciaSeleccionada.numext_prop }}
          {{ licenciaSeleccionada.numint_prop ? ', Int. ' + licenciaSeleccionada.numint_prop : '' }}<br>
          {{ licenciaSeleccionada.colonia_prop }}
        </p>
      </div>

      <!-- Ubicación del Negocio -->
      <div class="detail-section full-width">
        <h6 class="section-title">
          <font-awesome-icon icon="map-marker-alt" />
          Ubicación del Negocio
        </h6>
        <p>
          <strong>Dirección:</strong><br>
          {{ licenciaSeleccionada.ubicacion }} {{ licenciaSeleccionada.numext_ubic }}
          {{ licenciaSeleccionada.numint_ubic ? ', Int. ' + licenciaSeleccionada.numint_ubic : '' }}<br>
          {{ licenciaSeleccionada.colonia_ubic }}
        </p>
      </div>

      <!-- Giro y Actividad -->
      <div class="detail-section full-width">
        <h6 class="section-title">
          <font-awesome-icon icon="briefcase" />
          Giro y Actividad
        </h6>
        <p><strong>Giro:</strong> {{ licenciaSeleccionada.descripcion_giro }}</p>
        <p><strong>Actividad:</strong> {{ licenciaSeleccionada.actividad }}</p>
      </div>

      <!-- Información Técnica -->
      <div class="detail-section full-width">
        <h6 class="section-title">
          <font-awesome-icon icon="chart-bar" />
          Información Técnica
        </h6>
        <div class="row">
          <div class="col-md-3">
            <p><strong>Sup. Construida:</strong><br>{{ licenciaSeleccionada.sup_construida || 'N/A' }} m²</p>
          </div>
          <div class="col-md-3">
            <p><strong>Sup. Autorizada:</strong><br>{{ licenciaSeleccionada.sup_autorizada || 'N/A' }} m²</p>
          </div>
          <div class="col-md-3">
            <p><strong>Empleados:</strong><br>{{ licenciaSeleccionada.num_empleados || 'N/A' }}</p>
          </div>
          <div class="col-md-3">
            <p><strong>Aforo:</strong><br>{{ licenciaSeleccionada.aforo || 'N/A' }}</p>
          </div>
        </div>
        <p v-if="licenciaSeleccionada.inversion"><strong>Inversión:</strong> ${{ formatNumber(licenciaSeleccionada.inversion) }}</p>
        <p v-if="licenciaSeleccionada.rhorario"><strong>Horario:</strong> {{ licenciaSeleccionada.rhorario }}</p>
      </div>

      <div class="modal-actions">
        <button class="btn-municipal-secondary" @click="closeDetalleModal">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
        <button
          v-if="licenciaSeleccionada.vigente === 'V'"
          class="btn-municipal-primary"
          @click="modificarLicencia(licenciaSeleccionada); closeDetalleModal()"
        >
          <font-awesome-icon icon="edit" />
          Modificar Licencia
        </button>
      </div>
    </div>
  </Modal>

  <!-- Modal de Historial -->
  <Modal
    :show="showHistorialModal"
    :title="`Historial Completo - Licencia #${historialLicenciaId || ''}`"
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
        <small>Este modal mostrará: historial de movimientos, pagos, adeudos y bloqueos.</small>
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

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'consultaLicenciafrm'"
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

// Estado
const showFilters = ref(false)
const licencias = ref([])
const estadisticas = ref([])
const totalResultados = ref(0)
const currentPage = ref(1)
const itemsPerPage = ref(20)
const primeraBusqueda = ref(false)
const showDetalleModal = ref(false)
const showHistorialModal = ref(false)
const licenciaSeleccionada = ref({})
const historialLicenciaId = ref(null)
const loadingHistorial = ref(false)
const loadingEstadisticas = ref(true)

// Filtros
const filtros = ref({
  id_licencia: '',
  licencia: '',
  vigente: '',
  fecha_desde: '',
  fecha_hasta: '',
  propietario: '',
  rfc: '',
  id_giro: '',
  actividad: '',
  ubicacion: '',
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

// Funciones de formato
const formatNumber = (num) => {
  if (!num) return '0'
  return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

const getVigenteIcon = (vigente) => {
  const icons = {
    'V': 'check-circle',
    'C': 'times-circle',
    'A': 'arrow-up',
    'B': 'arrow-down'
  }
  return icons[vigente] || 'circle'
}

const getVigenteTexto = (vigente) => {
  const textos = {
    'V': 'Vigente',
    'C': 'Cancelado',
    'A': 'Alta',
    'B': 'Baja'
  }
  return textos[vigente] || vigente
}

const getBadgeClass = (vigente) => {
  const classes = {
    'V': 'badge-success',
    'C': 'badge-danger',
    'A': 'badge-purple',
    'B': 'badge-warning'
  }
  return classes[vigente] || 'badge-purple'
}

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Funciones principales
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(
      'consulta_licencias_estadisticas',
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

const buscarLicencias = async () => {
  // Limpiar localStorage antes de nueva búsqueda
  localStorage.removeItem('licencias_consulta')

  showLoading('Buscando licencias...', 'Consultando base de datos')
  primeraBusqueda.value = true
  showFilters.value = false  // Contraer acordeón al buscar

  try {
    // IMPORTANTE: Enviar TODOS los parámetros en orden posicional (13 total)
    const params = [
      // 1. p_id_licencia
      {
        nombre: 'p_id_licencia',
        valor: filtros.value.id_licencia ? parseInt(filtros.value.id_licencia) : null,
        tipo: 'integer'
      },
      // 2. p_licencia
      {
        nombre: 'p_licencia',
        valor: filtros.value.licencia ? parseInt(filtros.value.licencia) : null,
        tipo: 'integer'
      },
      // 3. p_vigente
      {
        nombre: 'p_vigente',
        valor: filtros.value.vigente || null,
        tipo: 'string'
      },
      // 4. p_fecha_desde
      {
        nombre: 'p_fecha_desde',
        valor: filtros.value.fecha_desde || null,
        tipo: 'date'
      },
      // 5. p_fecha_hasta
      {
        nombre: 'p_fecha_hasta',
        valor: filtros.value.fecha_hasta || null,
        tipo: 'date'
      },
      // 6. p_propietario
      {
        nombre: 'p_propietario',
        valor: filtros.value.propietario || null,
        tipo: 'string'
      },
      // 7. p_rfc
      {
        nombre: 'p_rfc',
        valor: filtros.value.rfc || null,
        tipo: 'string'
      },
      // 8. p_id_giro
      {
        nombre: 'p_id_giro',
        valor: filtros.value.id_giro ? parseInt(filtros.value.id_giro) : null,
        tipo: 'integer'
      },
      // 9. p_actividad
      {
        nombre: 'p_actividad',
        valor: filtros.value.actividad || null,
        tipo: 'string'
      },
      // 10. p_ubicacion
      {
        nombre: 'p_ubicacion',
        valor: filtros.value.ubicacion || null,
        tipo: 'string'
      },
      // 11. p_colonia
      {
        nombre: 'p_colonia',
        valor: filtros.value.colonia || null,
        tipo: 'string'
      },
      // 12. p_page
      {
        nombre: 'p_page',
        valor: currentPage.value,
        tipo: 'integer'
      },
      // 13. p_limit
      {
        nombre: 'p_limit',
        valor: itemsPerPage.value,
        tipo: 'integer'
      }
    ]

    const response = await execute(
      'consulta_licencias_list',
      'padron_licencias',
      params,
      'guadalajara',
      null,
      'comun'
    )

    hideLoading()

    if (response && response.result) {
      licencias.value = response.result
      if (licencias.value.length > 0) {
        totalResultados.value = parseInt(licencias.value[0].total_registros) || 0
      } else {
        totalResultados.value = 0
      }

      // Guardar resultados en localStorage
      localStorage.setItem('licencias_consulta', JSON.stringify(licencias.value))

      showToast('success', `Se encontraron ${totalResultados.value} licencia(s)`)
    } else {
      licencias.value = []
      totalResultados.value = 0
      showToast('info', 'No se encontraron licencias con los filtros especificados')
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    licencias.value = []
    totalResultados.value = 0
  }
}

const limpiarFiltros = () => {
  Object.keys(filtros.value).forEach(key => {
    filtros.value[key] = ''
  })
  licencias.value = []
  totalResultados.value = 0
  currentPage.value = 1
  primeraBusqueda.value = false
  establecerFechasPorDefecto()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    buscarLicencias()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  buscarLicencias()
}

const verDetalle = (licencia) => {
  licenciaSeleccionada.value = licencia
  showDetalleModal.value = true
}

const closeDetalleModal = () => {
  showDetalleModal.value = false
  licenciaSeleccionada.value = {}
}

const nuevaLicencia = () => {
  router.push('/padron-licencias/registro-solicitud')
}

const verHistorial = async (licencia) => {
  const idLicencia = licencia?.id_licencia || licencia
  historialLicenciaId.value = idLicencia
  showHistorialModal.value = true
  loadingHistorial.value = true

  setTimeout(() => {
    loadingHistorial.value = false
  }, 1000)
}

const closeHistorialModal = () => {
  showHistorialModal.value = false
  historialLicenciaId.value = null
}

const modificarLicencia = (licencia) => {
  const numeroLicencia = licencia?.licencia || licencia
  // Guardar el NÚMERO de licencia en sessionStorage para pasarlo de forma segura
  sessionStorage.setItem('licencia_a_modificar', numeroLicencia.toString())
  // Navegar sin exponer el número en la URL
  router.push('/padron-licencias/modificacion-licencias')
}

const establecerFechasPorDefecto = () => {
  const hoy = new Date()
  const seisMesesAtras = new Date()
  seisMesesAtras.setMonth(seisMesesAtras.getMonth() - 6)

  filtros.value.fecha_hasta = hoy.toISOString().split('T')[0]
  filtros.value.fecha_desde = seisMesesAtras.toISOString().split('T')[0]
}

const exportarExcel = async () => {
  showLoading('Exportando a Excel...', 'Generando archivo')

  try {
    // TODO: Implementar exportación real
    await new Promise(resolve => setTimeout(resolve, 800))

    hideLoading()

    await Swal.fire({
      title: 'Exportar a Excel',
      text: 'Funcionalidad en desarrollo. Utilizará SP_CONSULTALICENCIAS_EXPORTAR',
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

// Lifecycle
onMounted(async () => {
  establecerFechasPorDefecto()
  await cargarEstadisticas()

  // Cargar resultados guardados desde localStorage si existen
  const licenciasGuardadas = localStorage.getItem('licencias_consulta')
  if (licenciasGuardadas) {
    try {
      licencias.value = JSON.parse(licenciasGuardadas)
      if (licencias.value.length > 0) {
        totalResultados.value = parseInt(licencias.value[0].total_registros) || licencias.value.length
        primeraBusqueda.value = true
      }
    } catch (error) {
      console.error('Error al cargar licencias desde localStorage:', error)
      localStorage.removeItem('licencias_consulta')
    }
  }
})
</script>

<style scoped>
/* Los estilos están en municipal-theme.css */
/* Personalización específica de estadísticas para 4 columnas */
.stats-grid {
  grid-template-columns: repeat(4, 1fr) !important;
}

@media (max-width: 1200px) {
  .stats-grid {
    grid-template-columns: repeat(2, 1fr) !important;
  }
}

@media (max-width: 768px) {
  .stats-grid {
    grid-template-columns: repeat(1, 1fr) !important;
  }
}
</style>
