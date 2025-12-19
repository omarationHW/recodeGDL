<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Estadísticas de Adeudos</h1>
        <p>Mercados > Estadísticas de Adeudos de Locales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || resultados.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Parámetros de Consulta
          </h5>
        </div>

        <div class="municipal-card-body">
          <!-- Tipo de estadística -->
          <div class="row mb-3">
            <div class="col-md-12">
              <label class="municipal-form-label">Tipo de Estadística <span class="required">*</span></label>
              <div class="btn-group w-100" role="group">
                <button type="button" class="btn" :class="tipoEstadistica === 'global' ? 'btn-primary' : 'btn-outline-primary'"
                  @click="tipoEstadistica = 'global'" :disabled="loading">
                  <font-awesome-icon icon="globe" />
                  Todos los Adeudos
                </button>
                <button type="button" class="btn" :class="tipoEstadistica === 'importe' ? 'btn-primary' : 'btn-outline-primary'"
                  @click="tipoEstadistica = 'importe'" :disabled="loading">
                  <font-awesome-icon icon="dollar-sign" />
                  Adeudos ≥ Importe
                </button>
                <button type="button" class="btn" :class="tipoEstadistica === 'desglose' ? 'btn-primary' : 'btn-outline-primary'"
                  @click="tipoEstadistica = 'desglose'" :disabled="loading">
                  <font-awesome-icon icon="list-alt" />
                  Desglose por Año
                </button>
              </div>
            </div>
          </div>

          <!-- Filtros -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="filtros.year" min="1995" max="2999"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="filtros.month" min="1" max="12"
                placeholder="Mes (1-12)" :disabled="loading" />
            </div>

            <div class="form-group" v-if="tipoEstadistica !== 'global'">
              <label class="municipal-form-label">Importe Mínimo <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="filtros.importe" min="0" step="0.01"
                placeholder="0.00" :disabled="loading" />
            </div>
          </div>

          <!-- Botones -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="consultar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Consultar
                </button>
                <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
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
            <span class="badge-purple" v-if="resultados.length > 0">
              {{ resultados.length }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Procesando estadísticas...</p>
          </div>

          <!-- Error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else-if="resultados.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columnas" :key="col">{{ formatColumnName(col) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResultados" :key="idx" class="row-hover">
                  <td v-for="col in columnas" :key="col">
                    <span v-if="isNumericColumn(col) && col.includes('adeudo')">
                      {{ formatCurrency(row[col]) }}
                    </span>
                    <span v-else>{{ row[col] }}</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de paginación -->
          <div v-if="resultados.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, resultados.length) }}
                de {{ resultados.length }} registros
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

          <!-- Sin resultados -->
          <div v-else class="text-center py-5 text-muted">
            <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
            <p class="mt-3">Utiliza los filtros para consultar estadísticas de adeudos</p>
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
import { ref, computed, watch } from 'vue'
import axios from 'axios'

// Estado
const loading = ref(false)
const error = ref('')
const tipoEstadistica = ref('global')
const filtros = ref({
  year: new Date().getFullYear(),
  month: new Date().getMonth() + 1,
  importe: 0
})
const resultados = ref([])
const columnas = ref([])

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
const showToast = (message, type) => {
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

// Computed para paginación
const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return resultados.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(resultados.value.length / itemsPerPage.value)
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

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
}

// Reset página al cambiar datos
watch(resultados, () => {
  currentPage.value = 1
})

const mostrarAyuda = () => {
  showToast('Seleccione el tipo de estadística y los parámetros para consultar adeudos de locales', 'info')
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatColumnName = (col) => {
  const names = {
    oficina: 'Oficina',
    num_mercado: 'Mercado',
    local_count: 'Total Locales',
    adeudo: 'Adeudo',
    descripcion: 'Descripción',
    id_local: 'ID Local',
    local: 'Local',
    oficina: 'Oficina',
    mercado: 'Mercado',
    categoria: 'Categoría',
    seccion: 'Sección',
    letra: 'Letra',
    bloque: 'Bloque',
    nombre: 'Nombre',
    ade_ant: 'Adeudo Anterior',
    adeudo_total: 'Adeudo Total'
  }
  return names[col] || col.toUpperCase()
}

const isNumericColumn = (col) => {
  return ['adeudo', 'ade_ant', 'adeudo_total', 'importe'].some(key => col.includes(key))
}

const consultar = async () => {
  if (!filtros.value.year || !filtros.value.month) {
    showToast('Debe ingresar año y mes', 'warning')
    return
  }

  if (filtros.value.month < 1 || filtros.value.month > 12) {
    showToast('El mes debe estar entre 1 y 12', 'warning')
    return
  }

  if (tipoEstadistica.value !== 'global' && (!filtros.value.importe || filtros.value.importe < 0)) {
    showToast('Debe ingresar un importe válido', 'warning')
    return
  }

  loading.value = true
  error.value = ''
  resultados.value = []
  columnas.value = []

  try {
    let operacion = ''
    let parametros = [
      { nombre: 'p_year', valor: filtros.value.year, tipo: 'integer' },
      { nombre: 'p_month', valor: filtros.value.month, tipo: 'integer' }
    ]

    if (tipoEstadistica.value === 'global') {
      operacion = 'sp_estadisticas_global'
    } else if (tipoEstadistica.value === 'importe') {
      operacion = 'sp_estadisticas_importe'
      parametros.push({ nombre: 'p_importe', valor: filtros.value.importe, tipo: 'numeric' })
    } else if (tipoEstadistica.value === 'desglose') {
      operacion = 'sp_desgloce_adeudos_por_importe'
      parametros.push({ nombre: 'p_importe', valor: filtros.value.importe, tipo: 'numeric' })
    }

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: operacion,
        Base: 'mercados',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      resultados.value = res.data.eResponse.data.result || []
      if (resultados.value.length > 0) {
        columnas.value = Object.keys(resultados.value[0])
        showToast(`Se encontraron ${resultados.value.length} registros`, 'success')
      } else {
        showToast('No se encontraron registros con los criterios especificados', 'info')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar estadísticas'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar estadísticas'
    console.error('Error al consultar:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const limpiar = () => {
  filtros.value = {
    year: new Date().getFullYear(),
    month: new Date().getMonth() + 1,
    importe: 0
  }
  tipoEstadistica.value = 'global'
  resultados.value = []
  columnas.value = []
  error.value = ''
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (resultados.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    const csvRows = []
    csvRows.push(columnas.value.map(c => formatColumnName(c)).join(','))

    resultados.value.forEach(row => {
      csvRows.push(columnas.value.map(col => {
        let val = row[col] ?? ''
        if (typeof val === 'string' && val.includes(',')) {
          val = `"${val}"`
        }
        return val
      }).join(','))
    })

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `estadisticas_${tipoEstadistica.value}_${filtros.value.year}_${filtros.value.month}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('Archivo exportado exitosamente', 'success')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('Error al exportar el archivo', 'error')
  }
}
</script>
