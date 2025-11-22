<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="clipboard-list" /></div>
      <div class="module-view-info">
        <h1>Reporte de Folios (Solicitud)</h1>
        <p>Alternativa a cons14_solicrep</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="ejecutar"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Clave Infracción</label><input type="number" class="municipal-form-control" v-model.number="cveinf" placeholder="0=todas" /></div>
            <div class="form-group"><label class="municipal-form-label">Opción</label>
              <select class="municipal-form-control" v-model.number="opc">
                <option :value="1">Adeudos</option>
                <option :value="2">Pagados</option>
                <option :value="3">Cancelados</option>
                <option :value="4">Condonados</option>
                <option :value="5">Cancelados y Condonados</option>
              </select>
            </div>
            <div class="form-group"><label class="municipal-form-label">Fecha Inicio</label><input type="date" class="municipal-form-control" v-model="fec_ini" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Fin</label><input type="date" class="municipal-form-control" v-model="fec_fin" /></div>
          </div>
          <div class="alert alert-info mt-2">
            <small>Nota: cons14_solicrep es PROCEDURE. Esta vista usa funciones equivalentes (relación de folios y pagos). Si requieres el reporte exacto, se recomienda agregar un wrapper FUNCTION en la base o extender el backend para ejecutar CALL.</small>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Folio</th><th>Placa</th><th>Fecha</th><th>Infracción</th><th>Tarifa</th></tr></thead>
              <tbody>
                <tr v-for="r in rows" :key="`${r.axo}-${r.folio}`"><td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ r.placa }}</td><td>{{ formatDate(r.fecha_folio) }}</td><td>{{ r.infraccion }}</td><td>{{ r.tarifa }}</td></tr>
                <tr v-if="rows.length===0"><td colspan="6" class="text-center text-muted">Sin datos</td></tr>
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

const cveinf = ref(0)
const opc = ref(1)
const fec_ini = ref('')
const fec_fin = ref('')
const rows = ref([])
const loading = ref(false)

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function ejecutar() {
  loading.value = true
  rows.value = []
  try {
    // Fallback: usar relación de folios para cada día del rango o 'pagados' para opc=2
    const start = new Date(fec_ini.value)
    const end = new Date(fec_fin.value)
    const dayMs = 24*60*60*1000
    for (let t = start.getTime(); t <= end.getTime(); t += dayMs) {
      const d = new Date(t).toISOString().substring(0,10)
      if (opc.value === 2) {
        const rp = await apiService.execute('report_folios_pagados', 'estacionamiento_publico', [ { nombre: 'p_reca', valor: 9, tipo: 'integer' }, { nombre: 'p_fechora', valor: d, tipo: 'string' } ])
        const page = (rp?.data?.result || []).map(x => ({ axo: x.axo, folio: x.folio, placa: x.placa, fecha_folio: x.fecha_folio, infraccion: x.infraccion, tarifa: x.tarifa }))
        rows.value.push(...page)
      } else {
        const opMap = { 1:1, 3:4, 4:4, 5:4 } // aproximación
        const rr = await apiService.execute('sQRp_relacion_folios_report', 'estacionamiento_publico', [ { nombre: 'opcion', valor: opMap[opc.value] || 1, tipo: 'integer' }, { nombre: 'fecha', valor: d, tipo: 'string' } ])
        const rel = rr?.data?.result || []
        rows.value.push(...rel)
      }
    }
    if (cveinf.value) rows.value = rows.value.filter(r => Number(r.infraccion) === Number(cveinf.value))
  } finally { loading.value = false }
}
</script>

