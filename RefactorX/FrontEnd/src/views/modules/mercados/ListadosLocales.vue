<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-alt" />
      </div>
      <div class="module-view-info">
        <h1>Listados de Mercados</h1>
        <p>Inicio > Mercados > Listados</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || !hayResultados">
          <font-awesome-icon icon="file-excel" />
          Excel
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Tipo de Listado -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="tasks" />
            Tipo de Listado
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="listado-options">
            <label class="listado-option" :class="{ active: tipoListado === 'padron' }">
              <input type="radio" value="padron" v-model="tipoListado" @change="limpiarResultados">
              <span class="option-content">
                <font-awesome-icon icon="clipboard-list" />
                Padrón de Locales
              </span>
            </label>
            <label class="listado-option" :class="{ active: tipoListado === 'movimientos' }">
              <input type="radio" value="movimientos" v-model="tipoListado" @change="limpiarResultados">
              <span class="option-content">
                <font-awesome-icon icon="exchange-alt" />
                Movimientos Locales
              </span>
            </label>
            <label class="listado-option" :class="{ active: tipoListado === 'ingresozonas' }">
              <input type="radio" value="ingresozonas" v-model="tipoListado" @change="limpiarResultados">
              <span class="option-content">
                <font-awesome-icon icon="chart-bar" />
                Ingreso por Zonas
              </span>
            </label>
          </div>
        </div>
      </div>

      <!-- Filtros de Consulta -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Filtros Padrón -->
          <div v-if="tipoListado === 'padron'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="selectedRec" @change="onRecChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="selectedMercado" :disabled="loading || mercados.length === 0">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <!-- Filtros Movimientos -->
          <div v-if="tipoListado === 'movimientos'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaDesde" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaHasta" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="selectedRec" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>

          <!-- Filtros Ingreso Zonas -->
          <div v-if="tipoListado === 'ingresozonas'" class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaDesde" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaHasta" :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="buscar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Buscar
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

      <!-- Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="hayResultados">
              {{ formatNumber(totalRegistros) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando listado, por favor espere...</p>
          </div>

          <div v-else class="table-responsive">
            <!-- Tabla Padrón -->
            <table v-if="tipoListado === 'padron'" class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Rec.</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="locales.length === 0 && !searchPerformed">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros y busque</p>
                  </td>
                </tr>
                <tr v-else-if="locales.length === 0">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales</p>
                  </td>
                </tr>
                <tr v-else v-for="loc in paginatedData" :key="loc.id_local" class="row-hover">
                  <td>{{ loc.oficina }}</td>
                  <td>{{ loc.num_mercado }}</td>
                  <td>{{ loc.categoria }}</td>
                  <td>{{ loc.seccion }}</td>
                  <td><strong class="text-primary">{{ loc.local }}</strong></td>
                  <td>{{ loc.letra_local }}</td>
                  <td>{{ loc.bloque }}</td>
                  <td>{{ loc.nombre }}</td>
                  <td class="text-end">{{ loc.superficie }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(loc.renta) }}</strong></td>
                  <td>
                    <span :class="loc.vigencia === 'A' ? 'badge-success' : 'badge-danger'">
                      {{ loc.vigencia === 'A' ? 'Activo' : 'Baja' }}
                    </span>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Tabla Movimientos -->
            <table v-if="tipoListado === 'movimientos'" class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th>Rec.</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Tipo</th>
                  <th>Nombre</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="movimientos.length === 0 && !searchPerformed">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros y busque</p>
                  </td>
                </tr>
                <tr v-else-if="movimientos.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron movimientos</p>
                  </td>
                </tr>
                <tr v-else v-for="mov in paginatedData" :key="mov.id_movimiento" class="row-hover">
                  <td>{{ formatDate(mov.fecha) }}</td>
                  <td>{{ mov.oficina }}</td>
                  <td>{{ mov.num_mercado }}</td>
                  <td>{{ mov.categoria }}</td>
                  <td>{{ mov.seccion }}</td>
                  <td><strong class="text-primary">{{ mov.local }}</strong></td>
                  <td>{{ mov.letra_local }}</td>
                  <td>{{ mov.bloque }}</td>
                  <td><span class="badge-info">{{ mov.tipo }}</span></td>
                  <td>{{ mov.nombre }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Tabla Ingreso Zonas -->
            <table v-if="tipoListado === 'ingresozonas'" class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Zona</th>
                  <th>Descripción</th>
                  <th class="text-end">Importe Pagado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="ingresos.length === 0 && !searchPerformed">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros y busque</p>
                  </td>
                </tr>
                <tr v-else-if="ingresos.length === 0">
                  <td colspan="3" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron ingresos</p>
                  </td>
                </tr>
                <tr v-else v-for="ing in paginatedData" :key="ing.id_zona" class="row-hover">
                  <td><strong>{{ ing.id_zona }}</strong></td>
                  <td>{{ ing.zona }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(ing.pagado) }}</strong></td>
                </tr>
                <tr v-if="ingresos.length > 0" class="total-row">
                  <td colspan="2" class="text-end"><strong>Total General:</strong></td>
                  <td class="text-end"><strong class="text-primary">{{ formatCurrency(totalIngresos) }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div v-if="hayResultados" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRegistros) }}
                de {{ totalRegistros }} registros
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

  <DocumentationModal :show="showAyuda" :component-name="'ListadosLocales'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - ListadosLocales'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'ListadosLocales'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - ListadosLocales'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const tipoListado = ref('padron')
const recaudadoras = ref([])
const mercados = ref([])
const selectedRec = ref('')
const selectedMercado = ref('')
const fechaDesde = ref(new Date().toISOString().split('T')[0])
const fechaHasta = ref(new Date().toISOString().split('T')[0])

// Datos
const locales = ref([])
const movimientos = ref([])
const ingresos = ref([])
const loading = ref(false)
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

// Computed
const totalIngresos = computed(() => {
  return ingresos.value.reduce((sum, row) => sum + Number(row.pagado || 0), 0)
})

const hayResultados = computed(() => {
  if (tipoListado.value === 'padron') return locales.value.length > 0
  if (tipoListado.value === 'movimientos') return movimientos.value.length > 0
  if (tipoListado.value === 'ingresozonas') return ingresos.value.length > 0
  return false
})

const totalRegistros = computed(() => {
  if (tipoListado.value === 'padron') return locales.value.length
  if (tipoListado.value === 'movimientos') return movimientos.value.length
  if (tipoListado.value === 'ingresozonas') return ingresos.value.length
  return 0
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  if (tipoListado.value === 'padron') return locales.value.slice(start, end)
  if (tipoListado.value === 'movimientos') return movimientos.value.slice(start, end)
  if (tipoListado.value === 'ingresozonas') return ingresos.value.slice(start, end)
  return []
})

const totalPages = computed(() => {
  return Math.ceil(totalRegistros.value / itemsPerPage.value)
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

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ayuda: Seleccione el tipo de listado y los filtros correspondientes para generar el reporte', 'info')
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

const formatCurrency = (value) => {
  if (value === null || value === undefined || value === '') return '$0.00'
  const num = typeof value === 'number' ? value : parseFloat(value)
  if (isNaN(num)) return '$0.00'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatDate = (value) => {
  if (!value) return ''
  return new Date(value).toLocaleDateString('es-MX')
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const fetchRecaudadoras = async () => {
  showLoading('Cargando Listados de Locales', 'Preparando oficinas recaudadoras...')
  try {
    const res = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res?.success === true) {
      recaudadoras.value = res.data.result || []
    }
  } catch (err) {
    showToast('Error al cargar recaudadoras', 'error')
  } finally {
    hideLoading()
  }
}

const onRecChange = async () => {
  selectedMercado.value = ''
  mercados.value = []
  if (!selectedRec.value) return

  try {
    const res = await apiService.execute(
          'sp_get_catalogo_mercados',
          'mercados',
          [
          { nombre: 'p_oficina', tipo: 'integer', valor: selectedRec.value },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: 1 }
        ],
          '',
          null,
          'publico'
        )
    if (res?.success) {
      mercados.value = res.data.result || []
    }
  } catch (err) {
    showToast('Error al cargar mercados', 'error')
  }
}

const buscar = () => {
  if (tipoListado.value === 'padron') {
    buscarPadron()
  } else if (tipoListado.value === 'movimientos') {
    buscarMovimientos()
  } else if (tipoListado.value === 'ingresozonas') {
    buscarIngresoZonas()
  }
}

const buscarPadron = async () => {
  if (!selectedRec.value || !selectedMercado.value) {
    showToast('Seleccione recaudadora y mercado', 'warning')
    return
  }

  loading.value = true
  locales.value = []
  searchPerformed.value = true

  try {
    const res = await apiService.execute(
          'sp_listado_padron_locales',
          'mercados',
          [
          { nombre: 'p_oficina', valor: selectedRec.value },
          { nombre: 'p_mercado', valor: selectedMercado.value }
        ],
          '',
          null,
          'publico'
        )
    if (res?.success) {
      locales.value = res.data.result || []
      if (locales.value.length > 0) {
        showToast(`Se encontraron ${locales.value.length} locales`, 'success')
        showFilters.value = false
      } else {
        showToast('No hay locales para el mercado seleccionado', 'info')
      }
    }
  } catch (err) {
    showToast('Error al buscar padrón', 'error')
  } finally {
    loading.value = false
  }
}

const buscarMovimientos = async () => {
  if (!selectedRec.value || !fechaDesde.value || !fechaHasta.value) {
    showToast('Complete todos los filtros requeridos', 'warning')
    return
  }

  loading.value = true
  movimientos.value = []
  searchPerformed.value = true

  try {
    const res = await apiService.execute(
          'sp_listado_movimientos_locales',
          'mercados',
          [
          { nombre: 'p_oficina', valor: selectedRec.value },
          { nombre: 'p_fecha_desde', valor: fechaDesde.value },
          { nombre: 'p_fecha_hasta', valor: fechaHasta.value }
        ],
          '',
          null,
          'publico'
        )
    if (res?.success) {
      movimientos.value = res.data.result || []
      if (movimientos.value.length > 0) {
        showToast(`Se encontraron ${movimientos.value.length} movimientos`, 'success')
        showFilters.value = false
      } else {
        showToast('No hay movimientos para los filtros seleccionados', 'info')
      }
    }
  } catch (err) {
    showToast('Error al buscar movimientos', 'error')
  } finally {
    loading.value = false
  }
}

const buscarIngresoZonas = async () => {
  if (!fechaDesde.value || !fechaHasta.value) {
    showToast('Seleccione el rango de fechas', 'warning')
    return
  }

  loading.value = true
  ingresos.value = []
  searchPerformed.value = true

  try {
    const res = await apiService.execute(
          'sp_listado_ingreso_zonas',
          'mercados',
          [
          { nombre: 'p_fecha_desde', valor: fechaDesde.value },
          { nombre: 'p_fecha_hasta', valor: fechaHasta.value }
        ],
          '',
          null,
          'publico'
        )
    if (res?.success) {
      ingresos.value = res.data.result || []
      if (ingresos.value.length > 0) {
        showToast(`Se encontraron ${ingresos.value.length} zonas con ingresos`, 'success')
        showFilters.value = false
      } else {
        showToast('No hay ingresos para el rango seleccionado', 'info')
      }
    }
  } catch (err) {
    showToast('Error al buscar ingresos por zonas', 'error')
  } finally {
    loading.value = false
  }
}

const limpiarResultados = () => {
  locales.value = []
  movimientos.value = []
  ingresos.value = []
  searchPerformed.value = false
}

const limpiarFiltros = () => {
  selectedRec.value = ''
  selectedMercado.value = ''
  mercados.value = []
  fechaDesde.value = new Date().toISOString().split('T')[0]
  fechaHasta.value = new Date().toISOString().split('T')[0]
  limpiarResultados()
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (!hayResultados.value) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  showToast('Funcionalidad de exportación Excel en desarrollo', 'info')
}

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

onMounted(() => {
  fetchRecaudadoras()
})
</script>
