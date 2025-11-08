<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Giros Vigentes por Contribuyente</h1>
        <p>Padrón de Licencias - Reporte de Licencias Activas por Giro</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-primary"
          @click="exportToExcel"
          :disabled="loading || licencias.length === 0"
        >
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button
          class="btn-municipal-secondary"
          @click="generatePDF"
          :disabled="loading || licencias.length === 0"
        >
          <font-awesome-icon icon="file-pdf" />
          Generar PDF
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
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
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
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
            class="btn-municipal-secondary"
            @click="loadLicencias"
            :disabled="loading"
          >
            <font-awesome-icon icon="sync-alt" />
            Actualizar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Licencias Vigentes
          <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} licencias</span>
        </h5>
        <div v-if="loading" class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
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
              <tr v-for="lic in licencias" :key="lic.numero_licencia" class="row-hover">
                <td><strong class="text-primary">{{ lic.numero_licencia?.trim() }}</strong></td>
                <td>{{ lic.contribuyente?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge-info">
                    {{ lic.giro?.trim() || 'N/A' }}
                  </span>
                </td>
                <td>{{ lic.domicilio?.trim() || 'N/A' }}</td>
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
              <tr v-if="licencias.length === 0 && !loading">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron licencias con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Paginación -->
      <div class="pagination-container" v-if="totalRecords > 0 && !loading">
        <div class="pagination-info">
          <font-awesome-icon icon="info-circle" />
          Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
          a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
          de {{ totalRecords }} registros
        </div>

        <div class="pagination-controls">
          <div class="page-size-selector">
            <label>Mostrar:</label>
            <select v-model="itemsPerPage" @change="changePageSize">
              <option :value="10">10</option>
              <option :value="25">25</option>
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

    <!-- Loading overlay -->
    <div v-if="loading && licencias.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando licencias vigentes...</p>
      </div>
    </div>

    <!-- Toast Notifications -->
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'girosVigentesCteXgirofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

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
const licencias = ref([])
const catalogoGiros = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(25)
const totalRecords = ref(0)

// Filtros
const filters = ref({
  giro: '',
  zona: '',
  fechaInicio: '',
  fechaFin: ''
})

// Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
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
  setLoading(true, 'Cargando licencias vigentes...')

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

    if (response && response.result) {
      licencias.value = response.result
      if (licencias.value.length > 0) {
        totalRecords.value = parseInt(licencias.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      showToast('success', 'Licencias cargadas correctamente')
    } else {
      licencias.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar licencias')
    }
  } catch (error) {
    handleApiError(error)
    licencias.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchLicencias = () => {
  currentPage.value = 1
  loadLicencias()
}

const clearFilters = () => {
  filters.value = {
    giro: '',
    zona: '',
    fechaInicio: '',
    fechaFin: ''
  }
  currentPage.value = 1
  loadLicencias()
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadLicencias()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadLicencias()
}

const exportToExcel = async () => {
  setLoading(true, 'Generando archivo Excel...')

  try {
    await Swal.fire({
      icon: 'info',
      title: 'Exportando a Excel',
      text: 'La funcionalidad de exportación se implementará próximamente',
      confirmButtonColor: '#ea8215',
      timer: 2000
    })

    // Aquí se implementaría la lógica de exportación a Excel
    // usando una librería como xlsx o llamando a un endpoint específico

    showToast('info', 'Exportación a Excel en desarrollo')
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const generatePDF = async () => {
  setLoading(true, 'Generando reporte PDF...')

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
    setLoading(false)
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
  loadLicencias()
})

onBeforeUnmount(() => {
  // Limpieza si es necesario
})
</script>
