<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="building" /></div>
      <div class="module-view-info">
        <h1>Cat�logo de Mercados</h1>
        <p>Listado Completo de Mercados Municipales</p>
      </div>
              </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Par�metros del Reporte</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.oficina" min="1" />
            </div>
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
              <font-awesome-icon :icon="loading ? 'spinner' : 'building'" :spin="loading" /> Generar Listado
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="mercados.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
              </div>
      </div>

      <div class="municipal-card" v-if="mercados.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" /> Mercados Registrados
            <span class="badge-info">{{ mercados.length }}</span>
          </h5>
              </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="building" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ mercados.length }}</div>
                <div class="stat-label">Total Mercados</div>
              </div>
            </div>
            <div class="stat-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="map-marker-alt" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.zonasUnicas }}</div>
                <div class="stat-label">Zonas</div>
              </div>
            </div>
            <div class="stat-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="store" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ estadisticas.tiposEmision }}</div>
                <div class="stat-label">Tipos de Emisi�n</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Oficina</th>
                  <th>No. Mercado</th>
                  <th>Descripci�n</th>
                  <th>Zona</th>
                  <th>Cuenta Ingreso</th>
                  <th>Cuenta Energ�a</th>
                  <th>Tipo Emisi�n</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="merc in mercados" :key="merc.id_mercado" class="row-hover">
                  <td>{{ merc.oficina }}</td>
                  <td><strong>{{ merc.num_mercado_nvo }}</strong></td>
                  <td>{{ merc.descripcion }}</td>
                  <td><span class="badge-info">{{ merc.clave_zona }} - {{ merc.zona_desc }}</span></td>
                  <td><small>{{ merc.cuenta_ingreso }}</small></td>
                  <td><small>{{ merc.cuenta_energia }}</small></td>
                  <td><span :class="getTipoEmisionBadge(merc.tipo_emision)">{{ getTipoEmisionDesc(merc.tipo_emision) }}</span></td>
                </tr>
              </tbody>
            </table>
          </div>
              </div>
      </div>

      <div class="municipal-card" v-if="!loading && mercados.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="info-circle" size="3x" />
            <p>No se encontraron mercados para los par�metros especificados</p>
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
const mercados = ref([])
const filters = ref({
  oficina: null,
  zona: ''
})

const estadisticas = computed(() => {
  const zonasSet = new Set(mercados.value.map(m => m.clave_zona))
  const tiposSet = new Set(mercados.value.map(m => m.tipo_emision))
  return {
    zonasUnicas: zonasSet.size,
    tiposEmision: tiposSet.size
  }
})

const getTipoEmisionDesc = (tipo) => {
  const tipos = {
    'L': 'LASER',
    'M': 'MANUAL',
    'P': 'PUNTO DE VENTA'
  }
  return tipos[tipo] || tipo
}

const getTipoEmisionBadge = (tipo) => {
  const badges = {
    'L': 'badge-primary',
    'M': 'badge-warning',
    'P': 'badge-success'
  }
  return badges[tipo] || 'badge-secondary'
}

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

    const result = await executeStoredProcedure('sp_rpt_mercados', {
      p_oficina: filters.value.oficina || null,
      p_zona: filters.value.zona || null
    })

    if (result.success) {
      mercados.value = result.data || []
      if (mercados.value.length > 0) {
        toast.success(`${mercados.value.length} mercados encontrados`)
      } else {
        toast.info('No se encontraron mercados')
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
  const headers = ['Oficina', 'No. Mercado', 'Descripci�n', 'Zona', 'Cuenta Ingreso', 'Cuenta Energ�a', 'Tipo Emisi�n']
  const rows = mercados.value.map(m => [
    m.oficina,
    m.num_mercado_nvo,
    m.descripcion,
    `${m.clave_zona} - ${m.zona_desc}`,
    m.cuenta_ingreso,
    m.cuenta_energia,
    getTipoEmisionDesc(m.tipo_emision)
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `\"${cell}\"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `mercados_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadZonas()
  generar() // Cargar todos los mercados por defecto
})
</script>


