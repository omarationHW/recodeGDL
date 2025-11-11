<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice-dollar" /></div><div class="module-view-info"><h1>Facturación</h1><p>Emisión de facturas por expediente</p></div></div>
    <div class="module-view-content">
      <div class="stats-grid" v-if="loadingEstadisticas"><div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`"><div class="stat-content"><div class="skeleton-icon"></div><div class="skeleton-number"></div><div class="skeleton-label"></div><div class="skeleton-percentage"></div></div></div></div>
      <div class="stats-grid" v-else-if="estadisticas.length > 0"><div class="stat-card" v-for="stat in estadisticas" :key="stat.categoria" :class="`stat-${stat.clase}`"><div class="stat-content"><div class="stat-icon"><font-awesome-icon :icon="getStatIcon(stat.categoria)" /></div><h3 class="stat-number">{{ getStatValue(stat) }}</h3><p class="stat-label">{{ stat.descripcion }}</p><small class="stat-percentage" v-if="stat.porcentaje > 0">{{ stat.porcentaje.toFixed(1) }}%</small></div></div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Facturación</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="form.expediente" placeholder="Número de expediente"/></div><div class="form-group"><label class="municipal-form-label">RFC</label><input class="municipal-form-control" v-model="form.rfc" placeholder="RFC del contribuyente"/></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !form.expediente || !form.rfc" @click="emitir"><font-awesome-icon icon="file-invoice" /> Emitir Factura</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'; import { useApi } from '@/composables/useApi'; import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
const BASE_DB='estacionamiento_exclusivo', OP_LIST='sp_facturacion_list', OP_STATS='apremiossvn_apremios_estadisticas'
const { loading, execute } = useApi(); const { showToast, handleApiError } = useLicenciasErrorHandler()
const form=ref({expediente:'',rfc:''}), loadingEstadisticas=ref(true), estadisticas=ref([])
const cargarEstadisticas = async () => { loadingEstadisticas.value=true; try{ const result=await execute(OP_STATS, BASE_DB, []); estadisticas.value=Array.isArray(result?.rows)?result.rows:Array.isArray(result)?result:[] }catch(e){ estadisticas.value=[] }finally{ loadingEstadisticas.value=false } }
const emitir = async () => { if(!form.value.expediente || !form.value.rfc){ showToast('error','Debe completar todos los campos'); return }; const t0=performance.now(); try{ await execute(OP_LIST, BASE_DB, [{name:'expediente',type:'C',value:String(form.value.expediente||'')},{name:'rfc',type:'C',value:String(form.value.rfc||'')}]); const dur=performance.now()-t0, txt=dur<1000?`${Math.round(dur)}ms`:`${(dur/1000).toFixed(2)}s`; showToast('success',`Factura emitida en ${txt}`); limpiar() }catch(e){ handleApiError(e) } }
const limpiar = () => { form.value={expediente:'',rfc:''} }
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n); const formatMoney = (v) => Number(v||0).toLocaleString('es-MX',{style:'currency',currency:'MXN'})
const getStatIcon = (c) => ({'TOTAL':'chart-bar','VIGENTES':'check-circle','VENCIDOS':'times-circle','CON_EJECUTOR':'user-check','SIN_EJECUTOR':'user-times','IMPORTE_TOTAL':'coins'}[c]||'info-circle')
const getStatValue = (s) => s.categoria==='IMPORTE_TOTAL'?formatMoney(s.total):formatNumber(s.total)
onMounted(()=>{ cargarEstadisticas() })
</script>
