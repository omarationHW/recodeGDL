<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Reporte Salvadas</h1>
        <p>Mercados - Reporte Salvadas</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Reporte de Salvadas</h1>
    <form @submit.prevent="fetchReport">
      <div class="form-group">
        <label for="start_date">Fecha Inicio</label>
        <input type="date" v-model="filters.start_date" id="start_date" class="municipal-form-control" required>
      </div>
      <div class="form-group">
        <label for="end_date">Fecha Fin</label>
        <input type="date" v-model="filters.end_date" id="end_date" class="municipal-form-control" required>
      </div>
      <button type="submit" class="btn-municipal-primary">Generar Reporte</button>
    </form>
    <div v-if="loading" class="mt-3">
      <span>Cargando reporte...</span>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">
      {{ error }}
    </div>
    <div v-if="report.length" class="mt-4">
      <h2>Resultados</h2>
      <table class="municipal-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Fecha</th>
            <th>Descripción</th>
            <th>Valor</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in report" :key="idx">
            <td>{{ idx + 1 }}</td>
            <td>{{ row.fecha }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.valor }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && reportRequested" class="mt-4">
      <span>No se encontraron resultados para el rango seleccionado.</span>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RprtSalvadasPage',
  data() {
    return {
      filters: {
        start_date: '',
        end_date: ''
      },
      report: [],
      loading: false,
      error: '',
      reportRequested: false
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      this.reportRequested = true;
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
                start_date: this.filters.start_date,
                end_date: this.filters.end_date
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.status === 'ok') {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = 'Error de red o del servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rprt-salvadas-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
