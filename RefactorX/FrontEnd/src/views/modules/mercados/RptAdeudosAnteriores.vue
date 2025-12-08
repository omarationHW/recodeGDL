<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="history" /></div>
      <div class="module-view-info">
        <h1>Adeudos Anteriores</h1>
        <p>Inicio > Reportes > Adeudos Anteriores a 1996</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-success" @click="exportarExcel" :disabled="loading || datos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || datos.length === 0">
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
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'chevron-up' : 'chevron-down'" class="ms-2" />
          </h5>
        </div>
        <div v-show="showFilters" class="municipal-card-body">
          <div class="row g-3">
            <div class="col-md-3">
              <label for="axo" class="municipal-form-label">Año</label>
              <input
                v-model.number="filters.axo"
                type="number"
                min="1900"
                max="2099"
                class="municipal-form-control"
                id="axo"
                placeholder="Año"
              />
            </div>
            <div class="col-md-3">
              <label for="oficina" class="municipal-form-label">Oficina</label>
              <input
                v-model.number="filters.oficina"
                type="number"
                min="1"
                max="99"
                class="municipal-form-control"
                id="oficina"
                placeholder="Número de oficina"
              />
            </div>
            <div class="col-md-3">
              <label for="periodo" class="municipal-form-label">Periodo (Mes)</label>
              <input
                v-model.number="filters.periodo"
                type="number"
                min="1"
                max="12"
                class="municipal-form-control"
                id="periodo"
                placeholder="1-12"
              />
            </div>
          </div>
          <div class="button-row mt-3">
            <button class="btn-municipal-primary" @click="consultar" :disabled="loading">
              <font-awesome-icon icon="search" />
              {{ loading ? 'Consultando...' : 'Consultar' }}
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            {{ tituloReporte }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="datos.length > 0">{{ formatNumber(datos.length) }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status"><span class="visually-hidden">Cargando...</span></div>
            <p class="mt-3 text-muted">Generando reporte, por favor espere...</p>
          </div>
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header sticky-header">
                <tr>
                  <th>ID Local</th>
                  <th>Datos Local</th>
                  <th>Nombre</th>
                  <th>Año</th>
                  <th>Meses</th>
                  <th class="text-end">Renta</th>
                  <th class="text-end">Adeudo</th>
                  <th>Mercado</th>
                  <th>Recaudadora</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="datos.length === 0 && !consultaRealizada">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para generar el reporte</p>
                  </td>
                </tr>
                <tr v-else-if="datos.length === 0">
                  <td colspan="9" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron resultados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedDatos" :key="index" class="row-hover">
                  <td>{{ row.id_local }}</td>
                  <td>{{ row.datoslocal }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.meses || '-' }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta) }}</td>
                  <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.recaudadora }}</td>
                </tr>
              </tbody>
              <tfoot v-if="datos.length > 0">
                <tr class="table-secondary">
                  <td colspan="5" class="text-end"><strong>Total Renta:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalRenta) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalAdeudo) }}</strong></td>
                  <td colspan="2"></td>
                </tr>
              </tfoot>
            </table>
          </div>
          <div v-if="datos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ datos.length }} registros
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
                <font-awesome-icon icon="chevron-left" />
              </button>
              <span class="mx-3">Página {{ currentPage }} de {{ totalPages }}</span>
              <button @click="nextPage" :disabled="currentPage === totalPages" class="btn-pagination">
                <font-awesome-icon icon="chevron-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div v-if="toast.show" :class="['toast-notification', `toast-${toast.type}`]">
      <font-awesome-icon :icon="getToastIcon()" /><span>{{ toast.message }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const loading = ref(false);
const showFilters = ref(true);
const consultaRealizada = ref(false);
const datos = ref([]);
const filters = ref({ axo: new Date().getFullYear(), oficina: '', periodo: new Date().getMonth() + 1 });
const currentPage = ref(1);
const pageSize = ref(25);
const toast = ref({ show: false, message: '', type: 'info' });

const tituloReporte = computed(() => 'Listado de Adeudos de Años Anteriores a 1996');
const totalPages = computed(() => Math.ceil(datos.value.length / pageSize.value));
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value);
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, datos.value.length));
const paginatedDatos = computed(() => datos.value.slice(startIndex.value, endIndex.value));
const totalAdeudo = computed(() => datos.value.reduce((sum, r) => sum + (parseFloat(r.adeudo) || 0), 0));
const totalRenta = computed(() => datos.value.reduce((sum, r) => sum + (parseFloat(r.renta) || 0), 0));

const toggleFilters = () => { showFilters.value = !showFilters.value; };

const consultar = async () => {
  loading.value = true;
  consultaRealizada.value = true;
  datos.value = [];
  currentPage.value = 1;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'rpt_adeudos_anteriores',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) || new Date().getFullYear() },
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) || 0 },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) || 12 }
        ]
      }
    });
    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      datos.value = response.data.eResponse.data.result;
      showToast(datos.value.length === 0 ? 'No se encontraron resultados' : `Se encontraron ${datos.value.length} registros`, datos.value.length === 0 ? 'info' : 'success');
    } else {
      showToast('No se encontraron resultados', 'warning');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al consultar', 'error');
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => { filters.value = { axo: new Date().getFullYear(), oficina: '', periodo: new Date().getMonth() + 1 }; datos.value = []; consultaRealizada.value = false; currentPage.value = 1; };
const exportarExcel = () => { showToast('Funcionalidad de exportación en desarrollo', 'info'); };
const imprimir = () => { window.print(); };
const mostrarAyuda = () => { showToast('Reporte de adeudos anteriores a 1996. Filtre por año, oficina y periodo para consultar.', 'info'); };
const previousPage = () => { if (currentPage.value > 1) currentPage.value--; };
const nextPage = () => { if (currentPage.value < totalPages.value) currentPage.value++; };
const formatCurrency = (value) => { if (value === null || value === undefined) return '$0.00'; return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value); };
const formatNumber = (value) => { if (value === null || value === undefined) return '0'; return new Intl.NumberFormat('es-MX').format(value); };
const showToast = (message, type = 'info') => { toast.value = { show: true, message, type }; setTimeout(() => { toast.value.show = false; }, 3000); };
const getToastIcon = () => { const icons = { success: 'check-circle', error: 'exclamation-circle', warning: 'exclamation-triangle', info: 'info-circle' }; return icons[toast.value.type] || 'info-circle'; };

onMounted(async () => {
  showLoading('Cargando Reporte de Adeudos Anteriores', 'Preparando datos...');
  try {
    // Initialization complete
  } finally {
    hideLoading();
  }
});
</script>

<style src="@/styles/municipal-theme.css"></style>

<style scoped>
/* Print styles */
@media print {
  .module-view-header,
  .municipal-card-header,
  .pagination-container,
  .button-group {
    display: none !important;
  }
  .municipal-table {
    font-size: 10px;
  }
  .sticky-header {
    position: static !important;
  }
}

/* Sticky header for scrolling tables */
.sticky-header {
  position: sticky;
  top: 0;
  background-color: #fff;
  z-index: 10;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

/* Table container with scroll */
.table-container {
  max-height: 600px;
  overflow-y: auto;
}

/* Empty state icons */
.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

/* Row hover effect */
.row-hover:hover {
  background-color: #f0f8ff;
  cursor: pointer;
  transition: background-color 0.2s ease;
}

/* Header with badge alignment */
.header-with-badge {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-right {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}

/* Pagination container */
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding: 1rem;
  border-top: 1px solid #dee2e6;
  background-color: #f8f9fa;
}

.pagination-info {
  font-size: 0.9rem;
  color: #666;
  font-weight: 500;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.pagination-controls label {
  margin: 0;
  font-size: 0.9rem;
  white-space: nowrap;
}

.pagination-controls select {
  width: 80px;
  padding: 0.375rem 0.75rem;
}

.pagination-buttons {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-pagination {
  padding: 0.375rem 0.75rem;
  border: 1px solid #6f42c1;
  background-color: #fff;
  color: #6f42c1;
  border-radius: 0.375rem;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 0.875rem;
}

.btn-pagination:hover:not(:disabled) {
  background-color: #6f42c1;
  color: #fff;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(111, 66, 193, 0.2);
}

.btn-pagination:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Small form control for select */
.municipal-form-control-sm {
  padding: 0.375rem 0.75rem;
  font-size: 0.875rem;
  height: auto;
}

/* Toast notification */
.toast-notification {
  position: fixed;
  bottom: 2rem;
  right: 2rem;
  padding: 1rem 1.5rem;
  border-radius: 0.5rem;
  background-color: #fff;
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  z-index: 9999;
  animation: slideIn 0.3s ease-out;
  min-width: 300px;
  max-width: 500px;
  width: auto;
  height: auto;
  max-height: 100px;
}

.toast-success {
  border-left: 4px solid #28a745;
}

.toast-error {
  border-left: 4px solid #dc3545;
}

.toast-warning {
  border-left: 4px solid #ffc107;
}

.toast-info {
  border-left: 4px solid #17a2b8;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}
</style>
