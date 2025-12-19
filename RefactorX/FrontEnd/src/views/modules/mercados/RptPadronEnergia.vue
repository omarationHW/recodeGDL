<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Padrón de Energía Eléctrica</h1>
        <p>Inicio > Reportes > Padrón de Energía del Mercado</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="!resultados.length || loading">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="!resultados.length || loading">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de Consulta -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="mostrarFiltros ? 'angle-up' : 'angle-down'" class="ms-2" />
          </h5>
        </div>
        <div v-show="mostrarFiltros" class="municipal-card-body">
          <form @submit.prevent="consultar">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="municipal-form-label">
                  Recaudadora <span class="text-danger">*</span>
                </label>
                <select
                  v-model="filters.oficina"
                  class="municipal-form-control"
                  @change="onOficinaChange"
                  required
                >
                  <option value="">Seleccione recaudadora...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                   {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="municipal-form-label">
                  Mercado <span class="text-danger">*</span>
                </label>
                <select
                  v-model="filters.mercado"
                  class="municipal-form-control"
                  required
                  :disabled="!mercados.length"
                >
                  <option value="">{{ mercados.length ? 'Seleccione mercado...' : 'Primero seleccione recaudadora' }}</option>
                  <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">
                    {{ m.num_mercado_nvo }} - {{ m.descripcion }}
                  </option>
                </select>
              </div>
            </div>
            <div class="button-row mt-3">
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <font-awesome-icon icon="search" />
                {{ loading ? 'Consultando...' : 'Consultar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Estado: Cargando -->
      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-3 text-muted">Cargando padrón de energía...</p>
      </div>

      <!-- Estado: Sin búsqueda -->
      <div v-if="!busquedaRealizada && !loading" class="alert alert-info">
        <font-awesome-icon icon="info-circle" />
        Seleccione <strong>recaudadora</strong> y <strong>mercado</strong>, luego haga clic en <strong>Consultar</strong>.
      </div>

      <!-- Estado: Sin resultados -->
      <div v-if="busquedaRealizada && !resultados.length && !loading" class="alert alert-warning">
        <font-awesome-icon icon="exclamation-triangle" />
        No se encontraron registros de energía para el mercado seleccionado.
      </div>

      <!-- Tabla de Resultados -->
      <div v-if="resultados.length && !loading" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Padrón de Energía
            <span v-if="mercadoDescripcion" class="ms-2 text-muted" style="font-size: 0.9rem; font-weight: normal;">
              {{ mercadoDescripcion }}
            </span>
          </h5>
          <div class="header-right">
            <span class="badge-primary">{{ resultados.length }} locales</span>
            <span class="badge-success">Total KW: {{ formatNumber(totalCantidad) }}</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header sticky-header">
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
                <tr v-for="row in paginatedResultados" :key="row.id_local" class="row-hover">
                  <td class="text-end"><strong class="text-primary">{{ row.id_local }}</strong></td>
                  <td>{{ row.datoslocal }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.local_adicional || '-' }}</td>
                  <td class="text-end">{{ formatNumber(row.cantidad) }}</td>
                  <td class="text-center">
                    <span :class="getBadgeVigencia(row.vigencia)">{{ row.vigencia }}</span>
                  </td>
                  <td class="text-center">
                    <span class="badge-info">{{ row.cve_consumo }}</span>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="table-footer">
                  <th colspan="4" class="text-end">TOTALES:</th>
                  <th class="text-end">{{ formatNumber(totalCantidad) }}</th>
                  <th colspan="2"></th>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ resultados.length }} registros
            </div>
            <div class="pagination-controls">
              <label class="municipal-form-label mb-0">Registros por página:</label>
              <select v-model.number="pageSize" class="municipal-form-control municipal-form-control-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="previousPage" :disabled="currentPage === 1" class="btn-pagination">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="mx-3">Página {{ currentPage }} de {{ totalPages }}</span>
              <button @click="nextPage" :disabled="currentPage === totalPages" class="btn-pagination">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import Swal from 'sweetalert2';
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

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
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value);
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, resultados.value.length));
const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return resultados.value.slice(start, start + pageSize.value);
});
const totalCantidad = computed(() => resultados.value.reduce((sum, r) => sum + (parseFloat(r.cantidad) || 0), 0));
const mercadoDescripcion = computed(() => resultados.value.length > 0 ? resultados.value[0].descripcion : '');

const fetchRecaudadoras = async () => {
  showLoading('Cargando recaudadoras...', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Parametros: []
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      recaudadoras.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  } finally {
    hideLoading();
  }
};

const onOficinaChange = async () => {
  filters.value.mercado = '';
  mercados.value = [];
  if (!filters.value.oficina) return;

  showLoading('Cargando mercados...', 'Por favor espere');
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_mercados_by_recaudadora',
        Base: 'padron_licencias',
        Parametros: [{ Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) }]
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      mercados.value = response.data.eResponse.data.result;
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
  } finally {
    hideLoading();
  }
};

const consultar = async () => {
  showLoading('Consultando padrón de energía...', 'Por favor espere');
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
    resultados.value = [];
  } finally {
    loading.value = false;
    hideLoading();
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

const previousPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const formatNumber = (value) => {
  if (value == null) return '0.00';
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value);
};

const getBadgeVigencia = (vigencia) => {
  const badges = {
    'A': 'badge-success',
    'B': 'badge-danger',
    'E': 'badge-warning'
  };
  return badges[vigencia] || 'badge-secondary';
};

const imprimir = () => {
  window.print();
};

const exportarExcel = () => {
  const csv = [
    'ID Local,Datos Local,Nombre,Locales Adicionales,K/Cuota,Vigencia,F/K',
    ...resultados.value.map(r =>
      `${r.id_local},"${r.datoslocal}","${r.nombre}","${r.local_adicional || ''}",${r.cantidad},${r.vigencia},${r.cve_consumo}`
    )
  ].join('\n');
  const blob = new Blob(['\ufeff' + csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `padron_energia_${filters.value.oficina}_${filters.value.mercado}_${new Date().toISOString().split('T')[0]}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};


// Ayuda
function mostrarAyuda() {
  Swal.fire({
    title: 'Ayuda - Reporte de PadrÃ³n de EnergÃ­a',
    html: `
      <div style="text-align: left;">
        <h6>Funcionalidad del mÃ³dulo:</h6>
        <p>Este mÃ³dulo genera el reporte del padrÃ³n de energÃ­a elÃ©ctrica.</p>
        <h6>Instrucciones:</h6>
        <ol>
          <li>Seleccione la recaudadora y mercado
          <li>Puede filtrar por vigencia y otros criterios
          <li>Exporte el reporte para anÃ¡lisis adicional</li>
        </ol>
      </div>
    `,
    icon: 'info',
    confirmButtonText: 'Entendido'
  });
}

onMounted(() => {
  fetchRecaudadoras();
});
</script>

