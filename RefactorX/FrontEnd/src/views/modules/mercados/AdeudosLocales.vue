<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos de Locales</h1>
        <p>Inicio > Reportes > Adeudos de Locales</p>
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
        
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || adeudos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || adeudos.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
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
          <!-- Filtros en una sola fila -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedOficina" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="1995" max="2999"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="periodo" min="1" max="12"
                placeholder="Periodo (1-12)" :disabled="loading" />
            </div>
          </div>

          <!-- Botones de acción -->
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

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados de Adeudos de Locales
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="adeudos.length > 0">
              {{ formatNumber(adeudos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Mensaje de error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Rec.</th>
                  <th>Merc.</th>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Superficie</th>
                  <th>Clave Cuota</th>
                  <th>Adeudo</th>
                  <th>Recaudadora</th>
                  <th>Descripción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="adeudos.length === 0 && !searchPerformed">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar adeudos de locales</p>
                  </td>
                </tr>
                <tr v-else-if="adeudos.length === 0">
                  <td colspan="13" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron adeudos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedAdeudos" :key="index" @click="selectedAdeudo = row"
                  :class="{ 'table-row-selected': selectedAdeudo === row }" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.superficie }}</td>
                  <td>{{ row.clave_cuota }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.adeudo) }}</strong>
                  </td>
                  <td>{{ row.recaudadora }}</td>
                  <td>{{ row.descripcion }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="adeudos.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalRecords) }}
                de {{ totalRecords }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPage"
                @change="changePageSize($event.target.value)" style="width: auto; display: inline-block;">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"
                title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>

              <button v-for="page in visiblePages" :key="page" class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)">
                {{ page }}
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>

  </div>

  <DocumentationModal :show="showAyuda" :component-name="'AdeudosLocales'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - AdeudosLocales'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'AdeudosLocales'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - AdeudosLocales'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const selectedOficina = ref('')
const axo = ref(new Date().getFullYear())
const periodo = ref(new Date().getMonth() + 1)
const adeudos = ref([])
const selectedAdeudo = ref(null)
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => adeudos.value.length)

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ayuda: Seleccione una oficina, año y periodo para consultar los adeudos de locales')
}

const fetchRecaudadoras = async () => {
  showLoading('Cargando Adeudos de Locales', 'Preparando oficinas recaudadoras...')
  loading.value = true
  error.value = ''
  try {
    const res = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        )
    if (res.success) {
      recaudadoras.value = res.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast(`Se cargaron ${recaudadoras.value.length} oficinas recaudadoras`, 'success')
      }
    } else {
      error.value = res.message || 'Error al cargar recaudadoras'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar recaudadoras'
    console.error('Error al cargar recaudadoras:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const buscar = async () => {
  if (!selectedOficina.value || !axo.value || !periodo.value) {
    error.value = 'Debe seleccionar oficina, año y periodo'
    showToast(error.value, 'warning')
    return
  }

  if (periodo.value < 1 || periodo.value > 12) {
    error.value = 'El periodo debe estar entre 1 y 12'
    showToast(error.value, 'warning')
    return
  }

  if (axo.value < 1995 || axo.value > 2999) {
    error.value = 'El año debe estar entre 1995 y 2999'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  adeudos.value = []
  selectedAdeudo.value = null
  searchPerformed.value = true
  currentPage.value = 1

  try {
    const res = await apiService.execute(
          'sp_adeudos_locales',
          'mercados',
          [
          { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
          { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'string' },
          { nombre: 'p_periodo', valor: periodo.value, tipo: 'integer' }
        ],
          '',
          null,
          'publico'
        )
    if (res.success) {
      adeudos.value = res.data.result || []
      if (adeudos.value.length > 0) {
        showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron adeudos con los criterios especificados', 'info')
      }
    } else {
      error.value = res.message || 'Error al consultar adeudos'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar adeudos'
    console.error('Error al buscar adeudos:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  axo.value = new Date().getFullYear()
  periodo.value = new Date().getMonth() + 1
  adeudos.value = []
  selectedAdeudo.value = null
  error.value = ''
  searchPerformed.value = false
  currentPage.value = 1
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (adeudos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  // TODO: Implementar exportación a Excel
  showToast('Funcionalidad de exportación a Excel en desarrollo', 'info')
}

const imprimir = () => {
  if (adeudos.value.length === 0) {
    showToast('No hay datos para imprimir', 'warning')
    return
  }
  // TODO: Implementar impresión
  showToast('Funcionalidad de impresión en desarrollo', 'info')
}

// Utilidades
const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return 'N/A'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return 'N/A'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedAdeudos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return adeudos.value.slice(start, end)
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

// Paginación - Métodos
const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
  selectedAdeudo.value = null
}

const changePageSize = (size) => {
  itemsPerPage.value = parseInt(size)
  currentPage.value = 1
  selectedAdeudo.value = null
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
})
</script>
