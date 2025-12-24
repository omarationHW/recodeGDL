<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Requerimiento Cuentas Canceladas</h1>
        <p>Consulta de cuentas canceladas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book" />
          Documentacion
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Formulario de filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>🔍 Parámetros</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta *</label>
              <input
                class="municipal-form-control"
                type="text"
                v-model="filters.cuenta"
                placeholder="Ingrese la clave de cuenta"
                @keyup.enter="buscar"
              />
            </div>
          </div>

          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta"
              @click="buscar"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <span v-if="loading">Buscando...</span>
              <span v-else>Buscar</span>
            </button>

            <button
              class="btn-municipal-secondary"
              @click="limpiar"
              :disabled="loading"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>

          <div class="help-text">
            <small>* Campo requerido. Ingrese la clave de cuenta para buscar.</small>
          </div>
        </div>
      </div>

      <!-- Mensaje de éxito -->
      <div class="municipal-card" v-if="success">
        <div class="municipal-card-body">
          <div class="alert alert-success">
            <strong>✅ Éxito:</strong> {{ success }}
          </div>
        </div>
      </div>

      <!-- Mensaje de error -->
      <div class="municipal-card" v-if="error">
        <div class="municipal-card-body">
          <div class="alert alert-danger">
            <strong>❌ Error:</strong> {{ error }}
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card" v-if="rows.length > 0">
        <div class="municipal-card-header">
          <h5>📋 Resultados ({{ rows.length }} registros)</h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedRows" :key="idx">
                  <td v-for="col in columns" :key="col">{{ row[col] }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container" v-if="totalPages > 1">
            <button
              class="btn-pagination"
              @click="currentPage = 1"
              :disabled="currentPage === 1"
            >
              Primera
            </button>
            <button
              class="btn-pagination"
              @click="currentPage--"
              :disabled="currentPage === 1"
            >
              Anterior
            </button>
            <span class="pagination-info">
              Página {{ currentPage }} de {{ totalPages }}
            </span>
            <button
              class="btn-pagination"
              @click="currentPage++"
              :disabled="currentPage === totalPages"
            >
              Siguiente
            </button>
            <button
              class="btn-pagination"
              @click="currentPage = totalPages"
              :disabled="currentPage === totalPages"
            >
              Última
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay resultados -->
      <div class="municipal-card" v-if="searched && rows.length === 0">
        <div class="municipal-card-body">
          <div class="alert alert-info">
            <strong>ℹ️ Info:</strong> No se encontraron resultados para la cuenta especificada.
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'reqctascanfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Requerimiento Cuentas Canceladas'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'reqctascanfrm'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Requerimiento Cuentas Canceladas'"
      @close="showDocumentacion = false"
    />

  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
// Estados para modales de documentacion
const showAyuda = ref(false)
const showDocumentacion = ref(false)

const { loading, error: apiError, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const BASE_DB = 'multas_reglamentos'
const OP = 'RECAUDADORA_REQCTASCANFRM'

const filters = ref({
  cuenta: ''
})

const rows = ref([])
const columns = ref([])
const success = ref('')
const error = ref('')
const searched = ref(false)
const currentPage = ref(1)
const itemsPerPage = 10

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage)
})

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  const end = start + itemsPerPage
  return rows.value.slice(start, end)
})

async function buscar() {
  error.value = ''
  success.value = ''
  searched.value = false

  if (!filters.value.cuenta) {
    error.value = 'Por favor ingrese la clave de cuenta'
    return
  }

  try {
    const params = [
      { nombre: 'clave_cuenta', valor: String(filters.value.cuenta || ''), tipo: 'string' }
    ]

    console.log('Ejecutando:', OP, 'con parámetros:', params)

    const data = await execute(OP, BASE_DB, params)

    console.log('Respuesta del servidor:', data)

    // Extraer el array de resultados de la respuesta
    const arr = Array.isArray(data?.result)
      ? data.result
      : Array.isArray(data?.rows)
        ? data.rows
        : Array.isArray(data)
          ? data
          : []

    rows.value = arr
    columns.value = arr.length > 0 ? Object.keys(arr[0]) : []
    currentPage.value = 1
    searched.value = true

    if (arr.length > 0) {
      success.value = `Se encontraron ${arr.length} registros`
    }
  } catch (e) {
    console.error('Error al buscar:', e)
    error.value = apiError.value || e.message || 'Error al ejecutar la búsqueda'
    rows.value = []
    columns.value = []
    searched.value = true
  }
}

function limpiar() {
  filters.value = {
    cuenta: ''
  }
  rows.value = []
  columns.value = []
  success.value = ''
  error.value = ''
  searched.value = false
  currentPage.value = 1
}
</script>

