<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Derechos Licencias</h1>
        <p>dderechosLic.vue</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Licencia</label>
              <input class="municipal-form-control" v-model="filters.licencia" @keyup.enter="reload"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="reload">
              <font-awesome-icon icon="search"/> Buscar
            </button>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Derechos ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="c in cols" :key="c">{{ c }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, i) in paginatedRows" :key="i" class="row-hover">
                  <td v-for="c in cols" :key="c">{{ r[c] }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td :colspan="cols.length" class="text-center text-muted">Sin resultados</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                :disabled="currentPage === 1"
                @click="currentPage--"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-pagination"
                :disabled="currentPage === totalPages"
                @click="currentPage++"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Procesando operación...</p>
      </div>
    </div>
  </div>
</template>
<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_DDERECHOSLIC'
const SCHEMA = 'multas_reglamentos'

const { loading, execute } = useApi()

const filters = ref({ licencia: '' })
const rows = ref([])
const cols = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

async function reload() {
  try {
    const data = await execute(
      OP,
      BASE_DB,
      [
        { nombre: 'p_licencia', tipo: 'int', valor: Number(filters.value.licencia || 0) }
      ],
      '',
      null,
      SCHEMA
    )

    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
      ? data.rows
      : Array.isArray(data)
      ? data
      : []

    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
    currentPage.value = 1 // Reset a la primera página
  } catch (e) {
    rows.value = []
    cols.value = []
  }
}
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 20px;
  padding: 15px;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  color: #6c757d;
  font-size: 14px;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 15px;
}

.pagination-page {
  color: #495057;
  font-weight: 500;
}

.btn-pagination {
  padding: 8px 16px;
  border: 1px solid #dee2e6;
  border-radius: 4px;
  background-color: #fff;
  color: #495057;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #e9ecef;
  border-color: #adb5bd;
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}
</style>

