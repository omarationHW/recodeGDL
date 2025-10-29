<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="palette" /></div>
      <div class="module-view-info">
        <h1>Aspecto del Sistema</h1>
        <p>Catálogo y actual</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="load"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Listado de Aspectos</h5></div>
        <div class="municipal-card-body">
          <ul>
            <li v-for="a in aspectos" :key="a.nombre">{{ a.nombre }}</li>
          </ul>
          <p class="text-muted">Actual: <strong>{{ actual?.nombre || '—' }}</strong></p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const aspectos = ref([])
const actual = ref(null)
const loading = ref(false)

async function load() {
  loading.value = true
  aspectos.value = []
  actual.value = null
  try {
    const a = await apiService.execute('get_aspectos', 'estacionamiento_publico', [])
    const c = await apiService.execute('get_current_aspecto', 'estacionamiento_publico', [])
    aspectos.value = a?.data?.result || []
    actual.value = (c?.data?.result || [])[0]
  } finally { loading.value = false }
}

load()
</script>

