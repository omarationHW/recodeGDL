<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="clipboard-list" />
      </div>
      <div class="module-view-info">
        <h1>Padrón de Locales</h1>
        <p>Inicio > Mercados > Padrón de Locales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || padron.length === 0">
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRec" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Generar Padrón
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Padrón -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales Registrados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="padron.length > 0">
              {{ formatNumber(padron.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando padrón, por favor espere...</p>
          </div>

          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Rec.</th>
                  <th>Merc.</th>
                  <th>Nombre Mercado</th>
                  <th>Cat.</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre Locatario</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="padron.length === 0 && !searchPerformed">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione una recaudadora y genere el padrón</p>
                  </td>
                </tr>
                <tr v-else-if="padron.length === 0">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales para esta recaudadora</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedPadron" :key="index" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end">{{ row.superficie }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.renta) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div v-if="padron.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ paginationStart }}
                a {{ paginationEnd }}
                de {{ totalItems }} registros
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
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const selectedRec = ref('')

// Datos
const padron = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ayuda: Seleccione una oficina recaudadora para generar el padrón de locales', 'info')
}

const showToast = (message, type) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

const fetchRecaudadoras = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    })
    if (res.data.eResponse.success === true) {
      recaudadoras.value = res.data.eResponse.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast(`Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`, 'success')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al cargar recaudadoras'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar recaudadoras'
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const buscar = async () => {
  if (!selectedRec.value) {
    showToast('Debe seleccionar una oficina recaudadora', 'warning')
    return
  }

  loading.value = true
  error.value = ''
  padron.value = []
  searchPerformed.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_padron_locales',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_recaudadora', Valor: selectedRec.value }
        ]
      }
    })
    if (res.data.eResponse && res.data.eResponse.success === true) {
      padron.value = res.data.eResponse.data.result || []
      if (padron.value.length > 0) {
        showToast(`Se encontraron ${padron.value.length} locales`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron locales para esta recaudadora', 'info')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al generar padrón'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al generar padrón'
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedRec.value = ''
  padron.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (padron.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  showToast('Funcionalidad de exportación Excel en desarrollo', 'info')
}

const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return '$0.00'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const paginatedPadron = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return padron.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(padron.value.length / itemsPerPage.value)
})

const paginationStart = computed(() => {
  return padron.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > padron.value.length ? padron.value.length : end
})

const totalItems = computed(() => padron.value.length)

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

// Paginación - Métodos
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
}

// Reset página al buscar
watch(padron, () => {
  currentPage.value = 1
})

onMounted(async () => {
  showLoading('Cargando Padrón de Locales', 'Preparando oficinas recaudadoras...')
  try {
    await fetchRecaudadoras()
  } finally {
    hideLoading()
  }
})
</script>

<style scoped>
.empty-icon { color: #ccc; margin-bottom: 1rem; }
.text-end { text-align: right; }
.spinner-border { width: 3rem; height: 3rem; }
.row-hover:hover { background-color: #f8f9fa; }
.required { color: #dc3545; }
.municipal-table td.text-end, .municipal-table th.text-end { text-align: right; }
</style>
