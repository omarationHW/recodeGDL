<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cash-register" />
      </div>
      <div class="module-view-info">
        <h1>Ingresos Mercado Libertad</h1>
        <p>Inicio > Consultas > Ingresos Libertad</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="procesar" :disabled="loading || !isFormValid">
          <font-awesome-icon icon="play" /> Procesar
        </button>
        <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Parámetros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Mes a Procesar <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.mes" :disabled="loading">
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.anio"
                     min="2000" max="2999" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="form.mercado_id" :disabled="loading || mercados.length === 0">
                <option value="">Seleccione...</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <div v-if="ingresos.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="calendar-check" /> Ingresos por Fecha y Caja</h5>
          <div class="header-right">
            <span class="badge-purple">{{ ingresos.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th class="text-center">Fecha de Pago</th>
                  <th class="text-center">Caja</th>
                  <th class="text-end">Total Pagos</th>
                  <th class="text-end">Renta Pagada</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in ingresos" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td class="text-center">{{ formatDate(row.fecha_pago) }}</td>
                  <td class="text-center"><span class="badge-primary">{{ row.caja_pago }}</span></td>
                  <td class="text-end"><span class="badge-info">{{ row.pagos }}</span></td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe) }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="cajas.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="boxes" /> Totales por Caja</h5>
          <div class="header-right">
            <span class="badge-purple">{{ cajas.length }} cajas</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th class="text-center">Caja</th>
                  <th class="text-end">Total Pagos</th>
                  <th class="text-end">Renta Pagada</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in cajas" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td class="text-center"><span class="badge-primary">{{ row.caja_pago }}</span></td>
                  <td class="text-end"><span class="badge-info">{{ row.pagos }}</span></td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe) }}</strong></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="totals" class="municipal-card mt-3">
        <div class="municipal-card-header bg-success">
          <h5 class="text-white"><font-awesome-icon icon="calculator" /> Totales Globales</h5>
        </div>
        <div class="municipal-card-body">
          <div class="totals-grid">
            <div class="total-item">
              <div class="total-label">Total de Pagos:</div>
              <div class="total-value text-primary">{{ totals.total_pagos }}</div>
            </div>
            <div class="total-item">
              <div class="total-label">Total Pagado:</div>
              <div class="total-value text-success">{{ formatCurrency(totals.total_importe) }}</div>
            </div>
          </div>
        </div>
      </div>

      <div v-if="searched && !loading && ingresos.length === 0" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No hay ingresos registrados para el periodo seleccionado</p>
      </div>
    </div>

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

const today = new Date()

const form = ref({
  mes: today.getMonth() + 1,
  anio: today.getFullYear(),
  mercado_id: ''
})

const mercados = ref([])
const ingresos = ref([])
const cajas = ref([])
const totals = ref(null)
const loading = ref(false)
const searched = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

const meses = [
  { value: 1, label: 'Enero' },
  { value: 2, label: 'Febrero' },
  { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' },
  { value: 5, label: 'Mayo' },
  { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' },
  { value: 8, label: 'Agosto' },
  { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' },
  { value: 11, label: 'Noviembre' },
  { value: 12, label: 'Diciembre' }
]

const isFormValid = computed(() => {
  return form.value.mes && form.value.anio && form.value.mercado_id
})

const showToast = (type, message) => {
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

const mostrarAyuda = () => {
  showToast('info', 'Seleccione el mes, año y mercado para consultar los ingresos del Mercado Libertad. Se mostrarán los ingresos por fecha/caja, totales por caja y totales globales.')
}

const fetchMercados = async () => {
  loading.value = true
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_libertad',
        Base: 'padron_licencias',
        Parametros: []
      }
    })

    if (res.data.eResponse.success) {
      mercados.value = res.data.eResponse.data.result || []
      if (mercados.value.length > 0) {
        form.value.mercado_id = mercados.value[0].num_mercado_nvo
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al cargar mercados')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al cargar mercados')
  } finally {
    loading.value = false
  }
}

const procesar = async () => {
  if (!isFormValid.value) {
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }

  loading.value = true
  searched.value = true
  ingresos.value = []
  cajas.value = []
  totals.value = null

  try {
    // 1. Obtener ingresos por fecha y caja
    const resIngresos = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_ingresos_libertad',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_mes', Valor: parseInt(form.value.mes) },
          { Nombre: 'p_anio', Valor: parseInt(form.value.anio) },
          { Nombre: 'p_mercado', Valor: parseInt(form.value.mercado_id) }
        ]
      }
    })

    if (resIngresos.data.eResponse.success) {
      ingresos.value = resIngresos.data.eResponse.data.result || []
    }

    // 2. Obtener totales por caja
    const resCajas = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_cajas_libertad',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_mes', Valor: parseInt(form.value.mes) },
          { Nombre: 'p_anio', Valor: parseInt(form.value.anio) },
          { Nombre: 'p_mercado', Valor: parseInt(form.value.mercado_id) }
        ]
      }
    })

    if (resCajas.data.eResponse.success) {
      cajas.value = resCajas.data.eResponse.data.result || []
    }

    // 3. Obtener totales globales
    const resTotals = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_totals_libertad',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_mes', Valor: parseInt(form.value.mes) },
          { Nombre: 'p_anio', Valor: parseInt(form.value.anio) },
          { Nombre: 'p_mercado', Valor: parseInt(form.value.mercado_id) }
        ]
      }
    })

    if (resTotals.data.eResponse.success) {
      const result = resTotals.data.eResponse.data.result || []
      if (result.length > 0) {
        totals.value = result[0]
      }
    }

    if (ingresos.value.length > 0) {
      showToast('success', `Se encontraron ${ingresos.value.length} registros de ingresos`)
    } else {
      showToast('info', 'No se encontraron ingresos para el periodo seleccionado')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al procesar la consulta')
  } finally {
    loading.value = false
  }
}

const limpiar = () => {
  const today = new Date()
  form.value.mes = today.getMonth() + 1
  form.value.anio = today.getFullYear()
  form.value.mercado_id = mercados.value.length > 0 ? mercados.value[0].num_mercado_nvo : ''
  ingresos.value = []
  cajas.value = []
  totals.value = null
  searched.value = false
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const d = new Date(dateStr + 'T00:00:00')
  return d.toLocaleDateString('es-MX', { year: 'numeric', month: '2-digit', day: '2-digit' })
}

const formatCurrency = (val) => {
  if (val === null || val === undefined) return '$0.00'
  const num = typeof val === 'number' ? val : parseFloat(val)
  return '$' + num.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
}

onMounted(() => {
  fetchMercados()
})
</script>

<style scoped>
.empty-icon {
  color: #6c757d;
  opacity: 0.5;
  margin-bottom: 1rem;
}

.badge-primary {
  background: var(--municipal-blue);
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
}

.badge-info {
  background: #17a2b8;
  color: white;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-weight: 600;
}

.bg-success {
  background: linear-gradient(135deg, #28a745 0%, #218838 100%) !important;
}

.totals-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  padding: 1rem;
}

.total-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 1.5rem;
  background: #f8f9fa;
  border-radius: 8px;
  border-left: 4px solid var(--municipal-blue);
}

.total-label {
  font-size: 0.875rem;
  color: #6c757d;
  margin-bottom: 0.5rem;
  font-weight: 600;
  text-transform: uppercase;
}

.total-value {
  font-size: 2rem;
  font-weight: 700;
}
</style>
