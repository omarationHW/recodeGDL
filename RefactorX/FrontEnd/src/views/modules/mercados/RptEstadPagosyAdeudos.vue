<template>
  <div class="module-view mt-3">
    <!-- Breadcrumb -->
    <div class="mb-3">
      <span class="text-muted">Inicio / Mercados / Estadística de Pagos y Adeudos</span>
    </div>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-chart-bar"></i> Estadística de Pagos, Captura y Adeudos de Mercados</h2>
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header bg-primary text-white" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
        <i :class="mostrarFiltros ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
        Filtros de Consulta
      </div>
      <div class="municipal-card-body" v-show="mostrarFiltros">
        <form @submit.prevent="consultar">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Recaudadora <span class="text-danger">*</span></label>
              <select v-model="filters.recaudadora" class="municipal-form-control" @change="onRecaudadoraChange" required>
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Año <span class="text-danger">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control" min="1990" :max="new Date().getFullYear() + 1" required />
            </div>

            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Mes <span class="text-danger">*</span></label>
              <select v-model.number="filters.mes" class="municipal-form-control" required>
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
          </div>

          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Fecha Desde <span class="text-danger">*</span></label>
              <input type="date" v-model="filters.fechaDesde" class="municipal-form-control" required />
            </div>

            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Fecha Hasta <span class="text-danger">*</span></label>
              <input type="date" v-model="filters.fechaHasta" class="municipal-form-control" required />
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn-municipal-primary" :disabled="loading">
              <i class="fas fa-search"></i> Consultar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros">
              <i class="fas fa-eraser"></i> Limpiar
            </button>
            <button type="button" class="btn btn-outline-success" @click="exportarExcel" :disabled="!resultados.length">
              <i class="fas fa-file-excel"></i> Exportar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-2">Cargando estadísticas...</p>
    </div>

    <!-- Sin búsqueda -->
    <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
      <i class="fas fa-info-circle"></i> Seleccione los filtros y haga clic en <strong>Consultar</strong> para ver las estadísticas.
    </div>

    <!-- Sin resultados -->
    <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron estadísticas con los filtros seleccionados.
    </div>

    <!-- Resumen General -->
    <div v-if="resumen.length && !loading" class="card mb-3">
      <div class="municipal-card-header bg-light">
        <h5 class="mb-0"><i class="fas fa-chart-pie"></i> Resumen General</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div class="col-md-4" v-for="item in resumen" :key="item.tipo">
            <div class="municipal-card mb-2">
              <div class="municipal-card-body">
                <h6 class="card-title text-uppercase">{{ item.tipo }}</h6>
                <div class="d-flex justify-content-between">
                  <span>Locales:</span>
                  <strong>{{ formatNumber(item.locales) }}</strong>
                </div>
                <div class="d-flex justify-content-between">
                  <span>Importe:</span>
                  <strong>{{ formatCurrency(item.importe) }}</strong>
                </div>
                <div class="d-flex justify-content-between">
                  <span>Periodos:</span>
                  <strong>{{ formatNumber(item.periodos) }}</strong>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Resultados por Mercado -->
    <div v-if="resultados.length && !loading" class="municipal-card">
      <div class="municipal-card-header bg-light d-flex justify-content-between align-items-center">
        <div>
          <h5 class="mb-0"><i class="fas fa-table"></i> Detalle por Mercado</h5>
          <span class="badge-primary">{{ resultados.length}} mercados</span>
        </div>
      </div>
      <div class="municipal-card-body table-responsive">
        <table class="municipal-table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th rowspan="2" class="align-middle">Mercado</th>
              <th rowspan="2" class="align-middle">Nombre</th>
              <th colspan="3" class="text-center bg-success text-white">Pagados</th>
              <th colspan="3" class="text-center bg-info text-white">Capturados</th>
              <th colspan="3" class="text-center bg-danger text-white">Adeudos</th>
            </tr>
            <tr>
              <th class="text-center">Locales</th>
              <th class="text-center">Importe</th>
              <th class="text-center">Periodos</th>
              <th class="text-center">Locales</th>
              <th class="text-center">Importe</th>
              <th class="text-center">Periodos</th>
              <th class="text-center">Locales</th>
              <th class="text-center">Importe</th>
              <th class="text-center">Periodos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.num_mercado">
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.descripcion }}</td>
              <td class="text-end">{{ formatNumber(row.localpag) }}</td>
              <td class="text-end">{{ formatCurrency(row.pagospag) }}</td>
              <td class="text-end">{{ formatNumber(row.periodospag) }}</td>
              <td class="text-end">{{ formatNumber(row.localcap) }}</td>
              <td class="text-end">{{ formatCurrency(row.pagoscap) }}</td>
              <td class="text-end">{{ formatNumber(row.periodoscap) }}</td>
              <td class="text-end">{{ formatNumber(row.localade) }}</td>
              <td class="text-end">{{ formatCurrency(row.pagosade) }}</td>
              <td class="text-end">{{ formatNumber(row.periodosade) }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div class="card-footer">
        <div class="row align-items-center">
          <div class="col-md-6">
            <label class="me-2">Mostrar:</label>
            <select v-model.number="pageSize" class="form-select form-select-sm d-inline-block w-auto">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
            </select>
            <span class="ms-2">registros por página</span>
          </div>
          <div class="col-md-6 text-end">
            <button class="btn btn-sm btn-outline-secondary me-1" @click="currentPage--" :disabled="currentPage === 1">
              <i class="fas fa-chevron-left"></i>
            </button>
            <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
            <button class="btn btn-sm btn-outline-secondary ms-1" @click="currentPage++" :disabled="currentPage === totalPages">
              <i class="fas fa-chevron-right"></i>
            </button>
          </div>
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

// Referencias reactivas
const filters = ref({
  recaudadora: '',
  axo: new Date().getFullYear(),
  mes: new Date().getMonth() + 1,
  fechaDesde: '',
  fechaHasta: ''
});

const recaudadoras = ref([]);
const resultados = ref([]);
const resumen = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const mostrarFiltros = ref(true);

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

// Catálogos
const meses = ref([
  { value: 1, label: 'Enero' },
  { value: 2, label: 'Febrero' },
  { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' },
  { value: 5, label: 'Mayo' },
  { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' },
  { value: 8, label: 'Agosto' },
  { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' },
  { value: 11, label: 'Noviembre' },
  { value: 12, label: 'Diciembre' }
]);

// Computed
const totalPages = computed(() => Math.ceil(resultados.value.length / pageSize.value) || 1);

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return resultados.value.slice(start, end);
});

// Métodos
const fetchRecaudadoras = async () => {
  showLoading('Cargando Estadísticas de Pagos y Adeudos', 'Preparando oficinas recaudadoras...');
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
    showToast('Error al cargar recaudadoras', 'error');
  } finally {
    hideLoading();
  }
};

const onRecaudadoraChange = () => {
  // Lógica adicional si se requiere
};

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;

  try {
    // Consultar detalle
    const responseDetalle = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_estad_pagosyadeudos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(filters.value.recaudadora) },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_mes', Valor: parseInt(filters.value.mes) },
          { Nombre: 'p_fec3', Valor: filters.value.fechaDesde },
          { Nombre: 'p_fec4', Valor: filters.value.fechaHasta }
        ]
      }
    });

    // Consultar resumen
    const responseResumen = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_estad_pagosyadeudos_resumen',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(filters.value.recaudadora) },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_mes', Valor: parseInt(filters.value.mes) },
          { Nombre: 'p_fec3', Valor: filters.value.fechaDesde },
          { Nombre: 'p_fec4', Valor: filters.value.fechaHasta }
        ]
      }
    });

    if (responseDetalle.data.eResponse?.success && responseDetalle.data.eResponse?.data?.result) {
      resultados.value = agruparPorMercado(responseDetalle.data.eResponse.data.result);
      busquedaRealizada.value = true;
      currentPage.value = 1;
    }

    if (responseResumen.data.eResponse?.success && responseResumen.data.eResponse?.data?.result) {
      resumen.value = responseResumen.data.eResponse.data.result;
    }

    if (resultados.value.length === 0) {
      showToast('No se encontraron resultados', 'warning');
    }
  } catch (error) {
    showToast('Error al consultar', 'error');
    resultados.value = [];
    resumen.value = [];
  } finally {
    loading.value = false;
  }
};

const agruparPorMercado = (data) => {
  const grupos = {};

  data.forEach(row => {
    if (!grupos[row.num_mercado]) {
      grupos[row.num_mercado] = {
        num_mercado: row.num_mercado,
        descripcion: row.descripcion,
        localpag: 0,
        pagospag: 0,
        periodospag: 0,
        localcap: 0,
        pagoscap: 0,
        periodoscap: 0,
        localade: 0,
        pagosade: 0,
        periodosade: 0
      };
    }

    grupos[row.num_mercado].localpag += row.localpag || 0;
    grupos[row.num_mercado].pagospag += parseFloat(row.pagospag || 0);
    grupos[row.num_mercado].periodospag += row.periodospag || 0;
    grupos[row.num_mercado].localcap += row.localcap || 0;
    grupos[row.num_mercado].pagoscap += parseFloat(row.pagoscap || 0);
    grupos[row.num_mercado].periodoscap += row.periodoscap || 0;
    grupos[row.num_mercado].localade += row.localade || 0;
    grupos[row.num_mercado].pagosade += parseFloat(row.pagosade || 0);
    grupos[row.num_mercado].periodosade += row.periodosade || 0;
  });

  return Object.values(grupos);
};

const limpiarFiltros = () => {
  filters.value = {
    recaudadora: '',
    axo: new Date().getFullYear(),
    mes: new Date().getMonth() + 1,
    fechaDesde: '',
    fechaHasta: ''
  };
  resultados.value = [];
  resumen.value = [];
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
  if (value == null) return '0';
  return new Intl.NumberFormat('es-MX').format(value);
};

const exportarExcel = () => {
  const data = resultados.value.map(row => ({
    'Mercado': row.num_mercado,
    'Nombre': row.descripcion,
    'Locales Pagados': row.localpag,
    'Importe Pagado': row.pagospag,
    'Periodos Pagados': row.periodospag,
    'Locales Capturados': row.localcap,
    'Importe Capturado': row.pagoscap,
    'Periodos Capturados': row.periodoscap,
    'Locales Adeudo': row.localade,
    'Importe Adeudo': row.pagosade,
    'Periodos Adeudo': row.periodosade
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `estadistica_pagos_adeudos_${filters.value.axo}_${filters.value.mes}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const showToast = (message, type = 'info') => {
  // Implementación simple de toast
  // alert(message);
};

// Lifecycle
onMounted(() => {
  fetchRecaudadoras();
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
.sticky-top {
  position: sticky;
  top: 0;
  background-color: #f8f9fa;
  z-index: 10;
}

@media print {
  .card-header,
  .card-footer,
  .breadcrumb,
  button,
  .no-print {
    display: none !important;
  }

  table {
    font-size: 10px;
  }
}
</style>
