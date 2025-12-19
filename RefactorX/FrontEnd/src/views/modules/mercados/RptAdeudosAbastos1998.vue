<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Listado de Adeudos de Mercados del Año 1998</h1>
        <p>Inicio > Reportes > Adeudos Abastos 1998</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="exportarExcel" :disabled="loading || adeudos.length === 0">
          <font-awesome-icon icon="file-excel" />
          Exportar Excel
        </button>
        <button class="btn-municipal-primary" @click="imprimir" :disabled="loading || adeudos.length === 0">
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
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header" @click="toggleFilters" style="cursor: pointer;">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
            <font-awesome-icon :icon="showFilters ? 'angle-up' : 'angle-down'" class="ms-2" />
          </h5>
        </div>

        <div v-show="showFilters" class="municipal-card-body">
          <!-- Filtros -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año <span class="required">*</span></label>
              <input type="number" class="municipal-form-control" v-model.number="filters.axo" min="1998" max="1998" placeholder="1998" :disabled="loading" readonly />
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Recaudadora (Oficina) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="filters.oficina" @change="onOficinaChange" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_recaudadora" :value="rec.id_recaudadora">
                  {{ rec.id_recaudadora }} - {{ rec.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes) <span class="required">*</span></label>
              <select class="municipal-form-control" v-model.number="filters.periodo" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="m in meses" :key="m.id" :value="m.id">{{ m.nombre }}</option>
              </select>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="row mt-3">
            <div class="col-12">
              <div class="text-end">
                <button class="btn-municipal-primary me-2" @click="consultar" :disabled="loading">
                  <font-awesome-icon icon="search" />
                  Consultar
                </button>
                <button class="btn-municipal-secondary" @click="limpiarFiltros" :disabled="loading">
                  <font-awesome-icon icon="eraser" />
                  Limpiar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            {{ tituloReporte }}
          </h5>
          <div class="header-right">
            <span class="badge-purple" v-if="adeudos.length > 0">
              {{ formatNumber(adeudos.length) }} registros
            </span>
            <span class="badge-success ms-2" v-if="adeudos.length > 0">
              Total: {{ formatCurrency(totalAdeudo) }}
            </span>
          </div>
        </div>

        <div class="municipal-card-body table-container">
          <!-- Mensaje de loading -->
          <div v-if="loading" class="text-center py-5">
            <div class="spinner-border text-primary" role="status">
              <span class="visually-hidden">Cargando...</span>
            </div>
            <p class="mt-3 text-muted">Generando reporte, por favor espere...</p>
          </div>

          <!-- Tabla -->
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header sticky-header">
                <tr>
                  <th>Datos Local</th>
                  <th>Nombre</th>
                  <th class="text-end">Superficie</th>
                  <th class="text-end">Adeudo</th>
                  <th class="text-center">Meses</th>
                  <th class="text-center">Tot. Meses</th>
                  <th class="text-end">Renta E/A</th>
                  <th class="text-end">Renta S/D</th>
                  <th>Recaudadora</th>
                  <th>Mercado</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="adeudos.length === 0 && !consultaRealizada">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>Utiliza los filtros de búsqueda para generar el reporte</p>
                  </td>
                </tr>
                <tr v-else-if="adeudos.length === 0">
                  <td colspan="10" class="text-center text-muted">
                    <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
                    <p>No se encontraron adeudos con los criterios especificados</p>
                  </td>
                </tr>
                <tr v-else v-for="(row, index) in paginatedAdeudos" :key="index" @click="selectedRow = row" :class="{ 'table-row-selected': selectedRow === row }" class="row-hover">
                  <td>{{ row.datoslocal }}</td>
                  <td>{{ row.nombre }}</td>
                  <td class="text-end">{{ formatNumber(row.superficie) }}</td>
                  <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
                  <td class="text-center">{{ row.meses }}</td>
                  <td class="text-center">{{ row.totmeses }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta_ea) }}</td>
                  <td class="text-end">{{ formatCurrency(row.renta_sd) }}</td>
                  <td>{{ row.recaudadora }}</td>
                  <td>{{ row.descripcion }}</td>
                </tr>
              </tbody>
              <tfoot v-if="adeudos.length > 0" class="municipal-table-footer">
                <tr>
                  <td colspan="3" class="text-end"><strong>TOTAL GENERAL:</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalAdeudo) }}</strong></td>
                  <td colspan="2"></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalRentaEA) }}</strong></td>
                  <td class="text-end"><strong>{{ formatCurrency(totalRentaSD) }}</strong></td>
                  <td colspan="2"></td>
                </tr>
                <tr>
                  <td colspan="3" class="text-end"><strong>LOCALES CON ADEUDO:</strong></td>
                  <td class="text-end"><strong>{{ formatNumber(adeudos.length) }}</strong></td>
                  <td colspan="6"></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="adeudos.length > 0" class="pagination-container">
            <div class="pagination-info">
              Mostrando {{ startIndex + 1 }} - {{ endIndex }} de {{ adeudos.length }} registros
            </div>
            <div class="pagination-controls">
              <label>Registros por página:</label>
              <select v-model.number="pageSize" class="municipal-form-control" style="width: auto;">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="previousPage" :disabled="currentPage === 1" class="btn-municipal-secondary">
                <font-awesome-icon icon="angle-left" />
              </button>
              <span class="mx-3">Página {{ currentPage }} de {{ totalPages }}</span>
              <button @click="nextPage" :disabled="currentPage === totalPages" class="btn-municipal-secondary">
                <font-awesome-icon icon="angle-right" />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Toast notification -->
    <div v-if="toast.show" :class="['toast-notification', `toast-${toast.type}`]">
      <font-awesome-icon :icon="getToastIcon()" />
      <span>{{ toast.message }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

// Estados reactivos
const loading = ref(false);
const showFilters = ref(true);
const consultaRealizada = ref(false);
const selectedRow = ref(null);

const recaudadoras = ref([]);
const adeudos = ref([]);

const filters = ref({
  axo: 1998,
  oficina: '',
  periodo: 12
});

const meses = ref([
  { id: 1, nombre: 'Enero' },
  { id: 2, nombre: 'Febrero' },
  { id: 3, nombre: 'Marzo' },
  { id: 4, nombre: 'Abril' },
  { id: 5, nombre: 'Mayo' },
  { id: 6, nombre: 'Junio' },
  { id: 7, nombre: 'Julio' },
  { id: 8, nombre: 'Agosto' },
  { id: 9, nombre: 'Septiembre' },
  { id: 10, nombre: 'Octubre' },
  { id: 11, nombre: 'Noviembre' },
  { id: 12, nombre: 'Diciembre' }
]);

// Paginación
const currentPage = ref(1);
const pageSize = ref(25);

// Toast
const toast = ref({
  show: false,
  message: '',
  type: 'info'
});

// Computed
const tituloReporte = computed(() => {
  const oficinaSeleccionada = recaudadoras.value.find(r => r.id_rec === filters.value.oficina);
  let titulo = `LISTADO DE ADEUDOS DE MERCADOS DEL AÑO: ${filters.value.axo}`;
  if (oficinaSeleccionada) {
    titulo += `\nOFICINA RECAUDADORA DE INGRESOS ${oficinaSeleccionada.recaudadora.toUpperCase()}`;
  }
  return titulo;
});

const totalAdeudo = computed(() => {
  return adeudos.value.reduce((sum, row) => sum + Number(row.adeudo || 0), 0);
});

const totalRentaEA = computed(() => {
  return adeudos.value.reduce((sum, row) => sum + Number(row.renta_ea || 0), 0);
});

const totalRentaSD = computed(() => {
  return adeudos.value.reduce((sum, row) => sum + Number(row.renta_sd || 0), 0);
});

const totalPages = computed(() => Math.ceil(adeudos.value.length / pageSize.value));
const startIndex = computed(() => (currentPage.value - 1) * pageSize.value);
const endIndex = computed(() => Math.min(startIndex.value + pageSize.value, adeudos.value.length));

const paginatedAdeudos = computed(() => {
  return adeudos.value.slice(startIndex.value, endIndex.value);
});

// Métodos
const toggleFilters = () => {
  showFilters.value = !showFilters.value;
};

const fetchRecaudadoras = async () => {
  loading.value = true;
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
    showToast('Error al cargar recaudadoras', 'error');
  } finally {
    loading.value = false;
  }
};

const onOficinaChange = () => {
  // Lógica adicional al cambiar oficina si es necesaria
};

const consultar = async () => {
  // Validaciones
  if (!filters.value.oficina) {
    showToast('Por favor seleccione una recaudadora', 'warning');
    return;
  }
  if (!filters.value.periodo) {
    showToast('Por favor seleccione el periodo', 'warning');
    return;
  }

  loading.value = true;
  consultaRealizada.value = true;
  adeudos.value = [];
  currentPage.value = 1;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_adeudos_abastos_1998',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_axo', Valor: parseInt(filters.value.axo) },
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.oficina) },
          { Nombre: 'p_periodo', Valor: parseInt(filters.value.periodo) }
        ]
      }
    });

    if (response.data.eResponse?.success && response.data.eResponse?.data?.result) {
      adeudos.value = response.data.eResponse.data.result;
      if (adeudos.value.length === 0) {
        showToast('No se encontraron adeudos con los criterios especificados', 'info');
      } else {
        showToast(`Se encontraron ${adeudos.value.length} registros`, 'success');
      }
    } else {
      showToast('No se encontraron resultados', 'warning');
    }
  } catch (error) {
    console.error('Error al consultar adeudos:', error);
    showToast('Error al consultar adeudos de 1998', 'error');
  } finally {
    loading.value = false;
  }
};

const limpiarFiltros = () => {
  filters.value = {
    axo: 1998,
    oficina: '',
    periodo: 12
  };
  adeudos.value = [];
  consultaRealizada.value = false;
  selectedRow.value = null;
  currentPage.value = 1;
};

const exportarExcel = () => {
  if (adeudos.value.length === 0) return;

  // Crear CSV
  let csv = 'Datos Local,Nombre,Superficie,Adeudo,Meses,Tot. Meses,Renta E/A,Renta S/D,Recaudadora,Mercado\n';

  adeudos.value.forEach(row => {
    csv += `"${row.datoslocal}","${row.nombre}",${row.superficie},${row.adeudo},"${row.meses}",${row.totmeses},${row.renta_ea},${row.renta_sd},"${row.recaudadora}","${row.descripcion}"\n`;
  });

  csv += `\n,,,TOTAL GENERAL:,${totalAdeudo.value},,,${totalRentaEA.value},${totalRentaSD.value},\n`;
  csv += `,,,LOCALES CON ADEUDO:,${adeudos.value.length},,,,, \n`;

  // Descargar
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
  const link = document.createElement('a');
  const url = URL.createObjectURL(blob);
  link.setAttribute('href', url);
  link.setAttribute('download', `RptAdeudosAbastos1998_${filters.value.oficina}_${filters.value.periodo}.csv`);
  link.style.visibility = 'hidden';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);

  showToast('Archivo exportado exitosamente', 'success');
};

const imprimir = () => {
  window.print();
};

const mostrarAyuda = () => {
  showToast('Reporte de Adeudos de Mercados del Año 1998 - Incluye división de rentas Enero-Agosto (E/A) y Septiembre-Diciembre (S/D)', 'info');
};

const previousPage = () => {
  if (currentPage.value > 1) {
    currentPage.value--;
  }
};

const nextPage = () => {
  if (currentPage.value < totalPages.value) {
    currentPage.value++;
  }
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

// Lifecycle hooks
onMounted(async () => {
  showLoading('Cargando Reporte de Adeudos Abastos 1998', 'Preparando datos...');
  try {
    await fetchRecaudadoras();
    await consultar(); // Auto-cargar al inicio con oficina por defecto
  } finally {
    hideLoading();
  }
});
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

.table-row-selected {
  background-color: #e3f2fd !important;
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
}

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
}

.toast-success { border-left: 4px solid #28a745; }
.toast-error { border-left: 4px solid #dc3545; }
.toast-warning { border-left: 4px solid #ffc107; }
.toast-info { border-left: 4px solid #17a2b8; }

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

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.required {
  color: #dc3545;
}

.button-group {
  display: inline-flex;
  gap: 0.25rem;
}

.button-group-sm {
  gap: 0.125rem;
}

.module-view-header .btn-municipal-primary,
.module-view-header .btn-municipal-primary {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  color: white !important;
}

.pagination-controls {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1rem;
  padding: 1rem 0;
  gap: 1rem;
  flex-wrap: wrap;
}

.pagination-buttons {
  display: flex;
  gap: 0.25rem;
}

.pagination-buttons .btn,
.pagination-buttons .btn-municipal-secondary {
  min-width: 2rem;
}
</style>
