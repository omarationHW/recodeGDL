<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Estatus Requerimientos</h1>
        <p>Estadísticas y resumen de requerimientos</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Filtro (Ejecutor, Recaudadora, etc.)</label>
              <input
                class="municipal-form-control"
                v-model="filters.q"
                @keyup.enter="reload"
                placeholder="Buscar..."
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card" v-if="!loading">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="table" /> Resultados</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ c }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in rows" :key="i" class="row-hover">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td :colspan="cols.length || 1" class="text-center text-muted">
                    Sin registros
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center">
        <div class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_ESTADREQ'

const filters = ref({ q: '' })
const rows = ref([])
const cols = ref([])

async function reload() {
  try {
    const params = [
      { nombre: 'q', tipo: 'string', valor: String(filters.value.q || '') }
    ]
    const data = await execute(OP, BASE_DB, params)

    // La API puede retornar data.result, data.rows, o data directamente como array
    const arr = Array.isArray(data?.result) ? data.result
               : Array.isArray(data?.rows) ? data.rows
               : Array.isArray(data) ? data
               : []

    rows.value = arr
    cols.value = arr.length > 0 ? Object.keys(arr[0]) : []
  } catch (e) {
    console.error('Error al cargar datos:', e)
    rows.value = []
    cols.value = []
  }
}

// Cargar datos al iniciar
reload()
</script>
