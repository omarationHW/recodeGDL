<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="exchange-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Movimientos de Locales</h1>
        <p>Inicio > Mercados > Movimientos de Locales</p>
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
              <select v-model.number="filters.recaudadora" class="municipal-form-control" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" v-model="filters.fechaDesde" class="municipal-form-control" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" v-model="filters.fechaHasta" class="municipal-form-control" :disabled="loading" />
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Reporte de Movimientos de Locales</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} movimientos</span>
            <span class="badge-info ms-2">{{ contadorPorTipo.length }} tipos</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
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
                <tr v-for="row in paginatedResults" :key="row.id_movimiento" class="row-hover">
                  <td>{{ formatFecha(row.fecha) }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}-{{ row.local }}{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>
                    <span :class="getBadgeClass(row.tipodescripcion)">
                      {{ row.tipodescripcion }}
                    </span>
                  </td>
                  <td>{{ row.nombre }}</td>
                </tr>
              </tbody>
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
        <p class="mt-2">Cargando movimientos...</p>
      </div>

      <div v-if="!results.length && !loading && busquedaRealizada" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron movimientos en el período seleccionado.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const filters = ref({
  recaudadora: '',
  fechaDesde: '',
  fechaHasta: ''
});

const recaudadoras = ref([]);
const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);

const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);
const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return results.value.slice(start, start + pageSize.value);
});

const contadorPorTipo = computed(() => {
  const tipos = new Set(results.value.map(r => r.tipodescripcion));
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
  }
};

const consultar = async () => {
  if (!filters.value.recaudadora || !filters.value.fechaDesde || !filters.value.fechaHasta) {
    alert('Por favor complete todos los filtros requeridos');
    return;
  }

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
    'ALTA': 'badge-success',
    'BAJA TOTAL': 'badge-danger',
    'BAJA ADMINISTRATIVA': 'badge-danger',
    'BAJA POR ACUERDO': 'badge-danger',
    'REACTIVACION': 'badge-success',
    'REACTIVAR BLOQUEO': 'badge-success',
    'BLOQUEADO': 'badge-warning',
    'CAMBIO DE GIRO': 'badge-info',
    'CAMBIO FECHA ALTA': 'badge-info',
    'CAMBIO NOMBRE LOC.': 'badge-info',
    'CAMBIO DOMICILIO': 'badge-info',
    'CAMBIO DE ZONA': 'badge-info',
    'CAMBIO LOCAL,SUPERF.': 'badge-info'
  };
  return map[tipo] || 'badge-secondary';
};

const exportarExcel = () => {
  const csv = [
    'Fecha,Oficina,Mercado,Categoría,Local,Bloque,Tipo Movimiento,Nombre',
    ...results.value.map(r =>
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

const mostrarAyuda = () => {
  alert('Reporte de Movimientos de Locales\n\nSeleccione la recaudadora y el rango de fechas para consultar los movimientos realizados en los locales.');
};

onMounted(async () => {
  showLoading('Cargando Reporte de Movimientos', 'Preparando catálogos...');
  try {
    await fetchRecaudadoras();

    // Set default dates (current month)
    const today = new Date();
    const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
    filters.value.fechaDesde = firstDay.toISOString().split('T')[0];
    filters.value.fechaHasta = today.toISOString().split('T')[0];
  } finally {
    hideLoading();
  }
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
</style>
