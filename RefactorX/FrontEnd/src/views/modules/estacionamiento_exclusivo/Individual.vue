<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file" /></div>
      <div class="module-view-info"><h1>Requerimiento Individual</h1><p>Consulta individual de requerimientos</p></div>
      <div class="button-group ms-auto"><button class="btn-municipal-primary" @click="consultar" v-if="filters.expediente"><font-awesome-icon icon="sync-alt" /> Actualizar</button></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-header clickable-header" @click="toggleFilters"><h5><font-awesome-icon icon="filter" /> Criterios <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" /></h5></div><div v-show="showFilters" class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="filters.expediente" @keyup.enter="consultar" placeholder="Ingrese el expediente"/></div></div><div class="button-group"><button class="btn-municipal-primary" @click="consultar" :disabled="!filters.expediente"><font-awesome-icon icon="search" /> Consultar</button><button class="btn-municipal-secondary" @click="limpiarFiltros"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
      <div class="municipal-card"><div class="municipal-card-header"><div class="header-with-badge"><h5><font-awesome-icon icon="file-alt" /> Detalle</h5><span class="badge-purple" v-if="data">{{ Array.isArray(data) ? data.length : 1 }} registro(s)</span></div><div v-if="loading" class="spinner-border"></div></div><div class="municipal-card-body" v-if="!loading"><div v-if="!data && !primeraBusqueda" class="empty-state"><font-awesome-icon icon="search" size="3x" class="empty-icon" /><p>Ingrese un expediente</p></div><div v-else-if="!data" class="empty-state"><font-awesome-icon icon="inbox" size="3x" class="empty-icon" /><p>Sin información</p></div><div v-else><div class="result-tabs"><button class="tab-button" :class="{ active: activeTab === 'structured' }" @click="activeTab = 'structured'"><font-awesome-icon icon="table" /> Estructurada</button><button class="tab-button" :class="{ active: activeTab === 'json' }" @click="activeTab = 'json'"><font-awesome-icon icon="code" /> JSON</button></div><div v-show="activeTab === 'structured'" class="structured-view"><div v-if="!Array.isArray(data)"><div class="form-row" v-for="(value, key) in data" :key="key"><div class="form-group"><label class="municipal-form-label">{{ formatLabel(key) }}</label><p>{{ formatValue(value) }}</p></div></div></div><div v-else><div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="col in getColumns(data)" :key="col">{{ formatLabel(col) }}</th></tr></thead><tbody><tr v-for="(row, idx) in data" :key="idx"><td v-for="col in getColumns(data)" :key="col">{{ formatValue(row[col]) }}</td></tr></tbody></table></div></div></div><div v-show="activeTab === 'json'" class="json-view"><pre class="pre-wrap">{{ JSON.stringify(data, null, 2) }}</pre></div></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - Individual"
    >
      <h3>Individual</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Individual'"
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
const OP_QUERY = 'sp_individual_folio_search'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const showFilters=ref(true), filters=ref({expediente:''}), data=ref(null), primeraBusqueda=ref(false), activeTab=ref('structured')

const consultar = async () => {
  if (!filters.value.expediente) {
    showToast('error', 'Debe ingresar expediente')
    return
  }
  showLoading('Consultando expediente...', 'Buscando información')
  showFilters.value = false
  primeraBusqueda.value = true
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
    showToast('success', `Consulta en ${txt} - ${cnt} registro(s)`)
  } catch (e) {
    data.value = null
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const limpiarFiltros = () => { filters.value={expediente:''}; data.value=null; primeraBusqueda.value=false }
const toggleFilters = () => { showFilters.value=!showFilters.value }
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n); const formatMoney = (v) => Number(v||0).toLocaleString('es-MX',{style:'currency',currency:'MXN'})
const formatLabel = (k) => k.replace(/_/g,' ').replace(/([A-Z])/g,' $1').replace(/^./,s=>s.toUpperCase()).trim()
const formatValue = (v) => v===null||v===undefined?'-':typeof v==='boolean'?(v?'Sí':'No'):typeof v==='object'?JSON.stringify(v):String(v)
const getColumns = (a) => !a||a.length===0?[]:Object.keys(a[0])

// Documentacion y Ayuda
const showDocumentation = ref(false)
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const closeTechDocs = () => showTechDocs.value = false

</script>
