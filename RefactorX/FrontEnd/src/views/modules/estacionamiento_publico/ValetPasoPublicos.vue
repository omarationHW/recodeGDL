<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="car" /></div>
      <div class="module-view-info">
        <h1>Valet Paso — Estacionamientos</h1>
        <p>Procesar archivo (CSV) de valet</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="procesar"><font-awesome-icon icon="play" /> Procesar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-group full-width">
            <label class="municipal-form-label">Contenido CSV (pégalo aquí)</label>
            <textarea class="municipal-form-control" rows="8" v-model="csv"></textarea>
          </div>
          <div v-if="loading" class="spinner-border" role="status"></div>
          <pre v-if="output" class="text-muted">{{ output }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const csv = ref('')
const loading = ref(false)
const output = ref('')

async function procesar() {
  loading.value = true
  output.value = ''
  try {
    const params = [ { nombre: 'file_content', valor: csv.value, tipo: 'json' } ]
    const resp = await apiService.execute('process_valet_file', 'estacionamiento_publico', params)
    output.value = JSON.stringify(resp?.data?.result || resp, null, 2)
  } catch (e) {
    output.value = e.message || 'Error al procesar'
  } finally {
    loading.value = false
  }
}
</script>

