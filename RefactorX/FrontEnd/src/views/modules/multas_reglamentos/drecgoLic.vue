<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="id-card" /></div>
      <div class="module-view-info">
        <h1>Derechos Licencias</h1>
        <p>Consulta de derechos de licencias comerciales</p>
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
          <h5><font-awesome-icon icon="list" /> Licencias Registradas ({{ rows.length }} registros)</h5>
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
                <tr v-for="(r, idx) in paginatedRows" :key="idx" class="row-hover">
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

          <!-- Pagination Controls -->
          <div v-if="rows.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ rows.length }} registros
              </span>
            </div>
            <div class="pagination-buttons">
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="goToPage(1)">
                <font-awesome-icon icon="angles-left" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === 1"
                @click="prevPage">
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page-indicator">
                Página {{ currentPage }} de {{ totalPages }}
              </span>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="nextPage">
                <font-awesome-icon icon="chevron-right" />
              </button>
              <button
                class="btn-municipal-secondary"
                :disabled="currentPage === totalPages"
                @click="goToPage(totalPages)">
                <font-awesome-icon icon="angles-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showAyuda"
      :component-name="'drecgoLic'"
      :module-name="'multas_reglamentos'"
      :doc-type="'ayuda'"
      :title="'Derechos Licencias'"
      @close="showAyuda = false"
    />

    <!-- Modal de Documentacion -->
    <DocumentationModal
      :show="showDocumentacion"
      :component-name="'drecgoLic'"
      :module-name="'multas_reglamentos'"
      :doc-type="'documentacion'"
      :title="'Derechos Licencias'"
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
const OP = 'RECAUDADORA_DRECGOLIC'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({ licencia: '' })
const rows = ref([])
const currentPage = ref(1)
const pageSize = ref(10)

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

async function reload() {
  currentPage.value = 1 // Reset a la primera página al buscar
  const params = [
    { nombre: 'p_licencia', tipo: 'string', valor: String(filters.value.licencia || '') }
  ]

  try {
    showLoading('Consultando...', 'Por favor espere')
    const data = await execute(OP, BASE_DB, params, '', null, SCHEMA)
    rows.value = Array.isArray(data?.result) ? data.result : Array.isArray(data?.rows) ? data.rows : Array.isArray(data) ? data : []
  } catch (e) {
    rows.value = []
  } finally {
    hideLoading()
  }
}
</script>
