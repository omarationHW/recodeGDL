<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Cuenta Pública</h1>
        <p>Inicio > Reportes > Cuentas por Cobrar</p>
      </div>
      <div class="button-group ms-auto">
        <button 
          class="btn-municipal-primary" 
          @click="exportarExcel" 
          :disabled="loading || datos.length === 0"
        >
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button 
          class="btn-municipal-primary" 
          @click="imprimir" 
          :disabled="loading || datos.length === 0"
        >
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
        <button 
          class="btn-municipal-purple" 
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Content -->
    <div class="module-view-content">
      <!-- Filtros -->
      <div class="municipal-card">
        <div 
          class="municipal-card-header" 
          @click="toggleFilters" 
          style="cursor: pointer;"
        >
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon 
              :icon="showFilters ? 'angle-up' : 'angle-down'" 
              class="ms-2" 
            />
          </h5>
        </div>
        <div v-show="showFilters" class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año Fiscal</label>
              <input
                v-model.number="filters.axo"
                type="number"
                class="municipal-form-control"
                min="2000"
                max="2100"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Oficina</label>
              <input
                v-model.number="filters.oficina"
                type="number"
                class="municipal-form-control"
                min="1"
              />
            </div>
          </div>
          <div class="row mt-3">
            <div class="col-12 text-end">
              <button 
                class="btn-municipal-primary me-2" 
                @click="consultar" 
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                Consultar
              </button>
              <button 
                class="btn-municipal-secondary" 
                @click="limpiarFiltros" 
                :disabled="loading"
              >
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            {{ tituloReporte }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="datos.length > 0">
              {{ formatNumber(datos.length) }} registros
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando reporte...</p>
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header sticky-header">
                <tr>
                  <th>Recaudadora</th>
                  <th>Concepto</th>
                  <th class="text-end">Saldo Anterior</th>
                  <th class="text-end">Altas</th>
                  <th class="text-end">Movimientos</th>
                  <th class="text-end">Bajas</th>
                </tr>
              </thead>
              <tbody>
                <!-- Estado vacío inicial -->
                <tr v-if="datos.length === 0 && !consultaRealizada">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros</p>
                  </td>
                </tr>
                
                <!-- Sin resultados -->
                <tr v-else-if="datos.length === 0">
                  <td colspan="6" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron resultados</p>
                  </td>
                </tr>
                
                <!-- Datos -->
                <tr 
                  v-else 
                  v-for="(row, index) in paginatedDatos" 
                  :key="index" 
                  class="row-hover"
                >
                  <td>{{ row.recaudadora }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">{{ formatCurrency(row.saldo_mes_anterior) }}</td>
                  <td class="text-end">{{ formatCurrency(row.altas_importe) }}</td>
                  <td class="text-end">{{ formatCurrency(row.mov_mes_importe) }}</td>
                  <td class="text-end">{{ formatCurrency(row.bajas_importe) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="datos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ datos.length }} registros
            </div>
            
            <div class="pagination-controls">
              <label>Registros por página:</label>
              <select v-model.number="pageSize" class="municipal-form-control" style="width: auto; display: inline-block;">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
            </div>
            
            <div class="pagination-buttons">
              <button
                @click="previousPage"
                :disabled="currentPage === 1"
                class="btn-municipal-secondary"
              >
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="mx-3">Página {{ currentPage }} de {{ totalPages }}</span>
              <button
                @click="nextPage"
                :disabled="currentPage === totalPages"
                class="btn-municipal-secondary"
              >
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast Notification -->
    <div 
      v-if="toast.show" 
      :class="['toast-notification', `toast-${toast.type}`]"
    >
      <font-awesome-icon :icon="getToastIcon()" />
      <span>{{ toast.message }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading()

// Estado reactivo
const loading = ref(false);
const showFilters = ref(true);
const consultaRealizada = ref(false);
const datos = ref([]);
const filters = ref({
  axo: new Date().getFullYear(),
  oficina: 1
});
const currentPage = ref(1);
const pageSize = ref(25);
const toast = ref({
  show: false,
  message: '',
  type: 'info'
});

// Computed properties
const tituloReporte = computed(() => 'Reporte Cuenta Pública');

const totalPages = computed(() => Math.ceil(datos.value.length / pageSize.value));

const startIndex = computed(() => (currentPage.value - 1) * pageSize.value);

const endIndex = computed(() => 
  Math.min(startIndex.value + pageSize.value, datos.value.length)
);

const paginatedDatos = computed(() => 
  datos.value.slice(startIndex.value, endIndex.value)
);

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value;
};

const consultar = async () => {
  loading.value = true;
  consultaRealizada.value = true;
  datos.value = [];
  currentPage.value = 1;
  showLoading('Consultando datos', 'Por favor espere')

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'rpt_cuenta_publica',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_axo', Valor: filters.value.axo },
          { Nombre: 'p_oficina', Valor: filters.value.oficina }
        ]
      }
    });
// p_axo integer, p_oficina integer

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      datos.value = response.data.eResponse.data.result;
      showToast(
        datos.value.length === 0 
          ? 'No se encontraron resultados' 
          : `Se encontraron ${datos.value.length} registros`,
        datos.value.length === 0 ? 'info' : 'success'
      );
    } else {
      showToast('No se encontraron resultados', 'warning');
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al consultar', 'error');
  } finally {
    loading.value = false;
    hideLoading()
  }
};

const limpiarFiltros = () => {
  filters.value = {
    axo: new Date().getFullYear(),
    oficina: 1
  };
  datos.value = [];
  consultaRealizada.value = false;
  currentPage.value = 1;
};

const exportarExcel = () => {
  showToast('Funcionalidad en desarrollo', 'info');
};

const imprimir = () => {
  window.print();
};

const mostrarAyuda = () => {
  showToast('Reporte de cuentas por cobrar. Filtre por año fiscal y oficina.', 'info');
};

const previousPage = () => {
  if (currentPage.value > 1) currentPage.value--;
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) currentPage.value++;
};

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value);
};

const formatNumber = (value) => {
  if (value === null || value === undefined) return '0';
  return new Intl.NumberFormat('es-MX').format(value);
};

const showToast = (message, type = 'info') => {
  toast.value = { show: true, message, type };
  setTimeout(() => {
    toast.value.show = false;
  }, 3000);
};

const getToastIcon = () => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  };
  return icons[toast.value.type] || 'info-circle';
};
</script>

<style scoped>
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

.sticky-header {
  position: sticky;
  top: 0;
  background-color: #fff;
  z-index: 10;
}

.table-container {
  max-height: 600px;
  overflow-y: auto;
}

.empty-icon {
  color: #ccc;
  margin-bottom: 1rem;
}

.row-hover:hover {
  background-color: #f0f8ff;
  cursor: pointer;
}

.header-with-badge {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-right {
  display: flex;
  gap: 0.5rem;
}

.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding: 1rem;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  font-size: 0.9rem;
  color: #666;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.pagination-controls label {
  margin: 0;
  font-size: 0.9rem;
}

.pagination-controls select {
  width: auto;
}

.pagination-buttons {
  display: flex;
  align-items: center;
  gap: 0.25rem;
}

.pagination-buttons .btn,
.pagination-buttons .btn-municipal-secondary {
  min-width: 2rem;
}

.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}

.module-view-header .btn-municipal-primary,
.module-view-header .btn-municipal-success {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: white !important;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.required {
  color: #dc3545;
}
</style>