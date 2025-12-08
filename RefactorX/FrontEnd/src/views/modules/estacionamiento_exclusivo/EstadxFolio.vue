<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="list-ol" /></div>
      <div class="module-view-info">
        <h1>Estatus por Folio</h1>
        <p>Consulta de estatus de apremios por folio</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="reload" v-if="filters.folio">
          <font-awesome-icon icon="sync-alt" /> Actualizar
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header clickable-header" @click="toggleFilters"><h5><font-awesome-icon icon="filter" /> Criterios de Búsqueda <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" /></h5></div>
        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row"><div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" v-model="filters.folio" @keyup.enter="reload" placeholder="Ingrese el folio a consultar"/></div></div>
          <div class="button-group"><button class="btn-municipal-primary" @click="reload" :disabled="!filters.folio"><font-awesome-icon icon="search" /> Buscar</button><button class="btn-municipal-secondary" @click="limpiarFiltros"><font-awesome-icon icon="eraser" /> Limpiar</button></div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header"><div class="header-with-badge"><h5><font-awesome-icon icon="file-alt" /> Resultado</h5><span class="badge-purple" v-if="data">{{ Array.isArray(data) ? data.length : 1 }} registro(s)</span></div><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body" v-if="!loading">
          <div v-if="!data && !primeraBusqueda" class="empty-state"><font-awesome-icon icon="search" size="3x" class="empty-icon" /><p>Ingrese un folio para consultar</p></div>
          <div v-else-if="!data" class="empty-state"><font-awesome-icon icon="inbox" size="3x" class="empty-icon" /><p>No se encontró información</p></div>
          <div v-else>
            <div class="result-tabs"><button class="tab-button" :class="{ active: activeTab === 'structured' }" @click="activeTab = 'structured'"><font-awesome-icon icon="table" /> Estructurada</button><button class="tab-button" :class="{ active: activeTab === 'json' }" @click="activeTab = 'json'"><font-awesome-icon icon="code" /> JSON</button></div>
            <div v-show="activeTab === 'structured'" class="structured-view"><div v-if="!Array.isArray(data)"><div class="form-row" v-for="(value, key) in data" :key="key"><div class="form-group"><label class="municipal-form-label">{{ formatLabel(key) }}</label><p>{{ formatValue(value) }}</p></div></div></div><div v-else><div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="col in getColumns(data)" :key="col">{{ formatLabel(col) }}</th></tr></thead><tbody><tr v-for="(row, idx) in data" :key="idx"><td v-for="col in getColumns(data)" :key="col">{{ formatValue(row[col]) }}</td></tr></tbody></table></div></div></div>
            <div v-show="activeTab === 'json'" class="json-view"><pre class="pre-wrap">{{ JSON.stringify(data, null, 2) }}</pre></div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - EstadxFolio"
    >
      <h3>Estadx Folio</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'EstadxFolio'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'estadxfolio_stats'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const showFilters = ref(true)
const filters = ref({ folio: '' })
const data = ref(null)
const primeraBusqueda = ref(false)
const activeTab = ref('structured')

const reload = async () => {
  if (!filters.value.folio) {
    showToast('error', 'Debe ingresar un folio')
    return
  }
  showLoading('Consultando estatus...', 'Buscando folio')
  showFilters.value = false
  primeraBusqueda.value = true
  const t0 = performance.now()
  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_modulo', type: 'I', value: 28 },
      { name: 'p_rec', type: 'I', value: 1 },
      { name: 'p_fol1', type: 'I', value: parseInt(filters.value.folio || 0) },
      { name: 'p_fol2', type: 'I', value: parseInt(filters.value.folio || 0) }
    ])
    if (response && response.data) {
      data.value = Array.isArray(response.data) ? response.data : response.data
    } else if (response && response.result) {
      data.value = Array.isArray(response.result) ? response.result : response.result
    } else {
      data.value = null
    }
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    const cnt = !data.value ? 0 : Array.isArray(data.value) ? data.value.length : 1
    showToast('success', `Consulta en ${txt} - ${cnt} registro(s)`)
  } catch (e) {
    data.value = null
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiarFiltros = () => { filters.value={folio:''}; data.value=null; primeraBusqueda.value=false }
const toggleFilters = () => { showFilters.value=!showFilters.value }
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n)
const formatLabel = (k) => k.replace(/_/g,' ').replace(/([A-Z])/g,' $1').replace(/^./,s=>s.toUpperCase()).trim()
const formatValue = (v) => v===null||v===undefined?'-':typeof v==='boolean'?(v?'Sí':'No'):typeof v==='object'?JSON.stringify(v):String(v)
const getColumns = (a) => !a||a.length===0?[]:Object.keys(a[0])

// Documentacion y Ayuda
const showDocumentation = ref(false)
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const closeTechDocs = () => showTechDocs.value = false

</script>
