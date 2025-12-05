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
                <tr v-else v-for="(row, index) in pagos" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.axo }}</strong></td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatNumber(row.total_locales) }}</td>
                  <td class="text-end">{{ formatNumber(row.total_pagos) }}</td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.importe_total) }}</strong>
                  </td>
                </tr>
                <tr v-if="pagos.length > 0" class="table-footer">
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

const totalGeneral = computed(() => {
  return pagos.value.reduce((sum, item) => sum + (parseFloat(item.importe_total) || 0), 0)
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('info', 'Seleccione una oficina para consultar los pagos agrupados por año. Opcionalmente puede filtrar por año específico y mercado.')
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
        Base: 'padron_licencias',
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
  if (!selectedOficina.value) {
    error.value = 'Debe seleccionar una oficina'
    showToast('warning', error.value)
    return
  }

  loading.value = true
  error.value = ''
  pagos.value = []
  searchPerformed.value = true

  try {
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
        showToast('success', `Se encontraron ${pagos.value.length} registros de pagos`)
        showFilters.value = false
      } else {
        showToast('info', 'No se encontraron pagos con los criterios especificados')
      }
    } else {
      error.value = res.data.eResponse.message || 'Error al consultar pagos'
      showToast('error', error.value)
    }
  } catch (err) {
    error.value = 'Error de conexión al consultar pagos'
    console.error('Error al buscar:', err)
    showToast('error', error.value)
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedOficina.value = ''
  selectedMercado.value = ''
  axo.value = ''
  pagos.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('info', 'Filtros limpiados')
}

const exportarExcel = () => {
  if (pagos.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
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

    showToast('success', 'Archivo exportado exitosamente')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('error', 'Error al exportar el archivo')
  }
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
  fetchMercados()
})
</script>
