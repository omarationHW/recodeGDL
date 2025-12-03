<template>
  <div class="container-fluid mt-3">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/mercados">Mercados</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Ingreso Zonificado</li>
      </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-map-marked-alt"></i> Reporte de Ingreso Zonificado</h2>
    </div>

    <div class="card mb-3">
      <div class="card-header bg-primary text-white" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
        <i :class="mostrarFiltros ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
        Filtros de Consulta
      </div>
      <div class="card-body" v-show="mostrarFiltros">
        <form @submit.prevent="consultar">
          <div class="row">
            <div class="col-md-4 mb-3">
              <label class="form-label">Fecha Desde <span class="text-danger">*</span></label>
              <input type="date" v-model="filters.fecdesde" class="form-control" required />
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">Fecha Hasta <span class="text-danger">*</span></label>
              <input type="date" v-model="filters.fechasta" class="form-control" required />
            </div>
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn btn-primary" :disabled="loading">
              <i class="fas fa-search"></i> Consultar
            </button>
            <button type="button" class="btn btn-secondary" @click="limpiarFiltros">
              <i class="fas fa-eraser"></i> Limpiar
            </button>
            <button type="button" class="btn btn-outline-success" @click="exportarExcel" :disabled="!resultados.length">
              <i class="fas fa-file-excel"></i> Exportar
            </button>
          </div>
        </form>
      </div>
    </div>

    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-2">Cargando reporte...</p>
    </div>

    <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
      <i class="fas fa-info-circle"></i> Seleccione las fechas y haga clic en <strong>Consultar</strong>.
    </div>

    <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron registros para el período seleccionado.
    </div>

    <div v-if="resultados.length && !loading" class="card">
      <div class="card-header bg-light d-flex justify-content-between align-items-center">
        <div>
          <span class="badge bg-primary me-2">{{ resultados.length }} zonas</span>
          <span class="badge bg-success">Total: {{ formatCurrency(totalIngreso) }}</span>
        </div>
        <div class="text-muted">
          <small>Período: {{ filters.fecdesde }} al {{ filters.fechasta }}</small>
        </div>
      </div>
      <div class="card-body table-responsive">
        <table class="table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th style="width: 10%">Zona ID</th>
              <th style="width: 60%">Zona</th>
              <th style="width: 30%" class="text-end">Ingreso</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.id_zona">
              <td>{{ row.id_zona }}</td>
              <td>{{ row.zona }}</td>
              <td class="text-end fw-bold">{{ formatCurrency(row.pagado) }}</td>
            </tr>
          </tbody>
          <tfoot class="table-light">
            <tr>
              <th colspan="2" class="text-end">TOTAL:</th>
              <th class="text-end">{{ formatCurrency(totalIngreso) }}</th>
            </tr>
          </tfoot>
        </table>
      </div>

      <div class="card-footer">
        <div class="row align-items-center">
          <div class="col-md-6">
            <label class="me-2">Mostrar:</label>
            <select v-model.number="pageSize" class="form-select form-select-sm d-inline-block w-auto">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
              <option :value="250">250</option>
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

const filters = ref({
  fecdesde: '',
  fechasta: ''
});

const resultados = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const mostrarFiltros = ref(true);
const currentPage = ref(1);
const pageSize = ref(25);

const totalPages = computed(() => Math.ceil(resultados.value.length / pageSize.value) || 1);
const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return resultados.value.slice(start, start + pageSize.value);
});
const totalIngreso = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.pagado) || 0), 0));

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_ingreso_zonificado',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_fecdesde', Valor: filters.value.fecdesde },
          { Nombre: 'p_fechasta', Valor: filters.value.fechasta }
        ]
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      resultados.value = response.data.eResponse.data.result;
      busquedaRealizada.value = true;
      currentPage.value = 1;
    } else {
      resultados.value = [];
      busquedaRealizada.value = true;
    }
  } catch (error) {
    console.error('Error al consultar:', error);
    alert('Error al consultar el reporte');
    resultados.value = [];
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    fecdesde: '',
    fechasta: ''
  };
  resultados.value = [];
  busquedaRealizada.value = false;
  currentPage.value = 1;
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const exportarExcel = () => {
  const csv = [
    'Zona ID,Zona,Ingreso',
    ...resultados.value.map(r => `${r.id_zona},${r.zona},${r.pagado}`)
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `ingreso_zonificado_${filters.value.fecdesde}_${filters.value.fechasta}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

onMounted(() => {
  // Set default dates (current month)
  const today = new Date();
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
  filters.value.fecdesde = firstDay.toISOString().split('T')[0];
  filters.value.fechasta = today.toISOString().split('T')[0];
});
</script>

<style scoped>
.sticky-top {
  position: sticky;
  top: 0;
  background-color: #f8f9fa;
  z-index: 10;
}

@media print {
  .card-header, .card-footer, .breadcrumb, button { display: none !important; }
  table { font-size: 10px; }
}
</style>
