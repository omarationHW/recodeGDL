<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list-ol" /></div>
      <div class="module-view-info">
        <h1>Relación de Folios</h1>
        <p>Por tipo de fecha</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><select class="municipal-form-control" v-model.number="opcion"><option :value="1">Fecha Folio</option><option :value="2">Fecha Alta</option><option :value="3">Fecha Baja (Pago)</option><option :value="4">Fecha Baja (Cancelación)</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="fecha" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Folio</th><th>Placa</th><th>Fecha</th><th>Estado</th><th>Infracción</th><th>Tarifa</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.axo}-${r.folio}`"><td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ r.placa }}</td><td>{{ formatDate(r.fecha_folio) }}</td><td>{{ r.estado }}</td><td>{{ r.infraccion }}</td><td>{{ r.tarifa }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="7" class="text-center text-muted">Sin datos</td></tr>
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

const opcion = ref(1)
const fecha = ref(new Date().toISOString().substring(0,10))
const loading = ref(false)
const rows = ref([])

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function consultar() {
  loading.value = true
  rows.value = []
  try {
    const params = [ { nombre: 'opcion', valor: opcion.value, tipo: 'integer' }, { nombre: 'fecha', valor: fecha.value, tipo: 'string' } ]
    const resp = await apiService.execute('sQRp_relacion_folios_report', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } finally {
    loading.value = false
  }
}
</script>

