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
      <div class="stats-grid" v-if="loadingEstadisticas">
        <div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`">
          <div class="stat-content"><div class="skeleton-icon"></div><div class="skeleton-number"></div><div class="skeleton-label"></div><div class="skeleton-percentage"></div></div>
        </div>
      </div>
      <div class="stats-grid" v-else-if="estadisticas.length > 0">
        <div class="stat-card" v-for="stat in estadisticas" :key="stat.categoria" :class="`stat-${stat.clase}`">
          <div class="stat-content"><div class="stat-icon"><font-awesome-icon :icon="getStatIcon(stat.categoria)" /></div><h3 class="stat-number">{{ getStatValue(stat) }}</h3><p class="stat-label">{{ stat.descripcion }}</p><small class="stat-percentage" v-if="stat.porcentaje > 0">{{ stat.porcentaje.toFixed(1) }}%</small></div>
        </div>
      </div>
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
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
const BASE_DB='estacionamiento_exclusivo', OP_QUERY='estadxfolio_stats', OP_STATS='apremiossvn_apremios_estadisticas'
const { loading, execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const showFilters=ref(true), filters=ref({folio:''}), data=ref(null), primeraBusqueda=ref(false), loadingEstadisticas=ref(true), estadisticas=ref([]), activeTab=ref('structured')
const cargarEstadisticas = async () => { loadingEstadisticas.value=true; try{ const result=await execute(OP_STATS, BASE_DB, []); estadisticas.value=Array.isArray(result?.rows)?result.rows:Array.isArray(result)?result:[] }catch(e){ estadisticas.value=[] }finally{ loadingEstadisticas.value=false } }
const reload = async () => { if(!filters.value.folio){ showToast('error','Debe ingresar un folio'); return }; showFilters.value=false; primeraBusqueda.value=true; const t0=performance.now(); try{ data.value=await execute(OP_QUERY, BASE_DB, [{name:'folio',type:'C',value:String(filters.value.folio||'')}]); const dur=performance.now()-t0, txt=dur<1000?`${Math.round(dur)}ms`:`${(dur/1000).toFixed(2)}s`, cnt=!data.value?0:Array.isArray(data.value)?data.value.length:1; showToast('success',`Consulta en ${txt} - ${cnt} registro(s)`) }catch(e){ data.value=null; handleApiError(e) } }
const limpiarFiltros = () => { filters.value={folio:''}; data.value=null; primeraBusqueda.value=false }
const toggleFilters = () => { showFilters.value=!showFilters.value }
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n)
const formatMoney = (v) => Number(v||0).toLocaleString('es-MX',{style:'currency',currency:'MXN'})
const formatLabel = (k) => k.replace(/_/g,' ').replace(/([A-Z])/g,' $1').replace(/^./,s=>s.toUpperCase()).trim()
const formatValue = (v) => v===null||v===undefined?'-':typeof v==='boolean'?(v?'Sí':'No'):typeof v==='object'?JSON.stringify(v):String(v)
const getColumns = (a) => !a||a.length===0?[]:Object.keys(a[0])
const getStatIcon = (c) => ({'TOTAL':'chart-bar','VIGENTES':'check-circle','VENCIDOS':'times-circle','CON_EJECUTOR':'user-check','SIN_EJECUTOR':'user-times','IMPORTE_TOTAL':'coins'}[c]||'info-circle')
const getStatValue = (s) => s.categoria==='IMPORTE_TOTAL'?formatMoney(s.total):formatNumber(s.total)
onMounted(()=>{ cargarEstadisticas() })
</script>
<style scoped>
.result-tabs{display:flex;gap:0.5rem;margin-bottom:1rem;border-bottom:2px solid #dee2e6}
.tab-button{padding:0.5rem 1rem;background:none;border:none;border-bottom:2px solid transparent;cursor:pointer;color:#6c757d;transition:all 0.2s}
.tab-button:hover{color:#495057;border-bottom-color:#dee2e6}
.tab-button.active{color:#7a5dc7;border-bottom-color:#7a5dc7;font-weight:600}
.structured-view{padding:1rem 0}
.json-view{padding:1rem;background:#f8f9fa;border-radius:0.25rem}
</style>
