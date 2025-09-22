<template>
  <div class="unit1-report-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Folios</li>
      </ol>
    </nav>
    <h1>Municipio de Guadalajara</h1>
    <h2>Dirección de Estacionamientos Públicos</h2>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="fetchReport">
          <div class="form-group">
            <label for="fechora">Fecha y Hora</label>
            <input type="datetime-local" v-model="fechora" id="fechora" class="form-control" required />
          </div>
          <button type="submit" class="btn btn-primary" :disabled="loading">Generar Reporte</button>
        </form>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="report.length > 0" class="card">
      <div class="card-header">Resultados del Reporte</div>
      <div class="card-body p-0">
        <table class="table table-striped mb-0">
          <thead>
            <tr>
              <th>ASO</th>
              <th>Folio</th>
              <th>Placa</th>
              <th>Fecha/Hora</th>
              <th>Estado</th>
              <th>Clave</th>
              <th>Importe</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in report" :key="row.aso + '-' + row.folio">
              <td>{{ row.aso }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.placa }}</td>
              <td>{{ row.fecha_hora }}</td>
              <td>{{ row.estado }}</td>
              <td>{{ row.clave }}</td>
              <td>{{ row.importe }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-else-if="!loading && reportRequested" class="alert alert-info">No se encontraron resultados para la fecha/hora seleccionada.</div>
  </div>
</template>

<script>
export default {
  name: 'Unit1ReportPage',
  data() {
    return {
      fechora: '',
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
            eRequest: 'unit1_report',
            params: {
              fechora: this.fechora
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse.error || 'Error desconocido al obtener el reporte.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red o del servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.unit1-report-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.card {
  margin-bottom: 1.5rem;
}
</style>
