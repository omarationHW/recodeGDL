<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div>
      <div class="module-view-info">
        <h1>Reporte de Pagos — Estacionamientos</h1>
        <p>Folios pagados y adeudos por inspector</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="ejecutar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Recaudadora</label><input type="number" class="municipal-form-control" v-model.number="reca" placeholder="9=Todas" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Tipo de Reporte</label>
              <select class="municipal-form-control" v-model="tipo">
                <option value="pagados">Folios pagados</option>
                <option value="adeudo_inspector">Adeudos por inspector</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div v-if="tipo==='pagados'" class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th>Reca</th><th>Caja</th><th>Operación</th><th>Año</th><th>Folio</th><th>Placa</th><th>Fecha</th><th>Estado</th><th>Infracción</th><th>Tarifa</th><th>Movto</th></tr>
              </thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.axo}-${r.folio}`">
                  <td>{{ r.reca }}</td><td>{{ r.caja }}</td><td>{{ r.operacion }}</td><td>{{ r.axo }}</td><td>{{ r.folio }}</td>
                  <td>{{ r.placa }}</td><td>{{ formatDate(r.fecha_folio) }}</td><td>{{ r.estado }}</td><td>{{ r.infraccion }}</td><td>{{ formatMoney(r.tarifa) }}</td><td>{{ r.codigo_movto }}</td>
                </tr>
                <tr v-if="rows.length===0"><td colspan="11" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Inspector</th><th>Folios</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="r.vigilante"><td>{{ r.inspector }}</td><td>{{ r.folios }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="2" class="text-center text-muted">Sin datos</td></tr>
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

const fecha = ref('')
const reca = ref(9)
const tipo = ref('pagados')
const loading = ref(false)
const rows = ref([])

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }
function formatMoney(n) { try { return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n||0)) } catch { return n } }

async function ejecutar() {
  loading.value = true
  rows.value = []
  try {
    if (tipo.value === 'pagados') {
      const params = [ { nombre: 'p_reca', valor: reca.value, tipo: 'integer' }, { nombre: 'p_fechora', valor: fecha.value, tipo: 'string' } ]
      const resp = await apiService.execute('report_folios_pagados', 'estacionamiento_publico', params)
      rows.value = resp?.data?.result || []
    } else {
      const params = [ { nombre: 'p_fechora', valor: fecha.value, tipo: 'string' } ]
      const resp = await apiService.execute('report_folios_adeudo_por_inspector', 'estacionamiento_publico', params)
      rows.value = resp?.data?.result || []
    }
  } catch (e) {
    rows.value = []
  } finally {
    loading.value = false
  }
}
</script>

