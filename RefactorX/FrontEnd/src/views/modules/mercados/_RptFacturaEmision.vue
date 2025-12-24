<template>
  <div class="container-fluid mt-3">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/mercados">Mercados</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Facturación de Estados de Cuenta</li>
      </ol>
    </nav>

    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-file-invoice-dollar"></i> Facturación de Estados de Cuenta</h2>
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
              <label class="form-label">Recaudadora <span class="text-danger">*</span></label>
              <select v-model="filters.oficina" class="form-select" @change="onOficinaChange" required>
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="form-label">Mercado <span class="text-danger">*</span></label>
              <select v-model="filters.mercado" class="form-select" required :disabled="!mercados.length">
                <option value="">Seleccione...</option>
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-2 mb-3">
              <label class="form-label">Año <span class="text-danger">*</span></label>
              <input type="number" v-model.number="filters.axo" class="form-control" min="1990" :max="new Date().getFullYear() + 1" required />
            </div>
            <div class="col-md-2 mb-3">
              <label class="form-label">Periodo <span class="text-danger">*</span></label>
              <select v-model.number="filters.periodo" class="form-select" required>
                <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
              </select>
            </div>
            <div class="col-md-3 mb-3">
              <label class="form-label">Opción <span class="text-danger">*</span></label>
              <select v-model.number="filters.opc" class="form-select" required>
                <option :value="1">Solo mercado seleccionado</option>
                <option :value="2">Todos los mercados</option>
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
      <p class="mt-2">Cargando facturación...</p>
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
          <span class="badge bg-primary me-2">{{ resultados.length }} registros</span>
          <span class="badge bg-success">Total: {{ formatCurrency(totalImporte) }}</span>
        </div>
      </div>
      <div class="card-body table-responsive">
        <table class="table table-bordered table-hover table-sm">
          <thead class="table-light sticky-top">
            <tr>
              <th>Datos Local</th>
              <th>Nombre</th>
              <th>Descripción</th>
              <th class="text-end">Superficie</th>
              <th class="text-end">Importe Cuota</th>
              <th class="text-end">Importe</th>
              <th>Recaudadora</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.datoslocal">
              <td>{{ row.datoslocal }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.descripcion }}</td>
              <td class="text-end">{{ formatNumber(row.superficie) }}</td>
              <td class="text-end">{{ formatCurrency(row.importe_cuota) }}</td>
              <td class="text-end fw-bold">{{ formatCurrency(row.importe) }}</td>
              <td>{{ row.recaudadora }}</td>
            </tr>
          </tbody>
          <tfoot class="table-light">
            <tr>
              <th colspan="5" class="text-end">Total:</th>
              <th class="text-end">{{ formatCurrency(totalImporte) }}</th>
              <th></th>
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

  <DocumentationModal :show="showAyuda" :component-name="'_RptFacturaEmision'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - _RptFacturaEmision'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'_RptFacturaEmision'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - _RptFacturaEmision'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


const filters = ref({
  oficina: '',
  mercado: '',
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1,
  opc: 1
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

const totalPages = computed(() => Math.ceil(resultados.value.length / pageSize.value) || 1);
const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return resultados.value.slice(start, start + pageSize.value);
});
const totalImporte = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.importe) || 0), 0));

const fetchRecaudadoras = async () => {
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
    alert('Error al cargar recaudadoras');
  }
};

const onOficinaChange = async () => {
  filters.value.mercado = '';
  mercados.value = [];
  if (!filters.value.oficina) return;
  try {
    const response = await apiService.execute(
          'sp_get_mercados_by_recaudadora',
          'mercados',
          [{ nombre: 'p_oficina', valor: parseInt(filters.value.oficina) }],
          '',
          null,
          'publico'
        );
    if (response?.success && response?.data?.result) {
      mercados.value = response.data.result;
    }
  } catch (error) {
    alert('Error al cargar mercados');
  }
};

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;
  try {
    const response = await apiService.execute(
          'sp_rpt_factura_emision',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(filters.value.oficina) },
          { nombre: 'p_axo', valor: parseInt(filters.value.axo) },
          { nombre: 'p_periodo', valor: parseInt(filters.value.periodo) },
          { nombre: 'p_mercado', valor: parseInt(filters.value.mercado) },
          { nombre: 'p_opc', valor: parseInt(filters.value.opc) }
        ],
          '',
          null,
          'publico'
        );
    if (response?.success && response?.data?.result) {
      resultados.value = response.data.result;
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
    periodo: new Date().getMonth() + 1,
    opc: 1
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
    'Datos Local,Nombre,Descripción,Superficie,Importe Cuota,Importe,Recaudadora',
    ...resultados.value.map(r => `${r.datoslocal},${r.nombre},${r.descripcion},${r.superficie},${r.importe_cuota},${r.importe},${r.recaudadora}`)
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `factura_emision_${filters.value.axo}_${filters.value.periodo}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

onMounted(() => {
  fetchRecaudadoras();
});
</script>
