<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos Condonados</h1>
        <p>Consulta de Adeudos y Prescripciones Cancelados</p>
      </div>
        </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Filtros de B�squeda</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Mercado</label>
              <select class="municipal-form-control" v-model="filters.mercado">
                <option value="">Todos</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">{{ m.num_mercado_nvo }} - {{ m.descripcion }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">A�o</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.ano" min="1992" max="2999" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo</label>
              <select class="municipal-form-control" v-model.number="filters.periodo">
                <option :value="null">Todos</option>
                <option v-for="m in 12" :key="m" :value="m">{{ getMesNombre(m) }}</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="filters.tipo">
                <option value="">Todos</option>
                <option value="P">Prescripciones</option>
                <option value="C">Condonaciones</option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaDesde" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta</label>
              <input type="date" class="municipal-form-control" v-model="filters.fechaHasta" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" @click="buscar" :disabled="loading">
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Generar Reporte
            </button>
            <button class="btn-municipal-secondary" @click="limpiar">
              <font-awesome-icon icon="eraser" /> Limpiar
            </button>
            <button class="btn-municipal-success" @click="exportar" :disabled="condonaciones.length === 0">
              <font-awesome-icon icon="file-excel" /> Exportar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="condonaciones.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" /> Adeudos Condonados/Prescritos
            <span class="badge-info">{{ condonaciones.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="stats-grid" style="margin-bottom: 20px;">
            <div class="stat-municipal-card gradient-success">
              <div class="stat-icon"><font-awesome-icon icon="coins" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ formatCurrency(totales.total) }}</div>
                <div class="stat-label">Total Condonado</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-primary">
              <div class="stat-icon"><font-awesome-icon icon="file-signature" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ totales.prescripciones }}</div>
                <div class="stat-label">Prescripciones</div>
              </div>
            </div>
            <div class="stat-municipal-card gradient-warning">
              <div class="stat-icon"><font-awesome-icon icon="hand-holding-usd" /></div>
              <div class="stat-info">
                <div class="stat-value">{{ totales.condonaciones }}</div>
                <div class="stat-label">Condonaciones</div>
              </div>
            </div>
          </div>

          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Mercado</th>
                  <th>Local</th>
                  <th>A�o</th>
                  <th>Periodo</th>
                  <th class="text-end">Importe</th>
                  <th>Tipo</th>
                  <th>Observaci�n</th>
                  <th>Fecha</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="cond in condonaciones" :key="cond.id_cancelacion" class="row-hover">
                  <td>{{ cond.id_cancelacion }}</td>
                  <td>{{ cond.num_mercado }}</td>
                  <td><strong>{{ cond.local }}{{ cond.letra_local }}{{ cond.bloque }}</strong></td>
                  <td>{{ cond.axo }}</td>
                  <td>{{ getMesNombre(cond.periodo) }}</td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(cond.importe) }}</strong></td>
                  <td>
                    <span :class="cond.clave_canc === 'P' ? 'badge-primary' : 'badge-warning'">
                      {{ cond.clave_canc === 'P' ? 'Prescripci�n' : 'Condonaci�n' }}
                    </span>
                  </td>
                  <td><small>{{ cond.observacion }}</small></td>
                  <td>{{ formatDate(cond.fecha_alta) }}</td>
                  <td><small>{{ cond.usuario }}</small></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading && condonaciones.length === 0 && searched">
        <div class="municipal-card-body">
          <div class="empty-message">
            <font-awesome-icon icon="info-circle" size="3x" />
            <p>No se encontraron adeudos condonados con los filtros seleccionados</p>
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
const condonaciones = ref([])
const filters = ref({
  mercado: '',
  ano: new Date().getFullYear(),
  periodo: null,
  tipo: '',
  fechaDesde: '',
  fechaHasta: ''
})

const totales = computed(() => {
  return {
    total: condonaciones.value.reduce((sum, c) => sum + (parseFloat(c.importe) || 0), 0),
    prescripciones: condonaciones.value.filter(c => c.clave_canc === 'P').length,
    condonaciones: condonaciones.value.filter(c => c.clave_canc === 'C').length
  }
})

const getMesNombre = (m) => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  return meses[m - 1] || m
}

const formatCurrency = (value) => new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
const formatDate = (date) => date ? new Date(date).toLocaleDateString('es-MX') : 'N/A'

const loadMercados = async () => {
  const result = await executeStoredProcedure('get_mercados_list', {})
  if (result.success) {
    mercados.value = result.data || []
  }
}

const buscar = async () => {
  try {
    loading.value = true
    searched.value = true

    const result = await executeStoredProcedure('sp_get_adeudos_condonados', {
      p_mercado: filters.value.mercado || null,
      p_ano: filters.value.ano || null,
      p_periodo: filters.value.periodo || null,
      p_tipo: filters.value.tipo || null,
      p_fecha_desde: filters.value.fechaDesde || null,
      p_fecha_hasta: filters.value.fechaHasta || null
    })

    if (result.success) {
      condonaciones.value = result.data || []
      if (condonaciones.value.length > 0) {
        toast.success(`${condonaciones.value.length} registros encontrados`)
      } else {
        toast.info('No se encontraron registros')
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

const limpiar = () => {
  filters.value = {
    mercado: '',
    ano: new Date().getFullYear(),
    periodo: null,
    tipo: '',
    fechaDesde: '',
    fechaHasta: ''
  }
  condonaciones.value = []
  searched.value = false
}

const exportar = () => {
  // Preparar datos para CSV
  const headers = ['ID', 'Mercado', 'Local', 'A�o', 'Periodo', 'Importe', 'Tipo', 'Observaci�n', 'Fecha', 'Usuario']
  const rows = condonaciones.value.map(c => [
    c.id_cancelacion,
    c.num_mercado,
    `${c.local}${c.letra_local || ''}${c.bloque || ''}`,
    c.axo,
    c.periodo,
    c.importe,
    c.clave_canc === 'P' ? 'Prescripci�n' : 'Condonaci�n',
    c.observacion,
    formatDate(c.fecha_alta),
    c.usuario
  ])

  let csvContent = headers.join(',') + '\n'
  rows.forEach(row => {
    csvContent += row.map(cell => `"${cell}"`).join(',') + '\n'
  })

  const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' })
  const link = document.createElement('a')
  link.href = URL.createObjectURL(blob)
  link.download = `adeudos_condonados_${new Date().getTime()}.csv`
  link.click()
  toast.success('Archivo exportado correctamente')
}

onMounted(() => {
  loadMercados()
})
</script>


