<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="id-badge" /></div>
      <div class="module-view-info">
        <h1>Reportes de Calcomanías</h1>
        <p>Folios capturados por fecha</p>
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
            <div class="form-group full-width"><label class="municipal-form-label">Inspector (filtro opcional)</label>
              <select class="municipal-form-control" v-model.number="insSel">
                <option :value="0">Todos</option>
                <option v-for="i in inspectores" :key="i.id_esta_persona" :value="i.id_esta_persona">{{ i.inspector }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Inspector</th><th>Folios</th></tr></thead>
              <tbody>
                <tr v-for="r in rowsFiltradas" :key="r.vigilante"><td>{{ r.inspector }}</td><td>{{ r.folios }}</td></tr>
                <tr v-if="rowsFiltradas.length===0"><td colspan="2" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import apiService from '@/services/apiService'

const fecha = ref('')
const inspectores = ref([])
const insSel = ref(0)
const loading = ref(false)
const rows = ref([])

const rowsFiltradas = computed(() => insSel.value ? rows.value.filter(r => r.vigilante === insSel.value) : rows.value)

async function cargarInspectores() {
  const resp = await apiService.execute('sp_catalog_inspectors', 'estacionamiento_publico', [])
  inspectores.value = resp?.data?.result || []
}

async function ejecutar() {
  loading.value = true
  rows.value = []
  try {
    const params = [ { nombre: 'fechora', valor: fecha.value, tipo: 'string' } ]
    const resp = await apiService.execute('sp_report_folios', 'estacionamiento_publico', params)
    rows.value = resp?.data?.result || []
  } finally { loading.value = false }
}

onMounted(() => { cargarInspectores() })
</script>

