<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="barcode" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos Laser</h1>
        <p>Inicio > Mercados > Emisión Laser</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading">
          <font-awesome-icon icon="search" /> Consultar
        </button>
        <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        <button class="btn-municipal-info" @click="imprimir" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="print" /> Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
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
              <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
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

            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control"
                     min="2000" :max="new Date().getFullYear() + 1" :disabled="loading" />
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

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Generando reporte de emisión laser...</p>
      </div>

      <!-- Sin búsqueda -->
      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
        <font-awesome-icon icon="info-circle" /> Seleccione los filtros y haga clic en <strong>Consultar</strong> para generar el reporte.
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron recibos para los criterios seleccionados.
      </div>

      <!-- Tabla de Resultados -->
      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Emisión de Recibos Laser</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} recibos</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalSubtotal) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th>Meses Adeudo</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover">
                  <td>{{ row.local }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion_local }}</td>
                  <td>{{ row.meses || 'N/A' }}</td>
                  <td class="text-end">{{ formatCurrency(row.rentaaxos) }}</td>
                  <td class="text-end">{{ formatCurrency(row.recargos) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.subtotal) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <th colspan="4" class="text-end">Totales:</th>
                  <th class="text-end">{{ formatCurrency(totalRenta) }}</th>
                  <th class="text-end">{{ formatCurrency(totalRecargos) }}</th>
                  <th class="text-end"><strong class="text-success">{{ formatCurrency(totalSubtotal) }}</strong></th>
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
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

// Referencias reactivas
const filters = ref({
  oficina: '',
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1
});

const recaudadoras = ref([]);
const mercados = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

// Meses
const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
]);

// Computed
const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);

const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return results.value.slice(start, end);
});

const totalRenta = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.rentaaxos) || 0), 0);
});

const totalRecargos = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.recargos) || 0), 0);
});

const totalSubtotal = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.subtotal) || 0), 0);
});

// Métodos
const fetchRecaudadoras = async () => {
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  } finally {
    loading.value = false;
  }
};

const onOficinaChange = async () => {
  if (!filters.value.oficina) {
    mercados.value = [];
    filters.value.mercado = '';
    return;
  }

  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(filters.value.oficina) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    } else {
      mercados.value = [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    mercados.value = [];
  } finally {
    loading.value = false;
  }
};

const consultar = async () => {
  if (!filters.value.oficina || !filters.value.mercado) {
    alert('Por favor complete todos los filtros requeridos');
    return;
  }

  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_emision_laser',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) },
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      results.value = response.data.eResponse.data.result;
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
  }
};

const limpiar = () => {
  filters.value = {
    oficina: '',
    mercado: '',
    axo: new Date().getFullYear(),
    periodo: new Date().getMonth() + 1
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

const exportarExcel = () => {
  const data = results.value.map(row => ({
    'Local': row.local,
    'Nombre': row.nombre,
    'Descripción': row.descripcion_local,
    'Meses Adeudo': row.meses,
    'Renta': row.rentaaxos,
    'Recargos': row.recargos,
    'Subtotal': row.subtotal
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `emision_laser_${filters.value.oficina}_${filters.value.mercado}_${filters.value.axo}_${filters.value.periodo}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const imprimir = () => {
  window.print();
};

const mostrarAyuda = () => {
  alert('Emisión de Recibos Laser\n\nGenera el reporte de emisión de recibos en formato laser para un mercado específico en un periodo determinado.\n\nSeleccione la recaudadora, mercado, año y periodo (mes) para consultar.');
};

// Lifecycle
onMounted(() => {
  fetchRecaudadoras();
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';

@media print {
  .module-view-header,
  .municipal-card-header,
  .pagination-container,
  .button-group {
    display: none !important;
  }

  .municipal-table {
    font-size: 10px;
  }
}
</style>
