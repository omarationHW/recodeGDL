<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Facturaci�n Global</h1>
        <p>Reporte Global de Facturaci�n de Locales</p>
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
              <label class="municipal-form-label">A�o *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.ano" required min="1992" max="2999" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo *</label>
              <select class="municipal-form-control" v-model.number="filters.periodo" required>
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo de Reporte</label>
              <select class="municipal-form-control" v-model.number="filters.tipo">
                <option value="1">Con Adeudos</option>
                <option value="2">Todos los Locales</option>
              </select>
            </div>
              </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'file-invoice-dollar'" :spin="loading" /> Generar Facturaci�n
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="facturacion.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
              </div>
      </div>

      <div class="municipal-card" v-if="facturacion.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" /> Facturaci�n {{ getMesNombreCompleto(filters.periodo) }} {{ filters.ano }}
            <span class="badge-info">{{ facturacion.length }}</span>
          </h5>
              </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-danger">
              <div class="stat-icon"><font-awesome-icon icon="exclamation-triangle" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.adeudo) }}</div>
                <div class="stat-label">Adeudo Total</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="percentage" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.recargos) }}</div>
                <div class="stat-label">Recargos</div>
              </div>
            </div>
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.subtotal) }}</div>
                <div class="stat-label">Total a Facturar</div>
              </div>
            </div>
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ facturacion.length }}</div>
                <div class="stat-label">Locales</div>
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
                  <th>Meses</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Adeudo</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="fac in facturacion" :key="fac.id_local" class="row-hover">
                  <td><strong>{{ formatLocal(fac) }}</strong></td>
                  <td>{{ fac.nombre }}</td>
                  <td>{{ fac.mercado_desc }}</td>
                  <td><span class="badge-info">{{ fac.meses_adeudo }}</span></td>
                  <td class="text-end">{{ formatCurrency(fac.renta) }}</td>
                  <td class="text-end"><strong class="text-danger">{{ formatCurrency(fac.adeudo) }}</strong></td>
                  <td class="text-end text-warning">{{ formatCurrency(fac.recargos) }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(fac.subtotal) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="5"><strong>TOTALES</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.adeudo) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.recargos) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.subtotal) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
              </div>
      </div>

      <div class="municipal-card" v-if="!loading && facturacion.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="check-circle" size="3x" />
            <p>No hay locales con adeudos para el periodo seleccionado</p>
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
const facturacion = ref([])
const filters = ref({
  oficina: 1,
  ano: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1,
  tipo: 1
})

const totales = computed(() => {
  return {
    adeudo: facturacion.value.reduce((sum, f) => sum + (parseFloat(f.adeudo) || 0), 0),
    recargos: facturacion.value.reduce((sum, f) => sum + (parseFloat(f.recargos) || 0), 0),
    subtotal: facturacion.value.reduce((sum, f) => sum + (parseFloat(f.subtotal) || 0), 0)
  }
})

const getMesNombre = (m) => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return meses[m - 1] || m
}

const getMesNombreCompleto = (m) => {
  const meses = ['ENERO', 'FEBRERO', 'MARZO', 'ABRIL', 'MAYO', 'JUNIO', 'JULIO', 'AGOSTO', 'SEPTIEMBRE', 'OCTUBRE', 'NOVIEMBRE', 'DICIEMBRE']
  return meses[m - 1] || m
}

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)

const formatLocal = (item) => {
  return `${item.oficina}-${item.num_mercado}-${item.categoria}-${item.seccion}-${item.local}${item.letra_local || ''}${item.bloque || ''}`
}

const generar = async () => {
  try {
    loading.value = true
    searched.value = true

    const result = await executeStoredProcedure('sp_rpt_factura_global', {
      p_oficina: filters.value.oficina,
      p_axo: filters.value.ano,
      p_mes: filters.value.periodo,
      p_tipo: filters.value.tipo
    })

    if (result.success) {
      facturacion.value = result.data || []
      if (facturacion.value.length > 0) {
        toast.success(`${facturacion.value.length} locales encontrados`)
      } else {
        toast.info('No hay locales para facturaci�n')
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
  const headers = ['Local', 'Nombre', 'Mercado', 'Meses', 'Renta', 'Adeudo', 'Recargos', 'Subtotal']
  const rows = facturacion.value.map(f => [
    formatLocal(f),
    f.nombre,
    f.mercado_desc,
    f.meses_adeudo,
    f.renta,
    f.adeudo,
    f.recargos,
    f.subtotal
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `factura_global_${filters.value.ano}_${filters.value.periodo}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}
</script>


