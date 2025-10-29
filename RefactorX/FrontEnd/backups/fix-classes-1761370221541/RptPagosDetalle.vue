<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Detalle de Pagos</h1>
        <p>Reporte Detallado de Pagos por Local</p>
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
              <label class="municipal-form-label">Mercado *</label>
              <select class="municipal-form-control" v-model.number="filters.mercado" required>
                <option value="">Seleccione</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">{{ m.num_mercado_nvo }} - {{ m.descripcion }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Categor�a</label>
              <input type="text" class="municipal-form-control" v-model="filters.categoria" maxlength="2" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Secci�n</label>
              <input type="text" class="municipal-form-control" v-model="filters.seccion" maxlength="2" />
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Local</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.local" min="0" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">A�o</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.ano" min="1992" max="2999" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo</label>
              <select class="municipal-form-control" v-model.number="filters.periodo">
                <option value="">Todos</option>
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading || !filters.mercado">
              <font-awesome-icon :icon="loading ? 'spinner' : 'file-invoice-dollar'" :spin="loading" /> Generar Detalle
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
            <font-awesome-icon icon="list" /> Detalle de Pagos
            <span class="badge-info">{{ pagos.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.importe) }}</div>
                <div class="stat-label">Total Pagado</div>
              </div>
            </div>
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.localesUnicos }}</div>
                <div class="stat-label">Locales</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="file-alt" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ pagos.length }}</div>
                <div class="stat-label">Operaciones</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Domicilio</th>
                  <th>A�o</th>
                  <th>Periodo</th>
                  <th>Fecha Pago</th>
                  <th>Caja</th>
                  <th>Operaci�n</th>
                  <th>Partida</th>
                  <th class="text-end">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_pago" class="row-hover">
                  <td><strong>{{ formatLocal(pago) }}</strong></td>
                  <td>{{ pago.nombre }}</td>
                  <td><small>{{ pago.domicilio }}</small></td>
                  <td>{{ pago.anio }}</td>
                  <td><span class="badge-info">{{ String(pago.periodo).padStart(2, '0') }}</span></td>
                  <td>{{ formatFecha(pago.fecha_pago) }}</td>
                  <td>{{ pago.caja }}</td>
                  <td><small>{{ pago.operacion }}</small></td>
                  <td><small>{{ pago.partida }}</small></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(pago.importe) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="9"><strong>TOTAL</strong></td>
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
            <p>No se encontraron pagos para los par�metros especificados</p>
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
  categoria: '',
  seccion: '',
  local: null,
  ano: null,
  periodo: ''
})

const totales = computed(() => {
  return {
    importe: pagos.value.reduce((sum, p) => sum + (parseFloat(p.importe) || 0), 0)
  }
})

const estadisticas = computed(() => {
  const localesSet = new Set(pagos.value.map(p => `${p.oficina}-${p.num_mercado}-${p.seccion}-${p.local}`))
  return {
    localesUnicos: localesSet.size
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

    const result = await executeStoredProcedure('sp_rpt_pagos_detalle', {
      p_oficina: filters.value.oficina,
      p_mercado: filters.value.mercado,
      p_categoria: filters.value.categoria || null,
      p_seccion: filters.value.seccion || null,
      p_local: filters.value.local || null,
      p_anio: filters.value.ano || null,
      p_periodo: filters.value.periodo || null
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
  const headers = ['Local', 'Nombre', 'Domicilio', 'A�o', 'Periodo', 'Fecha Pago', 'Caja', 'Operaci�n', 'Partida', 'Importe']
  const rows = pagos.value.map(p => [
    formatLocal(p),
    p.nombre,
    p.domicilio,
    p.anio,
    String(p.periodo).padStart(2, '0'),
    formatFecha(p.fecha_pago),
    p.caja,
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
  link.download = `pagos_detalle_${filters.value.mercado}_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadMercados()
})
</script>


