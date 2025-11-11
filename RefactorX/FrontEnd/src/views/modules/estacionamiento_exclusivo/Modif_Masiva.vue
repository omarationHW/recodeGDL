<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="sliders" /></div><div class="module-view-info"><h1>Modificación Masiva</h1><p>Modificación masiva de registros</p></div></div>
    <div class="module-view-content">
      <div class="stats-grid" v-if="loadingEstadisticas"><div class="stat-card stat-card-loading" v-for="n in 6" :key="`loading-${n}`"><div class="stat-content"><div class="skeleton-icon"></div><div class="skeleton-number"></div><div class="skeleton-label"></div><div class="skeleton-percentage"></div></div></div></div>
      <div class="stats-grid" v-else-if="estadisticas.length > 0"><div class="stat-card" v-for="stat in estadisticas" :key="stat.categoria" :class="`stat-${stat.clase}`"><div class="stat-content"><div class="stat-icon"><font-awesome-icon :icon="getStatIcon(stat.categoria)" /></div><h3 class="stat-number">{{ getStatValue(stat) }}</h3><p class="stat-label">{{ stat.descripcion }}</p><small class="stat-percentage" v-if="stat.porcentaje > 0">{{ stat.porcentaje.toFixed(1) }}%</small></div></div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5><font-awesome-icon icon="edit" /> Formulario de Modificación</h5></div><div class="municipal-card-body"><div class="form-row"><div class="form-group full-width"><label class="municipal-form-label">Datos (JSON)</label><textarea class="municipal-form-control" rows="10" v-model="jsonPayload" placeholder='[{"expediente":"123","campo":"valor"}, ...]'></textarea></div></div><div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="aplicar"><font-awesome-icon icon="save" /> Aplicar Cambios</button><button class="btn-municipal-secondary" @click="limpiar"><font-awesome-icon icon="eraser" /> Limpiar</button></div></div></div>
    </div>
  </div>
</template>
<script setup>
import { ref, onMounted } from 'vue'; import { useApi } from '@/composables/useApi'; import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
const BASE_DB='estacionamiento_exclusivo', OP_APLICAR='sp_modif_masiva_aplicar', OP_STATS='apremiossvn_apremios_estadisticas'
const { loading, execute } = useApi(); const { showToast, handleApiError } = useLicenciasErrorHandler()
const jsonPayload=ref(''), loadingEstadisticas=ref(true), estadisticas=ref([])
const cargarEstadisticas = async () => { loadingEstadisticas.value=true; try{ const result=await execute(OP_STATS, BASE_DB, []); estadisticas.value=Array.isArray(result?.rows)?result.rows:Array.isArray(result)?result:[] }catch(e){ estadisticas.value=[] }finally{ loadingEstadisticas.value=false } }
const aplicar = async () => { if(!jsonPayload.value){ showToast('error','Debe ingresar datos JSON'); return }; const t0=performance.now(); try{ await execute(OP_APLICAR, BASE_DB, [{name:'datos',type:'C',value:jsonPayload.value}]); const dur=performance.now()-t0, txt=dur<1000?`${Math.round(dur)}ms`:`${(dur/1000).toFixed(2)}s`; showToast('success',`Cambios aplicados en ${txt}`); limpiar() }catch(e){ handleApiError(e) } }
const limpiar = () => { jsonPayload.value='' }
const formatNumber = (n) => new Intl.NumberFormat('es-MX').format(n); const formatMoney = (v) => Number(v||0).toLocaleString('es-MX',{style:'currency',currency:'MXN'})
const getStatIcon = (c) => ({'TOTAL':'chart-bar','VIGENTES':'check-circle','VENCIDOS':'times-circle','CON_EJECUTOR':'user-check','SIN_EJECUTOR':'user-times','IMPORTE_TOTAL':'coins'}[c]||'info-circle')
const getStatValue = (s) => s.categoria==='IMPORTE_TOTAL'?formatMoney(s.total):formatNumber(s.total)
onMounted(()=>{ cargarEstadisticas() })
</script>
