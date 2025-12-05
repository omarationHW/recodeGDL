<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percent" /></div>
      <div class="module-view-info">
        <h1>Descuento Recargos</h1>
        <p>Consulta descuentos aplicados a recargos de predios</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">CVE Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="buscar"
                placeholder="Ej: 8, 17, 40"
              />
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="buscar">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Descuentos de Recargos</h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>CVE Cuenta</th>
                  <th>Periodo Inicial</th>
                  <th>Periodo Final</th>
                  <th>Porcentaje</th>
                  <th>Fecha Alta</th>
                  <th>Capturista</th>
                  <th>Vigencia</th>
                  <th>Fecha Baja</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in rows" :key="idx" class="row-hover">
                  <td><code>{{ r.cvecuenta }}</code></td>
                  <td>{{ r.axoini }}/{{ r.bimini }}</td>
                  <td>{{ r.axofin }}/{{ r.bimfin }}</td>
                  <td><strong>{{ r.porcentaje }}%</strong></td>
                  <td>{{ r.fecalta }}</td>
                  <td>{{ r.captalta }}</td>
                  <td>
                    <span :class="'badge badge-' + (r.vigencia_desc === 'Vigente' ? 'success' : r.vigencia_desc === 'Pagado' ? 'info' : r.vigencia_desc === 'Bloqueado' ? 'warning' : 'secondary')">
                      {{ r.vigencia_desc }}
                    </span>
                  </td>
                  <td>{{ r.fecbaja || '-' }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="8" class="text-center text-muted">
                    Sin descuentos de recargos para esta cuenta
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
const OP = 'RECAUDADORA_DESCTOREC'

const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])

const SCHEMA = 'multas_reglamentos'

async function buscar() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') }
  ]
  try {
    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)
    rows.value = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  }
}

// No cargar automáticamente
// reload()
</script>
