<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percent" /></div>
      <div class="module-view-info">
        <h1>Descuentos Prediales</h1>
        <p>Consulta descuentos de predios (clave catastral)</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Clave Catastral (CVE Cuenta)</label>
              <input class="municipal-form-control" v-model="filters.cvecat" @keyup.enter="reload" placeholder="Ej: 58, 60, 70" />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Descuentos</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>CVE Cuenta</th>
                  <th>CVE Desc.</th>
                  <th>Descripción</th>
                  <th>%</th>
                  <th>Ejercicio</th>
                  <th>Bimestres</th>
                  <th>Fecha Alta</th>
                  <th>Capturista</th>
                  <th>Status</th>
                  <th>Solicitante</th>
                  <th>Observaciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.cvecuenta }}</code></td>
                  <td>{{ r.cvedescuento }}</td>
                  <td>{{ r.descripcion }}</td>
                  <td>{{ r.porcentaje }}%</td>
                  <td>{{ r.ejercicio }}</td>
                  <td>{{ r.bimini }} - {{ r.bimfin }}</td>
                  <td>{{ r.fecalta }}</td>
                  <td>{{ r.captalta }}</td>
                  <td><span :class="'badge badge-' + (r.status_desc === 'Vigente' ? 'success' : r.status_desc === 'Cancelado' ? 'secondary' : 'warning')">{{ r.status_desc }}</span></td>
                  <td>{{ r.solicitante }}</td>
                  <td>{{ r.observaciones }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="11" class="text-center text-muted">Sin registros</td>
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
const OP_LIST = 'RECAUDADORA_DESCPREDFRM'

const { loading, execute } = useApi()

const filters = ref({ cvecat: '' })
const rows = ref([])

const SCHEMA = 'multas_reglamentos'

async function reload() {
  const params = [
    { nombre: 'p_cvecat', tipo: 'string', valor: String(filters.value.cvecat || '') }
  ]
  try {
    const data = await execute(OP_LIST, BASE_DB, params, '', null, SCHEMA)
    rows.value = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  }
}

reload()
</script>
