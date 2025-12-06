<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bell" />
      </div>
      <div class="module-view-info">
        <h1>Listado de Notificaciones</h1>
        <p>Lista de actas notificadas por rango de folios</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <form @submit.prevent="onSubmit">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Recaudadora</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.reca"
                  required
                  min="1"
                  max="5"
                  placeholder="1-5"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Año</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.axo"
                  required
                  min="2000"
                  max="2099"
                  placeholder="2024"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Folio Inicial</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.inicio"
                  required
                  min="1"
                  placeholder="1"
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Folio Final</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.final"
                  required
                  min="1"
                  placeholder="100"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Documento</label>
                <div class="radio-group">
                  <label class="radio-label">
                    <input type="radio" v-model="form.tipo" value="N" />
                    Notificación
                  </label>
                  <label class="radio-label">
                    <input type="radio" v-model="form.tipo" value="R" />
                    Requerimiento
                  </label>
                  <label class="radio-label">
                    <input type="radio" v-model="form.tipo" value="S" />
                    Secuestro
                  </label>
                </div>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Ordenado por</label>
                <div class="radio-group">
                  <label class="radio-label">
                    <input type="radio" v-model="form.orden" value="lote" />
                    Número de lote
                  </label>
                  <label class="radio-label">
                    <input type="radio" v-model="form.orden" value="vigentes" />
                    Folio de notificación
                  </label>
                  <label class="radio-label">
                    <input type="radio" v-model="form.orden" value="dependencia" />
                    Dependencia y número
                  </label>
                </div>
              </div>
            </div>

            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" v-if="!loading" />
                <span v-if="loading">Buscando...</span>
                <span v-else>Buscar</span>
              </button>
            </div>
          </form>
        </div>
      </div>

      <div class="municipal-card" v-if="result.length > 0">
        <div class="municipal-card-header">
          <h5>Resultados ({{ result.length }} actas)</h5>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Dependencia</th>
                  <th>Año Acta</th>
                  <th>Núm. Acta</th>
                  <th>Núm. Lote</th>
                  <th>Folio Req</th>
                  <th>Contribuyente</th>
                  <th>Domicilio</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResult" :key="idx" class="row-hover">
                  <td>{{ row.abrevia }}</td>
                  <td>{{ row.axo_acta }}</td>
                  <td>{{ row.num_acta }}</td>
                  <td>{{ row.num_lote }}</td>
                  <td>{{ row.folioreq }}</td>
                  <td>{{ row.contribuyente }}</td>
                  <td>{{ row.domicilio }}</td>
                  <td class="text-right">${{ formatMoney(row.total) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Pagination Controls -->
          <div v-if="result.length > 0" class="pagination-container" style="display: flex; justify-content: space-between; align-items: center; padding: 1rem; border-top: 1px solid #dee2e6;">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ result.length }} registros
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

      <div class="municipal-card" v-else-if="searched && result.length === 0">
        <div class="municipal-card-body">
          <p class="text-center text-muted">No se encontraron resultados</p>
        </div>
      </div>

      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <p class="text-danger">{{ error }}</p>
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

const { loading, execute } = useApi()
const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_LISTANOTIFICACIONESFRM'

const form = ref({
  reca: 1,
  axo: new Date().getFullYear(),
  inicio: 1,
  final: 100,
  tipo: 'N',
  orden: 'lote'
})

const result = ref([])
const error = ref('')
const searched = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)

// Computed properties para paginación
const totalPages = computed(() => Math.ceil(result.value.length / pageSize.value))

const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)

const endIndex = computed(() => {
  const end = startIndex.value + pageSize.value
  return end > result.value.length ? result.value.length : end
})

const paginatedResult = computed(() => {
  return result.value.slice(startIndex.value, endIndex.value)
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

async function onSubmit() {
  currentPage.value = 1 // Reset a la primera página al buscar
  error.value = ''
  searched.value = false
  result.value = []

  try {
    const params = [
      { nombre: 'p_reca', tipo: 'integer', valor: form.value.reca },
      { nombre: 'p_axo', tipo: 'integer', valor: form.value.axo },
      { nombre: 'p_inicio', tipo: 'integer', valor: form.value.inicio },
      { nombre: 'p_final', tipo: 'integer', valor: form.value.final },
      { nombre: 'p_tipo', tipo: 'string', valor: form.value.tipo },
      { nombre: 'p_orden', tipo: 'string', valor: form.value.orden }
    ]

    const response = await execute(OP, BASE_DB, params)

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
    result.value = arr
    searched.value = true
  } catch (e) {
    error.value = e.message || 'Error al ejecutar la consulta'
    searched.value = true
  }
}

function formatMoney(value) {
  if (!value) return '0.00'
  return Number(value).toLocaleString('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  })
}
</script>

<style scoped>
.radio-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.radio-label {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  cursor: pointer;
  font-weight: normal;
}

.radio-label input[type="radio"] {
  cursor: pointer;
}

.text-right {
  text-align: right;
}

.text-center {
  text-align: center;
}

.text-muted {
  color: #6c757d;
}

.text-danger {
  color: #dc3545;
}
</style>
