<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="id-card" /></div>
      <div class="module-view-info">
        <h1>Derechos Licencias</h1>
        <p>Consulta de derechos de licencias comerciales</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Search form -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Número de Licencia</label>
              <input
                class="municipal-form-control"
                v-model="filters.licencia"
                @keyup.enter="reload"
                placeholder="Ej: 1, 5, 8"
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

      <!-- Results table -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Licencias Registradas</h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Licencia</th>
                  <th>Propietario</th>
                  <th>RFC</th>
                  <th>Domicilio</th>
                  <th>Giro</th>
                  <th>Zona</th>
                  <th>CVE Cuenta</th>
                  <th>Fecha Otorg.</th>
                  <th>Coordenadas</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.id_licencia }}</code></td>
                  <td><strong>{{ r.licencia }}</strong></td>
                  <td>{{ r.propietario }}</td>
                  <td>{{ r.rfc || '-' }}</td>
                  <td>{{ r.domicilio || '-' }}</td>
                  <td>{{ r.id_giro }}</td>
                  <td>{{ r.zona || '-' }} / {{ r.subzona || '-' }}</td>
                  <td>{{ r.cvecuenta || '-' }}</td>
                  <td>{{ r.fecha_otorgamiento }}</td>
                  <td><small>{{ r.coordenadas }}</small></td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    Sin resultados para esta licencia
                  </td>
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

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_DRECGOLIC'
const SCHEMA = 'multas_reglamentos'

const { loading, execute } = useApi()

const filters = ref({ licencia: '' })
const rows = ref([])

async function reload() {
  const params = [
    { nombre: 'p_licencia', tipo: 'string', valor: String(filters.value.licencia || '') }
  ]

  try {
    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)
    rows.value = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  }
}
</script>
