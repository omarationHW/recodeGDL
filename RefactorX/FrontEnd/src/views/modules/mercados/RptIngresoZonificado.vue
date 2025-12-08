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
              Mostrando {{ ((currentPage - 1) * pageSize) + 1 }}
              a {{ Math.min(currentPage * pageSize, totalRecords) }}
              de {{ totalRecords }} registros
            </div>
            <div class="pagination-controls">
              <label class="me-2">Registros por página:</label>
              <select v-model.number="pageSize" class="form-select form-select-sm">
                <option :value="10">10</option>
                <option :value="25">25</option>
                <option :value="50">50</option>
                <option :value="100">100</option>
                <option :value="250">250</option>
              </select>
            </div>
            <div class="pagination-buttons">
              <button @click="goToPage(1)" :disabled="currentPage === 1" title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>
              <button @click="goToPage(currentPage - 1)" :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>
              <button v-for="page in visiblePages" :key="page"
                :class="page === currentPage ? 'active' : ''"
                @click="goToPage(page)">
                {{ page }}
              </button>
              <button @click="goToPage(currentPage + 1)" :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>
              <button @click="goToPage(totalPages)" :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
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

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import axios from 'axios';
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const { showLoading, hideLoading } = useGlobalLoading()

const filters = ref({
  fecdesde: '',
  fechasta: ''
});

const results = ref([]);
const loading = ref(false);
const busquedaRealizada = ref(false);
const currentPage = ref(1);
const pageSize = ref(25);

// Toast
const toast = ref({ show: false, type: 'info', message: '' })

const showToast = (type, message) => {
  toast.value = { show: true, type, message }
  setTimeout(() => hideToast(), 5000)
}

const hideToast = () => { toast.value.show = false }

const getToastIcon = (type) => {
  const icons = { success: 'check-circle', error: 'times-circle', warning: 'exclamation-triangle', info: 'info-circle' }
  return icons[type] || 'info-circle'
}

// Paginación
const totalRecords = computed(() => results.value.length)
const totalPages = computed(() => Math.ceil(results.value.length / pageSize.value) || 1);

const paginatedResults = computed(() => {
  const start = (currentPage.value - 1) * pageSize.value;
  return results.value.slice(start, start + pageSize.value);
});

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
})

const goToPage = (page) => {
  if (page < 1 || page > totalPages.value) return
  currentPage.value = page
}

const totalIngreso = computed(() => results.value.reduce((sum, r) => sum + (parseFloat(r.pagado) || 0), 0));

const consultar = async () => {
  if (!filters.value.fecdesde || !filters.value.fechasta) {
    showToast('warning', 'Por favor complete todos los filtros requeridos');
    return;
  }

  loading.value = true;
  showLoading()
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
      if (results.value.length > 0) {
        showToast('success', `Se encontraron ${results.value.length} zonas con ingresos`)
      } else {
        showToast('info', 'No se encontraron registros para el período seleccionado')
      }
    } else {
      results.value = [];
      busquedaRealizada.value = true;
      showToast('error', 'Error al consultar los datos')
    }
  } catch (error) {
    console.error('Error al consultar:', error);
    results.value = [];
    busquedaRealizada.value = true;
    showToast('error', 'Error de conexión al consultar')
  } finally {
    loading.value = false;
    hideLoading()
  }
};

const formatCurrency = (value) => {
  if (value == null) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const exportarExcel = () => {
  if (results.value.length === 0) {
    showToast('warning', 'No hay datos para exportar')
    return
  }

  try {
    const csv = [
      'Zona ID,Zona,Ingreso',
      ...results.value.map(r => `${r.id_zona},"${r.zona}",${r.pagado}`)
    ].join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `ingreso_zonificado_${filters.value.fecdesde}_${filters.value.fechasta}.csv`;
    a.click();
    window.URL.revokeObjectURL(url);
    showToast('success', 'Archivo exportado exitosamente')
  } catch (err) {
    console.error('Error al exportar:', err)
    showToast('error', 'Error al exportar el archivo')
  }
};

const mostrarAyuda = () => {
  showToast('info', 'Reporte de Ingreso Zonificado - Seleccione el rango de fechas para generar el reporte de ingresos por zona.');
};

onMounted(() => {
  // Set default dates (current month)
  const today = new Date();
  const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
  filters.value.fecdesde = firstDay.toISOString().split('T')[0];
  filters.value.fechasta = today.toISOString().split('T')[0];
});
</script>
