<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-bar" /></div>
      <div class="module-view-info">
        <h1>Estadísticas — Estacionamientos Públicos</h1>
        <p>Concentrado por año</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="run"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año desde</label><input class="municipal-form-control" type="number" v-model.number="filters.axo_from" /></div>
            <div class="form-group"><label class="municipal-form-label">Año hasta</label><input class="municipal-form-control" type="number" v-model.number="filters.axo_to" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Infracción</th><th>Folios</th><th>Total</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.axo}-${r.infraccion}`"><td>{{ r.axo }}</td><td>{{ r.infraccion }}</td><td>{{ r.totfol }}</td><td>{{ formatMoney(r.totimp) }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="4" class="text-center text-muted">Sin datos</td></tr>
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

const loading = ref(false)
const rows = ref([])
const filters = ref({ axo_from: '', axo_to: '' })

function formatMoney(n) { try { return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n||0)) } catch { return n } }

async function run() {
  loading.value = true
  rows.value = []
  try {
    const params = [
      { nombre: 'axo_from', valor: filters.value.axo_from || null, tipo: filters.value.axo_from ? 'integer' : 'integer' },
      { nombre: 'axo_to', valor: filters.value.axo_to || null, tipo: filters.value.axo_to ? 'integer' : 'integer' }
    ]
    const resp = await apiService.execute('sqrp_esta01_report', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } catch (e) {
    rows.value = []
  } finally {
    loading.value = false
  }
}
</script>

