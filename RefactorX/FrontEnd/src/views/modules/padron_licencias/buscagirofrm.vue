<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search" />
      </div>
      <div class="module-view-info">
        <h1>Búsqueda de Giros</h1>
        <p>Padrón de Licencias - Búsqueda y Selección de Giros</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-primary"
          @click="buscarGiros"
        >
          <font-awesome-icon icon="sync-alt" />
          Actualizar
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
      <!-- Stats grid con skeleton loading -->
      <div class="stats-grid stats-grid-4" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 4" :key="`loading-${n}`">
          <div class="stat-content">
            <div class="skeleton-icon"></div>
            <div class="skeleton-number"></div>
            <div class="skeleton-label"></div>
          </div>
        </div>
      </div>

      <div class="stats-grid stats-grid-4" v-else-if="stats.total > 0">
        <div class="stat-card stat-primary">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="list" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.total) }}</h3>
            <p class="stat-label">Total Giros</p>
          </div>
        </div>
        <div class="stat-card stat-success">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="check-circle" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.vigentes) }}</h3>
            <p class="stat-label">Vigentes</p>
          </div>
        </div>
        <div class="stat-card stat-info">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="building" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.licencias) }}</h3>
            <p class="stat-label">Licencias</p>
          </div>
        </div>
        <div class="stat-card stat-warning">
          <div class="stat-content">
            <div class="stat-icon">
              <font-awesome-icon icon="bullhorn" />
            </div>
            <h3 class="stat-number">{{ formatNumber(stats.anuncios) }}</h3>
            <p class="stat-label">Anuncios</p>
          </div>
        </div>
      </div>

      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div class="municipal-card-body" v-show="showFilters">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Descripción del Giro</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="filters.descripcion"
                placeholder="Ingrese descripción..."
                @keyup.enter="buscarGiros"
              >
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="filters.tipo">
                <option value="">Todos</option>
                <option value="L">Licencia</option>
                <option value="A">Anuncio</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Vigencia</label>
              <select class="municipal-form-control" v-model="filters.vigente">
                <option value="">Todos</option>
                <option value="V">Vigente</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="buscarGiros"
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
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Búsqueda
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="totalResultados > 0">
              {{ formatNumber(totalResultados) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Empty State - Sin búsqueda -->
          <div v-if="giros.length === 0 && !hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="search" size="3x" />
            </div>
            <h4>Búsqueda de Giros</h4>
            <p>Utilice los filtros para buscar giros en el catálogo</p>
          </div>

          <!-- Empty State - Sin resultados -->
          <div v-else-if="giros.length === 0 && hasSearched" class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="inbox" size="3x" />
            </div>
            <h4>Sin resultados</h4>
            <p>No se encontraron giros con los criterios especificados</p>
          </div>

          <!-- Tabla con resultados -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th class="w-8">
                    <font-awesome-icon icon="hashtag" class="me-2" />
                    ID
                  </th>
                  <th class="w-35">
                    <font-awesome-icon icon="store" class="me-2" />
                    Descripción
                  </th>
                  <th class="w-25">
                    <font-awesome-icon icon="info-circle" class="me-2" />
                    Características
                  </th>
                  <th class="w-10 text-center">
                    <font-awesome-icon icon="tag" class="me-1" />
                    Tipo
                  </th>
                  <th class="w-12 text-center">
                    <font-awesome-icon icon="certificate" class="me-1" />
                    Clasificación
                  </th>
                  <th class="w-10 text-center">
                    <font-awesome-icon icon="check-circle" class="me-1" />
                    Estado
                  </th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="giro in paginatedGiros"
                  :key="giro.id_giro"
                  @click="selectedRow = giro"
                  :class="{ 'table-row-selected': selectedRow === giro }"
                  class="row-hover"
                >
                  <td>
                    <span class="badge badge-light-info">
                      {{ giro.id_giro }}
                    </span>
                  </td>
                  <td>
                    <div class="giro-name">
                      <font-awesome-icon icon="store" class="giro-icon" />
                      <span class="giro-text">{{ giro.descripcion?.trim() || 'N/A' }}</span>
                    </div>
                  </td>
                  <td>
                    <small class="text-muted">{{ giro.caracteristicas?.trim() || 'Sin características' }}</small>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="giro.tipo === 'L' ? 'badge-purple' : 'badge-warning'">
                      <font-awesome-icon :icon="giro.tipo === 'L' ? 'building' : 'bullhorn'" class="me-1" />
                      {{ giro.tipo === 'L' ? 'Licencia' : 'Anuncio' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="getClasificacionClass(giro.clasificacion)">
                      {{ giro.clasificacion || 'N/A' }}
                    </span>
                  </td>
                  <td class="text-center">
                    <span class="badge" :class="giro.vigente === 'V' ? 'badge-success' : 'badge-danger'">
                      <font-awesome-icon :icon="giro.vigente === 'V' ? 'check-circle' : 'times-circle'" class="me-1" />
                      {{ giro.vigente === 'V' ? 'VIGENTE' : 'CANCELADO' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="giros.length > 0">
            <div class="pagination-info">
              Mostrando {{ startRecord }} - {{ endRecord }} de {{ formatNumber(totalResultados) }} giros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                @click="previousPage"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
                Anterior
              </button>
              <span class="pagination-current">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                @click="nextPage"
                :disabled="currentPage === totalPages"
              >
                Siguiente
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label>Registros por página:</label>
              <select v-model="itemsPerPage" @change="changePageSize" class="municipal-form-control">
                <option :value="10">10</option>
                <option :value="20">20</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
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
        :componentName="'buscagirofrm'"
        :moduleName="'padron_licencias'"
        :docType="docType"
        :title="'Búsqueda de Giros'"
        @close="showDocModal = false"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

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
const giros = ref([])
const selectedRow = ref(null)
const hasSearched = ref(false)
const loadingEstadisticas = ref(false)
const stats = ref({
  total: 0,
  vigentes: 0,
  licencias: 0,
  anuncios: 0
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalResultados = ref(0)

// Filtros
const showFilters = ref(true)
const filters = ref({
  descripcion: '',
  tipo: '',
  vigente: 'V'
})

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Computed
const paginatedGiros = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return giros.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(totalResultados.value / itemsPerPage.value)
})

const startRecord = computed(() => {
  return (currentPage.value - 1) * itemsPerPage.value + 1
})

const endRecord = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > totalResultados.value ? totalResultados.value : end
})

// Métodos
const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true

  try {
    // Obtener estadísticas directamente de la BD
    const response = await execute(
      'consulta_giros_estadisticas',
      'padron_licencias',
      [],
      '', // tenant vacío
      null, // pagination
      'publico' // esquema
    )

    if (response && response.result && response.result.length > 0) {
      const result = response.result[0]
      stats.value = {
        total: parseInt(result.total) || 0,
        vigentes: parseInt(result.vigentes) || 0,
        licencias: parseInt(result.licencias) || 0,
        anuncios: parseInt(result.anuncios) || 0
      }
    }
  } catch (error) {
    // No mostrar toast de error para stats en este caso
  } finally {
    loadingEstadisticas.value = false
  }
}

const buscarGiros = async () => {
  showLoading('Buscando giros...', 'Consultando base de datos')
  hasSearched.value = true
  selectedRow.value = null
  currentPage.value = 1
  showFilters.value = false

  const startTime = performance.now()

  try {
    // Convertir strings vacíos a null explícitamente
    const descripcion = filters.value.descripcion?.trim() || null
    const tipo = filters.value.tipo === '' ? null : filters.value.tipo
    const vigente = filters.value.vigente === '' ? null : filters.value.vigente

    const response = await execute(
      'buscagiro_list',
      'padron_licencias',
      [
        { nombre: 'p_descripcion', valor: descripcion, tipo: 'string' },
        { nombre: 'p_tipo', valor: tipo, tipo: 'string' },
        { nombre: 'p_vigente', valor: vigente, tipo: 'string' }
      ],
      '', // tenant vacío para usar conexión por defecto
      null, // pagination
      'publico' // esquema
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)

    if (response && response.result) {
      giros.value = response.result
      totalResultados.value = giros.value.length

      // Formatear el mensaje con el tiempo
      const timeMessage = duration < 1 ? `${(duration * 1000).toFixed(0)}ms` : `${duration}s`
      showToast(
        'success',
        `Consulta exitosa: ${formatNumber(totalResultados.value)} giros encontrados`,
        timeMessage
      )
    } else {
      giros.value = []
      totalResultados.value = 0
      showToast('info', 'No se encontraron giros')
    }
  } catch (error) {
    handleApiError(error, 'Error al buscar giros')
    giros.value = []
    totalResultados.value = 0
  } finally {
    hideLoading()
  }
}

const clearFilters = () => {
  filters.value = {
    descripcion: '',
    tipo: '',
    vigente: 'V'
  }
  giros.value = []
  totalResultados.value = 0
  hasSearched.value = false
  currentPage.value = 1
  selectedRow.value = null
  showToast('info', 'Filtros limpiados')
}

// Paginación
const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
    selectedRow.value = null
  }
}

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
    selectedRow.value = null
  }
}

const changePageSize = () => {
  currentPage.value = 1
  selectedRow.value = null
}

// Helpers
const formatNumber = (value) => {
  if (!value && value !== 0) return '0'
  return new Intl.NumberFormat('es-MX').format(value)
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const getClasificacionClass = (clasificacion) => {
  const classes = {
    'A': 'badge-danger',
    'B': 'badge-warning',
    'C': 'badge-purple',
    'D': 'badge-success'
  }
  return classes[clasificacion] || 'badge-secondary'
}

// Lifecycle
onMounted(() => {
  cargarEstadisticas()
})
</script>
