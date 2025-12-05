<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Locales</h1>
        <p>Inicio > Mercados > Emisión de Recibos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="previsualizar" :disabled="loading">
          <font-awesome-icon icon="search" /> Previsualizar
        </button>
        <button class="btn-municipal-success" @click="emitirRecibos" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-invoice-dollar" /> Emitir Recibos
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Búsqueda</h5>
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
                <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                  {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" v-model.number="filters.axo" class="municipal-form-control"
                     min="1990" :max="new Date().getFullYear() + 1" :disabled="loading" />
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

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Recibos a Emitir</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} locales</span>
            <span class="badge-success ms-2">Total Adeudo: {{ formatCurrency(totalAdeudo) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Datos del Local</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Adeudo</th>
                  <th class="text-end">Recargos</th>
                  <th class="text-end">Subtotal</th>
                  <th>Meses Adeudados</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedResults" :key="row.id_local" class="row-hover">
                  <td>{{ datosLocal(row) }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion_local }}</td>
                  <td class="text-end">{{ formatNumber(row.superficie) }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta) }}</td>
                  <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                  <td class="text-end">{{ formatCurrency(row.recargos) }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.subtotal) }}</strong></td>
                  <td>{{ row.meses || 'N/A' }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="7" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalAdeudo) }}</strong></td>
                  <td></td>
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

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Cargando datos...</p>
      </div>

      <div v-if="!results.length && !loading && busquedaRealizada" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron locales para emitir recibos con los filtros seleccionados.
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
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);

const meses = ref([
  { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
  { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
  { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
  { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
]);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return results.value.slice(start, start + pageSize.value);
});
const totalAdeudo = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.subtotal) || 0), 0));

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
  }
};

const previsualizar = async () => {
  if (!filters.value.oficina || !filters.value.mercado) {
    alert('Por favor complete todos los filtros requeridos');
    return;
  }

  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_emision_locales_get',
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

const emitirRecibos = async () => {
  if (!results.value.length) {
    alert('No hay recibos para emitir');
    return;
  }

  if (!confirm(`¿Está seguro de emitir ${results.value.length} recibos?`)) {
    return;
  }

  loading.value = true;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_emision_locales_emit',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) },
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) },
          { Nombre: 'p_usuario_id', Valor: 1 }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      alert('Recibos emitidos correctamente');
      await previsualizar();
    } else {
      alert('Error al emitir recibos');
    }
  } catch (error) {
    console.error('Error al emitir recibos:', error);
    alert('Error al emitir recibos');
  } finally {
    loading.value = false;
  }
};

const datosLocal = (row) => {
  return `${row.oficina}-${row.num_mercado}-${row.categoria}-${row.seccion}-${row.local}${row.letra_local || ''}${row.bloque ? '-' + row.bloque : ''}`;
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const formatNumber = (value) => {
  if (value == null) return '0';
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value);
};

const mostrarAyuda = () => {
  alert('Emisión de Recibos de Locales\n\nSeleccione la recaudadora, mercado, año y periodo para previsualizar los recibos a emitir. Luego haga clic en "Emitir Recibos" para generar los recibos.');
};

onMounted(() => {
  fetchRecaudadoras();
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
</style>
