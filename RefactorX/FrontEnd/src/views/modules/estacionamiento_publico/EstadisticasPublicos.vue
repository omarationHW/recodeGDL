<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-bar" /></div>
      <div class="module-view-info">
        <h1>Estadísticas — Estacionamientos Públicos</h1>
        <p>Concentrado por año</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="run"><font-awesome-icon icon="play" /> Ejecutar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año desde</label><input class="municipal-form-control" type="number" v-model.number="filters.axo_from" /></div>
            <div class="form-group"><label class="municipal-form-label">Año hasta</label><input class="municipal-form-control" type="number" v-model.number="filters.axo_to" /></div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Año</th>
                  <th>Infracción</th>
                  <th>Folios</th>
                  <th>Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="r in paginatedRows" :key="`${r.axo}-${r.infraccion}`">
                  <td>{{ r.axo }}</td>
                  <td>{{ r.infraccion }}</td>
                  <td>{{ r.totfol }}</td>
                  <td>{{ formatMoney(r.totimp) }}</td>
                </tr>
                <tr v-if="rows.length===0">
                  <td colspan="4" class="text-center text-muted">Sin datos</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="rows.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} a {{ endIndex }} de {{ rows.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="prevPage"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="pagination-page">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="nextPage"
                :disabled="currentPage === totalPages"
              >
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label class="municipal-form-label">Registros por página:</label>
              <select class="municipal-form-control" v-model.number="pageSize" @change="currentPage = 1">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - EstadisticasPublicos"
    >
      <h3>Estadisticas Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'EstadisticasPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, reactive, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const rows = ref([])
const filters = reactive({
  axo_from: new Date().getFullYear() - 5,
  axo_to: new Date().getFullYear()
})

// Paginación
const currentPage = ref(1)
const pageSize = ref(25)

const totalPages = computed(() => Math.ceil(rows.value.length / pageSize.value))
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value)
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, rows.value.length))
const paginatedRows = computed(() => rows.value.slice(startIndex.value, endIndex.value))

function prevPage() {
  if (currentPage.value > 1) currentPage.value--
}

function nextPage() {
  if (currentPage.value < totalPages.value) currentPage.value++
}

function formatMoney(n) {
  try {
    return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(Number(n || 0))
  } catch {
    return n
  }
}

async function run() {
  if (!filters.axo_from || !filters.axo_to) {
    showToast('warning', 'Ingrese el rango de años a consultar')
    return
  }

  if (filters.axo_from > filters.axo_to) {
    showToast('warning', 'El año inicial debe ser menor o igual al año final')
    return
  }

  showLoading('Consultando...', 'Generando estadísticas')
  rows.value = []
  currentPage.value = 1
  try {
    const params = [
      { nombre: 'axo_from', valor: filters.axo_from, tipo: 'integer' },
      { nombre: 'axo_to', valor: filters.axo_to, tipo: 'integer' }
    ]
    const resp = await execute('sqrp_esta01_report', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    rows.value = Array.isArray(data) ? data : []

    if (rows.value.length === 0) {
      showToast('info', 'No hay estadísticas para el rango de años seleccionado')
    }
  } catch (e) {
    handleApiError(e)
    rows.value = []
  } finally {
    hideLoading()
  }
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

