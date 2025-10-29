<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="envelopes-bulk" /></div>
      <div class="module-view-info">
        <h1>Consulta de Remesas</h1>
        <p>sp_get_remesas y detalle de remesa</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="load"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="tipo"><option value="A">A</option><option value="B">B</option><option value="C">C</option><option value="D">D</option></select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Remesas</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Tipo</th><th>Remesa</th><th>Inicio</th><th>Fin</th><th>Control</th><th>Cant</th><th>Acciones</th></tr></thead>
              <tbody>
                <tr v-for="r in remesas" :key="r.num_remesa">
                  <td>{{ r.tipo }}</td><td>{{ r.num_remesa }}</td><td>{{ formatDate(r.fecha_inicio) }}</td><td>{{ formatDate(r.fecha_fin) }}</td><td>{{ r.control }}</td><td>{{ r.cant_reg }}</td>
                  <td><button class="btn-municipal-info btn-sm" @click="detalle(r)"><font-awesome-icon icon="eye" /></button></td>
                </tr>
                <tr v-if="remesas.length===0"><td colspan="7" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="detalleRemesa.length">
        <div class="municipal-card-header"><h5>Detalle de Remesa {{ remesaSel }}</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Placa</th><th>Año</th><th>Folio</th><th>Fecha Pago</th><th>Importe</th></tr></thead>
              <tbody>
                <tr v-for="d in detalleRemesa" :key="d.folio"><td>{{ d.placa }}</td><td>{{ d.axo }}</td><td>{{ d.folio }}</td><td>{{ formatDate(d.fechapago) }}</td><td>{{ d.importe }}</td></tr>
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

const tipo = ref('A')
const remesas = ref([])
const detalleRemesa = ref([])
const remesaSel = ref('')
const loading = ref(false)

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function load() {
  loading.value = true
  remesas.value = []
  try {
    const resp = await apiService.execute('sp_get_remesas', 'estacionamiento_publico', [ { nombre: 'tipo_param', valor: tipo.value, tipo: 'string' } ])
    remesas.value = resp?.data?.result || []
  } finally {
    loading.value = false
  }
}

async function detalle(r) {
  remesaSel.value = r.num_remesa
  const resp = await apiService.execute('sp_get_remesa_detalle_mpio', 'estacionamiento_publico', [ { nombre: 'remesa_param', valor: String(r.num_remesa), tipo: 'string' } ])
  detalleRemesa.value = resp?.data?.result || []
}

load()
</script>

