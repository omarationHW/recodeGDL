<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list" /></div>
      <div class="module-view-info">
        <h1>Reportes — Estacionamientos Públicos</h1>
        <p>Consultas y totales por licencia</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="runReport" :disabled="loading"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">ID Licencia</label><input class="municipal-form-control" v-model="filters.id_licencia" /></div>
            <div class="form-group"><label class="municipal-form-label">Tipo</label><input class="municipal-form-control" v-model="filters.tipo_l" placeholder="A/B/C" /></div>
            <div class="form-group"><label class="municipal-form-label">Redondeo</label><input class="municipal-form-control" v-model="filters.redon" placeholder="S/N" /></div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Totales por Licencia</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th>Cuenta</th><th>Obliga</th><th>Concepto</th><th>Importe</th><th>LicAnual</th></tr>
              </thead>
              <tbody>
                <tr v-for="r in totales" :key="r.concepto">
                  <td>{{ r.cuenta }}</td>
                  <td>{{ r.obliga }}</td>
                  <td>{{ r.concepto }}</td>
                  <td>{{ formatMoney(r.importe) }}</td>
                  <td>{{ r.licanun }}</td>
                </tr>
                <tr v-if="totales.length===0"><td colspan="5" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Reportes SP</h5></div>
        <div class="municipal-card-body">
          <div class="button-group">
            <button class="btn-municipal-secondary" @click="runSPReports" :disabled="loading">
              <font-awesome-icon icon="play" /> Ejecutar SPUBREPORTS
            </button>
          </div>
          <pre class="text-muted" v-if="spReportOutput">{{ spReportOutput }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import apiService from '@/services/apiService'

const loading = ref(false)
const totales = ref([])
const spReportOutput = ref('')
const filters = ref({ id_licencia: '', tipo_l: '', redon: '' })

function formatMoney(n) { try { return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n||0)) } catch { return n } }

async function runReport() {
  loading.value = true
  totales.value = []
  spReportOutput.value = ''
  try {
    const parametros = [
      { nombre: 'id_licencia', valor: filters.value.id_licencia, tipo: 'integer' },
      { nombre: 'tipo_l', valor: filters.value.tipo_l, tipo: 'string' },
      { nombre: 'redon', valor: filters.value.redon, tipo: 'string' }
    ]
    // Delphi: StoredProcName = 'spget_lic_detalles' (id_licencia, tipo_l, redon)
    const resp = await apiService.execute('spget_lic_detalles', 'estacionamiento_publico', parametros)
    totales.value = resp?.data?.result || []
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

async function runSPReports() {
  loading.value = true
  spReportOutput.value = ''
  try {
    const resp = await apiService.execute('spubreports', 'estacionamiento_publico', [])
    spReportOutput.value = JSON.stringify(resp?.data?.result || resp, null, 2)
  } catch (e) {
    spReportOutput.value = e.message || 'Error al ejecutar reporte'
  } finally {
    loading.value = false
  }
}
</script>
