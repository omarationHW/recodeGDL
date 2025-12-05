<template>
  <div class="module-view mt-3">
    <!-- Breadcrumb -->
    <div class="mb-3">
      <span class="text-muted">Inicio / Mercados / Padrón de Locales</span>
    </div>

    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h2><i class="fas fa-building"></i> Padrón de Arrendamiento de Mercados</h2>
    </div>

    <!-- Filtros -->
    <div class="municipal-card mb-3">
      <div class="municipal-card-header municipal-bg-primary text-white" @click="mostrarFiltros = !mostrarFiltros" style="cursor: pointer;">
        <i :class="mostrarFiltros ? 'fas fa-chevron-down' : 'fas fa-chevron-right'"></i>
        Filtros de Consulta
      </div>
      <div class="municipal-card-body" v-show="mostrarFiltros">
        <form @submit.prevent="consultar">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">Oficina Recaudadora <span class="text-danger">*</span></label>
              <select v-model="filters.oficina" class="municipal-form-control" @change="onOficinaChange" required>
                <option value="">Seleccione recaudadora...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="col-md-6 mb-3">
              <label class="municipal-form-label">Mercado <span class="text-danger">*</span></label>
              <select v-model="filters.mercado" class="municipal-form-control" required>
                <option value="">Seleccione mercado...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado" :value="merc.num_mercado">
                  {{ merc.num_mercado }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="d-flex gap-2">
            <button type="submit" class="btn-municipal-primary" :disabled="loading">
              <i class="fas fa-search"></i> Consultar
            </button>
            <button type="button" class="btn-municipal-secondary" @click="limpiar">
              <i class="fas fa-eraser"></i> Limpiar
            </button>
            <button type="button" class="btn-municipal-success" @click="exportarExcel" :disabled="!resultados.length">
              <i class="fas fa-file-excel"></i> Exportar
            </button>
          </div>
        </form>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="text-center py-5">
      <div class="spinner-border municipal-text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
      <p class="mt-2">Cargando padrón de locales...</p>
    </div>

    <!-- Sin búsqueda -->
    <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
      <i class="fas fa-info-circle"></i> Seleccione la oficina recaudadora y mercado, luego haga clic en <strong>Consultar</strong>.
    </div>

    <!-- Sin resultados -->
    <div v-if="busquedaRealizada && !resultados.length && !loading" class="municipal-alert municipal-alert-warning">
      <i class="fas fa-exclamation-triangle"></i> No se encontraron locales con los criterios seleccionados.
    </div>

    <!-- Tabla de Resultados -->
    <div v-if="resultados.length && !loading" class="municipal-card">
      <div class="municipal-card-header municipal-bg-light d-flex justify-content-between align-items-center">
        <div>
          <h5 class="mb-0">Padrón de Locales</h5>
          <span class="badge-primary me-2">{{ resultados.length }} locales</span>
          <span class="badge-info">Superficie Total: {{ totalSuperficie.toFixed(2) }} m²</span>
          <span class="badge-success ms-2">Renta Total: {{ formatCurrency(totalRenta) }}</span>
        </div>
      </div>
      <div class="municipal-card-body table-responsive">
        <table class="municipal-table table-bordered table-hover table-sm">
          <thead class="municipal-table-header sticky-top">
            <tr>
              <th>Oficina</th>
              <th>Mercado</th>
              <th>Categoría</th>
              <th>Sección</th>
              <th>Local</th>
              <th>Letra</th>
              <th>Bloque</th>
              <th>Nombre</th>
              <th class="text-end">Superficie (m²)</th>
              <th>Clave Cuota</th>
              <th>Descripción</th>
              <th class="text-end">Renta</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in paginatedResultados" :key="row.id_local">
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.categoria }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.letra_local }}</td>
              <td>{{ row.bloque }}</td>
              <td>{{ row.nombre }}</td>
              <td class="text-end">{{ formatNumber(row.superficie) }}</td>
              <td>{{ row.clave_cuota }}</td>
              <td>{{ row.descripcion }}</td>
              <td class="text-end fw-bold">{{ formatCurrency(row.renta) }}</td>
            </tr>
          </tbody>
          <tfoot class="municipal-table-footer">
            <tr>
              <th colspan="8" class="text-end">Totales:</th>
              <th class="text-end">{{ formatNumber(totalSuperficie) }} m²</th>
              <th colspan="2"></th>
              <th class="text-end fw-bold">{{ formatCurrency(totalRenta) }}</th>
            </tr>
          </tfoot>
        </table>
      </div>

      <!-- Paginación -->
      <div class="municipal-card-footer">
        <div class="row align-items-center">
          <div class="col-md-6">
            <label class="me-2">Mostrar:</label>
            <select v-model.number="pageSize" class="municipal-form-control d-inline-block w-auto">
              <option :value="10">10</option>
              <option :value="25">25</option>
              <option :value="50">50</option>
              <option :value="100">100</option>
              <option :value="250">250</option>
            </select>
            <span class="ms-2">registros por página</span>
          </div>
          <div class="col-md-6 text-end">
            <button class="btn-municipal-secondary btn-sm me-1" @click="currentPage--" :disabled="currentPage === 1">
              <i class="fas fa-chevron-left"></i>
            </button>
            <span class="mx-2">Página {{ currentPage }} de {{ totalPages }}</span>
            <button class="btn-municipal-secondary btn-sm ms-1" @click="currentPage++" :disabled="currentPage === totalPages">
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

// Referencias reactivas
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

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

// Computed
const totalPages = computed(() => Math.ceil(resultados.value.length / pageSize.value) || 1);

const paginatedResultados = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  const end = start + pageSize.value;
  return resultados.value.slice(start, end);
});

const totalSuperficie = computed(() => {
  return resultados.value.reduce((sum, row) => sum + (parseFloat(row.superficie) || 0), 0);
});

const totalRenta = computed(() => {
  return resultados.value.reduce((sum, row) => sum + (parseFloat(row.renta) || 0), 0);
});

// Métodos
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
    console.error('Error al cargar recaudadoras:', error);
    showToast('Error al cargar recaudadoras', 'error');
  } finally {
    loading.value = false;
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
    } else {
      mercados.value = [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
    mercados.value = [];
  } finally {
    loading.value = false;
  }
};

const consultar = async () => {
  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_padron_locales',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_recaudadora', Valor: parseInt(filters.value.oficina) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      // Filtrar por mercado si se seleccionó uno específico
      let data = response.data.eResponse.data.result;
      if (filters.value.mercado) {
        data = data.filter(row => row.num_mercado === parseInt(filters.value.mercado));
      }

      resultados.value = data;
      busquedaRealizada.value = true;
      currentPage.value = 1;

      if (resultados.value.length > 0) {
        showToast(`Se encontraron ${resultados.value.length} locales`, 'success');
      }
    } else {
      resultados.value = [];
      busquedaRealizada.value = true;
      showToast('No se encontraron resultados', 'warning');
    }
  } catch (error) {
    console.error('Error al consultar:', error);
    showToast('Error al consultar el padrón de locales', 'error');
    resultados.value = [];
    busquedaRealizada.value = true;
  } finally {
    loading.value = false;
  }
};

const limpiar = () => {
  filters.value = {
    oficina: '',
    mercado: ''
  };
  mercados.value = [];
  resultados.value = [];
  busquedaRealizada.value = false;
  currentPage.value = 1;
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
};

const formatNumber = (value) => {
  if (value == null) return '0.00';
  return parseFloat(value).toFixed(2);
};

const exportarExcel = () => {
  const data = resultados.value.map(row => ({
    'Oficina': row.oficina,
    'Mercado': row.num_mercado,
    'Categoría': row.categoria,
    'Sección': row.seccion,
    'Local': row.local,
    'Letra': row.letra_local,
    'Bloque': row.bloque,
    'Nombre': row.nombre,
    'Superficie': row.superficie,
    'Clave Cuota': row.clave_cuota,
    'Descripción': row.descripcion,
    'Renta': row.renta
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `padron_locales_${filters.value.oficina}_${filters.value.mercado}_${new Date().getTime()}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const showToast = (message, type = 'info') => {
  // alert(message);
};

// Lifecycle
onMounted(() => {
  fetchRecaudadoras();
});
</script>

<style scoped>
@import '@/styles/municipal-theme.css';

.sticky-top {
  position: sticky;
  top: 0;
  background-color: #f8f9fa;
  z-index: 10;
}

.btn-sm {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
}

@media print {
  .municipal-card-header,
  .municipal-card-footer,
  button,
  .no-print {
    display: none !important;
  }

  table {
    font-size: 10px;
  }
}
</style>
