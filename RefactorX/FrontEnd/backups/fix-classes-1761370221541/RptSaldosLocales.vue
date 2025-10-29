<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="balance-scale" /></div>
      <div class="module-view-info">
        <h1>Saldos de Locales</h1>
        <p>Estado de Cuenta por Local y Periodo</p>
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
            <div class="form-group">
              <label class="municipal-form-label">Hasta Periodo</label>
              <select class="municipal-form-control" v-model.number="filters.hasta_periodo">
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'balance-scale'" :spin="loading" /> Generar Saldos
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="saldos.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="saldos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-alt" /> Saldos al {{ getMesNombre(filters.hasta_periodo) }} {{ filters.ano }}
            <span class="badge-info">{{ saldos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-danger">
              <div class="stat-icon"><font-awesome-icon icon="exclamation-triangle" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.adeudo_total) }}</div>
                <div class="stat-label">Adeudo Total</div>
              </div>
            </div>
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.pagado_total) }}</div>
                <div class="stat-label">Total Pagado</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ saldos.length }}</div>
                <div class="stat-label">Locales</div>
              </div>
            </div>
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="percent" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.porcentajePago.toFixed(1) }}%</div>
                <div class="stat-label">% Cobranza</div>
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
                  <th class="text-end">Renta Mensual</th>
                  <th class="text-end">Meses Adeudo</th>
                  <th class="text-end">Total Adeudo</th>
                  <th class="text-end">Total Pagado</th>
                  <th class="text-end">Saldo</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="saldo in saldos" :key="saldo.id_local" class="row-hover">
                  <td><strong>{{ formatLocal(saldo) }}</strong></td>
                  <td>{{ saldo.nombre }}</td>
                  <td>{{ saldo.mercado_desc }}</td>
                  <td class="text-end">{{ formatCurrency(saldo.renta_mensual) }}</td>
                  <td class="text-end"><span class="badge-warning">{{ saldo.meses_adeudo }}</span></td>
                  <td class="text-end"><strong class="text-danger">{{ formatCurrency(saldo.total_adeudo) }}</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(saldo.total_pagado) }}</strong></td>
                  <td class="text-end"><strong :class="getSaldoClass(saldo.saldo)">{{ formatCurrency(saldo.saldo) }}</strong></td>
                  <td><span :class="getEstadoBadge(saldo.saldo)">{{ getEstadoDescripcion(saldo.saldo) }}</span></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="5"><strong>TOTALES</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.adeudo_total) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.pagado_total) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.saldo_total) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && saldos.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="info-circle" size="3x" />
            <p>No se encontraron locales para los par�metros especificados</p>
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
const saldos = ref([])
const filters = ref({
  oficina: 1,
  mercado: '',
  ano: new Date().getFullYear(),
  hasta_periodo: new Date().getMonth() + 1
})

const totales = computed(() => {
  return {
    adeudo_total: saldos.value.reduce((sum, s) => sum + (parseFloat(s.total_adeudo) || 0), 0),
    pagado_total: saldos.value.reduce((sum, s) => sum + (parseFloat(s.total_pagado) || 0), 0),
    saldo_total: saldos.value.reduce((sum, s) => sum + (parseFloat(s.saldo) || 0), 0)
  }
})

const estadisticas = computed(() => {
  const totalEsperado = totales.value.adeudo_total
  const porcentajePago = totalEsperado > 0 ? (totales.value.pagado_total / totalEsperado) * 100 : 0
  return {
    porcentajePago
  }
})

const getMesNombre = (m) => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return meses[m - 1] || m
}

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)

const formatLocal = (item) => {
  return `${item.oficina}-${item.num_mercado}-${item.categoria}-${item.seccion}-${item.local}${item.letra_local || ''}${item.bloque || ''}`
}

const getSaldoClass = (saldo) => {
  return saldo < 0 ? 'text-danger' : 'text-success'
}

const getEstadoDescripcion = (saldo) => {
  if (saldo === 0) return 'AL CORRIENTE'
  return saldo < 0 ? 'CON ADEUDO' : 'CON SALDO A FAVOR'
}

const getEstadoBadge = (saldo) => {
  if (saldo === 0) return 'badge-success'
  return saldo < 0 ? 'badge-danger' : 'badge-primary'
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

    const result = await executeStoredProcedure('sp_rpt_saldos_locales', {
      p_oficina: filters.value.oficina,
      p_mercado: filters.value.mercado || null,
      p_anio: filters.value.ano,
      p_hasta_periodo: filters.value.hasta_periodo
    })

    if (result.success) {
      saldos.value = result.data || []
      if (saldos.value.length > 0) {
        toast.success(`${saldos.value.length} locales encontrados`)
      } else {
        toast.info('No se encontraron locales')
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
  const headers = ['Local', 'Nombre', 'Mercado', 'Renta Mensual', 'Meses Adeudo', 'Total Adeudo', 'Total Pagado', 'Saldo', 'Estado']
  const rows = saldos.value.map(s => [
    formatLocal(s),
    s.nombre,
    s.mercado_desc,
    s.renta_mensual,
    s.meses_adeudo,
    s.total_adeudo,
    s.total_pagado,
    s.saldo,
    getEstadoDescripcion(s.saldo)
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `saldos_locales_${filters.value.ano}_${filters.value.hasta_periodo}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadMercados()
})
</script>

