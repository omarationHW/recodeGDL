<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="map-location-dot" /></div>
      <div class="module-view-info">
        <h1>Metrometers — Datos y Mapa</h1>
        <p>Buscar por Año y Folio</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="folio" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card" v-if="row">
        <div class="municipal-card-header"><h5>Información</h5></div>
        <div class="municipal-card-body">
          <table class="detail-table">
            <tr><td class="label">Dirección</td><td>{{ row.direccion }}</td></tr>
            <tr><td class="label">Marca/Modelo</td><td>{{ row.marca }} / {{ row.modelo }}</td></tr>
            <tr><td class="label">Lat/Lon</td><td>{{ row.poslat }}, {{ row.poslong }}</td></tr>
            <tr><td class="label">Motivo</td><td>{{ row.motivo }}</td></tr>
          </table>
        </div>
      </div>
      <div class="municipal-card" v-if="mapUrl">
        <div class="municipal-card-header"><h5>Mapa</h5></div>
        <div class="municipal-card-body">
          <img :src="mapUrl" alt="mapa" class="img-responsive img-bordered" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const axo = ref(new Date().getFullYear())
const folio = ref(0)
const row = ref(null)
const mapUrl = ref('')
const loading = ref(false)

async function buscar() {
  loading.value = true
  row.value = null
  mapUrl.value = ''
  try {
    const params = [ { nombre: 'p_axo', valor: axo.value, tipo: 'integer' }, { nombre: 'p_folio', valor: folio.value, tipo: 'integer' } ]
    const resp = await apiService.execute('sp_get_metrometer_by_axo_folio', 'estacionamiento_publico', params)
    const r = (resp?.data?.result || [])[0]
    row.value = r || null
    const resp2 = await apiService.execute('sp_get_metrometers_map_url', 'estacionamiento_publico', params)
    const m = (resp2?.data?.result || [])[0]
    mapUrl.value = m?.map_url || ''
  } finally {
    loading.value = false
  }
}
</script>

