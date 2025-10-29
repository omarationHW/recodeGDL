<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="magnifying-glass" /></div>
      <div class="module-view-info">
        <h1>Consulta General — Placa</h1>
        <p>sp14_afolios y sp14_bfolios</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Fuente Principal (Datos Edo)</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Tipo</th><th>Año</th><th>Folio</th><th>Alta</th><th>Pago</th><th>Cancelado</th><th>Importe</th><th>Remesa</th></tr></thead>
              <tbody>
                <tr v-for="r in resA" :key="`${r.axo}-${r.folio}`"><td>{{ r.tipoact }}</td><td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ formatDate(r.fechaalta) }}</td><td>{{ formatDate(r.fechapago) }}</td><td>{{ formatDate(r.fechacancelado) }}</td><td>{{ r.importe }}</td><td>{{ r.remesa }}</td></tr>
                <tr v-if="resA.length===0"><td colspan="8" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Fuente Secundaria (Datos Mpio)</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Tipo</th><th>Año</th><th>Folio</th><th>Alta</th><th>Pago</th><th>Cancelado</th><th>Importe</th><th>Remesa</th></tr></thead>
            <tbody>
                <tr v-for="r in resB" :key="`${r.axo}-${r.folio}`"><td>{{ r.tipoact }}</td><td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ formatDate(r.fechaalta) }}</td><td>{{ formatDate(r.fechapago) }}</td><td>{{ formatDate(r.fechacancelado) }}</td><td>{{ r.importe }}</td><td>{{ r.remesa }}</td></tr>
                <tr v-if="resB.length===0"><td colspan="8" class="text-center text-muted">Sin datos</td></tr>
            </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const placa = ref('')
const resA = ref([])
const resB = ref([])
const loading = ref(false)

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function consultar() {
  loading.value = true
  resA.value = []
  resB.value = []
  try {
    const p = [ { nombre: 'parPlaca', valor: placa.value, tipo: 'string' } ]
    const a = await apiService.execute('sp14_afolios', 'estacionamiento_publico', p)
    const b = await apiService.execute('sp14_bfolios', 'estacionamiento_publico', p)
    resA.value = a?.data?.result || []
    resB.value = b?.data?.result || []
  } finally {
    loading.value = false
  }
}
</script>

