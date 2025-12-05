<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="dumpster" /></div>
      <div class="module-view-info">
        <h1>Derechos de Fosa</h1>
        <p>Consulta y control de fosas en panteones municipales</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Search form -->
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Folio (ID Control)</label>
              <input
                class="municipal-form-control"
                v-model.number="filters.folio"
                type="number"
                @keyup.enter="reload"
                placeholder="Ej: 2, 7, 12"
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
          <h5><font-awesome-icon icon="list" /> Fosas Registradas</h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Control</th>
                  <th>Cementerio</th>
                  <th>Clase</th>
                  <th>Sección</th>
                  <th>Línea</th>
                  <th>Fosa</th>
                  <th>Titular</th>
                  <th>Período</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.id_control }}</code></td>
                  <td><strong>{{ r.cementerio }}</strong></td>
                  <td>{{ r.clase }}</td>
                  <td>{{ r.seccion }}</td>
                  <td>{{ r.linea }}</td>
                  <td><strong>{{ r.fosa }}</strong></td>
                  <td>{{ r.nombre_titular }}</td>
                  <td>{{ r.anio_minimo }} - {{ r.anio_maximo }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="8" class="text-center text-muted">
                    Sin resultados para este folio
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
const OP_LIST = 'RECAUDADORA_DRECGO_FOSA'
const SCHEMA = 'multas_reglamentos'

const { loading, execute } = useApi()

const filters = ref({ folio: null })
const rows = ref([])

async function reload() {
  const params = [
    { nombre: 'p_folio', tipo: 'int', valor: Number(filters.value.folio || 0) }
  ]

  try {
    const data = await execute(OP_LIST, BASE_DB, params, '', null, SCHEMA)
    rows.value = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  }
}
</script>
