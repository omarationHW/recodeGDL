<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="money-bill-wave" /></div>
      <div class="module-view-info">
        <h1>Pagos — Estacionamientos Públicos</h1>
        <p>Registro y consulta de pagos</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Licencia</label><input class="municipal-form-control" v-model="filters.numlicencia" /></div>
            <div class="form-group"><label class="municipal-form-label">Periodo</label><input class="municipal-form-control" v-model="filters.periodo" placeholder="YYYYMM" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Fecha</th><th>Concepto</th><th>Importe</th><th>Cajero</th></tr></thead>
              <tbody>
                <tr v-for="r in resultados" :key="r.id"><td>{{ r.fecha }}</td><td>{{ r.concepto }}</td><td>{{ formatMoney(r.importe) }}</td><td>{{ r.cajero }}</td></tr>
                <tr v-if="resultados.length===0"><td colspan="4" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const filters = reactive({ numlicencia: '', periodo: '' })
const resultados = ref([])
const loading = ref(false)

function formatMoney(n) { try { return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n||0)) } catch { return n } }

async function consultar() {
  loading.value = true
  resultados.value = []
  try {
    // Pendiente SP específico de pagos públicos
    const params = [ { nombre: 'numlicencia', valor: filters.numlicencia, tipo: 'integer' }, { nombre: 'periodo', valor: filters.periodo, tipo: 'string' } ]
    const resp = await apiService.execute('spubreports', 'estacionamiento_publico', params)
    resultados.value = resp?.data?.result || []
  } catch (e) {
    resultados.value = []
  } finally {
    loading.value = false
  }
}
</script>
