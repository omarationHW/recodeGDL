<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calendar-alt" /></div>
      <div class="module-view-info">
        <h1>Pagos por A�o</h1>
        <p>Reporte Anual de Pagos de Locales</p>
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
              <label class="municipal-form-label">A�o *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.ano" required min="1992" max="2999" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'calendar-alt'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="pagos.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="pagos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="file-invoice-dollar" /> Pagos Registrados - A�o {{ filters.ano }}
            <span class="badge-info">{{ pagos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-municipal-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.importe) }}</div>
                <div class="stat-label">Total Pagado</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="file-alt" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ pagos.length }}</div>
                <div class="stat-label">Pagos</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.localesUnicos }}</div>
                <div class="stat-label">Locales Pagaron</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-info">
              <div class="stat-icon"><font-awesome-icon icon="chart-bar" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(estadisticas.promedio) }}</div>
                <div class="stat-label">Promedio por Pago</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Mercado</th>
                  <th>Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Caja</th>
                  <th>Partida</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_pago" class="row-hover">
                  <td><strong>{{ formatLocal(pago) }}</strong></td>
                  <td>{{ pago.nombre }}</td>
                  <td>{{ pago.mercado_desc }}</td>
                  <td><span class="badge-info">{{ String(pago.periodo).padStart(2, '0') }}</span></td>
                  <td>{{ formatFecha(pago.fecha_pago) }}</td>
                  <td>{{ pago.caja }}</td>
                  <td><small>{{ pago.partida }}</small></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(pago.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="7"><strong>TOTAL</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.importe) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && pagos.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="info-circle" size="3x" />
            <p>No se encontraron pagos para el a�o especificado</p>
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
const pagos = ref([])
const filters = ref({
  oficina: 1,
  mercado: '',
  ano: new Date().getFullYear()
})

const totales = computed(() => {
  return {
    importe: pagos.value.reduce((sum, p) => sum + (parseFloat(p.importe) || 0), 0)
  }
})

const estadisticas = computed(() => {
  const localesSet = new Set(pagos.value.map(p => `${p.oficina}-${p.num_mercado}-${p.seccion}-${p.local}`))
  const promedio = pagos.value.length > 0 ? totales.value.importe / pagos.value.length : 0
  return {
    localesUnicos: localesSet.size,
    promedio
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

    const result = await executeStoredProcedure('sp_rpt_pagos_ano', {
      p_oficina: filters.value.oficina,
      p_mercado: filters.value.mercado || null,
      p_anio: filters.value.ano
    })

    if (result.success) {
      pagos.value = result.data || []
      if (pagos.value.length > 0) {
        toast.success(`${pagos.value.length} pagos encontrados`)
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
  const headers = ['Local', 'Nombre', 'Mercado', 'Periodo', 'Fecha Pago', 'Caja', 'Partida', 'Importe']
  const rows = pagos.value.map(p => [
    formatLocal(p),
    p.nombre,
    p.mercado_desc,
    String(p.periodo).padStart(2, '0'),
    formatFecha(p.fecha_pago),
    p.caja,
    p.partida,
    p.importe
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `pagos_ano_${filters.value.ano}_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadMercados()
})
</script>


