<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="building-columns" /></div>
      <div class="module-view-info">
        <h1>Conciliación Banorte — Estacionamientos</h1>
        <p>Consulta por año y folio</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="play" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="filtros.axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" type="number" v-model.number="filtros.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio (hasta)</label><input class="municipal-form-control" type="number" v-model.number="filtros.folio_to" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Modo</label>
              <select class="municipal-form-control" v-model="modo">
                <option value="single">Por folio</option>
                <option value="range">Por rango de folios</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Resultados</h5><div v-if="loading" class="spinner-border" role="status"></div></div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive" v-if="rows.length">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in visibleColumns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx">
                  <td v-for="col in visibleColumns" :key="col">{{ formatCell(r[col]) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="text-muted">Sin resultados</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import apiService from '@/services/apiService'

const filtros = ref({ axo: '', folio: '', folio_to: '' })
const modo = ref('single')
const loading = ref(false)
const rows = ref([])

async function consultar() {
  loading.value = true
  rows.value = []
  try {
    if (modo.value === 'single' || !filtros.value.folio_to) {
      const params = [
        { nombre: 'p_axo', valor: filtros.value.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: filtros.value.folio, tipo: 'integer' }
      ]
      const resp = await apiService.execute('sp_conciliados_by_folio', 'estacionamiento_publico', params)
      rows.value = resp?.data?.result || []
    } else {
      const start = Number(filtros.value.folio) || 0
      const end = Number(filtros.value.folio_to) || start
      const acc = []
      for (let f = start; f <= end; f++) {
        const params = [
          { nombre: 'p_axo', valor: filtros.value.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: f, tipo: 'integer' }
        ]
        const resp = await apiService.execute('sp_conciliados_by_folio', 'estacionamiento_publico', params)
        const part = resp?.data?.result || []
        for (const r of part) acc.push(r)
      }
      rows.value = acc
    }
  } catch (e) {
    rows.value = [{ error: e.message || 'Error' }]
  } finally {
    loading.value = false
  }
}

const visibleColumns = computed(() => {
  if (!rows.value.length) return []
  const keys = Object.keys(rows.value[0] || {})
  return keys
})

function formatCell(v) {
  if (v === null || typeof v === 'undefined') return '—'
  if (typeof v === 'number') return v
  // Try date
  const d = new Date(v)
  if (!isNaN(d.getTime()) && String(v).includes('-')) return d.toLocaleDateString()
  return String(v)
}
</script>
