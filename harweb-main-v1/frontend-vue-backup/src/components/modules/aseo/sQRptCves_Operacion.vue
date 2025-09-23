<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Claves de Operación</li>
      </ol>
    </nav>
    <h2 class="mb-3">MUNICIPIO DE GUADALAJARA</h2>
    <h4 class="mb-1">DIRECCION DE INGRESOS</h4>
    <h5 class="mb-3">Catálogo de Claves de Operación</h5>
    <div class="mb-3">
      <label for="clasificacion" class="form-label">Clasificación por:</label>
      <select id="clasificacion" v-model="opcion" class="form-select" @change="fetchData">
        <option :value="1">Número de Control</option>
        <option :value="2">Clave</option>
        <option :value="3">Descripción</option>
      </select>
    </div>
    <div class="table-responsive">
      <table class="table table-bordered table-striped">
        <thead class="table-light">
          <tr>
            <th class="text-center">Control</th>
            <th class="text-center">Clave</th>
            <th class="text-center">Descripción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in operaciones" :key="idx">
            <td class="text-center">{{ row.ctrol_operacion }}</td>
            <td class="text-center">{{ row.cve_operacion }}</td>
            <td>{{ row.descripcion }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="operaciones.length === 0 && !loading" class="alert alert-info">No hay datos para mostrar.</div>
      <div v-if="loading" class="text-center my-3">
        <span class="spinner-border"></span> Cargando...
      </div>
    </div>
    <footer class="mt-4 text-muted small">
      Impreso: {{ now }}
    </footer>
  </div>
</template>

<script>
export default {
  name: 'CvesOperacionPage',
  data() {
    return {
      operaciones: [],
      opcion: 1,
      loading: false,
      now: ''
    };
  },
  created() {
    this.updateNow();
    this.fetchData();
  },
  methods: {
    fetchData() {
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'get_operaciones',
          params: { opcion: this.opcion }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse && json.eResponse.success) {
            this.operaciones = json.eResponse.data;
          } else {
            this.operaciones = [];
            alert(json.eResponse ? json.eResponse.message : 'Error desconocido');
          }
        })
        .catch(() => {
          this.operaciones = [];
          alert('Error de comunicación con el servidor');
        })
        .finally(() => {
          this.loading = false;
        });
    },
    updateNow() {
      const d = new Date();
      this.now = d.toLocaleString();
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 900px;
}
table th, table td {
  vertical-align: middle;
}
</style>
