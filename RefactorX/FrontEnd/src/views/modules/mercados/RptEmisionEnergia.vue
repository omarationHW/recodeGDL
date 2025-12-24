<template>
  <div class="module-view">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div><div class="module-view-info"><h1>Emisión de Energía</h1><p>Inicio > Reportes > Emisión Recibos de Energía</p></div><div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || datos.length === 0"><font-awesome-icon icon="file-excel" />Exportar Excel</button><button class="btn-municipal-primary" @click="imprimir" :disabled="loading || datos.length === 0"><font-awesome-icon icon="print" />Imprimir</button></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;"><h5><font-awesome-icon icon="filter" />Filtros de Consulta<font-awesome-icon :icon="showFilters ? 'angle-up' : 'angle-down'" class="ms-2" /></h5></div><div v-show="showFilters" class="municipal-card-body"><div class="form-row"><div class="form-group"><label class="municipal-form-label">Oficina</label><input v-model.number="filters.oficina" type="number" class="municipal-form-control" min="1" /></div><div class="form-group"><label class="municipal-form-label">Mercado</label><input v-model.number="filters.mercado" type="number" class="municipal-form-control" min="1" /></div><div class="form-group"><label class="municipal-form-label">Año</label><input v-model.number="filters.axo" type="number" class="municipal-form-control" min="2000" max="2100" /></div><div class="form-group"><label class="municipal-form-label">Periodo (Mes)</label><input v-model.number="filters.periodo" type="number" class="municipal-form-control" min="1" max="12" /></div></div><div class="row mt-3"><div class="col-12 text-end"><button class="btn-municipal-primary me-2" @click="consultar" :disabled="loading"><font-awesome-icon icon="search" />Consultar</button><button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading"><font-awesome-icon icon="eraser" />Limpiar</button></div></div></div></div>
      <div class="municipal-card"><div class="municipal-card-header header-with-badge"><h5><font-awesome-icon icon="list" />{{ tituloReporte }}</h5><div class="header-right"><span class="badge-purple" v-if="datos.length > 0">{{ formatNumber(datos.length) }} registros</span></div></div><div class="municipal-card-body table-container"><div v-if="loading" class="text-center py-5"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Cargando...</span></div><p class="mt-3 text-muted">Generando reporte...</p></div><div v-else class="table-responsive"><table class="municipal-table"><thead class="municipal-table-header sticky-header"><tr><th>Datos Local</th><th>Nombre</th><th>Descripción</th><th>Cuenta Energía</th><th>Locales</th><th>Cantidad</th><th class="text-end">Importe</th><th>Tipo Consumo</th></tr></thead><tbody><tr v-if="datos.length === 0 && !consultaRealizada"><td colspan="8" class="text-center text-muted"><font-awesome-icon icon="search" size="2x" class="empty-icon" /><p>Utiliza los filtros</p></td></tr><tr v-else-if="datos.length === 0"><td colspan="8" class="text-center text-muted"><font-awesome-icon icon="inbox" size="2x" class="empty-icon" /><p>No se encontraron resultados</p></td></tr><tr v-else v-for="(row, index) in paginatedDatos" :key="index" class="row-hover"><td>{{ row.datoslocal }}</td><td>{{ row.nombre }}</td><td>{{ row.descripcion }}</td><td>{{ row.cuenta_energia }}</td><td>{{ row.local_adicional }}</td><td>{{ row.cantidad }}</td><td class="text-end">{{ formatCurrency(row.importe_energia) }}</td><td>{{ row.descripcion_consumo }}</td></tr></tbody></table></div><div v-if="datos.length > 0" class="pagination-container"><div class="pagination-info">Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ datos.length }} registros</div><div class="pagination-controls"><label>Registros por página:</label><select v-model.number="pageSize" class="municipal-form-control" style="width: auto; display: inline-block;"><option :value="10">10</option><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option><option :value="250">250</option></select></div><div class="pagination-buttons"><button @click="previousPage" :disabled="currentPage === 1" class="btn-municipal-secondary"><font-awesome-icon icon="angle-left" /></button><span class="mx-3">Página {{ currentPage }} de {{ totalPages }}</span><button @click="nextPage" :disabled="currentPage === totalPages" class="btn-municipal-secondary"><font-awesome-icon icon="angle-right" /></button></div></div></div></div>
    </div>
    <div v-if="toast.show" :class="['toast-notification', `toast-${toast.type}`]"><font-awesome-icon :icon="getToastIcon()" /><span>{{ toast.message }}</span></div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'RptEmisionEnergia'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptEmisionEnergia'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptEmisionEnergia'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptEmisionEnergia'" @close="showDocumentacion = false" />
</template>
<script setup>
import apiService from '@/services/apiService';
import { ref, computed } from 'vue'; const loading = ref(false); const showFilters = ref(true); const consultaRealizada = ref(false); const datos = ref([]); const filters = ref({ oficina: 1, mercado: 1, axo: new Date().getFullYear(), periodo: new Date().getMonth() + 1 }); const currentPage = ref(1); const pageSize = ref(25); const toast = ref({ show: false, message: '', type: 'info' });
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)

const tituloReporte = computed(() => 'Emisión de Recibos de Energía Eléctrica'); const totalPages = computed(() => Math.ceil(datos.value.length / pageSize.value)); const startIndex = computed(() => (currentPage.value - 1) * pageSize.value); const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, datos.value.length)); const paginatedDatos = computed(() => datos.value.slice(startIndex.value, endIndex.value));
const toggleFilters = () => { showFilters.value = !showFilters.value; }; const consultar = async () => { loading.value = true; consultaRealizada.value = true; datos.value = []; currentPage.value = 1; try { const response = await apiService.execute(
          'sp_rpt_emision_energia',
          'mercados',
          [
  { nombre: 'p_oficina', valor: parseInt(filters.value.oficina) },
          { nombre: 'p_mercado', valor: parseInt(filters.value.mercado) },
          { nombre: 'p_axo', valor: parseInt(filters.value.axo) },
          { nombre: 'p_periodo', valor: parseInt(filters.value.periodo) }],
          '',
          null,
          'publico'
        );
          
  // filters.value.oficina, filters.value.mercado, filters.value.axo, filters.value.periodo] } }); 
// p_oficina integer, p_mercado integer, p_axo integer, p_periodo integer)
if (response?.success && response?.data?.result) { datos.value = response.data.result; showToast(datos.value.length === 0 ? 'No se encontraron resultados' : `Se encontraron ${datos.value.length} registros`, datos.value.length === 0 ? 'info' : 'success'); } else { showToast('No se encontraron resultados', 'warning'); } } catch (error) { console.error('Error:', error); showToast('Error al consultar', 'error'); } finally { loading.value = false; } }; const limpiarFiltros = () => { filters.value = { oficina: 1, mercado: 1, axo: new Date().getFullYear(), periodo: new Date().getMonth() + 1 }; datos.value = []; consultaRealizada.value = false; currentPage.value = 1; }; const exportarExcel = () => { showToast('Funcionalidad en desarrollo', 'info'); }; const imprimir = () => { window.print(); }; const mostrarAyuda = () => { showToast('Emisión de recibos de energía eléctrica. Filtre por oficina, mercado, año y periodo.', 'info'); }; const previousPage = () => { if (currentPage.value > 1) currentPage.value--; }; const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; }; const formatCurrency = (value) => { if (value === null || value === undefined) return '$0.00'; return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value); }; const formatNumber = (value) => { if (value === null || value === undefined) return '0'; return new Intl.NumberFormat('es-MX').format(value); }; const showToast = (message, type = 'info') => { toast.value = { show: true, message, type }; setTimeout(() => { toast.value.show = false; }, 3000); }; const getToastIcon = () => { const icons = { success: 'check-circle', error: 'exclamation-circle', warning: 'exclamation-triangle', info: 'info-circle' }; return icons[toast.value.type] || 'info-circle'; };
</script>
