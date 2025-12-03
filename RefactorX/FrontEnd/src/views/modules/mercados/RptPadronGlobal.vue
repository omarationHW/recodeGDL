<template>
  <div class="container-fluid mt-3">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/mercados">Mercados</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón Global</li>
      </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-users"></i> Padrón Global de Locales</h2>
    </div>

    <div class="card mb-3">
      <div class="card-header bg-primary text-white" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
        <i :class="mostrarFiltros ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
        Filtros de Consulta
      </div>
      <div class="card-body" v-show="mostrarFiltros">
        <form @submit.prevent="consultar">
          <div class="row">
            <div class="col-md-2 mb-3">
              <label class="form-label">Año <span class="text-danger">*</span></label>
              <input type="number" v-model.number="filters.year" class="form-control" min="1990" :max="new Date().getFullYear() + 1" required />
            </div>
            <div class="col-md-2 mb-3">
              <label class="form-label">Mes <span class="text-danger">*</span></label>
              <select v-model.number="filters.month" class="form-select" required>
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Estatus <span class="text-danger">*</span></label>
              <select v-model="filters.status" class="form-select" required>
                <option value="A">Vigentes</option>
                <option value="B">Baja</option>
                <option value="C">Baja por Acuerdo</option>
                <option value="D">Baja Administrativa</option>
                <option value="T">Todos</option>
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
      <p class="mt-2">Cargando padrón global...</p>
    </div>

    <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
      <i class="fas fa-info-circle"></i> Seleccione año, mes y estatus, luego haga clic en <strong>Consultar</strong>.
    </div>

    <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron locales con los criterios seleccionados.
    </div>

    <div v-if="resultados.length && !loading" class="card">
      <div class="card-header bg-light d-flex justify-content-between align-items-center">
        <div>
          <span class="badge bg-primary me-2">{{ resultados.length }} locales</span>
          <span class="badge bg-success me-2">Al corriente: {{ localesAlCorriente }}</span>
          <span class="badge bg-danger">Con adeudo: {{ localesConAdeudo }}</span>
        </div>
        <div class="text-muted">
          <small>Año {{ filters.year }} - Mes {{ meses[filters.month - 1].label }}</small>
        </div>
      </div>
      <div class="card-body table-responsive">
        <table class="table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th>Registro</th>
              <th>Nombre</th>
              <th class="text-end">Superficie</th>
              <th class="text-end">Renta</th>
              <th class="text-center">Estatus</th>
              <th>Descripción Local</th>
              <th class="text-center">Adeudo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.id_local">
              <td>{{ row.registro }}</td>
              <td>{{ row.nombre }}</td>
              <td class="text-end">{{ formatNumber(row.superficie) }}</td>
              <td class="text-end">{{ formatCurrency(row.renta) }}</td>
              <td class="text-center">
                <span class="badge" :class="getBadgeVigencia(row.vigencia)">
                  {{ getTextoVigencia(row.vigencia) }}
                </span>
              </td>
              <td>{{ row.descripcion_local }}</td>
              <td class="text-center">
                <span class="badge" :class="row.adeudo === 1 ? 'bg-danger' : 'bg-success'">
                  {{ row.leyenda }}
                </span>
              </td>
            </tr>
          </tbody>
          <tfoot class="table-light">
            <tr>
              <th colspan="3" class="text-end">Totales:</th>
              <th class="text-end">{{ formatCurrency(totalRenta) }}</th>
              <th colspan="3"></th>
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
  year: new Date().getFullYear(),
  month: new Date().getMonth() + 1,
  status: 'A'
});

const resultados = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const mostrarFiltros = ref(true);
const currentPage = ref(1);
const pageSize = ref(25);

const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
]);

const totalPages = computed(() => Math.ceil(resultados.value.length / pageSize.value) || 1);
const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return resultados.value.slice(start, start + pageSize.value);
});
const totalRenta = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.renta) || 0), 0));
const localesAlCorriente = computed(() => resultados.value.filter(r => r.adeudo === 0).length);
const localesConAdeudo = computed(() => resultados.value.filter(r => r.adeudo === 1).length);

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_padron_global',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_year', Valor: parseInt(filters.value.year) },
          { Nombre: 'p_month', Valor: parseInt(filters.value.month) },
          { Nombre: 'p_status', Valor: filters.value.status }
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
    alert('Error al consultar el padrón global');
    resultados.value = [];
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    year: new Date().getFullYear(),
    month: new Date().getMonth() + 1,
    status: 'A'
  };
  resultados.value = [];
  busquedaRealizada.value = false;
  currentPage.value = 1;
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const formatNumber = (value) => {
  if (value == null) return '0';
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value);
};

const getBadgeVigencia = (vigencia) => {
  const map = {
    'A': 'bg-success',
    'B': 'bg-danger',
    'C': 'bg-warning',
    'D': 'bg-secondary'
  };
  return map[vigencia] || 'bg-info';
};

const getTextoVigencia = (vigencia) => {
  const map = {
    'A': 'Vigente',
    'B': 'Baja',
    'C': 'Baja Acuerdo',
    'D': 'Baja Admin'
  };
  return map[vigencia] || vigencia;
};

const exportarExcel = () => {
  const csv = [
    'Registro,Nombre,Superficie,Renta,Estatus,Descripción Local,Leyenda Adeudo',
    ...resultados.value.map(r =>
      `${r.registro},${r.nombre},${r.superficie},${r.renta},${getTextoVigencia(r.vigencia)},${r.descripcion_local},${r.leyenda}`
    )
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `padron_global_${filters.value.year}_${filters.value.month}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

onMounted(() => {
  // Component is ready
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
