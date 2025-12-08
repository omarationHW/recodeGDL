<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="envelopes-bulk" /></div>
      <div class="module-view-info">
        <h1>Consulta de Remesas</h1>
        <p>sp_get_remesas y detalle de remesa</p>
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
        <button class="btn-municipal-secondary" :disabled="loading" @click="load"><font-awesome-icon icon="sync-alt" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Tipo</label>
              <select class="municipal-form-control" v-model="tipo"><option value="A">A</option><option value="B">B</option><option value="C">C</option><option value="D">D</option></select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><h5>Remesas</h5></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Tipo</th><th>Remesa</th><th>Inicio</th><th>Fin</th><th>Control</th><th>Cant</th><th>Acciones</th></tr></thead>
              <tbody>
                <tr v-for="r in paginatedRemesas" :key="r.num_remesa">
                  <td>{{ r.tipo }}</td><td>{{ r.num_remesa }}</td><td>{{ formatDate(r.fecha_inicio) }}</td><td>{{ formatDate(r.fecha_fin) }}</td><td>{{ r.control }}</td><td>{{ r.cant_reg }}</td>
                  <td><button class="btn-municipal-info btn-sm" @click="verDetalle(r)" title="Ver detalle"><font-awesome-icon icon="eye" /></button></td>
                </tr>
                <tr v-if="remesas.length===0"><td colspan="7" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
          <div class="pagination-container" v-if="remesas.length > 0">
            <div class="pagination-info">
              Mostrando {{ startIndexRemesas + 1 }} - {{ endIndexRemesas }} de {{ remesas.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                @click="currentPageRemesas--"
                :disabled="currentPageRemesas === 1"
              >
                Anterior
              </button>
              <span class="pagination-page">Página {{ currentPageRemesas }} de {{ totalPagesRemesas }}</span>
              <button
                class="btn-pagination"
                @click="currentPageRemesas++"
                :disabled="currentPageRemesas === totalPagesRemesas"
              >
                Siguiente
              </button>
            </div>
            <div class="pagination-size">
              <label>Registros por página:</label>
              <select v-model.number="pageSizeRemesas" class="form-select-sm">
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

    <!-- Modal de Detalle de Remesa -->
    <div v-if="showDetalleModal" class="modal-overlay" @click.self="closeDetalleModal">
      <div class="modal-container modal-xl">
        <div class="modal-header">
          <h3><font-awesome-icon icon="list-alt" /> Detalle de Remesa {{ remesaSel }}</h3>
          <button class="modal-close" @click="closeDetalleModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Placa</th>
                  <th>Año</th>
                  <th>Folio</th>
                  <th>Fecha Pago</th>
                  <th>Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="d in paginatedDetalle" :key="d.folio">
                  <td>{{ d.placa }}</td>
                  <td>{{ d.axo }}</td>
                  <td>{{ d.folio }}</td>
                  <td>{{ formatDate(d.fechapago) }}</td>
                  <td>{{ formatMonto(d.importe) }}</td>
                </tr>
                <tr v-if="detalleRemesa.length === 0">
                  <td colspan="5" class="text-center text-muted">Sin registros</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="pagination-container" v-if="detalleRemesa.length > 0">
            <div class="pagination-info">
              Mostrando {{ startIndexDetalle + 1 }} - {{ endIndexDetalle }} de {{ detalleRemesa.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-pagination"
                @click="currentPageDetalle--"
                :disabled="currentPageDetalle === 1"
              >
                <font-awesome-icon icon="angle-left" /> Anterior
              </button>
              <span class="pagination-page">Página {{ currentPageDetalle }} de {{ totalPagesDetalle }}</span>
              <button
                class="btn-pagination"
                @click="currentPageDetalle++"
                :disabled="currentPageDetalle === totalPagesDetalle"
              >
                Siguiente <font-awesome-icon icon="angle-right" />
              </button>
            </div>
            <div class="pagination-size">
              <label>Registros:</label>
              <select v-model.number="pageSizeDetalle" class="form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="closeDetalleModal">
            <font-awesome-icon icon="times" /> Cerrar
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ConsRemesasPublicos"
    >
      <h3>Cons Remesas Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ConsRemesasPublicos'"
      :moduleName="'estacionamiento_publico'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, onMounted, computed, watch } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'public'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const tipo = ref('A')
const remesas = ref([])
const detalleRemesa = ref([])
const remesaSel = ref('')
const showDetalleModal = ref(false)

// Paginación para Remesas
const currentPageRemesas = ref(1)
const pageSizeRemesas = ref(10)

const totalPagesRemesas = computed(() => {
  return Math.ceil(remesas.value.length / pageSizeRemesas.value) || 1
})

const startIndexRemesas = computed(() => {
  return (currentPageRemesas.value - 1) * pageSizeRemesas.value
})

const endIndexRemesas = computed(() => {
  return Math.min(startIndexRemesas.value + pageSizeRemesas.value, remesas.value.length)
})

const paginatedRemesas = computed(() => {
  return remesas.value.slice(startIndexRemesas.value, endIndexRemesas.value)
})

watch([pageSizeRemesas], () => {
  currentPageRemesas.value = 1
})

// Paginación para Detalle
const currentPageDetalle = ref(1)
const pageSizeDetalle = ref(10)

const totalPagesDetalle = computed(() => {
  return Math.ceil(detalleRemesa.value.length / pageSizeDetalle.value) || 1
})

const startIndexDetalle = computed(() => {
  return (currentPageDetalle.value - 1) * pageSizeDetalle.value
})

const endIndexDetalle = computed(() => {
  return Math.min(startIndexDetalle.value + pageSizeDetalle.value, detalleRemesa.value.length)
})

const paginatedDetalle = computed(() => {
  return detalleRemesa.value.slice(startIndexDetalle.value, endIndexDetalle.value)
})

watch([pageSizeDetalle], () => {
  currentPageDetalle.value = 1
})

function formatDate(d) {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('es-MX')
}

function formatMonto(m) {
  if (!m && m !== 0) return '—'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(m)
}

async function load() {
  showLoading('Cargando...', 'Obteniendo remesas')
  remesas.value = []
  detalleRemesa.value = []
  currentPageRemesas.value = 1
  try {
    const resp = await execute('sp_get_remesas', BASE_DB, [
      { nombre: 'tipo_param', valor: tipo.value, tipo: 'string' }
    ], '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    remesas.value = Array.isArray(data) ? data : []

    if (remesas.value.length === 0) {
      showToast('info', `No se encontraron remesas de tipo ${tipo.value}`)
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function verDetalle(r) {
  if (!r || !r.num_remesa) {
    showToast('error', 'Registro inválido')
    return
  }
  detalle(r)
}

async function detalle(r) {
  showLoading('Cargando...', 'Obteniendo detalle de remesa')
  try {
    remesaSel.value = r.num_remesa
    currentPageDetalle.value = 1
    detalleRemesa.value = []

    const resp = await execute('sp_get_remesa_detalle_mpio', BASE_DB, [
      { nombre: 'remesa_param', valor: String(r.num_remesa), tipo: 'string' }
    ], '', null, SCHEMA)

    const data = resp?.result || resp?.data?.result || resp?.data || []
    detalleRemesa.value = Array.isArray(data) ? data : []

    if (detalleRemesa.value.length === 0) {
      showToast('info', 'Esta remesa no tiene registros de detalle')
    } else {
      showToast('success', `Se cargaron ${detalleRemesa.value.length} registros`)
      showDetalleModal.value = true
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function closeDetalleModal() {
  showDetalleModal.value = false
}

onMounted(() => {
  load()
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

