<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="magnifying-glass" /></div>
      <div class="module-view-info">
        <h1>Consulta General — Placa</h1>
        <p>sp14_afolios y sp14_bfolios</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>

      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group full-width"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="placa" /></div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>Fuente Principal (Datos Edo)</h5>
          <span v-if="resA.length > 0" class="badge bg-primary ms-2">{{ resA.length }} registros</span>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Tipo</th><th>Año</th><th>Folio</th><th>Alta</th><th>Pago</th><th>Cancelado</th><th>Importe</th><th>Remesa</th></tr></thead>
              <tbody>
                <tr v-for="r in paginatedResA" :key="`${r.axo}-${r.folio}`"><td>{{ r.tipoact }}</td><td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ formatDate(r.fechaalta) }}</td><td>{{ formatDate(r.fechapago) }}</td><td>{{ formatDate(r.fechacancelado) }}</td><td>{{ r.importe }}</td><td>{{ r.remesa }}</td></tr>
                <tr v-if="resA.length===0"><td colspan="8" class="text-center text-muted">Sin datos</td></tr>
              </tbody>
            </table>
          </div>
          <div v-if="resA.length > rowsPerPageA" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ ((currentPageA - 1) * rowsPerPageA) + 1 }} a {{ Math.min(currentPageA * rowsPerPageA, resA.length) }} de {{ resA.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="currentPageA--"
                :disabled="currentPageA === 1"
              >
                Anterior
              </button>
              <span class="pagination-pages">Página {{ currentPageA }} de {{ totalPagesA }}</span>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="currentPageA++"
                :disabled="currentPageA === totalPagesA"
              >
                Siguiente
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>Fuente Secundaria (Datos Mpio)</h5>
          <span v-if="resB.length > 0" class="badge bg-primary ms-2">{{ resB.length }} registros</span>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header"><tr><th>Tipo</th><th>Año</th><th>Folio</th><th>Alta</th><th>Pago</th><th>Cancelado</th><th>Importe</th><th>Remesa</th></tr></thead>
            <tbody>
                <tr v-for="r in paginatedResB" :key="`${r.axo}-${r.folio}`"><td>{{ r.tipoact }}</td><td>{{ r.axo }}</td><td>{{ r.folio }}</td><td>{{ formatDate(r.fechaalta) }}</td><td>{{ formatDate(r.fechapago) }}</td><td>{{ formatDate(r.fechacancelado) }}</td><td>{{ r.importe }}</td><td>{{ r.remesa }}</td></tr>
                <tr v-if="resB.length===0"><td colspan="8" class="text-center text-muted">Sin datos</td></tr>
            </tbody>
            </table>
          </div>
          <div v-if="resB.length > rowsPerPageB" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ ((currentPageB - 1) * rowsPerPageB) + 1 }} a {{ Math.min(currentPageB * rowsPerPageB, resB.length) }} de {{ resB.length }} registros
            </div>
            <div class="pagination-controls">
              <button
                class="btn-municipal-secondary btn-sm"
                @click="currentPageB--"
                :disabled="currentPageB === 1"
              >
                Anterior
              </button>
              <span class="pagination-pages">Página {{ currentPageB }} de {{ totalPagesB }}</span>
              <button
                class="btn-municipal-secondary btn-sm"
                @click="currentPageB++"
                :disabled="currentPageB === totalPagesB"
              >
                Siguiente
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ConsGralPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Consulta General — Placa'"
      @close="showDocModal = false"
    />

  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const placa = ref('')
const resA = ref([])
const resB = ref([])

// Paginación Tabla A
const currentPageA = ref(1)
const rowsPerPageA = ref(10)

// Paginación Tabla B
const currentPageB = ref(1)
const rowsPerPageB = ref(10)

// Computed para paginación Tabla A
const totalPagesA = computed(() => Math.ceil(resA.value.length / rowsPerPageA.value))
const paginatedResA = computed(() => {
  const start = (currentPageA.value - 1) * rowsPerPageA.value
  const end = start + rowsPerPageA.value
  return resA.value.slice(start, end)
})

// Computed para paginación Tabla B
const totalPagesB = computed(() => Math.ceil(resB.value.length / rowsPerPageB.value))
const paginatedResB = computed(() => {
  const start = (currentPageB.value - 1) * rowsPerPageB.value
  const end = start + rowsPerPageB.value
  return resB.value.slice(start, end)
})

function formatDate(d) {
  if (!d) return '—'
  return new Date(d).toLocaleDateString('es-MX')
}

function formatMonto(m) {
  if (!m && m !== 0) return '—'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(m)
}

async function consultar() {
  if (!placa.value.trim()) {
    showToast('warning', 'Ingrese una placa para consultar')
    return
  }

  showLoading('Consultando...', 'Buscando folios por placa')
  resA.value = []
  resB.value = []
  currentPageA.value = 1
  currentPageB.value = 1
  try {
    const p = [{ nombre: 'parplaca', valor: placa.value.toUpperCase(), tipo: 'string' }]

    // Ejecutar ambas consultas en paralelo
    const [respA, respB] = await Promise.all([
      execute('sp14_afolios', BASE_DB, p, '', null, SCHEMA),
      execute('sp14_bfolios', BASE_DB, p, '', null, SCHEMA)
    ])

    const dataA = respA?.result || respA?.data?.result || respA?.data || []
    const dataB = respB?.result || respB?.data?.result || respB?.data || []

    resA.value = Array.isArray(dataA) ? dataA : []
    resB.value = Array.isArray(dataB) ? dataB : []

    hideLoading()

    if (resA.value.length === 0 && resB.value.length === 0) {
      showToast('info', 'No se encontraron folios para esta placa')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  }
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

</script>

