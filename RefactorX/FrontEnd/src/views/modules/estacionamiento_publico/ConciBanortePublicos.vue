<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="building-columns" /></div>
      <div class="module-view-info">
        <h1>Conciliación Banorte — Estacionamientos</h1>
        <p>Consulta por año y folio</p>
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
        <button class="btn-municipal-secondary" :disabled="loading" @click="consultar"><font-awesome-icon icon="play" /> Consultar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="filtros.axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" type="number" v-model.number="filtros.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio (hasta)</label><input class="municipal-form-control" type="number" v-model.number="filtros.folio_to" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Modo</label>
              <select class="municipal-form-control" v-model="modo">
                <option value="single">Por folio</option>
                <option value="range">Por rango de folios</option>
              </select>
            </div>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Resultados</h5>
          <div v-if="loading" class="spinner-border" role="status"></div>
        </div>
        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive" v-if="paginatedRows.length">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th v-for="col in visibleColumns" :key="col">{{ col }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in paginatedRows" :key="idx">
                  <td v-for="col in visibleColumns" :key="col">{{ formatCell(r[col]) }}</td>
                </tr>
              </tbody>
            </table>

            <!-- Paginación -->
            <div class="pagination-container" v-if="totalPages > 1">
              <button
                class="btn-municipal-secondary"
                @click="previousPage"
                :disabled="currentPage === 1"
              >
                <font-awesome-icon icon="chevron-left" /> Anterior
              </button>
              <span class="pagination-info">
                Página {{ currentPage }} de {{ totalPages }} ({{ rows.length }} registros)
              </span>
              <button
                class="btn-municipal-secondary"
                @click="nextPage"
                :disabled="currentPage === totalPages"
              >
                Siguiente <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
          <!-- Estado vacío -->
          <div v-else class="empty-state">
            <div class="empty-state-icon">
              <font-awesome-icon icon="building-columns" />
            </div>
            <h4 class="empty-state-title">Sin registros de conciliación</h4>
            <p class="empty-state-description">
              Ingrese el año y folio para consultar los registros de conciliación Banorte.
            </p>
            <div class="empty-state-hint">
              <font-awesome-icon icon="lightbulb" class="hint-icon" />
              <span>Ejemplo: Año <strong>2025</strong>, Folio <strong>12345</strong></span>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ConciBanortePublicos"
    >
      <h3>Conci Banorte Publicos</h3>
      <p>Documentacion del modulo Estacionamiento Publico.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ConciBanortePublicos'"
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
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const filtros = reactive({ axo: new Date().getFullYear(), folio: null, folio_to: null })
const modo = ref('single')
const rows = ref([])

// Paginación
const currentPage = ref(1)
const itemsPerPage = ref(50)

async function consultar() {
  if (!filtros.axo || !filtros.folio) {
    showToast('warning', 'Ingrese año y folio para consultar')
    return
  }

  showLoading('Consultando...', 'Buscando conciliación Banorte')
  rows.value = []
  currentPage.value = 1
  try {
    if (modo.value === 'single' || !filtros.folio_to) {
      const params = [
        { nombre: 'p_axo', valor: filtros.axo, tipo: 'integer' },
        { nombre: 'p_folio', valor: filtros.folio, tipo: 'integer' }
      ]
      const resp = await execute('sp_conciliados_by_folio', BASE_DB, params, '', null, SCHEMA)
      const data = resp?.result || resp?.data?.result || resp?.data || []
      rows.value = Array.isArray(data) ? data : []
    } else {
      const start = Number(filtros.folio) || 0
      const end = Number(filtros.folio_to) || start

      if (end - start > 100) {
        showToast('warning', 'El rango máximo es de 100 folios')
        hideLoading()
        return
      }

      const acc = []
      for (let f = start; f <= end; f++) {
        const params = [
          { nombre: 'p_axo', valor: filtros.axo, tipo: 'integer' },
          { nombre: 'p_folio', valor: f, tipo: 'integer' }
        ]
        const resp = await execute('sp_conciliados_by_folio', BASE_DB, params, '', null, SCHEMA)
        const part = resp?.result || resp?.data?.result || resp?.data || []
        if (Array.isArray(part)) {
          for (const r of part) acc.push(r)
        }
      }
      rows.value = acc
    }

    hideLoading()

    if (rows.value.length === 0) {
      showToast('info', 'No se encontraron registros de conciliación')
    }
  } catch (e) {
    hideLoading()
    handleApiError(e)
  }
}

const visibleColumns = computed(() => {
  if (!rows.value.length) return []
  return Object.keys(rows.value[0] || {})
})

const totalPages = computed(() => {
  return Math.ceil(rows.value.length / itemsPerPage.value)
})

const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return rows.value.slice(start, end)
})

function nextPage() {
  if (currentPage.value < totalPages.value) {
    currentPage.value++
  }
}

function previousPage() {
  if (currentPage.value > 1) {
    currentPage.value--
  }
}

function formatCell(v) {
  if (v === null || typeof v === 'undefined') return '—'
  if (typeof v === 'number') return v.toLocaleString('es-MX')
  const d = new Date(v)
  if (!isNaN(d.getTime()) && String(v).includes('-')) return d.toLocaleDateString('es-MX')
  return String(v)
}

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
