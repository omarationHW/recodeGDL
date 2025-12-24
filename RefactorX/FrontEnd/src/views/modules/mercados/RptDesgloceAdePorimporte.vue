<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Desglose de Adeudos por Importe</h1>
        <p>Inicio > Reportes > Desglose de Adeudos por Año e Importe</p>
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
        
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || report.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || report.length === 0">
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
            <font-awesome-icon :icon="showFilters ? 'angle-up' : 'angle-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Filtros en una sola fila -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="year" min="2000" max="2100"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="period" min="1" max="12"
                placeholder="Periodo (1-12)" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Importe Mínimo ($) <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="amount" step="0.01" min="0"
                placeholder="0.00" :disabled="loading" />
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="fetchReport" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Consultar
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
            Locales con Adeudos Vencidos Desglosado por Año
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="report.length > 0">
              {{ formatNumber(report.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Título del reporte -->
          <div v-if="report.length > 0" class="text-center mb-3">
            <p class="fw-bold">
              Al periodo: {{ year }}-{{ period }} Importe mayor e igual a {{ formatCurrency(amount) }}
            </p>
          </div>

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
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Categoría</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th class="text-end">Adeudo Ant.</th>
                  <th class="text-end">Adeudo 2004</th>
                  <th class="text-end">Adeudo 2005</th>
                  <th class="text-end">Adeudo 2006</th>
                  <th class="text-end">Adeudo 2007</th>
                  <th class="text-end">Adeudo 2008</th>
                  <th class="text-end">Total Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="report.length === 0 && !searchPerformed">
                  <td colspan="16" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar el desglose de adeudos</p>
                  </td>
                </tr>
                <tr v-else-if="report.length === 0">
                  <td colspan="16" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron resultados con los parámetros indicados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, idx) in paginatedReport" :key="idx" class="row-hover">
                  <td>{{ row.spd_oficina }}</td>
                  <td>{{ row.spd_mercado }}</td>
                  <td>{{ row.spd_categoria }}</td>
                  <td>{{ row.spd_seccion }}</td>
                  <td><strong class="text-primary">{{ row.spd_local }}</strong></td>
                  <td>{{ row.spd_letra }}</td>
                  <td>{{ row.spd_bloque }}</td>
                  <td>{{ row.spd_nombre }}</td>
                  <td>{{ row.spd_descripcion }}</td>
                  <td class="text-end">{{ formatCurrency(row.spd_adeant) }}</td>
                  <td class="text-end">{{ formatCurrency(row.spd_ade2004) }}</td>
                  <td class="text-end">{{ formatCurrency(row.spd_ade2005) }}</td>
                  <td class="text-end">{{ formatCurrency(row.spd_ade2006) }}</td>
                  <td class="text-end">{{ formatCurrency(row.spd_ade2007) }}</td>
                  <td class="text-end">{{ formatCurrency(row.spd_ade2008) }}</td>
                  <td class="text-end">
                    <strong class="text-danger">{{ formatCurrency(row.spd_totade) }}</strong>
                  </td>
                </tr>
              </tbody>
              <tfoot v-if="report.length > 0" class="municipal-table-footer">
                <tr>
                  <td colspan="9" class="text-end fw-bold">Totales:</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_adeant')) }}</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_ade2004')) }}</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_ade2005')) }}</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_ade2006')) }}</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_ade2007')) }}</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_ade2008')) }}</td>
                  <td class="text-end fw-bold">{{ formatCurrency(total('spd_totade')) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="report.length > 0" class="pagination-controls">
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

  <DocumentationModal :show="showAyuda" :component-name="'RptDesgloceAdePorimporte'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptDesgloceAdePorimporte'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptDesgloceAdePorimporte'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptDesgloceAdePorimporte'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed } from 'vue'
import axios from 'axios'
import { useToast } from '@/composables/useToast'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const year = ref(new Date().getFullYear())
const period = ref(new Date().getMonth() + 1)
const amount = ref(0)
const report = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => report.value.length)

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Ayuda: Ingrese año, periodo (mes) e importe mínimo para consultar el desglose de adeudos vencidos por año')
}

const fetchReport = async () => {
  // Validaciones
  if (!year.value || !period.value || amount.value === null || amount.value === undefined) {
    error.value = 'Debe ingresar año, periodo e importe mínimo'
    showToast(error.value, 'warning')
    return
  }

  if (year.value < 2000 || year.value > 2100) {
    error.value = 'El año debe estar entre 2000 y 2100'
    showToast(error.value, 'warning')
    return
  }

  if (period.value < 1 || period.value > 12) {
    error.value = 'El periodo debe estar entre 1 y 12'
    showToast(error.value, 'warning')
    return
  }

  if (amount.value < 0) {
    error.value = 'El importe mínimo debe ser mayor o igual a cero'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  report.value = []
  searchPerformed.value = true
  currentPage.value = 1

  try {
    const res = await apiService.execute(
          'spd_11_ade_axo',
          'mercados',
          [
          { nombre: 'parm_axo', valor: parseInt(year.value) },
          { nombre: 'parm_mes', valor: parseInt(period.value) },
          { nombre: 'parm_cuota', valor: parseFloat(amount.value) }
        ],
          '',
          null,
          'publico'
        )

    if (res.success) {
      report.value = res.data.result || []
      if (report.value.length > 0) {
        showToast(`Se encontraron ${report.value.length} locales con adeudos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron resultados para los parámetros indicados', 'info')
      }
    } else {
      error.value = res.message || 'Error al consultar el reporte'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar el reporte'
    console.error('Error al consultar reporte:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  year.value = new Date().getFullYear()
  period.value = new Date().getMonth() + 1
  amount.value = 0
  report.value = []
  error.value = ''
  searchPerformed.value = false
  currentPage.value = 1
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (report.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }
  showToast('Funcionalidad de exportación a Excel en desarrollo', 'info')
}

const imprimir = () => {
  if (report.value.length === 0) {
    showToast('No hay datos para imprimir', 'warning')
    return
  }
  window.print()
}

// Utilidades
const formatCurrency = (val) => {
  if (val === null || val === undefined || val === '') return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  if (isNaN(num)) return '$0.00'
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const total = (field) => {
  return report.value.reduce((sum, row) => sum + (parseFloat(row[field]) || 0), 0)
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedReport = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return report.value.slice(start, end)
})

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let start = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let end = Math.min(totalPages.value, start + maxVisible - 1)

  if (end - start + 1 < maxVisible) {
    start = Math.max(1, end - maxVisible + 1)
  }

  for (let i = start; i <= end; i++) {
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
</script>
