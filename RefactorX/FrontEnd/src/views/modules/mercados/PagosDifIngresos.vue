<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="exclamation-triangle" />
      </div>
      <div class="module-view-info">
        <h1>Inconsistencias de Pagos</h1>
        <p>Inicio > Reportes > Inconsistencias de Pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || resultados.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
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
          <!-- Tipo de inconsistencia -->
          <div class="form-row mb-3">
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Inconsistencia <span class="required">*</span></label>
              <div class="radio-group">
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipo-renta" value="renta" v-model="tipoConsulta"
                    :disabled="loading" />
                  <label class="form-check-label" for="tipo-renta">
                    <font-awesome-icon icon="money-bill-wave" class="me-1" />
                    Renta Errónea
                  </label>
                </div>
                <div class="form-check form-check-inline">
                  <input class="form-check-input" type="radio" id="tipo-datos" value="datos" v-model="tipoConsulta"
                    :disabled="loading" />
                  <label class="form-check-label" for="tipo-datos">
                    <font-awesome-icon icon="database" class="me-1" />
                    Datos Erróneos (Cuenta/Caja/Operación)
                  </label>
                </div>
              </div>
            </div>
          </div>

          <!-- Filtros de fecha y recaudadora -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRecaudadora" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaDesde" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="fechaHasta" :disabled="loading" />
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
            {{ tipoConsulta === 'renta' ? 'Pagos con Renta Errónea' : 'Pagos con Datos Erróneos' }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="resultados.length > 0">
              {{ formatNumber(resultados.length) }} registros
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
            <table class="municipal-table" v-if="resultados.length > 0">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columnas" :key="col">{{ formatColumnName(col) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResultados" :key="idx" class="row-hover">
                  <td v-for="col in columnas" :key="col">
                    {{ formatCellValue(col, row[col]) }}
                  </td>
                </tr>
              </tbody>
            </table>

            <div v-else-if="!searchPerformed" class="text-center text-muted py-5">
              <font-awesome-icon icon="search" size="2x" class="empty-icon" />
              <p>Seleccione el tipo de inconsistencia y use los filtros para buscar</p>
            </div>

            <div v-else class="text-center text-muted py-5">
              <font-awesome-icon icon="check-circle" size="2x" class="empty-icon" style="color: #28a745;" />
              <p>No se encontraron inconsistencias en el rango de fechas especificado</p>
            </div>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="resultados.length > 0" class="pagination-controls">
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
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const selectedRecaudadora = ref('')
const fechaDesde = ref('')
const fechaHasta = ref('')
const tipoConsulta = ref('renta')
const resultados = ref([])
const columnas = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Toast
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)
const totalRecords = computed(() => resultados.value.length)

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ayuda: Seleccione el tipo de inconsistencia, recaudadora y rango de fechas para detectar pagos con errores', 'info')
}

const showToast = (type, message) => {
  toast.value = {
    show: true,
    type,
    message
  }
  setTimeout(() => {
    hideToast()
  }, 5000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'times-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

const fetchRecaudadoras = async () => {
  loading.value = true
  error.value = ''
  showLoading()
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    })
    if (res.data.eResponse.success) {
      recaudadoras.value = res.data.eResponse.data.result || []
      if (recaudadoras.value.length > 0) {
        showToast(`Se cargaron ${recaudadoras.value.length} recaudadoras`, 'success')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al cargar recaudadoras'
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
  // Validaciones
  if (!selectedRecaudadora.value || !fechaDesde.value || !fechaHasta.value) {
    error.value = 'Debe seleccionar recaudadora y rango de fechas'
    showToast(error.value, 'warning')
    return
  }

  if (fechaDesde.value > fechaHasta.value) {
    error.value = 'La fecha desde no puede ser mayor a la fecha hasta'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  resultados.value = []
  columnas.value = []
  searchPerformed.value = true
  currentPage.value = 1

  const operacion = tipoConsulta.value === 'renta' ? 'spd_11_dif_renta' : 'spd_11_dif_pagos'

  showLoading()
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: [
          { Nombre: 'parm_rec', Valor: parseInt(selectedRecaudadora.value) },
          { Nombre: 'parm_fpadsd', Valor: fechaDesde.value },
          { Nombre: 'parm_fpahst', Valor: fechaHasta.value }
        ]
      }
    })

    if (res.data.eResponse.success) {
      resultados.value = res.data.eResponse.data.result || []
      if (resultados.value.length > 0) {
        columnas.value = Object.keys(resultados.value[0])
        showToast(`Se encontraron ${resultados.value.length} inconsistencias`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron inconsistencias en el rango especificado', 'info')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error en la consulta'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al realizar la consulta'
    console.error('Error en búsqueda:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  selectedRecaudadora.value = ''
  fechaDesde.value = ''
  fechaHasta.value = ''
  tipoConsulta.value = 'renta'
  resultados.value = []
  columnas.value = []
  error.value = ''
  searchPerformed.value = false
  currentPage.value = 1
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (resultados.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    const cols = columnas.value
    let csv = cols.join(',') + '\n'
    resultados.value.forEach(r => {
      csv += cols.map(c => '"' + (r[c] !== null && r[c] !== undefined ? r[c] : '') + '"').join(',') + '\n'
    })

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const fileName = tipoConsulta.value === 'renta' ? 'pagos_renta_erronea.csv' : 'pagos_datos_erroneos.csv'
    a.download = fileName
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)

    showToast('Datos exportados exitosamente', 'success')
  } catch (err) {
    showToast('Error al exportar datos', 'error')
    console.error('Error en exportación:', err)
  }
}

// Utilidades
const formatNumber = (number) => {
  return new Intl.NumberFormat('es-MX').format(number)
}

const formatColumnName = (colName) => {
  const names = {
    id_pago_local: 'ID Pago',
    id_local: 'ID Local',
    axo: 'Año',
    periodo: 'Periodo',
    fecha_pago: 'Fecha Pago',
    oficina_pago: 'Oficina',
    caja_pago: 'Caja',
    operacion_pago: 'Operación',
    importe_pago: 'Importe',
    folio: 'Folio',
    fecha_modificacion: 'Fecha Mod.',
    id_usuario: 'ID Usuario',
    usuario: 'Usuario',
    oficina: 'Oficina',
    num_mercado: 'Mercado',
    categoria: 'Categoría',
    seccion: 'Sección',
    local: 'Local',
    letra_local: 'Letra',
    bloque: 'Bloque',
    cuenta_ingreso: 'Cuenta',
    renta_esperada: 'Renta Esperada'
  }
  return names[colName] || colName
}

const formatCellValue = (colName, value) => {
  if (value === null || value === undefined) return ''

  // Formatear montos
  if (colName === 'importe_pago' || colName === 'renta_esperada' || colName === 'cuenta_ingreso') {
    const num = parseFloat(value)
    if (!isNaN(num)) {
      return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
    }
  }

  // Formatear fechas
  if (colName === 'fecha_pago' && value) {
    return new Date(value).toLocaleDateString('es-MX')
  }

  if (colName === 'fecha_modificacion' && value) {
    return new Date(value).toLocaleString('es-MX')
  }

  return value
}

// Paginación - Computed
const totalPages = computed(() => {
  return Math.ceil(totalRecords.value / itemsPerPage.value)
})

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return resultados.value.slice(start, end)
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

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()

  // Establecer fechas por defecto (último mes)
  const hoy = new Date()
  fechaHasta.value = hoy.toISOString().split('T')[0]

  const haceUnMes = new Date()
  haceUnMes.setMonth(haceUnMes.getMonth() - 1)
  fechaDesde.value = haceUnMes.toISOString().split('T')[0]
})
</script>
