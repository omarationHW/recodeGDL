<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Estadísticas de Adeudos (Cuenta Pública)</h1>
        <p>Inicio > Mercados > Cuenta Pública</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || estadAdeudo.length === 0">
          <font-awesome-icon icon="print" />
          Imprimir
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
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select v-model.number="form.oficina" class="municipal-form-control" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="form.axo" class="municipal-form-control"
                min="1992" max="2999" placeholder="Año" :disabled="loading" />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mes <span class="required">*</span></label>
              <input type="number" v-model.number="form.periodo" class="municipal-form-control"
                min="1" max="12" placeholder="Mes (1-12)" :disabled="loading" />
            </div>
          </div>

          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="consultar" :disabled="loading || !form.oficina">
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

      <!-- Tablas de resultados -->
      <div class="row">
        <!-- Tabla 1: Total por Mercado y Mes -->
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="chart-bar" />
                Total por Mercado y Mes
              </h5>
              <div class="header-right">
                <span class="badge-purple" v-if="estadAdeudo.length > 0">
                  {{ estadAdeudo.length }} registros
                </span>
              </div>
            </div>

            <div class="municipal-card-body table-container">
              <div v-if="loading" class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Cargando...</span>
                </div>
                <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
              </div>

              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Ofn</th>
                      <th>Mer</th>
                      <th>Año</th>
                      <th>Mes</th>
                      <th>Total</th>
                      <th class="text-end">Importe Adeudo</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="estadAdeudo.length === 0 && !searchPerformed">
                      <td colspan="6" class="text-center text-muted">
                        <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                        <p>Utiliza los filtros para consultar estadísticas</p>
                      </td>
                    </tr>
                    <tr v-else-if="estadAdeudo.length === 0">
                      <td colspan="6" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                        <p>No se encontraron datos</p>
                      </td>
                    </tr>
                    <tr v-else v-for="row in estadAdeudo"
                      :key="`${row.oficina}-${row.num_mercado}-${row.axo}-${row.periodo}`"
                      class="row-hover">
                      <td>{{ row.oficina }}</td>
                      <td>{{ row.num_mercado }}</td>
                      <td>{{ row.axo }}</td>
                      <td>{{ row.periodo }}</td>
                      <td>{{ row.total }}</td>
                      <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- Tabla 2: Total Recaudadora y Mes -->
        <div class="col-md-6">
          <div class="municipal-card">
            <div class="municipal-card-header header-with-badge">
              <h5>
                <font-awesome-icon icon="chart-line" />
                Total Recaudadora y Mes
              </h5>
              <div class="header-right">
                <span class="badge-green" v-if="totalAdeudo.length > 0">
                  {{ totalAdeudo.length }} registros
                </span>
              </div>
            </div>

            <div class="municipal-card-body table-container">
              <div v-if="loading" class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                  <span class="visually-hidden">Cargando...</span>
                </div>
                <p class="mt-3 text-muted">Cargando datos, por favor espere...</p>
              </div>

              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Ofn</th>
                      <th>Año</th>
                      <th>Mes</th>
                      <th>Total</th>
                      <th class="text-end">Importe Adeudo</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-if="totalAdeudo.length === 0 && !searchPerformed">
                      <td colspan="5" class="text-center text-muted">
                        <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                        <p>Utiliza los filtros para consultar estadísticas</p>
                      </td>
                    </tr>
                    <tr v-else-if="totalAdeudo.length === 0">
                      <td colspan="5" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                        <p>No se encontraron datos</p>
                      </td>
                    </tr>
                    <tr v-else v-for="row in totalAdeudo"
                      :key="`${row.oficina}-${row.axo}-${row.periodo}`"
                      class="row-hover">
                      <td>{{ row.oficina }}</td>
                      <td>{{ row.axo }}</td>
                      <td>{{ row.periodo }}</td>
                      <td>{{ row.total }}</td>
                      <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resumen de Totales -->
      <div class="row mt-3" v-if="estadAdeudo.length > 0">
        <div class="col-md-6">
          <div class="alert alert-info d-flex align-items-center">
            <font-awesome-icon icon="calendar" class="me-3" size="2x" />
            <div>
              <strong>Meses de Adeudo:</strong>
              <h4 class="mb-0">{{ totalMeses }}</h4>
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="alert alert-success d-flex align-items-center">
            <font-awesome-icon icon="money-bill-wave" class="me-3" size="2x" />
            <div>
              <strong>Importe Total de Adeudo:</strong>
              <h4 class="mb-0">{{ formatCurrency(totalImporte) }}</h4>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const toast = useToast()
const { showLoading, hideLoading } = useGlobalLoading()

// Estados
const loading = ref(false)
const showFilters = ref(true)
const searchPerformed = ref(false)
const recaudadoras = ref([])
const estadAdeudo = ref([])
const totalAdeudo = ref([])

// Formulario
const now = new Date()
const form = ref({
  oficina: '',
  axo: now.getFullYear(),
  periodo: now.getMonth() + 1
})

// Computed
const totalMeses = computed(() => {
  return estadAdeudo.value.reduce((acc, row) => acc + Number(row.total), 0)
})

const totalImporte = computed(() => {
  return estadAdeudo.value.reduce((acc, row) => acc + Number(row.adeudo), 0)
})

// Métodos
const formatCurrency = (val) => {
  if (val == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN',
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(parseFloat(val))
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

const fetchRecaudadoras = async () => {
  try {
    showLoading('Cargando recaudadoras', 'Por favor espere')
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result
      if (!form.value.oficina && recaudadoras.value.length > 0) {
        form.value.oficina = recaudadoras.value[0].id_rec
      }
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error)
    toast.error('Error al cargar recaudadoras')
  } finally {
    hideLoading()
  }
}

const consultar = async () => {
  if (!form.value.oficina) {
    toast.warning('Seleccione una recaudadora')
    return
  }

  if (!form.value.axo || !form.value.periodo) {
    toast.warning('Complete año y mes')
    return
  }

  loading.value = true
  searchPerformed.value = true
  showLoading('Consultando estadísticas', 'Por favor espere')

  try {
    const [estadResp, totalResp] = await Promise.all([
      axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cuenta_publica_estad_adeudo',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
            { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
            { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) }
          ]
        }
      }),
      axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cuenta_publica_total_adeudo',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) },
            { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
            { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) }
          ]
        }
      })
    ])

    estadAdeudo.value = estadResp.data?.eResponse?.data?.result || []
    totalAdeudo.value = totalResp.data?.eResponse?.data?.result || []

    if (estadAdeudo.value.length === 0 && totalAdeudo.value.length === 0) {
      toast.info('No se encontraron datos para los criterios especificados')
    } else {
      toast.success('Datos cargados exitosamente')
    }
  } catch (error) {
    console.error('Error al consultar:', error)
    toast.error('Error al consultar estadísticas')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const imprimir = async () => {
  if (estadAdeudo.value.length === 0) {
    toast.warning('No hay datos para imprimir')
    return
  }

  try {
    loading.value = true
    showLoading('Generando reporte', 'Por favor espere')

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cuenta_publica_reporte',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) }
        ]
      }
    })

    if (response.data?.eResponse?.success) {
      toast.success('Reporte generado correctamente')
      // Aquí implementar la descarga del archivo si el backend lo genera
    } else {
      toast.warning('No se pudo generar el reporte')
    }
  } catch (error) {
    console.error('Error al generar reporte:', error)
    toast.error('Error al generar reporte')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const limpiar = () => {
  form.value = {
    oficina: recaudadoras.value.length > 0 ? recaudadoras.value[0].id_rec : '',
    axo: now.getFullYear(),
    periodo: now.getMonth() + 1
  }
  estadAdeudo.value = []
  totalAdeudo.value = []
  searchPerformed.value = false
  toast.info('Filtros limpiados')
}

const mostrarAyuda = () => {
  toast.info('Consulta de estadísticas de adeudos por recaudadora, año y mes')
}

// Lifecycle
onMounted(() => {
  fetchRecaudadoras()
})
</script>
