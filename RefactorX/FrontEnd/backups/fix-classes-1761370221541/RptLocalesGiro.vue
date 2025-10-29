<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Locales por Giro</h1>
        <p>Listado de Locales Agrupados por Tipo de Giro</p>
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
              <label class="municipal-form-label">Giro</label>
              <select class="municipal-form-control" v-model.number="filters.giro">
                <option value="">Todos</option>
                <option v-for="g in giros" :key="g.clave_giro" :value="g.clave_giro">{{ g.clave_giro }} - {{ g.descripcion }}</option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="generar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'store'" :spin="loading" /> Generar Listado
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="locales.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
              </div>
      </div>

      <div class="municipal-card" v-if="locales.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-alt" /> Locales por Giro
            <span class="badge-info">{{ locales.length }}</span>
          </h5>
              </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ locales.length }}</div>
                <div class="stat-label">Total Locales</div>
              </div>
            </div>
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="store" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.girosUnicos }}</div>
                <div class="stat-label">Giros Diferentes</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="dollar-sign" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.renta) }}</div>
                <div class="stat-label">Renta Total</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Giro</th>
                  <th>Domicilio</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                  <th>Vigencia</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="local in locales" :key="local.id_local" class="row-hover">
                  <td><strong>{{ formatLocal(local) }}</strong></td>
                  <td>{{ local.nombre }}</td>
                  <td><span class="badge-info">{{ local.clave_giro }} - {{ local.giro_desc }}</span></td>
                  <td><small>{{ local.domicilio }}</small></td>
                  <td class="text-end">{{ local.superficie }}</td>
                  <td class="text-end">{{ formatCurrency(local.renta) }}</td>
                  <td><span :class="getVigenciaBadge(local.vigencia)">{{ getVigenciaDescripcion(local.vigencia) }}</span></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="4"><strong>TOTALES</strong></td>
                  <td class="text-end"><strong>{{ totales.superficie.toFixed(2) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totales.renta) }}</strong></td>
                  <td></td>
                </tr>
              </tfoot>
            </table>
          </div>
              </div>
      </div>

      <div class="municipal-card" v-if="!loading && locales.length === 0 && searched">
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
const giros = ref([])
const locales = ref([])
const filters = ref({
  oficina: 1,
  mercado: '',
  giro: ''
})

const totales = computed(() => {
  return {
    renta: locales.value.reduce((sum, l) => sum + (parseFloat(l.renta) || 0), 0),
    superficie: locales.value.reduce((sum, l) => sum + (parseFloat(l.superficie) || 0), 0)
  }
})

const estadisticas = computed(() => {
  const girosSet = new Set(locales.value.map(l => l.clave_giro))
  return {
    girosUnicos: girosSet.size
  }
})

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)

const formatLocal = (item) => {
  return `${item.oficina}-${item.num_mercado}-${item.categoria}-${item.seccion}-${item.local}${item.letra_local || ''}${item.bloque || ''}`
}

const getVigenciaDescripcion = (vig) => {
  const descripciones = {
    'A': 'VIGENTE',
    'B': 'BAJA',
    'C': 'BAJA POR ACUERDO',
    'D': 'BAJA ADMINISTRATIVA'
  }
  return descripciones[vig] || 'VIGENTE'
}

const getVigenciaBadge = (vig) => {
  const badges = {
    'A': 'badge-success',
    'B': 'badge-danger',
    'C': 'badge-warning',
    'D': 'badge-secondary'
  }
  return badges[vig] || 'badge-success'
}

const loadMercados = async () => {
  const result = await executeStoredProcedure('get_mercados_list', {})
  if (result.success) {
    mercados.value = result.data || []
  }
}

const loadGiros = async () => {
  const result = await executeStoredProcedure('get_giros_list', {})
  if (result.success) {
    giros.value = result.data || []
  }
}

const generar = async () => {
  try {
    loading.value = true
    searched.value = true

    const result = await executeStoredProcedure('sp_rpt_locales_giro', {
      p_oficina: filters.value.oficina,
      p_mercado: filters.value.mercado || null,
      p_giro: filters.value.giro || null
    })

    if (result.success) {
      locales.value = result.data || []
      if (locales.value.length > 0) {
        toast.success(`${locales.value.length} locales encontrados`)
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
  const headers = ['Local', 'Nombre', 'Giro', 'Domicilio', 'Superficie', 'Renta', 'Vigencia']
  const rows = locales.value.map(l => [
    formatLocal(l),
    l.nombre,
    `${l.clave_giro} - ${l.giro_desc}`,
    l.domicilio,
    l.superficie,
    l.renta,
    getVigenciaDescripcion(l.vigencia)
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `locales_giro_${filters.value.oficina}_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadMercados()
  loadGiros()
})
</script>


