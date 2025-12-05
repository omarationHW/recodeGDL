<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="dollar-sign" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Pagos por Mercado</h1>
        <p>Inicio > Mercados > Pagos por Mercado</p>
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
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Desde <span class="required">*</span></label>
              <input type="date" v-model="filters.fecha_desde" class="municipal-form-control" :disabled="loading" />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Fecha Hasta <span class="required">*</span></label>
              <input type="date" v-model="filters.fecha_hasta" class="municipal-form-control" :disabled="loading" />
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Generando reporte...</p>
      </div>

      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
        <font-awesome-icon icon="info-circle" /> Seleccione filtros y haga clic en <strong>Consultar</strong>.
      </div>

      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron pagos.
      </div>

      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Pagos Registrados</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} registros</span>
            <span class="badge-success ms-2">Total: {{ formatCurrency(totalImporte) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Mercado</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha Pago</th>
                  <th>Rec.</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th class="text-end">Renta Pagada</th>
                  <th>Recibo</th>
                  <th>Fecha Mov.</th>
                  <th>Usuario</th>
                  <th>Fecha Req.</th>
                  <th>Folio Req.</th>
                  <th>Periodos Req.</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResults" :key="`pago-${idx}`" class="row-hover">
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.letra_local || '-' }}</td>
                  <td>{{ row.bloque || '-' }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ formatDate(row.fecha_pago) }}</td>
                  <td>{{ row.oficina_pago }}</td>
                  <td>{{ row.caja_pago }}</td>
                  <td>{{ row.operacion_pago }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe_pago) }}</strong></td>
                  <td>{{ row.folio }}</td>
                  <td>{{ row.fecha_modificacion || '-' }}</td>
                  <td>{{ row.usuario }}</td>
                  <td>{{ formatDate(row.fecha_emision) }}</td>
                  <td>{{ row.folio_1 || '-' }}</td>
                  <td>{{ row.requerimientos || '-' }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <th colspan="11" class="text-end">TOTAL:</th>
                  <th class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></th>
                  <th colspan="6"></th>
                </tr>
              </tfoot>
            </table>
          </div>
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
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++:" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
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
  fecha_desde: '',
  fecha_hasta: ''
});

const recaudadoras = ref([]);
const mercados = ref([]);
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
const totalImporte = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.importe_pago) || 0), 0));

// Inicializar fechas con el mes actual
onMounted(() => {
  const today = new Date();
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
  const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);

  filters.value.fecha_desde = firstDay.toISOString().split('T')[0];
  filters.value.fecha_hasta = lastDay.toISOString().split('T')[0];

  fetchRecaudadoras();
});

const fetchRecaudadoras = async () => {
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
};

const onOficinaChange = async () => {
  filters.value.mercado = '';
  mercados.value = [];
  busquedaRealizada.value = false;
  results.value = [];

  if (!filters.value.oficina) return;

  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_rec', Valor: parseInt(filters.value.oficina) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error:', error);
  } finally {
    loading.value = false;
  }
};

const consultar = async () => {
  if (!filters.value.oficina || !filters.value.mercado) {
    alert('Debe seleccionar recaudadora y mercado');
    return;
  }

  if (!filters.value.fecha_desde || !filters.value.fecha_hasta) {
    alert('Debe especificar el rango de fechas');
    return;
  }

  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_pagos_loc_grl',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) },
          { Nombre: 'p_fecha_desde', Valor: filters.value.fecha_desde },
          { Nombre: 'p_fecha_hasta', Valor: filters.value.fecha_hasta }
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
    console.error('Error:', error);
    results.value = [];
    busquedaRealizada.value = true;
  } finally {
    loading.value = false;
  }
};

const formatDate = (date) => {
  if (!date) return '-';
  return new Date(date).toLocaleDateString('es-MX');
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const exportarExcel = () => {
  const data = results.value.map(row => ({
    'Mercado': row.num_mercado,
    'Sección': row.seccion,
    'Local': row.local,
    'Letra': row.letra_local || '',
    'Bloque': row.bloque || '',
    'Año': row.axo,
    'Mes': row.periodo,
    'Fecha Pago': formatDate(row.fecha_pago),
    'Rec.': row.oficina_pago,
    'Caja': row.caja_pago,
    'Operación': row.operacion_pago,
    'Renta Pagada': row.importe_pago,
    'Recibo': row.folio,
    'Fecha Mov.': row.fecha_modificacion || '',
    'Usuario': row.usuario,
    'Fecha Req.': formatDate(row.fecha_emision),
    'Folio Req.': row.folio_1 || '',
    'Periodos Req.': row.requerimientos || ''
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).map(cell => `"${cell}"`).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `pagos_mercado_${filters.value.mercado}_${Date.now()}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => {
  alert('Reporte de Pagos por Mercado\n\nGenera un reporte de todos los pagos realizados en un mercado específico dentro de un rango de fechas.\n\nIncluye información detallada de cada pago, requerimientos y periodos pagados.');
};
</script>

<style scoped>
@import '@/styles/municipal-theme.css';
</style>
