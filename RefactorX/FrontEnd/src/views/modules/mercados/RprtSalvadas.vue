<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-chart-line" />
      </div>
      <div class="module-view-info">
        <h1>Reporte de Salvadas</h1>
        <p>Inicio > Mercados > Reporte de Salvadas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Reporte
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="fetchReport">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">
                  Fecha Inicio <span class="required">*</span>
                </label>
                <input
                  type="date"
                  v-model="filters.start_date"
                  class="municipal-form-control"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">
                  Fecha Fin <span class="required">*</span>
                </label>
                <input
                  type="date"
                  v-model="filters.end_date"
                  class="municipal-form-control"
                  required
                />
              </div>
            </div>
            <div class="row mt-3">
              <div class="col-12 text-end">
                <button
                  type="submit"
                  class="btn-municipal-primary"
                  :disabled="!filters.start_date || !filters.end_date"
                >
                  <font-awesome-icon icon="file-chart-line" />
                  Generar Reporte
                </button>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Resultados -->
      <div v-if="report.length" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados del Reporte
          </h5>
          <div class="header-right">
            <span class="badge-purple">{{ report.length }} registros</span>
          </div>
        </div>
        <div class="municipal-card-body table-container">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>#</th>
                  <th>Fecha</th>
                  <th>Descripción</th>
                  <th class="text-end">Valor</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in report" :key="idx" class="row-hover">
                  <td>{{ idx + 1 }}</td>
                  <td>{{ row.fecha }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td class="text-end">
                    <strong class="text-info">{{ row.valor }}</strong>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Sin resultados -->
      <div v-else-if="reportRequested && !globalLoading.isLoading.value" class="text-center text-muted py-5">
        <font-awesome-icon icon="inbox" size="2x" class="empty-icon" />
        <p>No se encontraron resultados para el rango seleccionado</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';

const globalLoading = useGlobalLoading();
const { showToast: toast } = useToast();

const filters = ref({
  start_date: '',
  end_date: ''
});
const report = ref([]);
const reportRequested = ref(false);

const fetchReport = async () => {
  await globalLoading.withLoading(async () => {
    reportRequested.value = true;
    report.value = [];

    try {
      const response = await fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            operation: 'getSalvadasReport',
            params: {
              start_date: filters.value.start_date,
              end_date: filters.value.end_date
            }
          }
        })
      });

      const data = await response.json();

      if (data.eResponse && data.eResponse.success) {
        report.value = data.eResponse.data;
        toast('Reporte generado exitosamente', 'success');
      } else {
        const errorMsg = data.eResponse ? data.eResponse.message : 'Error desconocido';
        toast(errorMsg, 'error');
      }
    } catch (err) {
      toast('Error de red o del servidor', 'error');
      console.error('Error en fetchReport:', err);
    }
  }, 'Generando reporte...', 'Por favor espere mientras se procesa la información');
};

const mostrarAyuda = () => {
  toast('Seleccione un rango de fechas y presione "Generar Reporte" para ver los resultados', 'info');
};
</script>
