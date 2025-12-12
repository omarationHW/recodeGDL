<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info"><h1>Reporte de Locales por Giro</h1><p>Inicio > Mercados > Locales por Giro</p></div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading"><font-awesome-icon icon="search" /> Consultar</button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || results.length === 0"><font-awesome-icon icon="file-excel" /> Exportar</button>
        <button class="btn-municipal-purple" @click="mostrarAyuda"><font-awesome-icon icon="question-circle" /> Ayuda</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header"><h5><font-awesome-icon icon="filter" /> Filtros</h5></div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Recaudadora <span class="required">*</span></label><select v-model="filters.oficina" class="municipal-form-control" @change="onOficinaChange" :disabled="loading"><option value="">Seleccione...</option><option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Mercado</label><select v-model="filters.mercado" class="municipal-form-control" :disabled="loading || !mercados.length"><option value="">Todos</option><option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option></select></div>
            <div class="form-group"><label class="municipal-form-label">Giro</label><select v-model="filters.giro" class="municipal-form-control" :disabled="loading"><option value="">Todos</option><option v-for="g in giros" :key="g.id_giro" :value="g.id_giro">{{ g.descripcion }}</option></select></div>
          </div>
        </div>
      </div>
      <div v-if="loading" class="text-center py-5"><div class="spinner-border municipal-text-primary" role="status"><span class="visually-hidden">Cargando...</span></div><p class="mt-2">Generando reporte...</p></div>
      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info"><font-awesome-icon icon="info-circle" /> Seleccione filtros y consulte.</div>
      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning"><font-awesome-icon icon="exclamation-triangle" /> No se encontraron locales.</div>
      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge"><h5><font-awesome-icon icon="list-alt" /> Locales por Giro</h5><div class="header-right"><span class="badge-purple">{{ results.length }} locales</span></div></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th>Mercado</th><th>Local</th><th>Nombre</th><th>Giro</th><th>Descripción Giro</th><th class="text-end">Superficie</th><th class="text-end">Renta</th></tr></thead><tbody><tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover"><td>{{ row.num_mercado }}</td><td>{{ datosLocal(row) }}</td><td>{{ row.nombre }}</td><td>{{ row.giro }}</td><td>{{ row.descripcion_giro }}</td><td class="text-end">{{ formatNumber(row.superficie) }} m²</td><td class="text-end"><strong>{{ formatCurrency(row.renta) }}</strong></td></tr></tbody><tfoot class="municipal-table-footer"><tr><th colspan="6" class="text-end">TOTAL RENTA:</th><th class="text-end"><strong class="text-success">{{ formatCurrency(totalRenta) }}</strong></th></tr></tfoot></table></div>
          <div class="pagination-container"><div class="pagination-info"><label>Mostrar:</label><select v-model.number="pageSize" class="municipal-form-control pagination-select"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option><option :value="250">250</option></select><span>registros por página</span></div><div class="pagination-controls"><button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1"><font-awesome-icon icon="angle-left" /></button><span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span><button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages"><font-awesome-icon icon="angle-right" /></button></div></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const filters = ref({ oficina: '', mercado: '', giro: '' });
const recaudadoras = ref([]);
const mercados = ref([]);
const giros = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => { const start = (currentPage.value - 1) * pageSize.value; return results.value.slice(start, start + pageSize.value); });
const totalRenta = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.renta) || 0), 0));

const fetchRecaudadoras = async () => { showLoading('Cargando recaudadoras...', 'Por favor espere'); loading.value = true; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'mercados', Parametros: [] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { recaudadoras.value = response.data.eResponse.data.result; } } catch (error) { console.error('Error:', error); } finally { loading.value = false; hideLoading(); } };
const fetchGiros = async () => { showLoading('Cargando giros...', 'Por favor espere'); loading.value = true; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_giros', Base: 'mercados', Parametros: [] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { giros.value = response.data.eResponse.data.result; } } catch (error) { console.error('Error:', error); } finally { loading.value = false; hideLoading(); } };
const onOficinaChange = async () => { if (!filters.value.oficina) { mercados.value = []; filters.value.mercado = ''; return; } showLoading('Cargando mercados...', 'Por favor espere'); loading.value = true; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_mercados_by_recaudadora', Base: 'mercados', Parametros: [{ Nombre: 'p_id_rec', Valor: parseInt(filters.value.oficina) }] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { mercados.value = response.data.eResponse.data.result; } else { mercados.value = []; } } catch (error) { console.error('Error:', error); mercados.value = []; } finally { loading.value = false; hideLoading(); } };
const consultar = async () => { if (!filters.value.oficina) { alert('Seleccione una recaudadora'); return; } showLoading('Consultando locales por giro...', 'Por favor espere'); loading.value = true; busquedaRealizada.value = false; try { const parametros = [{ Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) }]; if (filters.value.mercado) parametros.push({ Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) }); if (filters.value.giro) parametros.push({ Nombre: 'p_giro', Valor: parseInt(filters.value.giro) }); const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_rpt_locales_giro', Base: 'mercados', Parametros: parametros } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { results.value = response.data.eResponse.data.result; busquedaRealizada.value = true; currentPage.value = 1; } else { results.value = []; busquedaRealizada.value = true; } } catch (error) { console.error('Error:', error); results.value = []; busquedaRealizada.value = true; } finally { loading.value = false; hideLoading(); } };

const datosLocal = (row) => { let datos = `${row.categoria || ''}-${row.seccion || ''}-${row.local || ''}`; if (row.letra_local) datos += row.letra_local; if (row.bloque) datos += `-${row.bloque}`; return datos; };
const formatCurrency = (value) => { if (value == null) return '$0.00'; return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value); };
const formatNumber = (value) => { if (value == null) return '0.00'; return parseFloat(value).toFixed(2); };
const exportarExcel = () => { const data = results.value.map(row => ({ 'Mercado': row.num_mercado, 'Local': datosLocal(row), 'Nombre': row.nombre, 'Giro': row.giro, 'Descripción': row.descripcion_giro, 'Superficie': row.superficie, 'Renta': row.renta })); const csv = [Object.keys(data[0]).join(','), ...data.map(row => Object.values(row).join(','))].join('\n'); const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' }); const url = window.URL.createObjectURL(blob); const a = document.createElement('a'); a.href = url; a.download = `locales_giro_${filters.value.oficina}.csv`; a.click(); window.URL.revokeObjectURL(url); };
const mostrarAyuda = () => { alert('Reporte de Locales por Giro\n\nGenera un reporte de locales agrupados por tipo de giro comercial.\n\nPuede filtrar por recaudadora, mercado y giro específico.'); };

onMounted(() => { fetchRecaudadoras(); fetchGiros(); });
</script>

