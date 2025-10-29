<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="cash-register" /></div>
      <div class="module-view-info">
        <h1>Pagos por Caja</h1>
        <p>Reporte de Ingresos por Caja y Fecha</p>
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
              <label class="municipal-form-label">Caja *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.caja" required min="1" />
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
              <font-awesome-icon :icon="loading ? 'spinner' : 'cash-register'" :spin="loading" /> Generar Reporte
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
            <font-awesome-icon icon="list-alt" /> Pagos de Caja {{ filters.caja }}
            <span class="badge-info">{{ pagos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.importe) }}</div>
                <div class="stat-label">Total Recaudado</div>
              </div>
            </div>
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="file-invoice" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ pagos.length }}</div>
                <div class="stat-label">Operaciones</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="calendar-day" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.diasUnicos }}</div>
                <div class="stat-label">D�as con Pagos</div>
              </div>
            </div>
            <div class="stat-card gradient-info">
              <div class="stat-icon"><font-awesome-icon icon="chart-line" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(estadisticas.promedioDiario) }}</div>
                <div class="stat-label">Promedio Diario</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Fecha</th>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>A�o-Periodo</th>
                  <th>Operaci�n</th>
                  <th>Partida</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_pago" class="row-hover">
                  <td>{{ formatFecha(pago.fecha_pago) }}</td>
                  <td><strong>{{ formatLocal(pago) }}</strong></td>
                  <td>{{ pago.nombre }}</td>
                  <td><span class="badge-info">{{ pago.anio }}-{{ String(pago.periodo).padStart(2, '0') }}</span></td>
                  <td><small>{{ pago.operacion }}</small></td>
                  <td><small>{{ pago.partida }}</small></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(pago.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="6"><strong>TOTAL</strong></td>
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
            <p>No se encontraron pagos para la caja en el rango de fechas especificado</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from 'vue-toastification'

const { executeStoredProcedure } = useApi()
const { handleError } = useLicenciasErrorHandler()
const toast = useToast()

const loading = ref(false)
const searched = ref(false)
const pagos = ref([])
const filters = ref({
  oficina: 1,
  caja: 1,
  fecha_desde: new Date().toISOString().split('T')[0],
  fecha_hasta: new Date().toISOString().split('T')[0]
})

const totales = computed(() => {
  return {
    importe: pagos.value.reduce((sum, p) => sum + (parseFloat(p.importe) || 0), 0)
  }
})

const estadisticas = computed(() => {
  const diasSet = new Set(pagos.value.map(p => p.fecha_pago ? p.fecha_pago.split('T')[0] : ''))
  const promedioDiario = diasSet.size > 0 ? totales.value.importe / diasSet.size : 0
  return {
    diasUnicos: diasSet.size,
    promedioDiario
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

const generar = async () => {
  try {
    loading.value = true
    searched.value = true

    const result = await executeStoredProcedure('sp_rpt_pagos_caja', {
      p_oficina: filters.value.oficina,
      p_caja: filters.value.caja,
      p_fecha_desde: filters.value.fecha_desde,
      p_fecha_hasta: filters.value.fecha_hasta
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
  const headers = ['Fecha', 'Local', 'Nombre', 'A�o-Periodo', 'Operaci�n', 'Partida', 'Importe']
  const rows = pagos.value.map(p => [
    formatFecha(p.fecha_pago),
    formatLocal(p),
    p.nombre,
    `${p.anio}-${String(p.periodo).padStart(2, '0')}`,
    p.operacion,
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
  link.download = `pagos_caja_${filters.value.caja}_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}
</script>


