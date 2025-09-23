<template>
  <div class="rep-recaudadoras-page">
    <h1>Impresiones de Recaudadoras</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reportes</li>
        <li class="breadcrumb-item active" aria-current="page">Recaudadoras</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header">Ordenar por:</div>
      <div class="card-body">
        <div class="form-group">
          <label for="order">Seleccione el criterio de orden:</label>
          <select v-model="order" id="order" class="form-control w-auto d-inline-block ml-2">
            <option :value="1">Recaudadora</option>
            <option :value="2">Nombre</option>
            <option :value="3">Domicilio</option>
            <option :value="4">Sector</option>
          </select>
        </div>
        <button class="btn btn-primary mr-2" @click="fetchReport" :disabled="loading">
          <span v-if="loading" class="spinner-border spinner-border-sm"></span>
          Vista Previa
        </button>
        <button class="btn btn-secondary" @click="$router.back()">Salir</button>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0" class="table-responsive">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>#</th>
            <th>Recaudadora</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Sector</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in report" :key="row.id_rec">
            <td>{{ idx + 1 }}</td>
            <td>{{ row.id_rec }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.sector }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-info">No hay datos para mostrar.</div>
  </div>
</template>

<script>
export default {
  name: 'RepRecaudadorasPage',
  data() {
    return {
      order: 1,
      report: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getRecaudadorasReport',
          params: { order: this.order }
        });
        if (res.data.success) {
          this.report = res.data.data;
        } else {
          this.error = res.data.message || 'Error al obtener el reporte.';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    this.fetchReport();
  }
};
</script>

<style scoped>
.rep-recaudadoras-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  margin-bottom: 2rem;
}
</style>
