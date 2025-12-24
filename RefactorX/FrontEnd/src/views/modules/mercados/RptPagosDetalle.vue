<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-alt" />
      </div>
      <div class="module-view-info">
        <h1>Reporte Detalle de Pagos</h1>
        <p>Inicio > Mercados > Detalle de Pagos</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="showDocumentacion = true" title="Documentacion">
          <font-awesome-icon icon="book-open" />
          <span>Documentacion</span>
        </button>
        <button class="btn-municipal-purple" @click="showAyuda = true" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          <span>Ayuda</span>
        </button>
        
        <button class="btn-municipal-primary" @click="consultar" :disabled="loading">
          <font-awesome-icon icon="search" /> Consultar
        </button>
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || results.length === 0">
          <font-awesome-icon icon="file-excel" /> Exportar
        </button>
        
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="filter" /> Filtros de Consulta</h5>
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

      <!-- Loading -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Generando reporte detallado de pagos...</p>
      </div>

      <!-- Sin búsqueda -->
      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
        <font-awesome-icon icon="info-circle" /> Seleccione los filtros y haga clic en <strong>Consultar</strong> para generar el reporte.
      </div>

      <!-- Sin resultados -->
      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron pagos en el rango de fechas seleccionado.
      </div>

      <!-- Tabla de Resultados -->
      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Detalle de Pagos</h5>
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
                  <th>Fecha</th>
                  <th>Folio</th>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th class="text-end">Importe</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover">
                  <td>{{ formatDate(row.fecha_pago) }}</td>
                  <td>{{ row.folio || 'N/A' }}</td>
                  <td>{{ datosLocal(row) }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ getMesNombre(row.periodo) }}</td>
                  <td>{{ row.caja_pago }}</td>
                  <td>{{ row.operacion_pago }}</td>
                  <td class="text-end"><strong>{{ formatCurrency(row.importe_pago) }}</strong></td>
                  <td>{{ row.usuario || 'N/A' }}</td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <th colspan="8" class="text-end">TOTAL:</th>
                  <th class="text-end"><strong class="text-success">{{ formatCurrency(totalImporte) }}</strong></th>
                  <th></th>
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
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <DocumentationModal :show="showAyuda" :component-name="'RptPagosDetalle'" :module-name="'mercados'" :doc-type="'ayuda'" :title="'Mercados - RptPagosDetalle'" @close="showAyuda = false" />
  <DocumentationModal :show="showDocumentacion" :component-name="'RptPagosDetalle'" :module-name="'mercados'" :doc-type="'documentacion'" :title="'Mercados - RptPagosDetalle'" @close="showDocumentacion = false" />
</template>

<script setup>
import apiService from '@/services/apiService';
import { ref, computed, onMounted } from 'vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const showAyuda = ref(false)
const showDocumentacion = ref(false)


// Composables
const { showLoading, hideLoading } = useGlobalLoading();

// Referencias reactivas
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

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

// Computed
const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);

const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return results.value.slice(start, end);
});

const totalImporte = computed(() => {
  return results.value.reduce((sum, row) => sum + (parseFloat(row.importe_pago) || 0), 0);
});

// Métodos
const fetchRecaudadoras = async () => {
  loading.value = true;
  try {
    showLoading('Cargando recaudadoras', 'Por favor espere...');
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
    console.error('Error al cargar recaudadoras:', error);
  } finally {
    loading.value = false;
    hideLoading();
  }
};

const onOficinaChange = async () => {
  if (!filters.value.oficina) {
    mercados.value = [];
    filters.value.mercado = '';
    return;
  }

  loading.value = true;
  try {
    showLoading('Cargando mercados', 'Por favor espere...');
    const response = await apiService.execute(
          'sp_get_mercados_by_recaudadora',
          'mercados',
          [
          { nombre: 'p_id_rec', valor: parseInt(filters.value.oficina) }
        ],
          '',
          null,
          'publico'
        );

    if (response?.success && response?.data?.result) {
      mercados.value = response.data.result;
    } else {
      mercados.value = [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    mercados.value = [];
  } finally {
    loading.value = false;
    hideLoading();
  }
};

const consultar = async () => {
  if (!filters.value.oficina || !filters.value.mercado || !filters.value.fecha_desde || !filters.value.fecha_hasta) {
    alert('Por favor complete todos los filtros requeridos');
    return;
  }

  loading.value = true;
  busquedaRealizada.value = false;

  try {
    showLoading('Generando reporte detallado de pagos', 'Por favor espere...');
    const response = await apiService.execute(
          'sp_rpt_pagos_detalle',
          'mercados',
          [
          { nombre: 'p_oficina', valor: parseInt(filters.value.oficina) },
          { nombre: 'p_mercado', valor: parseInt(filters.value.mercado) },
          { nombre: 'p_fecha_desde', valor: filters.value.fecha_desde },
          { nombre: 'p_fecha_hasta', valor: filters.value.fecha_hasta }
        ],
          '',
          null,
          'publico'
        );

    if (response?.success && response?.data?.result) {
      results.value = response.data.result;
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
    hideLoading();
  }
};

const datosLocal = (row) => {
  let datos = `${row.categoria || ''}-${row.seccion || ''}-${row.local || ''}`;
  if (row.letra_local) datos += row.letra_local;
  if (row.bloque) datos += `-${row.bloque}`;
  return datos;
};

const getMesNombre = (mes) => {
  const meses = ['', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
  return meses[mes] || mes;
};

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
};

const exportarExcel = () => {
  const data = results.value.map(row => ({
    'Fecha': formatDate(row.fecha_pago),
    'Folio': row.folio || 'N/A',
    'Local': datosLocal(row),
    'Nombre': row.nombre,
    'Año': row.axo,
    'Periodo': getMesNombre(row.periodo),
    'Caja': row.caja_pago,
    'Operación': row.operacion_pago,
    'Importe': row.importe_pago,
    'Usuario': row.usuario || 'N/A'
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `pagos_detalle_${filters.value.oficina}_${filters.value.mercado}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => {
  alert('Reporte Detalle de Pagos\n\nGenera un reporte detallado de todos los pagos realizados en un mercado específico dentro de un rango de fechas.\n\nIncluye información completa como folio, año, periodo, caja, operación y usuario que registró el pago.');
};

// Lifecycle
onMounted(() => {
  fetchRecaudadoras();

  // Establecer fechas por defecto (último mes)
  const hoy = new Date();
  const hace30dias = new Date();
  hace30dias.setDate(hoy.getDate() - 30);

  filters.value.fecha_hasta = hoy.toISOString().split('T')[0];
  filters.value.fecha_desde = hace30dias.toISOString().split('T')[0];
});
</script>
