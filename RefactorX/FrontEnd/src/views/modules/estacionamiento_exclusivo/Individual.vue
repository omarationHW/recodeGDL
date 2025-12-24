<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file" />
      </div>
      <div class="module-view-info">
        <h1>Requerimiento Individual</h1>
        <p>Consulta individual de requerimientos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="consultar" v-if="filters.expediente">
          <font-awesome-icon icon="sync-alt" />
          Actualizar
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-header clickable-header" @click="toggleFilters">
        <h5>
          <font-awesome-icon icon="filter" />
          Criterios
          <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
        </h5>
      </div>
      <div v-show="showFilters" class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Expediente</label>
            <input
              class="municipal-form-control"
              v-model="filters.expediente"
              @keyup.enter="consultar"
              placeholder="Ingrese el expediente"
            />
          </div>
        </div>
        <div class="button-group">
          <button class="btn-municipal-primary" @click="consultar" :disabled="!filters.expediente">
            <font-awesome-icon icon="search" />
            Consultar
          </button>
          <button class="btn-municipal-secondary" @click="limpiarFiltros">
            <font-awesome-icon icon="eraser" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header header-with-badge">
        <h5>
          <font-awesome-icon icon="file-alt" />
          Detalle
        </h5>
        <div class="header-right">
          <span class="badge-purple" v-if="data">
            {{ Array.isArray(data) ? data.length : 1 }} registro(s)
          </span>
        </div>
      </div>
      <div class="municipal-card-body">
        <!-- Empty State - Sin búsqueda -->
        <div v-if="!data && !hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="search" size="3x" />
          </div>
          <h4>Requerimiento Individual</h4>
          <p>Ingrese un expediente para consultar la información</p>
        </div>

        <!-- Empty State - Sin resultados -->
        <div v-else-if="!data && hasSearched" class="empty-state">
          <div class="empty-state-icon">
            <font-awesome-icon icon="inbox" size="3x" />
          </div>
          <h4>Sin resultados</h4>
          <p>No se encontró información para el expediente especificado</p>
        </div>

        <!-- Datos encontrados -->
        <div v-else>
          <!-- Tabs -->
          <div class="municipal-tabs">
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'structured' }"
              @click="activeTab = 'structured'"
            >
              <font-awesome-icon icon="table" />
              Estructurada
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'json' }"
              @click="activeTab = 'json'"
            >
              <font-awesome-icon icon="code" />
              JSON
            </button>
          </div>

          <!-- Vista estructurada -->
          <div v-show="activeTab === 'structured'" class="structured-view">
            <div v-if="!Array.isArray(data)">
              <div class="form-row" v-for="(value, key) in data" :key="key">
                <div class="form-group">
                  <label class="municipal-form-label">{{ formatLabel(key) }}</label>
                  <p>{{ formatValue(value) }}</p>
                </div>
              </div>
            </div>
            <div v-else>
              <div class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th v-for="col in getColumns(data)" :key="col">{{ formatLabel(col) }}</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="(row, idx) in data"
                      :key="idx"
                      @click="selectedRow = row"
                      :class="{ 'table-row-selected': selectedRow === row }"
                      class="row-hover"
                    >
                      <td v-for="col in getColumns(data)" :key="col">{{ formatValue(row[col]) }}</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          <!-- Vista JSON -->
          <div v-show="activeTab === 'json'" class="json-view">
            <pre class="pre-wrap">{{ JSON.stringify(data, null, 2) }}</pre>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'Individual'"
      :moduleName="'estacionamiento_exclusivo'"
      :docType="docType"
      :title="'Requerimiento Individual'"
      @close="showDocModal = false"
    />
    </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>
<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

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

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'sp_individual_folio_search'

const { execute } = useApi()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const showFilters = ref(true)
const filters = ref({ expediente: '' })
const data = ref(null)
const hasSearched = ref(false)
const activeTab = ref('structured')
const selectedRow = ref(null)

const consultar = async () => {
  if (!filters.value.expediente) {
    showToast('error', 'Debe ingresar expediente')
    return
  }

  showLoading('Consultando expediente...', 'Buscando información')
  hasSearched.value = true
  selectedRow.value = null
  showFilters.value = false
  const t0 = performance.now()

  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_modulo', type: 'I', value: 28 },
      { name: 'p_folio', type: 'I', value: parseInt(filters.value.expediente || 0) },
      { name: 'p_recaudadora', type: 'I', value: 1 }
    ])

    let result = null
    if (response && response.data) {
      result = Array.isArray(response.data) ? response.data[0] : response.data
    } else if (response && response.result) {
      result = Array.isArray(response.result) ? response.result[0] : response.result
    }

    data.value = result

    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    const cnt = !data.value ? 0 : 1

    toast.value.duration = txt
    showToast('success', `Consulta exitosa - ${cnt} registro(s)`)
  } catch (e) {
    data.value = null
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

const limpiarFiltros = () => {
  filters.value = { expediente: '' }
  data.value = null
  hasSearched.value = false
  selectedRow.value = null
  activeTab.value = 'structured'
}

const toggleFilters = () => {
  showFilters.value = !showFilters.value
}

// Utilidades
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n)

const formatMoney = (v) => Number(v || 0).toLocaleString('es-MX', {
  style: 'currency',
  currency: 'MXN'
})

const formatLabel = (k) =>
  k.replace(/_/g, ' ')
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, s => s.toUpperCase())
    .trim()

const formatValue = (v) =>
  v === null || v === undefined
    ? '-'
    : typeof v === 'boolean'
    ? (v ? 'Sí' : 'No')
    : typeof v === 'object'
    ? JSON.stringify(v)
    : String(v)

const getColumns = (a) => !a || a.length === 0 ? [] : Object.keys(a[0])
</script>
