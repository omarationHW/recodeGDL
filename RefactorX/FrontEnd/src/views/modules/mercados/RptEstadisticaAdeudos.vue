<template>
  <div class="module-view mt-3">
    <!-- Breadcrumb -->
    <div class="mb-3">
      <span class="text-muted">Inicio / Mercados / Estadística de Adeudos</span>
    </div>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-chart-line"></i> Estadística Global de Adeudos Vencidos</h2>
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header municipal-bg-primary text-white" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
        <i :class="mostrarFiltros ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
        Filtros de Consulta
      </div>
      <div class="municipal-card-body" v-show="mostrarFiltros">
        <form @submit.prevent="consultar">
          <div class="row">
            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Año <span class="text-danger">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control" min="1990" :max="new Date().getFullYear() + 1" required />
            </div>

            <div class="col-md-2 mb-3">
              <label class="municipal-form-label">Periodo (Mes) <span class="text-danger">*</span></label>
              <select v-model.number="filters.periodo" class="municipal-form-control" required>
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>

            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Importe mínimo</label>
              <input type="number" v-model.number="filters.importe" class="municipal-form-control" step="0.01" min="0" />
              <small class="text-muted">Deje en 0 para todos los adeudos</small>
            </div>

            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Tipo de Reporte <span class="text-danger">*</span></label>
              <select v-model.number="filters.opc" class="municipal-form-control" required>
                <option :value="1">Global (Todos)</option>
                <option :value="2">Solo mayores o iguales a importe</option>
              </select>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn-municipal-primary" :disabled="loading">
              <i class="fas fa-search"></i> Consultar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros">
              <i class="fas fa-eraser"></i> Limpiar
            </button>
            <button type="button" class="btn-municipal-primary" @click="exportarExcel" :disabled="!resultados.length">
              <i class="fas fa-file-excel"></i> Exportar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border municipal-text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-2">Cargando estadísticas...</p>
    </div>

    <!-- Sin búsqueda -->
    <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
      <i class="fas fa-info-circle"></i> Seleccione los filtros y haga clic en <strong>Consultar</strong> para ver las estadísticas de adeudos.
    </div>

    <!-- Sin resultados -->
    <div v-if="busquedaRealizada && !resultados.length && !loading" class="municipal-alert municipal-alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron adeudos con los criterios seleccionados.
    </div>

    <!-- Tabla de Resultados -->
    <div v-if="resultados.length && !loading" class="municipal-card">
      <div class="municipal-card-header municipal-bg-light d-flex justify-content-between align-items-center">
        <div>
          <h5 class="mb-0">{{ tituloReporte }}</h5>
          <span class="badge-primary me-2">{{ resultados.length }} registros</span>
          <span class="badge-danger">Total Adeudo: {{ formatCurrency(totalAdeudo) }}</span>
        </div>
      </div>
      <div class="municipal-card-body table-responsive">
        <table class="municipal-table table-bordered table-hover table-sm">
          <thead class="municipal-table-header sticky-top">
            <tr>
              <th>Oficina</th>
              <th>Mercado</th>
              <th>Local</th>
              <th>Nombre Mercado</th>
              <th class="text-end">Importe Adeudo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="`${row.oficina}-${row.num_mercado}-${row.local}`">
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.descripcion }}</td>
              <td class="text-end fw-bold">{{ formatCurrency(row.adeudo) }}</td>
            </tr>
          </tbody>
          <tfoot class="municipal-table-footer">
            <tr>
              <th colspan="4" class="text-end">Total:</th>
              <th class="text-end">{{ formatCurrency(totalAdeudo) }}</th>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Paginación -->
      <div class="municipal-card-footer">
        <div class="row align-items-center">
          <div class="col-md-6">
            <label class="me-2">Mostrar:</label>
            <select v-model.number="pageSize" class="municipal-form-control d-inline-block w-auto">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
              <option :value="250">250</option>
            </select>
            <span class="ms-2">registros por página</span>
          </div>
          <div class="col-md-6 text-end">
            <button class="btn-municipal-secondary btn-sm me-1" @click="currentPage--" :disabled="currentPage === 1">
              <i class="fas fa-chevron-left"></i>
            </button>
            <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
            <button class="btn-municipal-secondary btn-sm ms-1" @click="currentPage++" :disabled="currentPage === totalPages">
              <i class="fas fa-chevron-right"></i>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import axios from 'axios';

// Referencias reactivas
const filters = ref({
  axo: new Date().getFullYear(),
  periodo: 1,
  importe: 0,
  opc: 1
});

const resultados = ref([]);
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

const totalAdeudo = computed(() => {
  return resultados.value.reduce((sum, row) => sum + (parseFloat(row.adeudo) || 0), 0);
});

const tituloReporte = computed(() => {
  if (filters.value.opc === 1) {
    return `Estadística Global de Adeudos Vencidos al Periodo: ${filters.value.axo}-${filters.value.periodo}`;
  } else {
    return `Estadística de Adeudos Vencidos al Periodo: ${filters.value.axo}-${filters.value.periodo} (Mayor o Igual a ${formatCurrency(filters.value.importe)})`;
  }
});

// Métodos
const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'rpt_estadistica_adeudos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) },
          { Nombre: 'p_importe', Valor: parseFloat(filters.value.importe) || 0 },
          { Nombre: 'p_opc', Valor: parseInt(filters.value.opc) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      resultados.value = response.data.eResponse.data.result;
      busquedaRealizada.value = true;
      currentPage.value = 1;

      if (resultados.value.length > 0) {
        showToast(`Se encontraron ${resultados.value.length} registros con adeudos`, 'success');
      }
    } else {
      resultados.value = [];
      busquedaRealizada.value = true;
      showToast('No se encontraron resultados', 'warning');
    }
  } catch (error) {
    showToast('Error al consultar', 'error');
    resultados.value = [];
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    axo: new Date().getFullYear(),
    periodo: 1,
    importe: 0,
    opc: 1
  };
  resultados.value = [];
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
  const data = resultados.value.map(row => ({
    'Oficina': row.oficina,
    'Mercado': row.num_mercado,
    'Local': row.local,
    'Nombre Mercado': row.descripcion,
    'Importe Adeudo': row.adeudo
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `estadistica_adeudos_${filters.value.axo}_${filters.value.periodo}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const showToast = (message, type = 'info') => {
  // alert(message);
};
</script>

<style scoped>
@import '@/styles/municipal-theme.css';

.sticky-top {
  position: sticky;
  top: 0;
  background-color: #f8f9fa;
  z-index: 10;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

@media print {
  .municipal-card-header,
  .municipal-card-footer,
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
