<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="lightbulb" /></div>
      <div class="module-view-info"><h1>Reporte de Ingresos por Energía</h1><p>Inicio > Mercados > Ingresos Energía</p></div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading"><font-awesome-icon icon="search" /> Consultar</button>
        <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading || results.length === 0"><font-awesome-icon icon="file-excel" /> Exportar</button>
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
            <div class="form-group"><label class="municipal-form-label">Año <span class="required">*</span></label><input type="number" v-model.number="filters.axo" class="municipal-form-control" min="1990" :max="new Date().getFullYear() + 1" :disabled="loading" /></div>
            <div class="form-group"><label class="municipal-form-label">Periodo</label><select v-model.number="filters.periodo" class="municipal-form-control" :disabled="loading"><option value="">Todos</option><option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option></select></div>
          </div>
        </div>
      </div>
      <div v-if="loading" class="text-center py-5"><div class="spinner-border municipal-text-primary" role="status"><span class="visually-hidden">Cargando...</span></div><p class="mt-2">Generando reporte...</p></div>
      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info"><font-awesome-icon icon="info-circle" /> Seleccione filtros y consulte.</div>
      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning"><font-awesome-icon icon="exclamation-triangle" /> No se encontraron ingresos.</div>
      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge"><h5><font-awesome-icon icon="list-alt" /> Ingresos Energía</h5><div class="header-right"><span class="badge-purple">{{ results.length }} registros</span><span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span></div></div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header"><tr><th>Fecha</th><th>Mercado</th><th>Local</th><th>Nombre</th><th>Año/Periodo</th><th class="text-end">Consumo</th><th class="text-end">Importe</th></tr></thead><tbody><tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover"><td>{{ formatDate(row.fecha_pago) }}</td><td>{{ row.num_mercado }}</td><td>{{ datosLocal(row) }}</td><td>{{ row.nombre }}</td><td>{{ row.axo }}/{{ row.periodo }}</td><td class="text-end">{{ formatNumber(row.consumo) }} kW</td><td class="text-end"><strong>{{ formatCurrency(row.importe_pago) }}</strong></td></tr></tbody><tfoot class="municipal-table-footer"><tr><th colspan="6" class="text-end">TOTAL:</th><th class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></th></tr></tfoot></table></div>
          <div class="pagination-container"><div class="pagination-info"><label>Mostrar:</label><select v-model.number="pageSize" class="municipal-form-control pagination-select"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option><option :value="250">250</option></select><span>registros por página</span></div><div class="pagination-controls"><button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1"><font-awesome-icon icon="chevron-left" /></button><span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span><button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages"><font-awesome-icon icon="chevron-right" /></button></div></div>
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

const filters = ref({ oficina: '', mercado: '', axo: new Date().getFullYear(), periodo: '' });
const recaudadoras = ref([]);
const mercados = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);
const meses = ref([{ value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' }, { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' }, { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' }, { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }]);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => { const start = (currentPage.value - 1) * pageSize.value; return results.value.slice(start, start + pageSize.value); });
const totalImporte = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.importe_pago) || 0), 0));

const fetchRecaudadoras = async () => { loading.value = true; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'mercados', Parametros: [] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { recaudadoras.value = response.data.eResponse.data.result; } } catch (error) { console.error('Error:', error); } finally { loading.value = false; } };
const onOficinaChange = async () => { if (!filters.value.oficina) { mercados.value = []; filters.value.mercado = ''; return; } loading.value = true; try { const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_get_mercados_by_recaudadora', Base: 'mercados', Parametros: [{ Nombre: 'p_id_rec', Valor: parseInt(filters.value.oficina) }] } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { mercados.value = response.data.eResponse.data.result; } else { mercados.value = []; } } catch (error) { console.error('Error:', error); mercados.value = []; } finally { loading.value = false; } };
const consultar = async () => { if (!filters.value.oficina) { alert('Seleccione una recaudadora'); return; } loading.value = true; busquedaRealizada.value = false; try { const parametros = [{ Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) }, { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) }]; if (filters.value.mercado) parametros.push({ Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) }); if (filters.value.periodo) parametros.push({ Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) }); const response = await axios.post('/api/generic', { eRequest: { Operacion: 'sp_rpt_ingresos_energia', Base: 'mercados', Parametros: parametros } }); if (response.data.eResponse?.success && response.data.eResponse?.data?.result) { results.value = response.data.eResponse.data.result; busquedaRealizada.value = true; currentPage.value = 1; } else { results.value = []; busquedaRealizada.value = true; } } catch (error) { console.error('Error:', error); results.value = []; busquedaRealizada.value = true; } finally { loading.value = false; } };

const datosLocal = (row) => { let datos = `${row.categoria || ''}-${row.seccion || ''}-${row.local || ''}`; if (row.letra_local) datos += row.letra_local; if (row.bloque) datos += `-${row.bloque}`; return datos; };
const formatDate = (value) => { if (!value) return ''; return new Date(value).toLocaleDateString('es-MX'); };
const formatCurrency = (value) => { if (value == null) return '$0.00'; return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value); };
const formatNumber = (value) => { if (value == null) return '0'; return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value); };
const exportarExcel = () => { const data = results.value.map(row => ({ 'Fecha': formatDate(row.fecha_pago), 'Mercado': row.num_mercado, 'Local': datosLocal(row), 'Nombre': row.nombre, 'Año': row.axo, 'Periodo': row.periodo, 'Consumo': row.consumo, 'Importe': row.importe_pago })); const csv = [Object.keys(data[0]).join(','), ...data.map(row => Object.values(row).join(','))].join('\n'); const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' }); const url = window.URL.createObjectURL(blob); const a = document.createElement('a'); a.href = url; a.download = `ingresos_energia_${filters.value.oficina}_${filters.value.axo}.csv`; a.click(); window.URL.revokeObjectURL(url); };
const mostrarAyuda = () => { alert('Reporte de Ingresos por Energía Eléctrica\n\nGenera un reporte de los ingresos por consumo de energía eléctrica.\n\nIncluye información de consumo en kilowatts y monto pagado.'); };

onMounted(async () => {
  showLoading('Cargando Reporte de Ingresos de Energía', 'Preparando oficinas recaudadoras...');
  try {
    await fetchRecaudadoras();
  } finally {
    hideLoading();
  }
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
</style>
