<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Giros con Adeudo</h1>
        <p>Padrón de Licencias - Reporte de Giros con Adeudos</p></div>
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
          :disabled="loading || giros.length === 0"
        >
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Tarjeta de resumen -->
    <div class="municipal-card" v-if="summary.totalGiros > 0">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="chart-line" />
          Resumen de Adeudos
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="stats-grid">
          <div class="stat-item">
            <div class="stat-icon stat-primary">
              <font-awesome-icon icon="layer-group" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ summary.totalGiros }}</div>
              <div class="stat-label">Giros con Adeudo</div>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon stat-warning">
              <font-awesome-icon icon="file-invoice" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ summary.totalLicencias }}</div>
              <div class="stat-label">Licencias con Adeudo</div>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon stat-danger">
              <font-awesome-icon icon="dollar-sign" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatCurrency(summary.totalAdeudo) }}</div>
              <div class="stat-label">Adeudo Total</div>
            </div>
          </div>
          <div class="stat-item">
            <div class="stat-icon stat-info">
              <font-awesome-icon icon="calculator" />
            </div>
            <div class="stat-content">
              <div class="stat-value">{{ formatCurrency(summary.averageAdeudo) }}</div>
              <div class="stat-label">Promedio por Giro</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Año</label>
            <select class="municipal-form-control" v-model="filters.year">
              <option value="">Todos los años</option>
              <option v-for="year in availableYears" :key="year" :value="year">{{ year }}</option>
            </select>
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Giro/Categoría</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.giro"
              placeholder="Nombre del giro"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Adeudo Mínimo</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.minDebt"
              placeholder="0.00"
              step="0.01"
            >
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="searchGiros"
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
            @click="loadGiros"
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
          Giros con Adeudo
          <span class="badge-info" v-if="totalRecords > 0">{{ totalRecords }} registros</span>
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
                <th>Giro</th>
                <th>Total Licencias</th>
                <th>Licencias con Adeudo</th>
                <th>% Adeudo</th>
                <th>Monto Total</th>
                <th>Promedio</th>
                <th>Porcentaje de Deuda</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="giro in giros" :key="giro.id" class="row-hover">
                <td><strong class="text-primary">{{ giro.giro?.trim() || 'N/A' }}</strong></td>
                <td>
                  <span class="badge-secondary">
                    <font-awesome-icon icon="file-alt" />
                    {{ giro.total_licencias || 0 }}
                  </span>
                </td>
                <td>
                  <span class="badge-warning">
                    <font-awesome-icon icon="exclamation-triangle" />
                    {{ giro.licencias_con_adeudo || 0 }}
                  </span>
                </td>
                <td>
                  <span class="badge" :class="getPercentageClass(giro.porcentaje_adeudo)">
                    {{ formatPercentage(giro.porcentaje_adeudo) }}%
                  </span>
                </td>
                <td>
                  <strong class="text-danger">{{ formatCurrency(giro.monto_total_adeudo) }}</strong>
                </td>
                <td>
                  <span class="text-muted">{{ formatCurrency(giro.promedio_adeudo) }}</span>
                </td>
                <td>
                  <div class="debt-progress">
                    <div
                      class="debt-progress-bar"
                      :style="{ width: `${Math.min(giro.porcentaje_adeudo || 0, 100)}%` }"
                      :class="getProgressBarClass(giro.porcentaje_adeudo)"
                    >
                      <span v-if="giro.porcentaje_adeudo > 10">{{ formatPercentage(giro.porcentaje_adeudo) }}%</span>
                    </div>
                  </div>
                </td>
              </tr>
              <tr v-if="giros.length === 0 && !loading">
                <td colspan="7" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron giros con adeudos</p>
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

    <!-- Loading overlay -->
    <div v-if="loading && giros.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando reporte de giros con adeudo...</p>
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
      :componentName="'GirosDconAdeudofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, computed, onMounted } from 'vue'
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
const giros = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = ref(0)

// Resumen
const summary = ref({
  totalGiros: 0,
  totalLicencias: 0,
  totalAdeudo: 0,
  averageAdeudo: 0
})

// Filtros
const filters = ref({
  year: '',
  giro: '',
  minDebt: ''
})

// Años disponibles
const availableYears = computed(() => {
  const currentYear = new Date().getFullYear()
  const years = []
  for (let i = currentYear; i >= currentYear - 10; i--) {
    years.push(i)
  }
  return years
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

// Métodos
const loadGiros = async () => {
  setLoading(true, 'Cargando giros con adeudo...')

  try {
    const response = await execute(
      'GirosDconAdeudofrm_sp_giros_dcon_adeudo',
      'padron_licencias',
      [
        { nombre: 'p_year', valor: filters.value.year || null, tipo: 'integer' },
        { nombre: 'p_giro', valor: filters.value.giro || null, tipo: 'string' },
        { nombre: 'p_min_debt', valor: filters.value.minDebt || null, tipo: 'string' },
        { nombre: 'p_page', valor: currentPage.value, tipo: 'integer' },
        { nombre: 'p_limit', valor: itemsPerPage.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      giros.value = response.result
      if (giros.value.length > 0) {
        totalRecords.value = parseInt(giros.value[0].total_records) || 0
      } else {
        totalRecords.value = 0
      }
      calculateSummary()
      showToast('success', 'Datos cargados correctamente')
    } else {
      giros.value = []
      totalRecords.value = 0
      showToast('error', 'Error al cargar datos')
    }
  } catch (error) {
    handleApiError(error)
    giros.value = []
    totalRecords.value = 0
  } finally {
    setLoading(false)
  }
}

const searchGiros = () => {
  currentPage.value = 1
  loadGiros()
}

const clearFilters = () => {
  filters.value = {
    year: '',
    giro: '',
    minDebt: ''
  }
  currentPage.value = 1
  loadGiros()
}

const exportToExcel = async () => {
  const result = await Swal.fire({
    title: 'Exportar a Excel',
    text: '¿Desea exportar el reporte de giros con adeudo a Excel?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, exportar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    setLoading(true, 'Generando archivo Excel...')

    try {
      const response = await execute(
        'GirosDconAdeudofrm_report_giros_dcon_adeudo',
        'padron_licencias',
        [
          { nombre: 'p_year', valor: filters.value.year || null, tipo: 'integer' },
          { nombre: 'p_giro', valor: filters.value.giro || null, tipo: 'string' },
          { nombre: 'p_min_debt', valor: filters.value.minDebt || null, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (response && response.result) {
        await Swal.fire({
          icon: 'success',
          title: 'Excel generado',
          text: 'El archivo se ha generado correctamente',
          confirmButtonColor: '#ea8215',
          timer: 2000
        })
        showToast('success', 'Archivo Excel generado exitosamente')
      }
    } catch (error) {
      handleApiError(error)
    } finally {
      setLoading(false)
    }
  }
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    loadGiros()
  }
}

const changePageSize = () => {
  currentPage.value = 1
  loadGiros()
}

const calculateSummary = () => {
  if (giros.value.length === 0) {
    summary.value = {
      totalGiros: 0,
      totalLicencias: 0,
      totalAdeudo: 0,
      averageAdeudo: 0
    }
    return
  }

  let totalLicencias = 0
  let totalAdeudo = 0

  giros.value.forEach(giro => {
    totalLicencias += parseInt(giro.licencias_con_adeudo) || 0
    totalAdeudo += parseFloat(giro.monto_total_adeudo) || 0
  })

  summary.value = {
    totalGiros: giros.value.length,
    totalLicencias: totalLicencias,
    totalAdeudo: totalAdeudo,
    averageAdeudo: giros.value.length > 0 ? totalAdeudo / giros.value.length : 0
  }
}

// Utilidades
const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const formatPercentage = (value) => {
  if (!value && value !== 0) return '0.00'
  return parseFloat(value).toFixed(2)
}

const getPercentageClass = (percentage) => {
  const percent = parseFloat(percentage) || 0
  if (percent >= 75) return 'badge-danger'
  if (percent >= 50) return 'badge-warning'
  if (percent >= 25) return 'badge-info'
  return 'badge-success'
}

const getProgressBarClass = (percentage) => {
  const percent = parseFloat(percentage) || 0
  if (percent >= 75) return 'progress-danger'
  if (percent >= 50) return 'progress-warning'
  if (percent >= 25) return 'progress-info'
  return 'progress-success'
}

// Lifecycle
onMounted(() => {
  loadGiros()
})
</script>

<style scoped>
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1rem;
}

.stat-item {
  display: flex;
  align-items: center;
  padding: 1rem;
  background: #f8f9fa;
  border-radius: 0.5rem;
  border: 1px solid #e9ecef;
}

.stat-icon {
  width: 50px;
  height: 50px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 0.5rem;
  margin-right: 1rem;
  font-size: 1.5rem;
  color: white;
}

.stat-icon.stat-primary {
  background: linear-gradient(135deg, #ea8215 0%, #c46e12 100%);
}

.stat-icon.stat-warning {
  background: linear-gradient(135deg, #ffc107 0%, #e0a800 100%);
}

.stat-icon.stat-danger {
  background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
}

.stat-icon.stat-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.stat-content {
  flex: 1;
}

.stat-value {
  font-size: 1.75rem;
  font-weight: 700;
  color: #2c3e50;
  line-height: 1;
  margin-bottom: 0.25rem;
}

.stat-label {
  font-size: 0.875rem;
  color: #6c757d;
  font-weight: 500;
}

.debt-progress {
  width: 100%;
  height: 24px;
  background-color: #e9ecef;
  border-radius: 0.25rem;
  overflow: hidden;
  position: relative;
}

.debt-progress-bar {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 600;
  color: white;
  transition: width 0.3s ease;
}

.debt-progress-bar.progress-success {
  background: linear-gradient(90deg, #28a745 0%, #20c997 100%);
}

.debt-progress-bar.progress-info {
  background: linear-gradient(90deg, #17a2b8 0%, #138496 100%);
}

.debt-progress-bar.progress-warning {
  background: linear-gradient(90deg, #ffc107 0%, #e0a800 100%);
}

.debt-progress-bar.progress-danger {
  background: linear-gradient(90deg, #dc3545 0%, #c82333 100%);
}
</style>
