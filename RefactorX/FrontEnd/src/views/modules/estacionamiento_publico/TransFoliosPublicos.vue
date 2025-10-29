<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="share" /></div>
      <div class="module-view-info">
        <h1>Transferencia de Folios — Estacionamientos</h1>
        <p>Operaciones sobre folios (spd_delesta01)</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="ejecutar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="form.axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="form.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="form.placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Convenio</label><input type="number" class="municipal-form-control" v-model.number="form.convenio" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="form.fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Reca</label><input type="number" class="municipal-form-control" v-model.number="form.reca" /></div>
            <div class="form-group"><label class="municipal-form-label">Caja</label><input class="municipal-form-control" v-model="form.caja" /></div>
            <div class="form-group"><label class="municipal-form-label">Oper</label><input type="number" class="municipal-form-control" v-model.number="form.oper" /></div>
            <div class="form-group"><label class="municipal-form-label">Usuario Aut.</label><input type="number" class="municipal-form-control" v-model.number="form.usuauto" /></div>
            <div class="form-group"><label class="municipal-form-label">Opción</label><input type="number" class="municipal-form-control" v-model.number="form.opc" /></div>
          </div>
          <div v-if="loading" class="spinner-border" role="status"></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const form = reactive({ axo: 0, folio: 0, placa: '', convenio: 0, fecha: '', reca: 0, caja: '', oper: 0, usuauto: 0, opc: 1 })
const loading = ref(false)
const message = ref('')

async function ejecutar() {
  loading.value = true
  message.value = ''
  try {
    const p = form
    const params = [
      { nombre: 'axo', valor: p.axo, tipo: 'integer' },
      { nombre: 'folio', valor: p.folio, tipo: 'integer' },
      { nombre: 'placa', valor: p.placa, tipo: 'string' },
      { nombre: 'convenio', valor: p.convenio, tipo: 'integer' },
      { nombre: 'fecha', valor: p.fecha, tipo: 'string' },
      { nombre: 'reca', valor: p.reca, tipo: 'integer' },
      { nombre: 'caja', valor: p.caja, tipo: 'string' },
      { nombre: 'oper', valor: p.oper, tipo: 'integer' },
      { nombre: 'usuauto', valor: p.usuauto, tipo: 'integer' },
      { nombre: 'opc', valor: p.opc, tipo: 'integer' }
    ]
    const resp = await apiService.execute('spd_delesta01', 'estacionamiento_publico', params)
    message.value = resp?.message || 'Operación enviada'
  } catch (e) {
    message.value = e.message || 'Error al ejecutar'
  } finally {
    loading.value = false
  }
}
</script>

