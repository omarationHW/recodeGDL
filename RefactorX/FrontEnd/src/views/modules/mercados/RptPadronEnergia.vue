<template>
  <div class="container-fluid mt-3">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/mercados">Mercados</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón Energía</li>
      </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-bolt"></i> Padrón de Energía Eléctrica del Mercado</h2>
    </div>

    <div class="card mb-3">
      <div class="card-header bg-primary text-white" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
        <i :class="mostrarFiltros ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
        Filtros de Consulta
      </div>
      <div class="card-body" v-show="mostrarFiltros">
        <form @submit.prevent="consultar">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="form-label">Recaudadora <span class="text-danger">*</span></label>
              <select v-model="filters.oficina" class="form-select" @change="onOficinaChange" required>
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Mercado <span class="text-danger">*</span></label>
              <select v-model="filters.mercado" class="form-select" required :disabled="!mercados.length">
                <option value="">Seleccione...</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
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
      <p class="mt-2">Cargando padrón...</p>
    </div>

    <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
      <i class="fas fa-info-circle"></i> Seleccione recaudadora y mercado, luego haga clic en <strong>Consultar</strong>.
    </div>

    <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron registros de energía para este mercado.
    </div>

    <div v-if="resultados.length && !loading" class="card">
      <div class="card-header bg-light d-flex justify-content-between align-items-center">
        <div>
          <span class="badge bg-primary me-2">{{ resultados.length }} locales</span>
          <span class="badge bg-success">Total KW: {{ formatNumber(totalCantidad) }}</span>
        </div>
        <div class="text-muted">
          <small v-if="mercadoDescripcion">{{ mercadoDescripcion }}</small>
        </div>
      </div>
      <div class="card-body table-responsive">
        <table class="table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th>ID Local</th>
              <th>Datos del Local</th>
              <th>Nombre</th>
              <th>Locales Adicionales</th>
              <th class="text-end">K / Cuota</th>
              <th class="text-center">Vigencia</th>
              <th class="text-center">F/K</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.id_local">
              <td class="text-end">{{ row.id_local }}</td>
              <td>{{ row.datoslocal }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.local_adicional }}</td>
              <td class="text-end">{{ formatNumber(row.cantidad) }}</td>
              <td class="text-center">{{ row.vigencia }}</td>
              <td class="text-center">{{ row.cve_consumo }}</td>
            </tr>
          </tbody>
          <tfoot class="table-light">
            <tr>
              <th colspan="4" class="text-end">Totales:</th>
              <th class="text-end">{{ formatNumber(totalCantidad) }}</th>
              <th colspan="2"></th>
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
  oficina: '',
  mercado: ''
});

const recaudadoras = ref([]);
const mercados = ref([]);
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
const totalCantidad = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.cantidad) || 0), 0));
const mercadoDescripcion = computed(() => resultados.value.length > 0 ? resultados.value[0].descripcion : '');

const fetchRecaudadoras = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'mercados', Parametros: [] }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
    alert('Error al cargar recaudadoras');
  }
};

const onOficinaChange = async () => {
  filters.value.mercado = '';
  mercados.value = [];
  if (!filters.value.oficina) return;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'mercados',
        Parametros: [{ Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) }]
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    alert('Error al cargar mercados');
  }
};

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'rpt_padron_energia',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) }
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
    alert('Error al consultar el padrón');
    resultados.value = [];
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    oficina: '',
    mercado: ''
  };
  mercados.value = [];
  resultados.value = [];
  busquedaRealizada.value = false;
  currentPage.value = 1;
};

const formatNumber = (value) => {
  if (value == null) return '0';
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value);
};

const exportarExcel = () => {
  const csv = [
    'ID Local,Datos Local,Nombre,Locales Adicionales,K/Cuota,Vigencia,F/K',
    ...resultados.value.map(r =>
      `${r.id_local},${r.datoslocal},${r.nombre},${r.local_adicional},${r.cantidad},${r.vigencia},${r.cve_consumo}`
    )
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `padron_energia_${filters.value.oficina}_${filters.value.mercado}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

onMounted(() => {
  fetchRecaudadoras();
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
