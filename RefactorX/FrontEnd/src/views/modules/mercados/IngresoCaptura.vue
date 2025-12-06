<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Ingresos Capturados</h1>
        <p>Inicio > Consultas > Ingreso Captura</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="buscar" :disabled="loading || !isFormValid">
          <font-awesome-icon icon="search" /> Buscar
        </button>
        <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Mercado <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.num_mercado"
                     min="1" :disabled="loading" placeholder="Ej: 1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha de Pago <span class="required">*</span></label>
              <input type="date" class="municipal-form-control" v-model="form.fecha_pago" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Oficina de Pago <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.oficina_pago"
                     min="1" :disabled="loading" placeholder="Ej: 1" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Caja de Pago <span class="required">*</span></label>
              <input type="text" class="municipal-form-control" v-model="form.caja_pago"
                     maxlength="3" :disabled="loading" placeholder="Ej: A" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Operación de Pago <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="form.operacion_pago"
                     min="1" :disabled="loading" placeholder="Ej: 100" />
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Resumen de Ingresos Capturados</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
            <span class="badge-info ms-2">Pagos: {{ totalPagos }}</span>
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
                  <th class="text-center">Operación</th>
                  <th class="text-end">Periodos/Pagos</th>
                  <th class="text-end">Renta Pagada</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in results" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td class="text-center">{{ formatDate(row.fecha_pago) }}</td>
                  <td class="text-center"><span class="badge-primary">{{ row.caja_pago }}</span></td>
                  <td class="text-center"><strong class="text-primary">{{ row.operacion_pago }}</strong></td>
                  <td class="text-end"><span class="badge-info">{{ row.pagos }}</span></td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="4" class="text-end"><strong>TOTALES:</strong></td>
                  <td class="text-end"><strong class="text-primary">{{ totalPagos }}</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div v-else-if="searched && !loading" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No hay resultados para los filtros seleccionados</p>
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
import { ref, computed } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const form = ref({
  num_mercado: null,
  fecha_pago: '',
  oficina_pago: null,
  caja_pago: '',
  operacion_pago: null
})

const results = ref([])
const loading = ref(false)
const searched = ref(false)
const toast = ref({ show: false, type: 'info', message: '' })

const isFormValid = computed(() => {
  return form.value.num_mercado && form.value.fecha_pago &&
         form.value.oficina_pago && form.value.caja_pago &&
         form.value.operacion_pago
})

const totalImporte = computed(() => {
  return results.value.reduce((sum, row) => sum + parseFloat(row.importe || 0), 0)
})

const totalPagos = computed(() => {
  return results.value.reduce((sum, row) => sum + parseInt(row.pagos || 0), 0)
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
  showToast('info', 'Complete todos los filtros (mercado, fecha, oficina, caja y operación) para consultar los ingresos capturados en ese periodo.')
}

const buscar = async () => {
  if (!isFormValid.value) {
    showToast('warning', 'Complete todos los campos requeridos')
    return
  }

  loading.value = true
  results.value = []
  searched.value = true

  showLoading()
  try {
    const res = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_ingreso_captura',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_num_mercado', Valor: parseInt(form.value.num_mercado) },
          { Nombre: 'p_fecha_pago', Valor: form.value.fecha_pago },
          { Nombre: 'p_oficina_pago', Valor: parseInt(form.value.oficina_pago) },
          { Nombre: 'p_caja_pago', Valor: form.value.caja_pago.toUpperCase() },
          { Nombre: 'p_operacion_pago', Valor: parseInt(form.value.operacion_pago) }
        ]
      }
    })

    if (res.data.eResponse.success) {
      results.value = res.data.eResponse.data.result || []
      if (results.value.length > 0) {
        showToast('success', `Se encontraron ${results.value.length} registros`)
      } else {
        showToast('info', 'No se encontraron resultados para los filtros aplicados')
      }
    } else {
      showToast('error', res.data.eResponse.message || 'Error al consultar')
    }
  } catch (err) {
    showToast('error', 'Error de conexión al realizar la consulta')
  } finally {
    loading.value = false
    hideLoading()
  }
}

const exportarExcel = () => {
  if (results.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    let csv = 'Fecha de Pago,Caja,Operación,Periodos/Pagos,Renta Pagada\n'
    results.value.forEach(row => {
      csv += `${formatDate(row.fecha_pago)},${row.caja_pago},${row.operacion_pago},${row.pagos},${row.importe}\n`
    })
    csv += `,,TOTALES,${totalPagos.value},${totalImporte.value}\n`

    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `ingreso_captura_${form.value.num_mercado}_${form.value.fecha_pago}.csv`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)

    showToast('success', 'Archivo exportado exitosamente')
  } catch (err) {
    showToast('error', 'Error al exportar')
  }
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
</script>
