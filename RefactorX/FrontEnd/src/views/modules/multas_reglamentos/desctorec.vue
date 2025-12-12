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
          <h5><font-awesome-icon icon="list" /> Descuentos de Recargos ({{ rows.length }} registros)</h5>
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
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
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

          <!-- Pagination Controls -->
          <div v-if="rows.length > 0" class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; border-top: 1px solid #dee2e6;">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
              </span>
            </div>
            <div class="pagination-controls" style="display: flex; gap: 0.5rem;">
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="goToPage(1)"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="prevPage"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span style="display: flex; align-items: center; padding: 0 1rem; font-weight: 500;">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="nextPage"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)"
                style="padding: 0.5rem 0.75rem;">
                <font-awesome-icon icon="angles-right" />
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
const OP = 'RECAUDADORA_DESCTOREC'

const { loading, execute } = useApi()

const filters = ref({ cuenta: '' })
const rows = ref([])
const currentPage = ref(1)
const pageSize = ref(10)

const SCHEMA = 'publico'

// Computed properties para paginación
const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value))

const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)

const endIndex = computed(() => {
  const end = startIndex.value + pageSize.value
  return end > rows.value.length ? rows.value.length : end
})

const paginatedRows = computed(() => {
  return rows.value.slice(startIndex.value, endIndex.value)
})

// Funciones de paginación
function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function prevPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function goToPage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

async function buscar() {
  currentPage.value = 1 // Reset a la primera página al buscar
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
