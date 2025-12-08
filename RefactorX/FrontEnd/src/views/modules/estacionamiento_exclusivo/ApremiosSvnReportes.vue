<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="chart-pie" /></div><div class="module-view-info"><h1>Reportes y Estadísticas SVN</h1><p>Consulta de estadísticas generales</p></div><div class="button-group ms-auto"><button class="btn-municipal-primary" @click="toggleFilters"><font-awesome-icon :icon="showFilters?'chevron-up':'chevron-down'" /> Filtros</button></div></div>
    <div class="module-view-content">
      <div class="stats-grid" v-if="loadingEstadisticas"><div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`"><div class="stat-content"><div class="skeleton-icon"></div><div class="skeleton-number"></div><div class="skeleton-label"></div><div class="skeleton-percentage"></div></div></div></div>
      <div class="stats-grid" v-else-if="estadisticas.length > 0"><div class="stat-card" v-for="stat in estadisticas" :key="stat.categoria" :class="`stat-${stat.clase}`"><div class="stat-content"><div class="stat-icon"><font-awesome-icon :icon="getStatIcon(stat.categoria)" /></div><h3 class="stat-number">{{ getStatValue(stat) }}</h3><p class="stat-label">{{ stat.descripcion }}</p><small class="stat-percentage" v-if="Number(stat.porcentaje) > 0">{{ Number(stat.porcentaje).toFixed(1) }}%</small></div></div></div>
      <div class="municipal-card" v-if="showFilters"><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Desde</label><input class="municipal-form-control" type="date" v-model="filters.desde"/></div><div class="form-group"><label class="municipal-form-label">Hasta</label><input class="municipal-form-control" type="date" v-model="filters.hasta"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="consultar"><font-awesome-icon icon="chart-line" /> Consultar</button></div></div></div>
      <div class="municipal-card"><div class="municipal-card-header"><div class="header-with-badge"><h5><font-awesome-icon icon="list" /> Resumen Estadístico</h5><span class="badge-purple" v-if="totalResultados > 0">{{ formatNumber(totalResultados) }} registros totales</span></div><div v-if="loading" class="spinner-border"></div></div><div class="municipal-card-body table-container" v-if="!loading"><div v-if="rows.length === 0" class="empty-state"><font-awesome-icon icon="inbox" size="3x" class="empty-icon" /><p>{{ searched?'Sin resultados':'Use los filtros para consultar' }}</p></div><div v-else class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="c in cols" :key="c">{{ formatLabel(c) }}</th></tr></thead><tbody><tr v-for="(r,i) in paginatedRows" :key="i" class="clickable-row"><td v-for="c in cols" :key="c">{{ formatValue(r[c]) }}</td></tr></tbody></table></div><div v-if="rows.length > 0" class="pagination-controls"><div class="pagination-info"><span class="text-muted">Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, totalResultados) }} de {{ totalResultados }} registros</span></div><div class="pagination-size"><label class="municipal-form-label me-2">Por página:</label><select class="municipal-form-control form-control-sm" v-model="itemsPerPage" @change="currentPage=1"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option></select></div><div class="pagination-buttons"><button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"><font-awesome-icon icon="angle-double-left" /></button><button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1"><font-awesome-icon icon="angle-left" /></button><button v-for="page in visiblePages" :key="page" class="btn-sm" :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'" @click="goToPage(page)">{{ page }}</button><button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages"><font-awesome-icon icon="angle-right" /></button><button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages"><font-awesome-icon icon="angle-double-right" /></button></div></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - ApremiosSvnReportes"
    >
      <h3>Apremios Svn Reportes</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'ApremiosSvnReportes'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_STATS_GENERAL = 'sp_estadisticas_generales'
const OP_STATS = 'apremiossvn_apremios_estadisticas'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const filters=ref({desde:'',hasta:''}), rows=ref([]), cols=ref([]), showFilters=ref(true), searched=ref(false), loadingEstadisticas=ref(true), estadisticas=ref([]), currentPage=ref(1), itemsPerPage=ref(25)
const totalResultados = computed(()=>rows.value.length)
const totalPages = computed(()=>Math.ceil(totalResultados.value/itemsPerPage.value))
const paginatedRows = computed(()=>{ const start=(currentPage.value-1)*itemsPerPage.value; return rows.value.slice(start, start+itemsPerPage.value) })
const visiblePages = computed(()=>{ const pages=[]; const start=Math.max(1,currentPage.value-2); const end=Math.min(totalPages.value,currentPage.value+2); for(let i=start; i<=end; i++) pages.push(i); return pages })
const goToPage = (p) => { if (p >= 1 && p <= totalPages.value) currentPage.value = p }
const toggleFilters = () => { showFilters.value = !showFilters.value }

const cargarEstadisticas = async () => {
  loadingEstadisticas.value = true
  try {
    const response = await execute(OP_STATS, BASE_DB, [])
    if (response && response.data) {
      estadisticas.value = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      estadisticas.value = Array.isArray(response.result) ? response.result : []
    } else {
      estadisticas.value = []
    }
  } catch (e) {
    estadisticas.value = []
  } finally {
    loadingEstadisticas.value = false
  }
}

const consultar = async () => {
  showLoading('Consultando estadísticas...', 'Generando reporte')
  currentPage.value = 1
  searched.value = true
  const t0 = performance.now()
  try {
    const response = await execute(OP_STATS_GENERAL, BASE_DB, [
      { name: 'desde', type: 'D', value: String(filters.value.desde || '') },
      { name: 'hasta', type: 'D', value: String(filters.value.hasta || '') }
    ])
    let arr = []
    if (response && response.data) {
      arr = Array.isArray(response.data) ? response.data : []
    } else if (response && response.result) {
      arr = Array.isArray(response.result) ? response.result : []
    }
    rows.value = arr
    cols.value = arr.length ? Object.keys(arr[0]) : []
    const dur = performance.now() - t0
    const txt = dur < 1000 ? `${Math.round(dur)}ms` : `${(dur / 1000).toFixed(2)}s`
    showToast('success', `${rows.value.length} registro(s) en ${txt}`)
  } catch (e) {
    rows.value = []
    cols.value = []
    handleApiError(e)
  } finally {
    hideLoading()
  }
}
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n); const formatMoney = (v) => Number(v||0).toLocaleString('es-MX',{style:'currency',currency:'MXN'})
const formatLabel = (k) => k.replace(/_/g,' ').replace(/([A-Z])/g,' $1').replace(/^./,s=>s.toUpperCase()).trim()
const formatValue = (v) => v===null||v===undefined?'-':typeof v==='boolean'?(v?'Sí':'No'):String(v)
const getStatIcon = (c) => ({'TOTAL':'chart-bar','VIGENTES':'check-circle','VENCIDOS':'times-circle','CON_EJECUTOR':'user-check','SIN_EJECUTOR':'user-times','IMPORTE_TOTAL':'coins'}[c]||'info-circle')
const getStatValue = (s) => s.categoria==='IMPORTE_TOTAL'?formatMoney(s.total):formatNumber(s.total)
onMounted(()=>{ cargarEstadisticas(); consultar() })

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>

