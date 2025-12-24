<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Giros Vigentes por Contribuyente</h1>
        <p>Padrón de Licencias - Reporte de Licencias Activas por Giro</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-warning"
          @click="router.push({ name: 'ConsultaLicenciafrm' })"
          title="Regresar a Consulta de Licencias"
        >
          <font-awesome-icon icon="arrow-left" />
          Regresar
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

    <!-- Filtros de búsqueda (Collapsible) -->
    <div class="municipal-card">
      <div
        class="accordion-header"
        :class="{ 'collapsed': !filtersPanelExpanded }"
        @click="filtersPanelExpanded = !filtersPanelExpanded"
      >
        <h5 class="municipal-card-title">
          <font-awesome-icon icon="filter" />
          Filtros de Búsqueda
        </h5>
        <font-awesome-icon :icon="filtersPanelExpanded ? 'chevron-up' : 'chevron-down'" />
      </div>
      <div v-show="filtersPanelExpanded" class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Giro (Categoría)</label>
            <select class="municipal-form-control" v-model="filters.giro">
              <option value="">Todos los giros</option>
              <option v-for="giro in catalogoGiros" :key="giro.clave" :value="giro.clave">
                {{ giro.nombre }}
              </option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Zona</label>
            <select class="municipal-form-control" v-model="filters.zona">
              <option value="">Todas las zonas</option>
              <option value="1">Zona 1 - Centro</option>
              <option value="2">Zona 2 - Norte</option>
              <option value="3">Zona 3 - Sur</option>
              <option value="4">Zona 4 - Este</option>
              <option value="5">Zona 5 - Oeste</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Inicio</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaInicio"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Fecha Fin</label>
            <input
              type="date"
              class="municipal-form-control"
              v-model="filters.fechaFin"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchLicencias"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="clearFilters"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="loadLicencias"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
          <button
            class="btn-municipal-primary"
            @click="exportToExcel"
            :disabled="licencias.length === 0"
          >
            <font-awesome-icon icon="file-excel" />
            Exportar Excel
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="list" />
          Licencias Vigentes
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="licencias.length > 0">
            {{ formatNumber(licencias.length) }} licencias
          </span>
        </div>
      </div>

      <div class="municipal-card-body table-container">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="licencias.length === 0 && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="chart-line" size="3x" />
          </div>
          <h4>Licencias Vigentes por Giro</h4>
          <p>Utilice los filtros o presione Buscar para cargar las licencias</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="licencias.length === 0 && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontraron licencias con los criterios especificados</p>
        </div>

        <!-- Tabla con datos -->
        <div v-else class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Licencia</th>
                <th>Contribuyente</th>
                <th>Giro</th>
                <th>Domicilio</th>
                <th>Zona</th>
                <th>Fecha Expedición</th>
                <th>Vigencia</th>
                <th>Estatus</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="lic in paginatedLicencias"
                :key="lic.numero_licencia"
                @click="selectedRow = lic"
                :class="{ 'table-row-selected': selectedRow === lic }"
                class="row-hover"
              >
                <td><strong class="text-primary">{{ lic.numero_licencia?.trim() }}</strong></td>
                <td>{{ lic.contribuyente?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge-purple">
                    {{ lic.giro?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">{{ lic.domicilio?.trim() || 'N/A' }}</small>
                </td>
                <td>
                  <span class="badge-secondary">
                    Zona {{ lic.zona || 'N/A' }}
                  </span>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDate(lic.fecha_expedicion) }}
                  </small>
                </td>
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar-check" />
                    {{ formatDate(lic.fecha_vigencia) }}
                  </small>
                </td>
                <td>
                  <span class="badge" :class="getStatusBadgeClass(lic.estatus)">
                    <font-awesome-icon :icon="getStatusIcon(lic.estatus)" />
                    {{ lic.estatus?.trim() || 'Vigente' }}
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Controles de Paginación -->
        <div v-if="licencias.length > 0" class="pagination-controls">
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

    <!-- Resumen estadístico -->
    <div class="municipal-card" v-if="licencias.length > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="chart-bar" />
          Resumen Estadístico
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-icon">
              <font-awesome-icon icon="file-alt" />
            </div>
            <div class="stat-info">
              <span class="stat-label">Total Licencias</span>
              <span class="stat-value">{{ totalRecords }}</span>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">
              <font-awesome-icon icon="check-circle" />
            </div>
            <div class="stat-info">
              <span class="stat-label">Licencias Vigentes</span>
              <span class="stat-value">{{ licenciasVigentes }}</span>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">
              <font-awesome-icon icon="building" />
            </div>
            <div class="stat-info">
              <span class="stat-label">Giros Diferentes</span>
              <span class="stat-value">{{ girosDiferentes }}</span>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon">
              <font-awesome-icon icon="map-marker-alt" />
            </div>
            <div class="stat-info">
              <span class="stat-label">Zonas Cubiertas</span>
              <span class="stat-value">{{ zonasCubiertas }}</span>
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
      :componentName="'girosVigentesCteXgirofrm'"
      :moduleName="'padron_licencias'"
      :docType="docType"
      :title="'Giros Vigentes por Contribuyente'"
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
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

const router = useRouter()

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
const licencias = ref([])
const catalogoGiros = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)
const filtersPanelExpanded = ref(true)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => licencias.value.length)
const totalPages = computed(() => Math.ceil(totalRecords.value / itemsPerPage.value))

const paginatedLicencias = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return licencias.value.slice(start, end)
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

// Filtros
const filters = ref({
  giro: '',
  zona: '',
  fechaInicio: '',
  fechaFin: ''
})

const licenciasVigentes = computed(() => {
  return licencias.value.filter(lic => lic.estatus === 'Vigente').length
})

const girosDiferentes = computed(() => {
  const giros = new Set(licencias.value.map(lic => lic.giro))
  return giros.size
})

const zonasCubiertas = computed(() => {
  const zonas = new Set(licencias.value.map(lic => lic.zona).filter(z => z))
  return zonas.size
})

// Métodos
const loadCatalogoGiros = async () => {
  try {
    const response = await execute(
      'girosVigentesCteXgirofrm_sp_get_catalogo_giros',
      'padron_licencias',
      [],
      'guadalajara'
    )

    if (response && response.result) {
      catalogoGiros.value = response.result
    } else {
      catalogoGiros.value = []
    }
  } catch (error) {
    handleApiError(error)
    catalogoGiros.value = []
  }
}

const loadLicencias = async () => {
  showLoading('Cargando licencias vigentes...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null

  const startTime = performance.now()

  try {
    const response = await execute(
      'girosVigentesCteXgirofrm_sp_giros_vigentes_cte_x_giro',
      'padron_licencias',
      [
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' },
        { nombre: 'p_giro', valor: filters.value.giro || null, tipo: 'string' },
        { nombre: 'p_zona', valor: filters.value.zona || null, tipo: 'string' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1 ? `${((endTime - startTime)).toFixed(0)}ms` : `${duration}s`

    if (response && response.result) {
      licencias.value = response.result
      if (licencias.value.length > 0) {
        toast.value.duration = durationText
        showToast('success', `Se encontraron ${licencias.value.length} licencias`)
      } else {
        showToast('info', 'No se encontraron licencias')
      }
    } else {
      licencias.value = []
      showToast('error', 'Error al cargar licencias')
    }
  } catch (error) {
    handleApiError(error)
    licencias.value = []
  } finally {
    hideLoading()
  }
}

const searchLicencias = () => {
  currentPage.value = 1
  selectedRow.value = null
  loadLicencias()
}

const clearFilters = () => {
  filters.value = {
    giro: '',
    zona: '',
    fechaInicio: '',
    fechaFin: ''
  }
  licencias.value = []
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
}

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

const exportToExcel = async () => {
  showLoading('Generando archivo Excel...', 'Por favor espere')

  try {
    await Swal.fire({
      icon: 'info',
      title: 'Exportando a Excel',
      text: 'La funcionalidad de exportación se implementará próximamente',
      confirmButtonColor: '#ea8215',
      timer: 2000
    })

    showToast('info', 'Exportación a Excel en desarrollo')
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

const generatePDF = async () => {
  showLoading('Generando reporte PDF...', 'Por favor espere')

  try {
    const response = await execute(
      'girosVigentesCteXgirofrm_sp_reporte_giros_vigentes_cte_xgiro',
      'padron_licencias',
      [
        { nombre: 'p_giro', valor: filters.value.giro || null, tipo: 'string' },
        { nombre: 'p_zona', valor: filters.value.zona || null, tipo: 'string' },
        { nombre: 'p_fecha_inicio', valor: filters.value.fechaInicio || null, tipo: 'date' },
        { nombre: 'p_fecha_fin', valor: filters.value.fechaFin || null, tipo: 'date' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: 'Reporte generado',
        text: 'El reporte PDF ha sido generado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      showToast('success', 'Reporte PDF generado exitosamente')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al generar reporte',
        text: 'No se pudo generar el reporte PDF',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    hideLoading()
  }
}

// Utilidades
const getStatusBadgeClass = (estatus) => {
  const classes = {
    'Vigente': 'badge-success',
    'Por Vencer': 'badge-warning',
    'Vencida': 'badge-danger',
    'Suspendida': 'badge-secondary'
  }
  return classes[estatus] || 'badge-secondary'
}

const getStatusIcon = (estatus) => {
  const icons = {
    'Vigente': 'check-circle',
    'Por Vencer': 'exclamation-triangle',
    'Vencida': 'times-circle',
    'Suspendida': 'ban'
  }
  return icons[estatus] || 'info-circle'
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
  loadCatalogoGiros()
  // No cargar licencias automáticamente, esperar búsqueda del usuario
})

onBeforeUnmount(() => {
  // Limpieza si es necesario
})
</script>
