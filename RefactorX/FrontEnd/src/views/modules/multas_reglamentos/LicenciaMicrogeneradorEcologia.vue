<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="leaf" />
      </div>
      <div class="module-view-info">
        <h1>Licencia Microgenerador Ecología</h1>
        <p>Consulta de licencias ecológicas de microgeneración</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Búsqueda por RFC</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">RFC</label>
              <input
                class="municipal-form-control"
                v-model="filters.rfc"
                placeholder="Ej: ABC123456XYZ"
                @keyup.enter="consultar"
                maxlength="13"
              />
              <small class="form-text">Ingrese el RFC del solicitante (12-13 caracteres)</small>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.rfc"
              @click="consultar"
            >
              <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading"/>
              {{ loading ? 'Consultando...' : 'Consultar' }}
            </button>
          </div>
        </div>
      </div>

      <!-- Error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert-danger">
            <font-awesome-icon icon="times-circle"/>
            <strong>Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="rows.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table"/>
            Licencias ecológicas encontradas ({{ rows.length }})
          </h5>
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
                <tr v-for="(r, i) in rows" :key="i">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div class="municipal-card" v-else-if="searched && !error">
        <div class="municipal-card-body">
          <div class="alert-info">
            <font-awesome-icon icon="info-circle"/>
            <strong>No se encontraron licencias ecológicas para el RFC proporcionado</strong>
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
const OP = 'RECAUDADORA_LICENCIAMICROGENERADORECOLOGIA'

const filters = ref({ rfc: '' })
const rows = ref([])
const cols = ref([])
const error = ref(null)
const searched = ref(false)

async function consultar() {
  error.value = null
  searched.value = false

  const params = [
    { nombre: 'p_rfc', tipo: 'string', valor: String(filters.value.rfc || '').toUpperCase() }
  ]

  try {
    const response = await execute(OP, BASE_DB, params)
    searched.value = true

    // Manejar diferentes formatos de respuesta
    let data = null

    if (response?.result) {
      data = response.result
    } else if (response?.rows) {
      data = response.rows
    } else if (Array.isArray(response)) {
      data = response
    } else {
      data = response
    }

    const arr = Array.isArray(data) ? data : []
    rows.value = arr
    cols.value = arr.length > 0 ? Object.keys(arr[0]) : []

  } catch (e) {
    searched.value = true
    error.value = e?.message || 'Error al realizar la consulta'
    rows.value = []
    cols.value = []
  }
}
</script>

<style scoped>
.form-text {
  color: #6c757d;
  font-size: 0.85rem;
  margin-top: 4px;
  display: block;
}

.table-container {
  overflow-x: auto;
}

.table-responsive {
  width: 100%;
  overflow-x: auto;
}

.municipal-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 0;
}

.municipal-table-header {
  background-color: #f8f9fa;
  border-bottom: 2px solid #dee2e6;
}

.municipal-table-header th {
  padding: 12px;
  text-align: left;
  font-weight: 600;
  color: #495057;
  border-bottom: 2px solid #dee2e6;
}

.municipal-table tbody tr {
  border-bottom: 1px solid #dee2e6;
}

.municipal-table tbody tr:hover {
  background-color: #f8f9fa;
}

.municipal-table tbody td {
  padding: 12px;
  color: #212529;
}

.alert-danger {
  background-color: #f8d7da;
  border: 1px solid #f5c6cb;
  border-radius: 8px;
  padding: 16px;
  color: #721c24;
}

.alert-danger svg {
  margin-right: 8px;
}

.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  border-radius: 8px;
  padding: 16px;
  color: #0c5460;
}

.alert-info svg {
  margin-right: 8px;
}
</style>
