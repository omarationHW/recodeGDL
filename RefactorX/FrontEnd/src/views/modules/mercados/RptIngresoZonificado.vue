<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Ingreso Zonificado</h1>
        <p>Inicio > Mercados > Ingreso Zonificado</p>
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
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" v-model="filters.fecdesde" class="municipal-form-control" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" v-model="filters.fechasta" class="municipal-form-control" :disabled="loading" />
            </div>
          </div>
        </div>
      </div>

      <div v-if="results.length > 0" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Reporte de Ingreso Zonificado</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} zonas</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalIngreso) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 10%">Zona ID</th>
                  <th style="width: 60%">Zona</th>
                  <th style="width: 30%" class="text-end">Ingreso</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in paginatedResults" :key="row.id_zona" class="row-hover">
                  <td>{{ row.id_zona }}</td>
                  <td>{{ row.zona }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.pagado) }}</strong></td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td colspan="2" class="text-end"><strong>TOTAL:</strong></td>
                  <td class="text-end"><strong class="text-success">{{ formatCurrency(totalIngreso) }}</strong></td>
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
        <p class="mt-2">Cargando reporte...</p>
      </div>

      <div v-if="!results.length && !loading && busquedaRealizada" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron registros para el período seleccionado.
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
const totalIngreso = computed(() => results.value.reduce((sum, r) => sum + (parseFloat(r.pagado) || 0), 0));

const consultar = async () => {
  if (!filters.value.fecdesde || !filters.value.fechasta) {
    alert('Por favor complete todos los filtros requeridos');
    return;
  }

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

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const exportarExcel = () => {
  const csv = [
    'Zona ID,Zona,Ingreso',
    ...results.value.map(r => `${r.id_zona},${r.zona},${r.pagado}`)
  ].join('\n');
  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `ingreso_zonificado_${filters.value.fecdesde}_${filters.value.fechasta}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => {
  alert('Reporte de Ingreso Zonificado\n\nSeleccione el rango de fechas para generar el reporte de ingresos por zona.');
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
@import '@/styles/municipal-theme.css';
</style>
