<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="balance-scale" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Saldos de Locales</h1>
        <p>Inicio > Mercados > Saldos de Locales</p>
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
              <label class="municipal-form-label">Año</label>
              <input
                type="number"
                v-model.number="filters.axo"
                class="municipal-form-control"
                min="1990"
                :max="new Date().getFullYear() + 1"
                placeholder="Todos"
                :disabled="loading"
              />
              <small class="form-text text-muted">Dejar vacío para ver todos los años</small>
            </div>
          </div>
        </div>
      </div>

      <div v-if="loading" class="text-center py-5">
        <div class="spinner-border municipal-text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-2">Generando reporte de saldos...</p>
      </div>

      <div v-if="!busquedaRealizada && !loading" class="municipal-alert municipal-alert-info">
        <font-awesome-icon icon="info-circle" /> Seleccione filtros y haga clic en <strong>Consultar</strong>.
      </div>

      <div v-if="busquedaRealizada && !results.length && !loading" class="municipal-alert municipal-alert-warning">
        <font-awesome-icon icon="exclamation-triangle" /> No se encontraron locales con saldos.
      </div>

      <div v-if="results.length && !loading" class="municipal-card mt-3">
        <div class="municipal-card-header header-with-badge">
          <h5><font-awesome-icon icon="list-alt" /> Saldos por Local</h5>
          <div class="header-right">
            <span class="badge-purple">{{ results.length }} locales</span>
            <span class="badge-info ms-2">Adeudos: {{ formatCurrency(totalAdeudos) }}</span>
            <span class="badge-success ms-2">Pagos: {{ formatCurrency(totalPagos) }}</span>
            <span :class="totalSaldo >= 0 ? 'badge-danger' : 'badge-success'" class="ms-2">
              Saldo: {{ formatCurrency(totalSaldo) }}
            </span>
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
                  <th>Nombre</th>
                  <th class="text-end">Total Adeudos</th>
                  <th class="text-end">Total Pagos</th>
                  <th class="text-end">Saldo</th>
                  <th>Último Pago</th>
                  <th class="text-center">Periodos Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in paginatedResults" :key="idx" class="row-hover">
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ formatLocal(row) }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end">{{ formatCurrency(row.total_adeudos) }}</td>
                  <td class="text-end">{{ formatCurrency(row.total_pagos) }}</td>
                  <td class="text-end">
                    <strong :class="parseFloat(row.saldo) > 0 ? 'text-danger' : 'text-success'">
                      {{ formatCurrency(row.saldo) }}
                    </strong>
                  </td>
                  <td>{{ formatDate(row.ultimo_pago) }}</td>
                  <td class="text-center">
                    <span v-if="row.periodos_adeudo > 0" class="badge-warning">
                      {{ row.periodos_adeudo }}
                    </span>
                    <span v-else class="badge-success">0</span>
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <th colspan="4" class="text-end">TOTALES:</th>
                  <th class="text-end"><strong class="text-info">{{ formatCurrency(totalAdeudos) }}</strong></th>
                  <th class="text-end"><strong class="text-success">{{ formatCurrency(totalPagos) }}</strong></th>
                  <th class="text-end">
                    <strong :class="totalSaldo > 0 ? 'text-danger' : 'text-success'">
                      {{ formatCurrency(totalSaldo) }}
                    </strong>
                  </th>
                  <th colspan="2"></th>
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
              <button class="btn-municipal-secondary btn-sm" @click="currentPage++" :disabled="currentPage === totalPages">
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
  axo: null
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

const totalAdeudos = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.total_adeudos) || 0), 0));
const totalPagos = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.total_pagos) || 0), 0));
const totalSaldo = computed(() => results.value.reduce((sum, row) => sum + (parseFloat(row.saldo) || 0), 0));

onMounted(() => {
  filters.value.axo = new Date().getFullYear();
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

  loading.value = true;
  busquedaRealizada.value = false;

  try {
    const parametros = [
      { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
      { Nombre: 'p_mercado', Valor: parseInt(filters.value.mercado) }
    ];

    // Si hay año especificado, agregarlo como parámetro
    if (filters.value.axo) {
      parametros.push({ Nombre: 'p_axo', Valor: parseInt(filters.value.axo) });
    } else {
      parametros.push({ Nombre: 'p_axo', Valor: null });
    }

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_rpt_saldos_locales',
        Base: 'padron_licencias',
        Parametros: parametros
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

const formatLocal = (row) => {
  let local = `${row.local}`;
  if (row.letra_local) local += row.letra_local;
  if (row.bloque) local += `-${row.bloque}`;
  return local;
};

const formatDate = (date) => {
  if (!date) return 'Sin pagos';
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
    'Local': formatLocal(row),
    'Nombre': row.nombre,
    'Total Adeudos': row.total_adeudos,
    'Total Pagos': row.total_pagos,
    'Saldo': row.saldo,
    'Último Pago': formatDate(row.ultimo_pago),
    'Periodos Adeudo': row.periodos_adeudo
  }));

  const csv = [
    Object.keys(data[0]).join(','),
    ...data.map(row => Object.values(row).map(cell => `"${cell}"`).join(','))
  ].join('\n');

  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `saldos_locales_${filters.value.mercado}_${filters.value.axo || 'todos'}.csv`;
  a.click();
  window.URL.revokeObjectURL(url);
};

const mostrarAyuda = () => {
  alert('Reporte de Saldos de Locales\n\nMuestra el estado de cuenta de cada local en un mercado:\n\n- Total Adeudos: Suma de todos los adeudos del local\n- Total Pagos: Suma de todos los pagos realizados\n- Saldo: Diferencia entre adeudos y pagos\n  • Saldo positivo (rojo): El local debe dinero\n  • Saldo negativo (verde): El local tiene saldo a favor\n- Periodos Adeudo: Número de periodos con adeudos pendientes\n- Último Pago: Fecha del último pago registrado\n\nPuede filtrar por año específico o ver todos los años dejando el campo vacío.');
};
</script>

<style scoped>
@import '@/styles/municipal-theme.css';

.form-text {
  display: block;
  margin-top: 0.25rem;
  font-size: 0.875rem;
}

.text-muted {
  color: #6c757d;
}
</style>
