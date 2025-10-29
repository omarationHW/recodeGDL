<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bolt" /></div>
      <div class="module-view-info">
        <h1>Ingresos de Energ�a</h1>
        <p>Detalle de Pagos de Energ�a El�ctrica</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Par�metros del Reporte</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.oficina" required min="1" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado</label>
              <select class="municipal-form-control" v-model.number="filters.mercado">
                <option value="">Todos</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">{{ m.num_mercado_nvo }} - {{ m.descripcion }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde *</label>
              <input type="date" class="municipal-form-control" v-model="filters.fecha_desde" required />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta *</label>
              <input type="date" class="municipal-form-control" v-model="filters.fecha_hasta" required />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'bolt'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="ingresos.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="ingresos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="chart-line" /> Pagos de Energ�a Registrados
            <span class="badge-info">{{ ingresos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.importe) }}</div>
                <div class="stat-label">Total Ingresado</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="chart-area" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ totales.cantidad.toFixed(2) }}</div>
                <div class="stat-label">Cantidad Total</div>
              </div>
            </div>
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="file-invoice" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ ingresos.length }}</div>
                <div class="stat-label">Pagos</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Local Adic.</th>
                  <th>A�o-Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Caja</th>
                  <th class="text-end">Cantidad</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="ing in ingresos" :key="ing.id_pago_energia" class="row-hover">
                  <td><strong>{{ formatLocal(ing) }}</strong></td>
                  <td>{{ ing.nombre }}</td>
                  <td>{{ ing.local_adicional }}</td>
                  <td>{{ ing.anio }}-{{ String(ing.periodo).padStart(2, '0') }}</td>
                  <td>{{ formatFecha(ing.fecha_pago) }}</td>
                  <td>{{ ing.caja }}</td>
                  <td class="text-end">{{ ing.cantidad }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(ing.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="6"><strong>TOTAL</strong></td>
                  <td class="text-end"><strong>{{ totales.cantidad.toFixed(2) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.importe) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && ingresos.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="info-circle" size="3x" />
            <p>No se encontraron pagos de energ�a para los par�metros especificados</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from 'vue-toastification'

const { executeStoredProcedure } = useApi()
const { handleError } = useLicenciasErrorHandler()
const toast = useToast()

const loading = ref(false)
const searched = ref(false)
const mercados = ref([])
const ingresos = ref([])
const filters = ref({
  oficina: 1,
  mercado: '',
  fecha_desde: new Date().toISOString().split('T')[0],
  fecha_hasta: new Date().toISOString().split('T')[0]
})

const totales = computed(() => {
  return {
    importe: ingresos.value.reduce((sum, i) => sum + (parseFloat(i.importe) || 0), 0),
    cantidad: ingresos.value.reduce((sum, i) => sum + (parseFloat(i.cantidad) || 0), 0)
  }
})

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)

const formatLocal = (item) => {
  return `${item.oficina}-${item.num_mercado}-${item.categoria}-${item.seccion}-${item.local}${item.letra_local || ''}${item.bloque || ''}`
}

const formatFecha = (fecha) => {
  if (!fecha) return ''
  return new Date(fecha).toLocaleDateString('es-MX')
}

const loadMercados = async () => {
  const result = await executeStoredProcedure('get_mercados_list', {})
  if (result.success) {
    mercados.value = result.data || []
  }
}

const generar = async () => {
  try {
    loading.value = true
    searched.value = true

    const result = await executeStoredProcedure('sp_rpt_ingresos_energia', {
      p_oficina: filters.value.oficina,
      p_mercado: filters.value.mercado || null,
      p_fecha_desde: filters.value.fecha_desde,
      p_fecha_hasta: filters.value.fecha_hasta
    })

    if (result.success) {
      ingresos.value = result.data || []
      if (ingresos.value.length > 0) {
        toast.success(`${ingresos.value.length} pagos encontrados`)
      } else {
        toast.info('No se encontraron pagos')
      }
    } else {
      handleError(result)
    }
  } catch (error) {
    handleError(error)
  } finally {
    loading.value = false
  }
}

const exportar = () => {
  const headers = ['Local', 'Nombre', 'Local Adic.', 'A�o-Periodo', 'Fecha Pago', 'Caja', 'Cantidad', 'Importe']
  const rows = ingresos.value.map(i => [
    formatLocal(i),
    i.nombre,
    i.local_adicional,
    `${i.anio}-${String(i.periodo).padStart(2, '0')}`,
    formatFecha(i.fecha_pago),
    i.caja,
    i.cantidad,
    i.importe
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `ingresos_energia_${filters.value.oficina}_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadMercados()
})
</script>


