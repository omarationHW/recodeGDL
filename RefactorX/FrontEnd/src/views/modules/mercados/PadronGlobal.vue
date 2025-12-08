<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Padrón Global de Locales</h1>
        <p>Inicio > Mercados > Padrón Global</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Filtros de Consulta</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-3 mb-3">
            <label class="municipal-form-label">Año</label>
            <input type="number" v-model.number="filters.axo" class="municipal-form-control" min="1995" max="3000" :disabled="loading" />
          </div>
          <div class="col-md-3 mb-3">
            <label class="municipal-form-label">Mes</label>
            <input type="number" v-model.number="filters.mes" class="municipal-form-control" min="1" max="12" :disabled="loading" />
          </div>
          <div class="col-md-4 mb-3">
            <label class="municipal-form-label">Estado del local</label>
            <select v-model="filters.vig" class="municipal-form-control" :disabled="loading">
              <option value="A">VIGENTES</option>
              <option value="B">CON BAJA TOTAL</option>
              <option value="C">CON BAJA POR ACUERDO</option>
              <option value="D">CON BAJA ADMINISTRATIVA</option>
            </select>
          </div>
          <div class="col-md-2 mb-3 d-flex align-items-end">
            <button class="btn-municipal-primary w-100" @click="fetchPadron" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              Consultar
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="municipal-card mb-3">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <h5>Padrón Global de Locales</h5>
        <div>
          <button class="btn-municipal-success me-2" @click="exportExcel" :disabled="loading">Exportar Excel</button>
          <button class="btn-municipal-secondary" @click="$router.push('/')">Salir</button>
        </div>
      </div>
      <div class="municipal-card-body p-0">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div v-else class="table-responsive">
          <table class="municipal-table table-sm table-hover mb-0">
            <thead>
              <tr>
                <th>Rec.</th>
                <th>Merc.</th>
                <th>Nombre Mercado</th>
                <th>Cat.</th>
                <th>Secc.</th>
                <th>Local</th>
                <th>Let</th>
                <th>Blq</th>
                <th>Nombre</th>
                <th>Adicionales</th>
                <th>Superficie</th>
                <th>Renta</th>
                <th>Estado</th>
                <th>Leyenda</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in padron" :key="row.id_local">
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local }}</td>
                <td>{{ row.bloque }}</td>
                <td>{{ row.nombre }}</td>
                <td>{{ row.descripcion_local }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ formatCurrency(row.renta) }}</td>
                <td>{{ estadoLabel(row.vigencia) }}</td>
                <td>{{ row.leyenda }}</td>
              </tr>
              <tr v-if="padron.length === 0">
                <td colspan="14" class="text-center">No hay datos para los filtros seleccionados.</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const router = useRouter()
const toast = useToast()

const loading = ref(false)
const padron = ref([])

const now = new Date()
const filters = ref({
  axo: now.getFullYear(),
  mes: now.getMonth() + 1,
  vig: 'A'
})

const fetchPadron = async () => {
  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_padron_global',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_mes', Valor: parseInt(filters.value.mes) },
          { Nombre: 'p_vigencia', Valor: filters.value.vig }
        ]
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result) {
      padron.value = response.data.eResponse.data.result
      toast.success(`Se encontraron ${padron.value.length} registros`)
    } else {
      padron.value = []
      toast.info('No se encontraron datos para los filtros seleccionados')
    }
  } catch (error) {
    toast.error('Error al consultar el padrón global')
    console.error('Error:', error)
    padron.value = []
  } finally {
    loading.value = false
  }
}

const exportExcel = async () => {
  if (padron.value.length === 0) {
    toast.warning('No hay datos para exportar')
    return
  }

  loading.value = true
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_vencimiento_rec',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_mes', Valor: parseInt(filters.value.mes) },
          { Nombre: 'p_vigencia', Valor: filters.value.vig }
        ]
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.url) {
      window.open(response.data.eResponse.data.url, '_blank')
      toast.success('Archivo Excel generado correctamente')
    } else {
      toast.error('No se pudo generar el archivo Excel')
    }
  } catch (error) {
    toast.error('Error al exportar a Excel')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const estadoLabel = (vig) => {
  const estados = {
    'A': 'VIGENTE',
    'B': 'BAJA TOTAL',
    'C': 'BAJA POR ACUERDO',
    'D': 'BAJA ADMINISTRATIVA'
  }
  return estados[vig] || vig
}

const formatCurrency = (val) => {
  if (typeof val === 'number') {
    return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' })
  }
  return val || ''
}

onMounted(() => {
  fetchPadron()
})
</script>

<style scoped>
/* Estilos adicionales si son necesarios */
</style>
