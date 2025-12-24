<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-signature" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Facturación Global</h1>
        <p>Inicio > Mercados > Facturación Global</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading">
          <font-awesome-icon icon="search" /> Consultar
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
              <select v-model="filters.oficina" class="municipal-form-control" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control" min="1990" :max="new Date().getFullYear() + 1" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <select v-model.number="filters.periodo" class="municipal-form-control" :disabled="loading">
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status"><span class="visually-hidden">Cargando...</span></div>
        <p class="mt-2">Generando reporte de facturación global...</p>
      </div>

      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
        <font-awesome-icon icon="info-circle" /> Seleccione los filtros y haga clic en <strong>Consultar</strong>.
      </div>

      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron registros.
      </div>

      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Facturación Global</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr><th>Mercado</th><th>Descripción</th><th class="text-end">Total Facturado</th><th class="text-end">Locales</th></tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover">
                  <td>{{ row.num_mercado }}</td><td>{{ row.descripcion }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.total_facturado) }}</strong></td>
                  <td class="text-end">{{ row.total_locales }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr><th colspan="2" class="text-end">TOTAL:</th>
                <th class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></th><th></th></tr>
              </tfoot>
            </table>
          </div>
          <div class="pagination-container">
            <div class="pagination-info">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" class="municipal-form-control pagination-select">
                <option :value="10">10</option><option :value="25">25</option><option :value="50">50</option><option :value="100">100</option>
              </select>
              <span>registros por página</span>
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1"><font-awesome-icon icon="angle-left" /></button>
              <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages"><font-awesome-icon icon="angle-right" /></button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'RptFacturaGLunes'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptFacturaGLunes'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptFacturaGLunes'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptFacturaGLunes'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading();

const filters = ref({ oficina: '', axo: new Date().getFullYear(), periodo: new Date().getMonth() + 1 });
const recaudadoras = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);

const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
]);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return results.value.slice(start, start + pageSize.value);
});
const totalImporte = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.total_facturado) || 0), 0));

const fetchRecaudadoras = async () => {
  loading.value = true;
  try {
    const response = await apiService.execute(
          'sp_get_recaudadoras',
          'mercados',
          [],
          '',
          null,
          'publico'
        );
    if (response?.success && response?.data?.result) {
      recaudadoras.value = response.data.result;
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
};

const consultar = async () => {
  if (!filters.value.oficina) { alert('Seleccione una recaudadora'); return; }
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await apiService.execute(
          'sp_rpt_factura_global',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(filters.value.oficina) },
          { nombre: 'p_axo', valor: parseInt(filters.value.axo) },
          { nombre: 'p_periodo', valor: parseInt(filters.value.periodo) }
        ],
          '',
          null,
          'publico'
        );
    if (response?.success && response?.data?.result) {
      results.value = response.data.result;
      busquedaRealizada.value = true;
      currentPage.value = 1;
    } else {
      results.value = [];
      busquedaRealizada.value = true;
    }
  } catch (error) {
    console.error('Error:', error);
    results.value = [];
    busquedaRealizada.value = true;
  } finally {
    loading.value = false;
  }
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const exportarExcel = () => {
  const data = results.value.map(row => ({ 'Mercado': row.num_mercado, 'Descripción': row.descripcion, 'Total': row.total_facturado, 'Locales': row.total_locales }));
  const csv = [Object.keys(data[0]).join(','), ...data.map(row => Object.values(row).join(','))].join('\n');
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `facturacion_global_${filters.value.oficina}_${filters.value.axo}_${filters.value.periodo}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => { alert('Reporte de Facturación Global\n\nGenera un resumen de la facturación total por mercado para un periodo específico.'); };

onMounted(async () => {
  showLoading('Cargando Reporte de Factura Global', 'Preparando oficinas recaudadoras...');
  try {
    await fetchRecaudadoras();
  } finally {
    hideLoading();
  }
});
</script>
