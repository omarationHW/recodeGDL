<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-export" /></div>
      <div class="module-view-info">
        <h1>Generar Remesa de Altas</h1>
        <p>sp14_remesa (altas)</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingPeriodo" @click="getPeriodo"><font-awesome-icon icon="calendar" /> Último periodo</button>
        <button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="play" /> Generar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><input type="number" class="municipal-form-control" v-model.number="opc" placeholder="1" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Inicio</label><input type="date" class="municipal-form-control" v-model="fec_ini" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Fin</label><input type="date" class="municipal-form-control" v-model="fec_fin" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Actual Fin</label><input type="date" class="municipal-form-control" v-model="fec_a_fin" /></div>
          </div>
          <div v-if="loadingPeriodo" class="spinner-border" role="status"></div>
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
const fec_ini = ref('')
const fec_fin = ref('')
const fec_a_fin = ref('')
const loading = ref(false)
const loadingPeriodo = ref(false)
const message = ref('')

async function getPeriodo() {
  loadingPeriodo.value = true
  try {
    const resp = await apiService.execute('get_periodo_altas', 'estacionamiento_publico', [])
    const r = (resp?.data?.result || [])[0]
    if (r) {
      fec_ini.value = r.fecha_inicio
      fec_fin.value = r.fecha_fin
      fec_a_fin.value = r.fecha_fin
    }
  } finally {
    loadingPeriodo.value = false
  }
}

async function generar() {
  loading.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_Opc', valor: opc.value, tipo: 'integer' },
      { nombre: 'p_Axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_Fec_Ini', valor: fec_ini.value, tipo: 'string' },
      { nombre: 'p_Fec_Fin', valor: fec_fin.value, tipo: 'string' },
      { nombre: 'p_Fec_A_Fin', valor: fec_a_fin.value, tipo: 'string' }
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

