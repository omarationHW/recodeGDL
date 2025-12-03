<template>
  <div class="container-fluid mt-3">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/mercados">Mercados</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Factura Energía</li>
      </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-bolt"></i> Reporte de Factura de Energía</h2>
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
            <div class="col-md-3 mb-3">
              <label class="form-label">Año <span class="text-danger">*</span></label>
              <input type="number" v-model.number="filters.axo" class="form-control" min="1990" :max="new Date().getFullYear() + 1" required />
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Periodo <span class="text-danger">*</span></label>
              <select v-model.number="filters.periodo" class="form-select" required>
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
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
      <p class="mt-2">Cargando reporte...</p>
    </div>

    <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
      <i class="fas fa-info-circle"></i> Seleccione los filtros y haga clic en <strong>Consultar</strong>.
    </div>

    <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron registros.
    </div>

    <div v-if="resultados.length && !loading" class="card">
      <div class="card-header bg-light d-flex justify-content-between align-items-center">
        <div>
          <span class="badge bg-primary me-2">{{ resultados.length }} locales</span>
          <span class="badge bg-success">Total KW: {{ formatNumber(totalCantidad) }}</span>
          <span class="badge bg-danger ms-2">Total: {{ formatCurrency(totalImporte1) }}</span>
        </div>
      </div>
      <div class="card-body table-responsive">
        <table class="table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th>Nombre</th>
              <th>Local</th>
              <th>Bloque</th>
              <th class="text-end">KW</th>
              <th class="text-end">Costo KW/HR</th>
              <th>Local Adicional</th>
              <th class="text-end">Importe</th>
              <th class="text-end">Importe Total</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="`${row.oficina}-${row.num_mercado}-${row.local}`">
              <td>{{ row.nombre }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.bloque }}</td>
              <td class="text-end">{{ formatNumber(row.cantidad) }}</td>
              <td class="text-end">{{ formatCurrency(row.importe) }}</td>
              <td>{{ row.local_adicional }}</td>
              <td class="text-end">{{ formatCurrency(row.importe) }}</td>
              <td class="text-end fw-bold">{{ formatCurrency(row.importe_1) }}</td>
            </tr>
          </tbody>
          <tfoot class="table-light">
            <tr>
              <th colspan="3" class="text-end">Totales:</th>
              <th class="text-end">{{ formatNumber(totalCantidad) }}</th>
              <th></th>
              <th></th>
              <th></th>
              <th class="text-end">{{ formatCurrency(totalImporte1) }}</th>
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
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1
});

const recaudadoras = ref([]);
const mercados = ref([]);
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
const totalCantidad = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.cantidad) || 0), 0));
const totalImporte1 = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.importe_1) || 0), 0));

const fetchRecaudadoras = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: { Operacion: 'sp_get_recaudadoras', Base: 'mercados', Parametros: [] }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
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
    alert('Error al cargar mercados');
  }
};

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'rpt_factura_energia',
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
      resultados.value = response.data.eResponse.data.result;
      busquedaRealizada.value = true;
      currentPage.value = 1;
    } else {
      resultados.value = [];
      busquedaRealizada.value = true;
    }
  } catch (error) {
    alert('Error al consultar');
    resultados.value = [];
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    oficina: '',
    mercado: '',
    axo: new Date().getFullYear(),
    periodo: new Date().getMonth() + 1
  };
  mercados.value = [];
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

const exportarExcel = () => {
  const csv = [
    'Nombre,Local,Bloque,KW,Costo KW/HR,Local Adicional,Importe,Importe Total',
    ...resultados.value.map(r => `${r.nombre},${r.seccion},${r.bloque},${r.cantidad},${r.importe},${r.local_adicional},${r.importe},${r.importe_1}`)
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `factura_energia_${filters.value.axo}_${filters.value.periodo}.csv`;
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
