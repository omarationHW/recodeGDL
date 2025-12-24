<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="percent" /></div>
      <div class="module-view-info">
        <h1>Descuentos Derechos de Mercado</h1>
        <p>Consulta de descuentos aplicables a derechos de mercado por cuenta y ejercicio</p>
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
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Cuenta</label>
              <input
                class="municipal-form-control"
                v-model="filters.cuenta"
                @keyup.enter="filters.cuenta.trim() && reload()"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="filters.ejercicio"
                placeholder="Ej: 2024"
                @keyup.enter="filters.cuenta.trim() && reload()"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              :disabled="loading || !filters.cuenta.trim()"
              @click="reload"
            >
              <font-awesome-icon icon="search" v-if="!loading" />
              <font-awesome-icon icon="spinner" spin v-if="loading" />
              {{ loading ? 'Buscando...' : 'Buscar' }}
            </button>
            <button
              class="btn-municipal-secondary"
              :disabled="loading"
              @click="limpiar"
            >
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="list" /> Registros ({{ rows.length }} registros)</h5>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Cargando...</span></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta</th>
                  <th>Descuento</th>
                  <th>Desde</th>
                  <th>Hasta</th>
                  <th>Estatus</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
                  <td><code>{{ r.clave_cuenta }}</code></td>
                  <td>{{ r.descuento }}</td>
                  <td>{{ r.desde }}</td>
                  <td>{{ r.hasta }}</td>
                  <td>{{ r.estatus }}</td>
                </tr>
                <tr v-if="rows.length === 0">
                  <td colspan="5" class="text-center text-muted">Sin registros</td>
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


    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'DescDerechosMerc'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Descuentos Derechos de Mercado'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'DescDerechosMerc'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Descuentos Derechos de Mercado'"
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


const BASE_DB = 'multas_reglamentos'
const OP_LIST = 'RECAUDADORA_DESCDERECHOS_MERC'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ cuenta: '', ejercicio: 2024 })
const rows = ref([])
const currentPage = ref(1)
const itemsPerPage = 10

// Paginación
const totalPages = computed(() => Math.ceil(rows.value.length / itemsPerPage))
const startIndex = computed(() => (currentPage.value - 1) * itemsPerPage)
const endIndex = computed(() => Math.min(startIndex.value + itemsPerPage, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

async function reload() {
  const params = [
    { nombre: 'p_clave_cuenta', tipo: 'string', valor: String(filters.value.cuenta || '') },
    { nombre: 'p_ejercicio', tipo: 'int', valor: Number(filters.value.ejercicio || 0) }
  ]

  showLoading('Consultando...', 'Por favor espere')
  try {
    const response = await execute(OP_LIST, BASE_DB, params, '', null, 'publico')
    console.log('Respuesta completa:', response)

    // Extraer datos con fallbacks
    const responseData = response?.eResponse?.data || response?.data || response
    const arr = Array.isArray(responseData?.result) ? responseData.result :
                 Array.isArray(responseData?.rows) ? responseData.rows :
                 Array.isArray(responseData) ? responseData : []

    console.log('Registros extraídos:', arr.length, arr)
    rows.value = arr
    currentPage.value = 1 // Reset a la primera página
  } catch (e) {
    console.error('Error al consultar descuentos:', e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

function limpiar() {
  filters.value = { cuenta: '', ejercicio: 2024 }
  rows.value = []
  currentPage.value = 1
}
</script>


