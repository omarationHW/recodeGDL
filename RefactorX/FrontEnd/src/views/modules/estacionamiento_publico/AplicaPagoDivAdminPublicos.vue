<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="hand-holding-dollar" /></div>
      <div class="module-view-info">
        <h1>Aplicar Pago — Diversos Admin</h1>
        <p>Búsqueda y aplicación de pagos</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><select class="municipal-form-control" v-model.number="opcion"><option :value="0">Placa</option><option :value="1">Placa + Folio</option><option :value="2">Año + Folio</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" type="number" v-model.number="folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="axo" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Año</th><th>Folio</th><th>Placa</th><th>Fecha</th><th>Infracción</th><th>Tarifa</th><th>Acciones</th></tr></thead>
              <tbody>
                <tr v-for="r in resultados" :key="`${r.axo}-${r.folio}`">
                  <td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ r.placa }}</td><td>{{ formatDate(r.fecha_folio) }}</td><td>{{ r.infraccion }}</td><td>{{ r.tarifa }}</td>
                  <td><button class="btn-municipal-primary btn-sm" @click="aplicar(r)"><font-awesome-icon icon="check" /> Aplicar</button></td>
                </tr>
                <tr v-if="resultados.length===0"><td colspan="7" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Parámetros de Pago</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Fecha Pago</label><input type="date" class="municipal-form-control" v-model="pago.fecha" /></div>
            <div class="form-group"><label class="municipal-form-label">Reca</label><input type="number" class="municipal-form-control" v-model.number="pago.reca" /></div>
            <div class="form-group"><label class="municipal-form-label">Caja</label><input class="municipal-form-control" v-model="pago.caja" /></div>
            <div class="form-group"><label class="municipal-form-label">Oper</label><input type="number" class="municipal-form-control" v-model.number="pago.oper" /></div>
            <div class="form-group"><label class="municipal-form-label">Usuario</label><input class="municipal-form-control" v-model="pago.usuario" /></div>
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

const opcion = ref(0)
const placa = ref('')
const folio = ref(null)
const axo = ref(new Date().getFullYear())
const resultados = ref([])
const loading = ref(false)
const message = ref('')
const pago = ref({ fecha: new Date().toISOString().substring(0,10), reca: 9, caja: '', oper: 0, usuario: '' })

function formatDate(d) { if (!d) return '—'; const dt = new Date(d); return dt.toLocaleDateString() }

async function buscar() {
  loading.value = true
  resultados.value = []
  try {
    const params = [ { nombre: 'opcion', valor: opcion.value, tipo: 'integer' }, { nombre: 'placa', valor: placa.value, tipo: 'string' }, { nombre: 'folio', valor: folio?.value || 0, tipo: 'integer' }, { nombre: 'axo', valor: axo.value, tipo: 'integer' } ]
    const resp = await apiService.execute('sp_busca_folios_divadmin', 'estacionamiento_publico', params)
    resultados.value = resp?.data?.result || []
  } finally { loading.value = false }
}

async function aplicar(r) {
  message.value = ''
  try {
    const p = pago.value
    const params = [ { nombre: 'parAxo', valor: r.axo, tipo: 'integer' }, { nombre: 'parFolio', valor: r.folio, tipo: 'integer' }, { nombre: 'parFecha', valor: p.fecha, tipo: 'string' }, { nombre: 'parReca', valor: p.reca, tipo: 'integer' }, { nombre: 'parCaja', valor: p.caja, tipo: 'string' }, { nombre: 'parOper', valor: p.oper, tipo: 'integer' }, { nombre: 'parUsuario', valor: p.usuario, tipo: 'string' } ]
    const resp = await apiService.execute('sp_aplica_pago_divadmin', 'estacionamiento_publico', params)
    message.value = resp?.message || 'Pago aplicado'
  } catch (e) {
    message.value = e.message || 'Error al aplicar pago'
  }
}
</script>

