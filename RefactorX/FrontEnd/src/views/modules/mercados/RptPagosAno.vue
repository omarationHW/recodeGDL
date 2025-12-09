<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-check" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagos por Año</h1>
        <p>Mercados > Reporte de Pagos Agrupados por Año</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || pagos.length === 0">
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
            <font-awesome-icon :icon="showFilters ? 'angle-up' : 'angle-down'" class="ms-2" />
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
              <label class="municipal-form-label">Año (Opcional)</label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="1995" max="2999"
                placeholder="Todos los años" :disabled="loading" />
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
            Pagos por Año
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="pagos.length > 0">
              {{ formatNumber(pagos.length) }} registros
            </span>
            <span class="badge-success ms-2" v-if="totalGeneral > 0">
              Total: {{ formatCurrency(totalGeneral) }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
          </div>

          <!-- Error -->
          <div v-else-if="error" class="alert alert-danger" role="alert">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ error }}
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Mercado</th>
                  <th>Descripción</th>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Total Pagos</th>
                  <th class="text-end">Importe Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="pagos.length === 0 && !searchPerformed">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para consultar pagos por año</p>
                  </td>
                </tr>
                <tr v-else-if="pagos.length === 0">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron pagos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedPagos" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.axo }}</strong></td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatNumber(row.total_locales) }}</td>
                  <td class="text-end">{{ formatNumber(row.total_pagos) }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_total) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="pagos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ paginationStart }} a {{ paginationEnd }} de {{ totalItems }} registros
            </div>
            <div class="pagination-controls">
              <label class="me-2">Registros por página:</label>
              <select v-model.number="itemsPerPage" class="municipal-form-control" style="width: auto;">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="prevPage" :disabled="currentPage === 1" class="btn-municipal-secondary btn-sm">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span>Página {{ currentPage }} de {{ totalPages }}</span>
              <button @click="nextPage" :disabled="currentPage === totalPages" class="btn-municipal-secondary btn-sm">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>

          <!-- Totales -->
          <div v-if="pagos.length > 0" class="table-responsive mt-3">
            <table class="municipal-table">
              <tbody>
                <tr class="table-footer">
                  <td colspan="5" class="text-end"><strong>TOTAL GENERAL:</strong></td>
                  <td class="text-end">
                    <strong class="text-primary" style="font-size: 1.1em;">{{ formatCurrency(totalGeneral) }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast } = useToast()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const mercados = ref([])
const selectedOficina = ref('')
const selectedMercado = ref('')
const axo = ref('')
const pagos = ref([])
const loading = ref(false)
const error = ref('')
const searchPerformed = ref(false)

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(10)

// Computed
const mercadosFiltrados = computed(() => {
  if (!selectedOficina.value) return []
  return mercados.value.filter(m => m.oficina === selectedOficina.value)
})

const totalGeneral = computed(() => {
  return pagos.value.reduce((sum, item) => sum + (parseFloat(item.importe_total) || 0), 0)
})

const paginatedPagos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return pagos.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(pagos.value.length / itemsPerPage.value)
})

const paginationStart = computed(() => {
  return pagos.value.length === 0 ? 0 : (currentPage.value - 1) * itemsPerPage.value + 1
})

const paginationEnd = computed(() => {
  const end = currentPage.value * itemsPerPage.value
  return end > pagos.value.length ? pagos.value.length : end
})

const totalItems = computed(() => pagos.value.length)

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
watch(pagos, () => {
  currentPage.value = 1
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Seleccione una oficina para consultar los pagos agrupados por año. Opcionalmente puede filtrar por año específico y mercado.')
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatNumber = (value) => {
  return new Intl.NumberFormat('es-MX').format(value)
}

const fetchRecaudadoras = async () => {
  try {
    showLoading('Cargando recaudadoras', 'Por favor espere...')
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    })
    if (res.data.eResponse.success) {
      recaudadoras.value = res.data.eResponse.data.result || []
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err)
  } finally {
    hideLoading()
  }
}

const fetchMercados = async () => {
  try {
    showLoading('Cargando mercados', 'Por favor espere...')
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
  } finally {
    hideLoading()
  }
}

const buscar = async () => {
  if (!selectedOficina.value) {
    error.value = 'Debe seleccionar una oficina'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  pagos.value = []
  searchPerformed.value = true

  try {
    showLoading('Generando reporte de pagos por año', 'Por favor espere...')
    const parametros = [
      { nombre: 'p_oficina', valor: selectedOficina.value, tipo: 'integer' }
    ]

    if (axo.value) {
      parametros.push({ nombre: 'p_axo', valor: axo.value, tipo: 'integer' })
    } else {
      parametros.push({ nombre: 'p_axo', valor: null, tipo: 'integer' })
    }

    if (selectedMercado.value) {
      parametros.push({ nombre: 'p_mercado', valor: selectedMercado.value, tipo: 'integer' })
    } else {
      parametros.push({ nombre: 'p_mercado', valor: null, tipo: 'integer' })
    }

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_pagos_ano',
        Base: 'mercados',
        Parametros: parametros
      }
    })

    if (res.data.eResponse.success) {
      pagos.value = res.data.eResponse.data.result || []
      if (pagos.value.length > 0) {
        showToast(`Se encontraron ${pagos.value.length} registros de pagos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron pagos con los criterios especificados', 'info')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar pagos'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar pagos'
    console.error('Error al buscar:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  selectedMercado.value = ''
  axo.value = ''
  pagos.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
}

const exportarExcel = () => {
  if (pagos.value.length === 0) {
    showToast('No hay datos para exportar', 'warning')
    return
  }

  try {
    const headers = ['Año', 'Mercado', 'Descripción', 'Locales', 'Total Pagos', 'Importe Total']
    const csvRows = []
    csvRows.push(headers.join(','))

    pagos.value.forEach(row => {
      const values = [
        row.axo,
        row.num_mercado,
        `"${row.descripcion}"`,
        row.total_locales,
        row.total_pagos,
        row.importe_total
      ]
      csvRows.push(values.join(','))
    })

    // Agregar total
    csvRows.push(`"","","","","TOTAL",${totalGeneral.value}`)

    const blob = new Blob([csvRows.join('\n')], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `pagos_por_ano_${selectedOficina.value}_${Date.now()}.csv`
    link.click()
    URL.revokeObjectURL(url)

    showToast('Archivo exportado exitosamente', 'success')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('Error al exportar el archivo', 'error')
  }
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
  fetchMercados()
})
</script>
