<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="square-parking" /></div><div class="module-view-info"><h1>Reporte por Registro Estacionómetro</h1><p>Listado de apremios por estacionómetro</p></div><div class="button-group ms-auto"><button class="btn-municipal-secondary" @click="showFilters = !showFilters"><font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" /> {{ showFilters ? 'Ocultar' : 'Mostrar' }} Filtros</button></div></div>
    <div class="module-view-content">
      <div v-if="showFilters" class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Filtros</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Vigencia</label><input class="municipal-form-control" type="text" v-model="p_vigencia" placeholder="Vigencia"/></div><div class="form-group"><label class="municipal-form-label">Clave Practicado</label><input class="municipal-form-control" type="text" v-model="p_clave_practicado" placeholder="Clave Practicado"/></div><div class="form-group"><label class="municipal-form-label">Colonia</label><input class="municipal-form-control" type="text" v-model="p_colonia" placeholder="Colonia"/></div><div class="form-group"><label class="municipal-form-label">Oficina</label><input class="municipal-form-control" type="number" v-model="p_oficina" placeholder="Oficina"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="buscar"><font-awesome-icon icon="search" /> Buscar</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
      <div class="municipal-card"><div class="municipal-card-header"><div class="header-with-badge"><h5><font-awesome-icon icon="list" /> Listado Estacionómetro</h5><span class="badge-purple" v-if="totalResultados > 0">{{ formatNumber(totalResultados) }} registros totales</span></div><div v-if="loading" class="spinner-border"></div></div><div class="municipal-card-body table-container" v-if="!loading"><div v-if="!searched" class="empty-state"><font-awesome-icon icon="search" size="3x" class="empty-icon" /><p>Use los filtros para buscar registros</p></div><div v-else-if="rows.length === 0" class="empty-state"><font-awesome-icon icon="inbox" size="3x" class="empty-icon" /><p>No se encontraron resultados</p></div><div v-else class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th v-for="c in cols" :key="c">{{ formatLabel(c) }}</th></tr></thead><tbody><tr v-for="(r,i) in paginatedRows" :key="i" class="clickable-row"><td v-for="c in cols" :key="c">{{ formatValue(r[c]) }}</td></tr></tbody></table></div><div v-if="rows.length > 0" class="pagination-controls"><div class="pagination-info"><span class="text-muted">Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} a {{ Math.min(currentPage * itemsPerPage, totalResultados) }} de {{ totalResultados }} registros</span></div><div class="pagination-size"><label class="municipal-form-label me-2">Por página:</label><select class="municipal-form-control form-control-sm" v-model="itemsPerPage" @change="currentPage=1"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option></select></div><div class="pagination-buttons"><button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"><font-awesome-icon icon="angle-double-left" /></button><button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)" :disabled="currentPage === 1"><font-awesome-icon icon="angle-left" /></button><button v-for="page in visiblePages" :key="page" class="btn-sm" :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'" @click="goToPage(page)">{{ page }}</button><button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages"><font-awesome-icon icon="angle-right" /></button><button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)" :disabled="currentPage === totalPages"><font-awesome-icon icon="angle-double-right" /></button></div></div></div></div>
    </div>
    
    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      @close="closeDocumentation"
      title="Ayuda - RprtListaxRegEstacionometro"
    >
      <h3>Rprt Listax Reg Estacionometro</h3>
      <p>Documentacion del modulo Estacionamiento Exclusivo.</p>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'RprtListaxRegEstacionometro'"
      :moduleName="'estacionamiento_exclusivo'"
      @close="closeTechDocs"
    />

  </div>
</template>
<script setup>
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_exclusivo'
const OP_QUERY = 'rpt_listaxreg_estacionometro'

const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

const rows = ref([])
const cols = ref([])
const currentPage = ref(1)
const itemsPerPage = ref(25)
const showFilters = ref(true)
const searched = ref(false)
const p_vigencia = ref('')
const p_clave_practicado = ref('')
const p_colonia = ref('')
const p_oficina = ref('')

const totalResultados = computed(() => rows.value.length)
const totalPages = computed(() => Math.ceil(totalResultados.value / itemsPerPage.value))
const paginatedRows = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  return rows.value.slice(start, start + itemsPerPage.value)
})
const visiblePages = computed(() => {
  const pages = []
  const start = Math.max(1, currentPage.value - 2)
  const end = Math.min(totalPages.value, currentPage.value + 2)
  for (let i = start; i <= end; i++) pages.push(i)
  return pages
})
const goToPage = (p) => { if (p >= 1 && p <= totalPages.value) currentPage.value = p }

const buscar = async () => {
  showLoading('Generando reporte...', 'Listado por estacionómetro')
  currentPage.value = 1
  searched.value = true
  const t0 = performance.now()
  try {
    const response = await execute(OP_QUERY, BASE_DB, [
      { name: 'p_vigencia', type: 'S', value: String(p_vigencia.value || '') },
      { name: 'p_clave_practicado', type: 'S', value: String(p_clave_practicado.value || '') },
      { name: 'p_colonia', type: 'S', value: String(p_colonia.value || '') },
      { name: 'p_oficina', type: 'I', value: String(p_oficina.value || '') }
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
const limpiar = () => { p_vigencia.value=''; p_clave_practicado.value=''; p_colonia.value=''; p_oficina.value=''; rows.value=[]; cols.value=[]; searched.value=false; currentPage.value=1 }
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n)
const formatLabel = (k) => k.replace(/_/g,' ').replace(/([A-Z])/g,' $1').replace(/^./,s=>s.toUpperCase()).trim()
const formatValue = (v) => v===null||v===undefined?'-':typeof v==='boolean'?(v?'Sí':'No'):String(v)

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
