<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="city" /></div>
      <div class="module-view-info">
        <h1>Estado Municipal — Estacionamientos</h1>
        <p>Remesas y operaciones</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loadingRemesas" @click="loadRemesas"><font-awesome-icon icon="sync-alt" /> Remesas</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Remesas recientes</h5><div v-if="loadingRemesas" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loadingRemesas">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Remesa</th><th>Fecha</th><th>Aplica Tesorería</th></tr></thead>
              <tbody>
                <tr v-for="r in remesas" :key="r.remesa"><td>{{ r.remesa }}</td><td>{{ formatDate(r.fecharemesa) }}</td><td>{{ formatDate(r.aplicadoteso) }}</td></tr>
                <tr v-if="remesas.length===0"><td colspan="3" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Operación spd_delesta01</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="form.axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="form.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="form.placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Convenio</label><input type="number" class="municipal-form-control" v-model.number="form.convenio" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="form.fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Reca</label><input type="number" class="municipal-form-control" v-model.number="form.reca" /></div>
            <div class="form-group"><label class="municipal-form-label">Caja</label><input class="municipal-form-control" v-model="form.caja" /></div>
            <div class="form-group"><label class="municipal-form-label">Oper</label><input type="number" class="municipal-form-control" v-model.number="form.oper" /></div>
            <div class="form-group"><label class="municipal-form-label">UsuAuto</label><input type="number" class="municipal-form-control" v-model.number="form.usuauto" /></div>
            <div class="form-group"><label class="municipal-form-label">Opc</label><input type="number" class="municipal-form-control" v-model.number="form.opc" /></div>
          </div>
          <div class="button-group"><button class="btn-municipal-primary" :disabled="loadingOp" @click="ejecutarOp"><font-awesome-icon icon="play" /> Ejecutar</button></div>
          <div v-if="loadingOp" class="spinner-border" role="status"></div>
          <p v-if="opMsg" class="text-muted">{{ opMsg }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const remesas = ref([])
const loadingRemesas = ref(false)
const loadingOp = ref(false)
const opMsg = ref('')

const form = ref({ axo: 0, folio: 0, placa: '', convenio: 0, fecha: '', reca: 0, caja: '', oper: 0, usuauto: 0, opc: 1 })

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function loadRemesas() {
  loadingRemesas.value = true
  remesas.value = []
  try {
    const resp = await apiService.execute('sp_get_remesas_estado_mpio', 'estacionamiento_publico', [])
    remesas.value = resp?.data?.result || []
  } catch (e) {
    remesas.value = []
  } finally {
    loadingRemesas.value = false
  }
}

async function ejecutarOp() {
  loadingOp.value = true
  opMsg.value = ''
  try {
    const p = form.value
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
    opMsg.value = resp?.message || 'Operación ejecutada'
  } catch (e) {
    opMsg.value = e.message || 'Error en operación'
  } finally {
    loadingOp.value = false
  }
}
</script>

