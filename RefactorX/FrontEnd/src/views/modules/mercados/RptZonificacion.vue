<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="map-marked-alt" /></div>
      <div class="module-view-info">
        <h1>Zonificaci�n de Mercados</h1>
        <p>Reporte de Mercados y Locales por Zona</p>
      </div>
              </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Par�metros del Reporte</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Zona</label>
              <select class="municipal-form-control" v-model.number="filters.zona">
                <option value="">Todas</option>
                <option v-for="z in zonas" :key="z.clave_zona" :value="z.clave_zona">{{ z.clave_zona }} - {{ z.descripcion }}</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'map-marked-alt'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="zonificacion.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="zonificacion.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" /> Zonificaci�n de Mercados
            <span class="badge-info">{{ zonificacion.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-municipal-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="map-marker-alt" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.zonasUnicas }}</div>
                <div class="stat-label">Zonas</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.mercadosUnicos }}</div>
                <div class="stat-label">Mercados</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="store" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ totales.total_locales }}</div>
                <div class="stat-label">Locales Totales</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-info">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.renta_total) }}</div>
                <div class="stat-label">Renta Global</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Zona</th>
                  <th>Descripci�n Zona</th>
                  <th>Mercado</th>
                  <th>Descripci�n Mercado</th>
                  <th class="text-end">Locales</th>
                  <th class="text-end">Superficie Total</th>
                  <th class="text-end">Renta Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(item, idx) in zonificacion" :key="idx" class="row-hover">
                  <td><strong>{{ item.clave_zona }}</strong></td>
                  <td>{{ item.zona_desc }}</td>
                  <td><span class="badge-primary">{{ item.num_mercado }}</span></td>
                  <td>{{ item.mercado_desc }}</td>
                  <td class="text-end">{{ item.total_locales }}</td>
                  <td class="text-end">{{ item.superficie_total.toFixed(2) }} m�</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(item.renta_total) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="4"><strong>TOTALES</strong></td>
                  <td class="text-end"><strong>{{ totales.total_locales }}</strong></td>
                  <td class="text-end"><strong>{{ totales.superficie_total.toFixed(2) }} m�</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.renta_total) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && zonificacion.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="info-circle" size="3x" />
            <p>No se encontraron datos de zonificaci�n</p>
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
const zonas = ref([])
const zonificacion = ref([])
const filters = ref({
  zona: ''
})

const totales = computed(() => {
  return {
    total_locales: zonificacion.value.reduce((sum, z) => sum + (parseInt(z.total_locales) || 0), 0),
    superficie_total: zonificacion.value.reduce((sum, z) => sum + (parseFloat(z.superficie_total) || 0), 0),
    renta_total: zonificacion.value.reduce((sum, z) => sum + (parseFloat(z.renta_total) || 0), 0)
  }
})

const estadisticas = computed(() => {
  const zonasSet = new Set(zonificacion.value.map(z => z.clave_zona))
  const mercadosSet = new Set(zonificacion.value.map(z => z.num_mercado))
  return {
    zonasUnicas: zonasSet.size,
    mercadosUnicos: mercadosSet.size
  }
})

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)

const loadZonas = async () => {
  const result = await executeStoredProcedure('get_zonas_list', {})
  if (result.success) {
    zonas.value = result.data || []
  }
}

const generar = async () => {
  try {
    loading.value = true
    searched.value = true

    const result = await executeStoredProcedure('sp_rpt_zonificacion', {
      p_zona: filters.value.zona || null
    })

    if (result.success) {
      zonificacion.value = result.data || []
      if (zonificacion.value.length > 0) {
        toast.success(`${zonificacion.value.length} registros encontrados`)
      } else {
        toast.info('No se encontraron datos')
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
  const headers = ['Zona', 'Descripci�n Zona', 'Mercado', 'Descripci�n Mercado', 'Locales', 'Superficie Total', 'Renta Total']
  const rows = zonificacion.value.map(z => [
    z.clave_zona,
    z.zona_desc,
    z.num_mercado,
    z.mercado_desc,
    z.total_locales,
    z.superficie_total.toFixed(2),
    z.renta_total
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `zonificacion_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadZonas()
  generar() // Cargar todas las zonas por defecto
})
</script>

