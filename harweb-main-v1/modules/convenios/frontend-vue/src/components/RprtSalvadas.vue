<template>
  <div class="rprt-salvadas-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Salvadas</li>
      </ol>
    </nav>
    <h1>Reporte de Salvadas</h1>
    <form @submit.prevent="generateReport">
      <div class="form-group">
        <label for="user_id">Usuario</label>
        <input type="text" v-model="form.user_id" id="user_id" class="form-control" placeholder="ID de usuario (opcional)">
      </div>
      <div class="form-group">
        <label for="date_from">Desde</label>
        <input type="date" v-model="form.date_from" id="date_from" class="form-control">
      </div>
      <div class="form-group">
        <label for="date_to">Hasta</label>
        <input type="date" v-model="form.date_to" id="date_to" class="form-control">
      </div>
      <button type="submit" class="btn btn-primary" :disabled="loading">Generar Reporte</button>
    </form>
    <div v-if="loading" class="mt-3">
      <span>Cargando reporte...</span>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">
      {{ error }}
    </div>
    <div v-if="report.length" class="mt-4">
      <h2>Resultados</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>#</th>
            <th>Usuario</th>
            <th>Fecha</th>
            <th>Descripción</th>
            <th>Estado</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in report" :key="idx">
            <td>{{ idx + 1 }}</td>
            <td>{{ row.user_name }}</td>
            <td>{{ row.saved_at }}</td>
            <td>{{ row.description }}</td>
            <td>{{ row.status }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="!loading && report.length === 0 && submitted" class="alert alert-info mt-3">
      No se encontraron resultados para los criterios seleccionados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'RprtSalvadasPage',
  data() {
    return {
      form: {
        user_id: '',
        date_from: '',
        date_to: ''
      },
      report: [],
      loading: false,
      error: '',
      submitted: false
    };
  },
  methods: {
    async generateReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      this.submitted = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'RprtSalvadas.generateReport',
            params: {
              user_id: this.form.user_id || null,
              date_from: this.form.date_from || null,
              date_to: this.form.date_to || null
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.report = data.data;
        } else {
          this.error = data.message || 'Error desconocido al generar el reporte.';
        }
      } catch (err) {
        this.error = 'Error de red o del servidor: ' + err.message;
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
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
