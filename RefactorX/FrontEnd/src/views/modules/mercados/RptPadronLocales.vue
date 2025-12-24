<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="building" />
      </div>
      <div class="module-view-info">
        <h1>Padrón de Arrendamiento de Mercados</h1>
        <p>Inicio > Mercados > Padrón de Locales</p>
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
        <button class="btn-municipal-secondary" @click="limpiar" :disabled="loading">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || !results.length">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Consulta</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina Recaudadora <span class="required">*</span></label>
              <select v-model="filters.oficina" class="municipal-form-control" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                 {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Mercado <span class="required">*</span></label>
              <select v-model="filters.mercado" class="municipal-form-control" :disabled="loading || !mercados.length">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Cargando padrón de locales...</p>
      </div>

      <!-- Sin búsqueda -->
      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
        <font-awesome-icon icon="info-circle" /> Seleccione la oficina recaudadora y mercado, luego haga clic en <strong>Consultar</strong>.
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron locales con los criterios seleccionados.
      </div>

      <!-- Tabla de Resultados -->
      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Padrón de Locales</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} locales</span>
            <span class="badge-info ms-2">Superficie: {{ formatNumber(totalSuperficie) }} m²</span>
            <span class="badge-success ms-2">Renta: {{ formatCurrency(totalRenta) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Categoría</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th class="text-end">Superficie (m²)</th>
                  <th>Clave Cuota</th>
                  <th>Descripción</th>
                  <th class="text-end">Renta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedResults" :key="row.id_local" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end">{{ formatNumber(row.superficie) }}</td>
                  <td>{{ row.clave_cuota }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.renta) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <th colspan="8" class="text-end">Totales:</th>
                  <th class="text-end">{{ formatNumber(totalSuperficie) }} m²</th>
                  <th colspan="2"></th>
                  <th class="text-end"><strong class="text-success">{{ formatCurrency(totalRenta) }}</strong></th>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              <label>Mostrar:</label>
              <select v-model.number="pageSize" class="municipal-form-control pagination-select">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
              <span>registros por página</span>
            </div>
            <div class="pagination-controls">
              <button class="btn-municipal-secondary btn-sm" @click="currentPage--" :disabled="currentPage === 1">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'RptPadronLocales'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptPadronLocales'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptPadronLocales'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptPadronLocales'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const { showLoading, hideLoading } = useGlobalLoading();

// Referencias reactivas
const filters = ref({
  oficina: '',
  mercado: ''
});

const recaudadoras = ref([]);
const mercados = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

// Computed
const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);

const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return results.value.slice(start, end);
});

const totalSuperficie = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.superficie) || 0), 0);
});

const totalRenta = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.renta) || 0), 0);
});

// Métodos
const fetchRecaudadoras = async () => {
  showLoading('Cargando recaudadoras...', 'Por favor espere');
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
    console.error('Error al cargar recaudadoras:', error);
  } finally {
    loading.value = false;
    hideLoading();
  }
};

const onOficinaChange = async () => {
  if (!filters.value.oficina) {
    mercados.value = [];
    filters.value.mercado = '';
    return;
  }

  showLoading('Cargando mercados...', 'Por favor espere');
  loading.value = true;
  try {
    const response = await apiService.execute(
          'sp_get_mercados_by_recaudadora',
          'mercados',
          [
          { nombre: 'p_id_rec', valor: parseInt(filters.value.oficina) }
        ],
          '',
          null,
          'publico'
        );

    if (response?.success && response?.data?.result) {
      mercados.value = response.data.result;
    } else {
      mercados.value = [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    mercados.value = [];
  } finally {
    loading.value = false;
    hideLoading();
  }
};

const consultar = async () => {
  if (!filters.value.oficina || !filters.value.mercado) {
    alert('Por favor complete todos los filtros requeridos');
    return;
  }

  showLoading('Consultando padrón de locales...', 'Por favor espere');
  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const response = await apiService.execute(
          'sp_get_padron_locales',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(filters.value.oficina) },
          { nombre: 'p_mercado', valor: parseInt(filters.value.mercado) }
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
    console.error('Error al consultar:', error);
    results.value = [];
    busquedaRealizada.value = true;
  } finally {
    loading.value = false;
    hideLoading();
  }
};

const limpiar = () => {
  filters.value = {
    oficina: '',
    mercado: ''
  };
  mercados.value = [];
  results.value = [];
  busquedaRealizada.value = false;
  currentPage.value = 1;
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
};

const formatNumber = (value) => {
  if (value == null) return '0.00';
  return parseFloat(value).toFixed(2);
};

const exportarExcel = () => {
  const data = results.value.map(row => ({
    'Oficina': row.oficina,
    'Mercado': row.num_mercado,
    'Categoría': row.categoria,
    'Sección': row.seccion,
    'Local': row.local,
    'Letra': row.letra_local,
    'Bloque': row.bloque,
    'Nombre': row.nombre,
    'Superficie': row.superficie,
    'Clave Cuota': row.clave_cuota,
    'Descripción': row.descripcion,
    'Renta': row.renta
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `padron_locales_${filters.value.oficina}_${filters.value.mercado}_${new Date().getTime()}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => {
  alert('Padrón de Arrendamiento de Mercados\n\nSeleccione la oficina recaudadora y el mercado para consultar el padrón de locales registrados.\n\nLa tabla muestra todos los locales con su información de arrendamiento, superficie y renta mensual.');
};

// Lifecycle
onMounted(() => {
  fetchRecaudadoras();
});
</script>
