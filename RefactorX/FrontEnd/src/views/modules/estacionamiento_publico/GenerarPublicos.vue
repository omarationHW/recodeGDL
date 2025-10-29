<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-check" /></div>
      <div class="module-view-info">
        <h1>Generación — Estacionamientos Públicos</h1>
        <p>Reportes y salidas</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="generar"><font-awesome-icon icon="play" /> Generar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <pre v-if="output" class="text-muted">{{ output }}</pre>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Generando...</span></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const loading = ref(false)
const output = ref('')

async function generar() {
  loading.value = true
  output.value = ''
  try {
    const resp = await apiService.execute('sp_get_public_parking_list', 'estacionamiento_publico', [])
    output.value = JSON.stringify(resp?.data?.result || resp, null, 2)
  } catch (e) {
    output.value = e.message || 'Error al generar'
  } finally {
    loading.value = false
  }
}
</script>

