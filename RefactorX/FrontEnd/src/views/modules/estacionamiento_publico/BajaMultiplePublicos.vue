<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-xmark" /></div>
      <div class="module-view-info">
        <h1>Baja Múltiple de Folios</h1>
        <p>Consulta de incidencias por archivo</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Nombre de archivo</label><input class="municipal-form-control" v-model="archivo" placeholder="Ej. bajas_2025_10_15.csv" /></div>
          </div>
          <div class="alert alert-info"><small>Nota: la inserción/aplicación de bajas se realiza con PROCEDUREs (`sp_insert_folios_baja_esta`, `sp14_ejecuta_sp`). El backend actual ejecuta funciones con SELECT. Para procesar el archivo completo por API, es recomendable agregar wrappers FUNCTION en la BD o permitir `CALL` en backend. Aquí puedes consultar las incidencias con `sp_get_incidencias_baja_multiple`.</small></div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Incidencias</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Placa</th><th>Folio Archivo</th><th>Fecha Archivo</th><th>Anomalía</th><th>Referencia</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.placa}-${r.folio_archivo}`"><td>{{ r.placa }}</td><td>{{ r.folio_archivo }}</td><td>{{ r.fecha_archivo }}</td><td>{{ r.anomalia }}</td><td>{{ r.referencia }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin incidencias</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const archivo = ref('')
const loading = ref(false)
const rows = ref([])

async function consultar() {
  loading.value = true
  rows.value = []
  try {
    const resp = await apiService.execute('sp_get_incidencias_baja_multiple', 'estacionamiento_publico', [ { nombre: 'p_archivo', valor: archivo.value, tipo: 'string' } ])
    rows.value = resp?.data?.result || []
  } finally { loading.value = false }
}
</script>

