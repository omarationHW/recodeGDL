<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-plus" /></div>
      <div class="module-view-info">
        <h1>Generación Individual — Remesa</h1>
        <p>Agregar por placa/folio y generar archivo</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingAdd" @click="add"><font-awesome-icon icon="plus" /> Agregar</button>
        <button class="btn-municipal-primary" :disabled="loadingFile" @click="generarArchivo"><font-awesome-icon icon="download" /> Generar Archivo</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><select class="municipal-form-control" v-model.number="opcion"><option :value="0">Placa</option><option :value="1">Placa + Folios</option><option :value="2">Año + Folios</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Folios (coma)</label><input class="municipal-form-control" v-model="folios" placeholder="Ej. 123,456" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Remesa</label><input class="municipal-form-control" v-model="remesa" /></div>
          </div>
          <div v-if="loadingAdd" class="spinner-border" role="status"></div>
          <div v-if="loadingFile" class="spinner-border" role="status"></div>
          <pre v-if="output" class="text-muted">{{ output }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const opcion = ref(0)
const placa = ref('')
const axo = ref(new Date().getFullYear())
const folios = ref('')
const remesa = ref('')
const loadingAdd = ref(false)
const loadingFile = ref(false)
const output = ref('')

async function add() {
  loadingAdd.value = true
  try {
    const params = [
      { nombre: 'p_opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value, tipo: 'string' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_folio', valor: folios.value, tipo: 'string' },
      { nombre: 'p_remesa', valor: remesa.value, tipo: 'string' }
    ]
    await apiService.execute('sp_gen_individual_add', 'estacionamiento_publico', params)
  } finally {
    loadingAdd.value = false
  }
}

async function generarArchivo() {
  loadingFile.value = true
  output.value = ''
  try {
    const params = [ { nombre: 'p_remesa', valor: remesa.value, tipo: 'string' } ]
    const resp = await apiService.execute('sp_gen_individual_generate_file', 'estacionamiento_publico', params)
    const rows = resp?.data?.result || []
    const lines = rows.map(r => Object.values(r).join('|')).join('\n')
    output.value = lines
  } finally {
    loadingFile.value = false
  }
}
</script>

