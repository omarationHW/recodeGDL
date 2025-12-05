<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Factura de Emisión</h1>
        <p>Inicio > Mercados > Factura de Emisión</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading">
          <font-awesome-icon icon="search" /> Consultar
        </button>
        <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
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
                <option v-for="m in mercados" :key="m.num_mercado" :value="m.num_mercado">
                  {{ m.num_mercado }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control"
                     min="1990" :max="new Date().getFullYear() + 1" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo <span class="required">*</span></label>
              <select v-model.number="filters.periodo" class="municipal-form-control" :disabled="loading">
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Reporte de Factura de Emisión</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th class="text-end">Importe</th>
                  <th class="text-center">Fecha</th>
                  <th class="text-center">Estado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover">
                  <td class="text-center">{{ idx + 1 }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe) }}</strong></td>
                  <td class="text-center">{{ formatDate(row.fecha) }}</td>
                  <td class="text-center">
                    <span :class="getEstadoBadge(row.estado)">{{ row.estado }}</span>
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="5" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></td>
                  <td colspan="2"></td>
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

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Cargando reporte de facturas...</p>
      </div>

      <div v-if="!results.length && !loading && busquedaRealizada" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron registros con los criterios seleccionados.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';

const filters = ref({
  oficina: '',
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1,
  opc: 1
});

const recaudadoras = ref([]);
const mercados = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

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

const totalImporte = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.importe) || 0), 0);
});

// Métodos
const fetchRecaudadoras = async () => {
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (err) {
    console.error('Error al cargar recaudadoras:', err);
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
        Base: 'padron_licencias',
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
  } catch (err) {
    console.error('Error al cargar mercados:', err);
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
        Operacion: 'sp_rpt_factura_emision',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) },
          { Nombre: 'p_opc', Valor: parseInt(filters.value.opc) }
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
  } catch (err) {
    console.error('Error al consultar:', err);
    results.value = [];
    busquedaRealizada.value = true;
  } finally {
    loading.value = false;
  }
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
};

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const getEstadoBadge = (estado) => {
  const badges = {
    'pagado': 'badge-success',
    'pendiente': 'badge-warning',
    'vencido': 'badge-danger'
  };
  return badges[estado?.toLowerCase()] || 'badge-secondary';
};

const exportarExcel = () => {
  const data = results.value.map(row => ({
    'Oficina': row.oficina,
    'Mercado': row.num_mercado,
    'Local': row.local,
    'Nombre': row.nombre,
    'Importe': row.importe,
    'Fecha': row.fecha,
    'Estado': row.estado
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `factura_emision_${filters.value.axo}_${filters.value.periodo}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => {
  alert('Reporte de Factura de Emisión\n\nSeleccione la recaudadora, mercado, año y periodo para generar el reporte.');
};

// Lifecycle
onMounted(() => {
  fetchRecaudadoras();
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
</style>
