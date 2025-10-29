<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="circle-info" /></div>
      <div class="module-view-info">
        <h1>Información — Estacionamientos Públicos</h1>
        <p>Resumen y métricas</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="loadInfo"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
          <pre v-else class="text-muted">{{ JSON.stringify(info, null, 2) }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import apiService from '@/services/apiService'

const loading = ref(false)
const info = ref({})

async function loadInfo() {
  loading.value = true
  try {
    // Usamos consulta general para mostrar conteos básicos (placeholder sin datos locales)
    const resp = await apiService.execute('sp_get_public_parking_list', 'estacionamiento_publico', [])
    const result = resp?.data?.result || []
    info.value = { registros: result.length }
  } catch (e) {
    info.value = { error: e.message || 'Error al cargar' }
  } finally {
    loading.value = false
  }
}

onMounted(loadInfo)
</script>

