<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos Condonados</h1>
        <p>Mercados > Reporte de Adeudos Condonados de Locales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || adeudos.length === 0">
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

            <div class="form-group">
              <label class="municipal-form-label">Mercado (Opcional)</label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="loading || !selectedOficina">
                <option value="">Todos los mercados</option>
                <option v-for="m in mercadosFiltrados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
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

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos Condonados
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
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Importe</th>
                  <th>Clave Cond.</th>
                  <th>Fecha</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="adeudos.length === 0 && !searchPerformed">
                  <td colspan="14" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar adeudos condonados</p>
                  </td>
                </tr>
                <tr v-else-if="adeudos.length === 0">
                  <td colspan="14" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron adeudos condonados con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedAdeudos" :key="index" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.letra_local || '-' }}</td>
                  <td>{{ row.bloque || '-' }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe) }}</strong>
                  </td>
                  <td>{{ row.clave_canc }}</td>
                  <td>{{ formatDate(row.fecha_alta) }}</td>
                  <td>{{ row.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="adeudos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ paginationStart }} a {{ paginationEnd }} de {{ totalItems }} registros
            </div>
            <div class="pagination-controls">
              <label class="me-2">Registros por página:</label>
              <select v-model.number="itemsPerPage" class="form-select form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="prevPage" :disabled="currentPage === 1" class="btn-municipal-secondary btn-sm">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span>Página {{ currentPage }} de {{ totalPages }}</span>
              <button @click="nextPage" :disabled="currentPage === totalPages" class="btn-municipal-secondary btn-sm">
                <font-awesome-icon icon="chevron-right" />
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
const mercados = ref([])
const selectedOficina = ref('')
const selectedMercado = ref('')
const axo = ref(new Date().getFullYear())
const periodo = ref(new Date().getMonth() + 1)
const adeudos = ref([])
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

// Computed
const mercadosFiltrados = computed(() => {
  if (!selectedOficina.value) return []
  return mercados.value.filter(m => m.oficina === selectedOficina.value)
})

const paginatedAdeudos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return adeudos.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(adeudos.value.length / itemsPerPage.value)
})

const paginationStart = computed(() => {
  return adeudos.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > adeudos.value.length ? adeudos.value.length : end
})

const totalItems = computed(() => adeudos.value.length)

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

const prevPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

// Reset página al cambiar datos
watch(adeudos, () => {
  currentPage.value = 1
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Seleccione una oficina, año y periodo para consultar los adeudos condonados de locales')
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

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  return new Intl.NumberFormat('es-MX').format(value)
}

const formatDate = (value) => {
  if (!value) return '-'
  const date = new Date(value)
  return date.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const fetchRecaudadoras = async () => {
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
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err)
  }
}

const fetchMercados = async () => {
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_reporte_catalogo_mercados',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar mercados:', err)
  }
}

const buscar = async () => {
  if (!selectedOficina.value || !axo.value || !periodo.value) {
    error.value = 'Debe seleccionar oficina, año y periodo'
    showToast('warning', error.value)
    return
  }

  if (periodo.value < 1 || periodo.value > 12) {
    error.value = 'El periodo debe estar entre 1 y 12'
    showToast('warning', error.value)
    return
  }

  loading.value = true
  error.value = ''
  adeudos.value = []
  searchPerformed.value = true

  try {
    const parametros = [
      { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'integer' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_periodo', valor: periodo.value, tipo: 'integer' }
    ]

    if (selectedMercado.value) {
      parametros.push({ nombre: 'p_mercado', valor: selectedMercado.value, tipo: 'integer' })
    } else {
      parametros.push({ nombre: 'p_mercado', valor: null, tipo: 'integer' })
    }

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_reporte_adeudos_condonados',
        Base: 'mercados',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      adeudos.value = res.data.eResponse.data.result || []
      if (adeudos.value.length > 0) {
        showToast('success', `Se encontraron ${adeudos.value.length} adeudos condonados`)
        showFilters.value = false
      } else {
        showToast('info', 'No se encontraron adeudos condonados con los criterios especificados')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar adeudos condonados'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar adeudos'
    console.error('Error al buscar:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  selectedMercado.value = ''
  axo.value = new Date().getFullYear()
  periodo.value = new Date().getMonth() + 1
  adeudos.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (adeudos.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const headers = ['Oficina', 'Mercado', 'Cat', 'Sec', 'Local', 'Letra', 'Bloque', 'Nombre', 'Año', 'Periodo', 'Importe', 'Clave Cond.', 'Fecha', 'Usuario']
    const csvRows = []
    csvRows.push(headers.join(','))

    adeudos.value.forEach(row => {
      const values = [
        row.oficina,
        row.num_mercado,
        row.categoria,
        row.seccion,
        row.local,
        row.letra_local || '',
        row.bloque || '',
        `"${row.nombre}"`,
        row.axo,
        row.periodo,
        row.importe,
        `"${row.clave_canc}"`,
        formatDate(row.fecha_alta),
        `"${row.usuario}"`
      ]
      csvRows.push(values.join(','))
    })

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `adeudos_condonados_${axo.value}_${periodo.value}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('success', 'Archivo exportado exitosamente')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('error', 'Error al exportar el archivo')
  }
}

// Lifecycle
onMounted(async () => {
  showLoading('Cargando Reporte de Adeudos Condonados', 'Preparando catálogos...')
  try {
    await Promise.all([fetchRecaudadoras(), fetchMercados()])
  } finally {
    hideLoading()
  }
})
</script>
