<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="building-columns" /></div>
      <div class="module-view-info">
        <h1>Generar Remesa — Pagos Banorte</h1>
        <p>sp14_remesa (opc=2)</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="play" /> Generar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Inicio</label><input type="date" class="municipal-form-control" v-model="fec_ini" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Fin</label><input type="date" class="municipal-form-control" v-model="fec_fin" /></div>
          </div>
          <div v-if="loading" class="spinner-border" role="status"></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const axo = ref(new Date().getFullYear())
const fec_ini = ref('')
const fec_fin = ref('')
const loading = ref(false)
const message = ref('')

async function generar() {
  loading.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_opc', valor: 2, tipo: 'integer' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_fec_ini', valor: fec_ini.value, tipo: 'string' },
      { nombre: 'p_fec_fin', valor: fec_fin.value, tipo: 'string' },
      { nombre: 'p_fec_a_fin', valor: fec_fin.value, tipo: 'string' }
    ]
    const resp = await apiService.execute('sp14_remesa', 'estacionamiento_publico', params)
    const r = (resp?.data?.result || [])[0]
    message.value = r ? `${r.obs || 'Generado'} (remesa: ${r.remesa || 'N/A'})` : 'Sin respuesta'
  } catch (e) {
    message.value = e.message || 'Error al generar'
  } finally {
    loading.value = false
  }
}
</script>

