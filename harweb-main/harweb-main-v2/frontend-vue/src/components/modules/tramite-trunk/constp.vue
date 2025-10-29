<template>
  <div class="container mt-5">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Transmisiones Patrimoniales</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        Consulta de Transmisiones Patrimoniales
      </div>
      <div class="card-body">
        <form @submit.prevent="submitForm">
          <div class="mb-3 row">
            <label for="notaria" class="col-sm-3 col-form-label">Notaría</label>
            <div class="col-sm-9">
              <input type="number" min="0" class="form-control" id="notaria" v-model.number="form.notaria" required />
            </div>
          </div>
          <div class="mb-3 row">
            <label for="municipio" class="col-sm-3 col-form-label">Municipio de Adscripción</label>
            <div class="col-sm-9">
              <input type="number" min="0" class="form-control" id="municipio" v-model.number="form.municipio" required />
            </div>
          </div>
          <div class="mb-3 row">
            <label for="escritura" class="col-sm-3 col-form-label">Escritura</label>
            <div class="col-sm-9">
              <input type="number" min="0" class="form-control" id="escritura" v-model.number="form.escritura" required />
            </div>
          </div>
          <div class="mb-3 text-end">
            <button type="submit" class="btn btn-success" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm"></span>
              Consultar
            </button>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="result && result.length" class="mt-4">
          <h5>Resultado de la Consulta</h5>
          <table class="table table-bordered table-sm mt-2">
            <thead>
              <tr>
                <th>#</th>
                <th>Notaría</th>
                <th>Municipio</th>
                <th>Escritura</th>
                <th>Otros Datos</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in result" :key="idx">
                <td>{{ idx + 1 }}</td>
                <td>{{ row.notaria }}</td>
                <td>{{ row.municipio }}</td>
                <td>{{ row.escritura }}</td>
                <td>{{ row.otros_datos }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="result && !result.length" class="alert alert-info mt-3">
          No se encontraron resultados para los criterios ingresados.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsTPPage',
  data() {
    return {
      form: {
        notaria: '',
        municipio: '',
        escritura: ''
      },
      loading: false,
      error: '',
      result: null
    };
  },
  methods: {
    async submitForm() {
      this.error = '';
      this.result = null;
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              operation: 'constp_query',
              params: {
                notaria: this.form.notaria,
                municipio: this.form.municipio,
                escritura: this.form.escritura
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.result = data.eResponse.data;
        } else {
          this.error = data.eResponse.error || 'Error desconocido en la consulta.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 600px;
}
</style>
