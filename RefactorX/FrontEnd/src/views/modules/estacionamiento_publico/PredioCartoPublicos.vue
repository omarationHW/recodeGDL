<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="map" /></div>
      <div class="module-view-info">
        <h1>Predio Cartográfico</h1>
        <p>URL del visor por clave catastral</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="link" /> Obtener URL</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Clave Catastral</label><input class="municipal-form-control" v-model="clave" /></div>
          </div>
          <div v-if="url" class="button-group"><a class="btn-municipal-primary" :href="url" target="_blank"><font-awesome-icon icon="external-link-alt" /> Abrir visor</a></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const clave = ref('')
const url = ref('')
const message = ref('')
const loading = ref(false)

async function consultar() {
  loading.value = true
  url.value = ''; message.value = ''
  try {
    const resp = await apiService.execute('sp_get_predio_carto_url', 'estacionamiento_publico', [ { nombre: 'p_cvecatastro', valor: clave.value, tipo: 'string' } ])
    const v = resp?.eResponse?.data?.result ?? resp?.data?.result
    url.value = Array.isArray(v) ? (v[0] || '') : (v || '')
    if (!url.value) message.value = resp?.eResponse?.message || 'Sin URL'
  } catch (e) { message.value = e.message || 'Error' } finally { loading.value = false }
}
</script>

