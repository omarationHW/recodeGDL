<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-tie" /></div>
      <div class="module-view-info">
        <h1>Inspectores/Vigilantes</h1>
        <p>Catálogo de inspectores</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="load"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="spinner-border" role="status"></div>
          <div class="table-responsive" v-else>
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>ID</th><th>Inspector</th></tr></thead>
              <tbody>
                <tr v-for="i in rows" :key="i.id_esta_persona"><td>{{ i.id_esta_persona }}</td><td>{{ i.inspector }}</td></tr>
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

const rows = ref([])
const loading = ref(false)

async function load() {
  loading.value = true
  rows.value = []
  try {
    const resp = await apiService.execute('sp_get_inspectors', 'estacionamiento_publico', [])
    rows.value = resp?.data?.result || []
  } finally { loading.value = false }
}

load()
</script>

