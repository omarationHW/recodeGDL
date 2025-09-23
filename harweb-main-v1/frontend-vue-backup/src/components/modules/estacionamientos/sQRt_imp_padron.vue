<template>
  <div class="padron-report-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón Vehicular</li>
      </ol>
    </nav>
    <h1>Padrón Vehicular del Estado de Jalisco</h1>
    <div class="card mb-4">
      <div class="card-body">
        <form @submit.prevent="fetchReport">
          <div class="form-row">
            <div class="form-group col-md-3">
              <label for="id1">ID Inicial</label>
              <input type="number" class="form-control" id="id1" v-model.number="id1" required />
            </div>
            <div class="form-group col-md-3">
              <label for="id2">ID Final</label>
              <input type="number" class="form-control" id="id2" v-model.number="id2" required />
            </div>
            <div class="form-group col-md-3 align-self-end">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="results.length">
      <div class="table-responsive">
        <table class="table table-bordered table-striped">
          <thead class="thead-dark">
            <tr>
              <th>ID</th>
              <th>Placa Actual</th>
              <th>Placa Anterior</th>
              <th>Clave Vehicular</th>
              <th>Propietario</th>
              <th>Municipio</th>
              <th>Marca</th>
              <th>Tipo</th>
              <th>Clase</th>
              <th>Modelo</th>
              <th>Color</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in results" :key="row.id">
              <td>{{ row.id }}</td>
              <td>{{ row.placa }}</td>
              <td>{{ row.placaant }}</td>
              <td>{{ row.claveveh }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.municipio }}</td>
              <td>{{ row.marca }}</td>
              <td>{{ row.tipo }}</td>
              <td>{{ row.clase }}</td>
              <td>{{ row.modelo }}</td>
              <td>{{ row.color }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-secondary">No hay resultados para mostrar.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PadronReportPage',
  data() {
    return {
      id1: '',
      id2: '',
      results: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.results = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            eRequest: 'get_padron_report',
            params: {
              id1: this.id1,
              id2: this.id2
            }
          })
        });
        const data = await response.json();
        if (data.eResponse === 'success') {
          this.results = data.data;
        } else {
          this.error = data.message || 'Error desconocido al consultar el reporte.';
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
.padron-report-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding-left: 0;
}
</style>
