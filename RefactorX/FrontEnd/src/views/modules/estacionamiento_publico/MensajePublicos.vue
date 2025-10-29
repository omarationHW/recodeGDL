<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="comment-dots" /></div>
      <div class="module-view-info">
        <h1>Mensaje del Sistema</h1>
        <p>Registro/visualización</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="enviar"><font-awesome-icon icon="paper-plane" /> Enviar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Tipo</label><input class="municipal-form-control" v-model="tipo" placeholder="info|warning|error" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Mensaje</label><input class="municipal-form-control" v-model="msg" /></div>
            <div class="form-group"><label class="municipal-form-label">Ícono</label><input class="municipal-form-control" v-model="icono" placeholder="info-circle" /></div>
          </div>
          <pre v-if="output" class="text-muted">{{ JSON.stringify(output, null, 2) }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const tipo = ref('info')
const msg = ref('')
const icono = ref('info-circle')
const loading = ref(false)
const output = ref(null)

async function enviar() {
  loading.value = true
  output.value = null
  try {
    const params = [ { nombre: 'tipo', valor: tipo.value, tipo: 'string' }, { nombre: 'msg', valor: msg.value, tipo: 'string' }, { nombre: 'icono', valor: icono.value, tipo: 'string' } ]
    const resp = await apiService.execute('sp_mensaje_show', 'estacionamiento_publico', params)
    output.value = resp?.data?.result || []
  } finally { loading.value = false }
}
</script>

