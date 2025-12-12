<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Locales</h1>
        <p>Inicio > Mercados > Emisión de Recibos</p>
      </div>
      <div class="button-group ms-auto">
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
            Filtros de Emisión
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Filtros en una sola fila -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina (Recaudadora) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedRec" @change="onRecChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model="selectedMercado" :disabled="!selectedRec || loading">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="axo" min="2003" max="2999"
                placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Periodo <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="periodo" min="1" max="12"
                placeholder="Mes" :disabled="loading" />
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="generarEmision" :disabled="loading">
                  <font-awesome-icon icon="cogs" />
                  Generar
                </button>             
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Recibos Generados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Recibos Generados
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="recibos.length > 0">
              {{ formatNumber(recibos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando emisión, por favor espere...</p>
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
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Subtotal</th>
                  <th class="text-center">Meses</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="recibos.length === 0 && !searchPerformed">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Seleccione los filtros y genere la emisión</p>
                  </td>
                </tr>
                <tr v-else-if="recibos.length === 0">
                  <td colspan="7" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron locales para el mercado seleccionado</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in recibos" :key="index" class="row-hover">
                  <td><strong class="text-primary">{{ row.local }}{{ row.letra_local || '' }}</strong></td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion_local }}</td>
                  <td class="text-end">{{ row.superficie }}</td>
                  <td class="text-end">
                    <strong class="text-info">{{ formatCurrency(row.renta) }}</strong>
                  </td>
                  <td class="text-end">
                    <strong class="text-success">{{ formatCurrency(row.subtotal) }}</strong>
                  </td>
                  <td class="text-center">{{ row.meses }}</td>
                </tr>
              </tbody>
              <tfoot v-if="recibos.length > 0">
                <tr class="table-info">
                  <td colspan="5" class="text-end"><strong>Total:</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalSubtotal) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
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
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const recaudadoras = ref([])
const mercados = ref([])
const selectedRec = ref('')
const selectedMercado = ref('')
const axo = ref(new Date().getFullYear())
const periodo = ref(new Date().getMonth() + 1)

// Datos
const recibos = ref([])
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
const totalSubtotal = computed(() => {
  return recibos.value.reduce((sum, row) => sum + Number(row.subtotal || 0), 0)
})

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const mostrarAyuda = () => {
  showToast('Ayuda: Seleccione una oficina, mercado, año y periodo para generar la emisión de recibos', 'info')
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
  showLoading('Cargando Emisión de Locales', 'Preparando oficinas recaudadoras...')
  loading.value = true
  error.value = ''
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
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
    console.error('Error al cargar recaudadoras:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const onRecChange = async () => {
  selectedMercado.value = ''
  mercados.value = []
  if (!selectedRec.value) return

  loading.value = true
  error.value = ''
  try {
    const nivelUsuario = 1
    const oficinaParam = selectedRec.value || null

    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'integer', valor: oficinaParam },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: nivelUsuario }
        ]
      }
    })

    if (res.data.eResponse && res.data.eResponse.success === true) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        showToast(`Se cargaron ${mercados.value.length} mercados`, 'success')
      } else {
        showToast('No se encontraron mercados para esta oficina', 'info')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al cargar mercados'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al cargar mercados'
    console.error('Error al cargar mercados:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const generarEmision = async () => {
  if (!selectedRec.value || !selectedMercado.value || !axo.value || !periodo.value) {
    error.value = 'Debe seleccionar oficina, mercado, año y periodo'
    showToast(error.value, 'warning')
    return
  }

  if (periodo.value < 1 || periodo.value > 12) {
    error.value = 'El periodo debe estar entre 1 y 12'
    showToast(error.value, 'warning')
    return
  }

  loading.value = true
  error.value = ''
  recibos.value = []
  searchPerformed.value = true

  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_emision_locales_generar',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: selectedRec.value },
          { Nombre: 'p_mercado', Valor: selectedMercado.value },
          { Nombre: 'p_axo', Valor: axo.value },
          { Nombre: 'p_periodo', Valor: periodo.value }
        ]
      }
    })

    if (res.data.eResponse && res.data.eResponse.success === true) {
      recibos.value = res.data.eResponse.data.result || []
      if (recibos.value.length > 0) {
        showToast(`Se generaron ${recibos.value.length} recibos`, 'success')
        showFilters.value = false
      } else {
        showToast('No se encontraron locales para el mercado seleccionado', 'info')
      }
    } else {
      error.value = res.data.eResponse?.message || 'Error al generar emisión'
      showToast(error.value, 'error')
    }
  } catch (err) {
    error.value = 'Error de conexión al generar emisión'
    console.error('Error al generar emisión:', err)
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}

const limpiarFiltros = () => {
  selectedRec.value = ''
  selectedMercado.value = ''
  mercados.value = []
  axo.value = new Date().getFullYear()
  periodo.value = new Date().getMonth() + 1
  recibos.value = []
  error.value = ''
  searchPerformed.value = false
  showToast('Filtros limpiados', 'info')
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

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
})
</script>

<style scoped>
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.text-end {
  text-align: right;
}

.text-center {
  text-align: center;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.row-hover:hover {
  background-color: #f8f9fa;
}

.required {
  color: #dc3545;
}

.municipal-table td.text-end,
.municipal-table th.text-end {
  text-align: right;
}

.municipal-table td.text-center,
.municipal-table th.text-center {
  text-align: center;
}
</style>
