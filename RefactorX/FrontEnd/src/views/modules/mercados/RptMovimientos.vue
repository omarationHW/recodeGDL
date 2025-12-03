<template>
  <div class="container-fluid mt-3">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/mercados">Mercados</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Movimientos de Locales</li>
      </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-exchange-alt"></i> Reporte de Movimientos de Locales</h2>
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
              <label class="form-label">Recaudadora <span class="text-danger">*</span></label>
              <select v-model.number="filters.recaudadora" class="form-select" required>
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">Fecha Desde <span class="text-danger">*</span></label>
              <input type="date" v-model="filters.fechaDesde" class="form-control" required />
            </div>
            <div class="col-md-4 mb-3">
              <label class="form-label">Fecha Hasta <span class="text-danger">*</span></label>
              <input type="date" v-model="filters.fechaHasta" class="form-control" required />
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
      <p class="mt-2">Cargando movimientos...</p>
    </div>

    <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
      <i class="fas fa-info-circle"></i> Seleccione recaudadora y fechas, luego haga clic en <strong>Consultar</strong>.
    </div>

    <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron movimientos en el período seleccionado.
    </div>

    <div v-if="resultados.length && !loading" class="card">
      <div class="card-header bg-light d-flex justify-content-between align-items-center">
        <div>
          <span class="badge bg-primary me-2">{{ resultados.length }} movimientos</span>
          <span class="badge bg-info">{{ contadorPorTipo.length }} tipos diferentes</span>
        </div>
        <div class="text-muted">
          <small>Del {{ filters.fechaDesde }} al {{ filters.fechaHasta }}</small>
        </div>
      </div>
      <div class="card-body table-responsive">
        <table class="table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th>Fecha</th>
              <th>Oficina</th>
              <th>Mercado</th>
              <th>Categoría</th>
              <th>Local</th>
              <th>Bloque</th>
              <th>Tipo Movimiento</th>
              <th>Nombre</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.id_movimiento">
              <td>{{ formatFecha(row.fecha) }}</td>
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.categoria }}</td>
              <td>{{ row.seccion }}-{{ row.local }}{{ row.letra_local }}</td>
              <td>{{ row.bloque }}</td>
              <td>
                <span class="badge" :class="getBadgeClass(row.tipodescripcion)">
                  {{ row.tipodescripcion }}
                </span>
              </td>
              <td>{{ row.nombre }}</td>
            </tr>
          </tbody>
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
  recaudadora: '',
  fechaDesde: '',
  fechaHasta: ''
});

const recaudadoras = ref([]);
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

const contadorPorTipo = computed(() => {
  const tipos = new Set(resultados.value.map(r => r.tipodescripcion));
  return Array.from(tipos);
});

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

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_movimientos_locales',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_fecha_desde', Valor: filters.value.fechaDesde },
          { Nombre: 'p_fecha_hasta', Valor: filters.value.fechaHasta },
          { Nombre: 'p_recaudadora_id', Valor: parseInt(filters.value.recaudadora) }
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
    alert('Error al consultar movimientos');
    resultados.value = [];
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    recaudadora: '',
    fechaDesde: '',
    fechaHasta: ''
  };
  resultados.value = [];
  busquedaRealizada.value = false;
  currentPage.value = 1;
};

const formatFecha = (fecha) => {
  if (!fecha) return '';
  return new Date(fecha).toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
};

const getBadgeClass = (tipo) => {
  const map = {
    'ALTA': 'bg-success',
    'BAJA TOTAL': 'bg-danger',
    'BAJA ADMINISTRATIVA': 'bg-danger',
    'BAJA POR ACUERDO': 'bg-danger',
    'REACTIVACION': 'bg-success',
    'REACTIVAR BLOQUEO': 'bg-success',
    'BLOQUEADO': 'bg-warning',
    'CAMBIO DE GIRO': 'bg-info',
    'CAMBIO FECHA ALTA': 'bg-info',
    'CAMBIO NOMBRE LOC.': 'bg-info',
    'CAMBIO DOMICILIO': 'bg-info',
    'CAMBIO DE ZONA': 'bg-info',
    'CAMBIO LOCAL,SUPERF.': 'bg-info'
  };
  return map[tipo] || 'bg-secondary';
};

const exportarExcel = () => {
  const csv = [
    'Fecha,Oficina,Mercado,Categoría,Local,Bloque,Tipo Movimiento,Nombre',
    ...resultados.value.map(r =>
      `${formatFecha(r.fecha)},${r.oficina},${r.num_mercado},${r.categoria},${r.seccion}-${r.local}${r.letra_local},${r.bloque},${r.tipodescripcion},${r.nombre}`
    )
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `movimientos_locales_${filters.value.fechaDesde}_${filters.value.fechaHasta}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

onMounted(() => {
  fetchRecaudadoras();

  // Set default dates (current month)
  const today = new Date();
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
  filters.value.fechaDesde = firstDay.toISOString().split('T')[0];
  filters.value.fechaHasta = today.toISOString().split('T')[0];
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
