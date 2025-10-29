<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-shield" /></div>
      <div class="module-view-info">
        <h1>Autorización de Descuentos</h1>
        <p>Consulta histórica y cambio a Tesorero</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button>
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
        <div class="municipal-card-header"><h5>Folios Históricos</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Folio</th><th>Placa</th><th>Fecha Folio</th><th>Acción</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.axo}-${r.folio}`">
                  <td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ r.placa }}</td><td>{{ formatDate(r.fecha_folio) }}</td>
                  <td><button class="btn-municipal-primary btn-sm" @click="cambiar(r)"><font-awesome-icon icon="user-check" /> Tesorero</button></td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="5" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const placa = ref('')
const rows = ref([])
const loading = ref(false)
const message = ref('')

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function buscar() {
  loading.value = true
  rows.value = []
  try {
    const resp = await apiService.execute('sp_buscar_folios_histo', 'estacionamiento_publico', [ { nombre: 'p_placa', valor: placa.value, tipo: 'string' } ])
    rows.value = resp?.data?.result || []
  } finally { loading.value = false }
}

async function cambiar(r) {
  message.value = ''
  try {
    const resp = await apiService.execute('sp_cambiar_a_tesorero', 'estacionamiento_publico', [ { nombre: 'p_axo', valor: r.axo, tipo: 'integer' }, { nombre: 'p_folio', valor: r.folio, tipo: 'integer' } ])
    message.value = resp?.message || 'Actualizado'
  } catch (e) { message.value = e.message || 'Error' }
}
</script>

