<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="calendar-day" /></div>
      <div class="module-view-info">
        <h1>Generación Diaria — Remesas</h1>
        <p>sp14_remesa (diario)</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="play" /> Generar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><input type="number" class="municipal-form-control" v-model.number="opc" placeholder="1" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="fecha" /></div>
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

const opc = ref(1)
const axo = ref(new Date().getFullYear())
const fecha = ref(new Date().toISOString().substring(0,10))
const loading = ref(false)
const message = ref('')

async function generar() {
  loading.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_Opc', valor: opc.value, tipo: 'integer' },
      { nombre: 'p_Axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_Fec_Ini', valor: fecha.value, tipo: 'string' },
      { nombre: 'p_Fec_Fin', valor: fecha.value, tipo: 'string' },
      { nombre: 'p_Fec_A_Fin', valor: fecha.value, tipo: 'string' }
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

