<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info"><h1>Reporte Multa Municipal</h1></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Ejercicio</label>
              <input class="municipal-form-control" type="number" v-model.number="filters.ejercicio"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="generar">Generar</button>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th v-for="c in cols" :key="c">{{ c }}</th></tr>
              </thead>
              <tbody>
                <tr v-for="(r,i) in rows" :key="i">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
                </tr>
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
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REPMULTAMPALFRM'

const filters = ref({
  ejercicio: new Date().getFullYear()
})

const rows = ref([])
const cols = ref([])

async function generar() {
  try {
    const data = await execute(OP, BASE_DB, [
      { nombre: 'p_ejercicio', valor: Number(filters.value.ejercicio || 0), tipo: 'integer' }
    ])

    // Extraer el array de resultados de la respuesta
    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
        ? data.rows
        : Array.isArray(data)
          ? data
          : []

    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
  } catch (e) {
    console.error('Error al generar reporte:', e)
    rows.value = []
    cols.value = []
  }
}
</script>
