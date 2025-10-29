<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="rotate-left" /></div>
      <div class="module-view-info">
        <h1>Reactivar Folios — Estacionamientos</h1>
        <p>Búsqueda por placa+folio o año+folio</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><select class="municipal-form-control" v-model.number="opcion"><option :value="0">Placa+Folio</option><option :value="1">Año+Folio</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="text" class="municipal-form-control" v-model="folio" placeholder="Puede ser lista coma" /></div>
          </div>
          <div v-if="loading" class="spinner-border" role="status"></div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Folio</th><th>Placa</th><th>Movto</th><th>Fecha</th></tr></thead>
              <tbody>
                <tr v-for="r in resultados" :key="`${r.axo}-${r.folio}`">
                  <td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ r.placa }}</td><td>{{ r.codigo_movto }}</td><td>{{ formatDate(r.fecha_movto) }}</td>
                </tr>
                <tr v-if="resultados.length===0"><td colspan="5" class="text-center text-muted">Sin datos</td></tr>
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

const opcion = ref(0)
const placa = ref('')
const axo = ref(new Date().getFullYear())
const folio = ref('')
const resultados = ref([])
const loading = ref(false)

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function buscar() {
  loading.value = true
  resultados.value = []
  try {
    const params = [
      { nombre: 'p_opcion', valor: opcion.value, tipo: 'integer' },
      { nombre: 'p_placa', valor: placa.value, tipo: 'string' },
      { nombre: 'p_axo', valor: axo.value, tipo: 'integer' },
      { nombre: 'p_folio', valor: folio.value, tipo: 'string' }
    ]
    const resp = await apiService.execute('sp_reactiva_folios_buscar', 'estacionamiento_publico', params)
    resultados.value = resp?.data?.result || []
  } finally {
    loading.value = false
  }
}
</script>

