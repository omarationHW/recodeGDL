<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-pie" /></div>
      <div class="module-view-info"><h1>Reportes y Estadísticas SVN</h1></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Desde</label><input class="municipal-form-control" type="date" v-model="filters.desde" /></div>
            <div class="form-group"><label class="municipal-form-label">Hasta</label><input class="municipal-form-control" type="date" v-model="filters.hasta" /></div>
          </div>
          <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="loadStats"><font-awesome-icon icon="chart-line" /> Consultar</button></div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resumen</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Expedientes</label>
              <div><strong>{{ stats.expedientes || 0 }}</strong></div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Recuperado</label>
              <div><strong>{{ money(stats.recuperado) }}</strong></div>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Notificaciones</label>
              <div><strong>{{ stats.notificaciones || 0 }}</strong></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'INFORMIX'
const OP_STATS = 'APREMIOSSVN_ESTADISTICAS_GENERALES'
const { loading, execute } = useApi()

const filters = ref({ desde: '', hasta: '' })
const stats = ref({})

async function loadStats(){
  const params = [
    { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
    { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') }
  ]
  try { stats.value = await execute(OP_STATS, BASE_DB, params) } catch(e){ stats.value = {} }
}

function money(v){ return Number(v||0).toLocaleString('es-MX',{style:'currency',currency:'MXN'}) }
</script>

