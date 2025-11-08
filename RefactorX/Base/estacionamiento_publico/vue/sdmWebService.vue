<template>
  <div class="predio-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Predio</li>
      </ol>
    </nav>
    <h1>Consulta de Predio</h1>
    <form @submit.prevent="consultarPredio">
      <div class="form-group">
        <label for="s_idpredial">ID Predial</label>
        <input v-model="form.s_idpredial" type="text" class="form-control" id="s_idpredial" required>
      </div>
      <div class="form-group">
        <label for="s_opcion">Opción</label>
        <input v-model="form.s_opcion" type="text" class="form-control" id="s_opcion" required>
      </div>
      <button type="submit" class="btn btn-primary" :disabled="loading">Consultar</button>
    </form>
    <div v-if="loading" class="mt-3">
      <span class="spinner-border spinner-border-sm"></span> Consultando...
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="predios.length" class="mt-4">
      <h2>Resultado</h2>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Cve Cuenta</th>
            <th>Recaud</th>
            <th>Tipo</th>
            <th>Cuenta</th>
            <th>Cve Catastral</th>
            <th>Subpredio</th>
            <th>Propietario</th>
            <th>Calle</th>
            <th>Num Ext</th>
            <th>Zona</th>
            <th>Subzona</th>
            <th>Status</th>
            <th>Mensaje</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(predio, idx) in predios" :key="idx">
            <td>{{ predio.cvecuenta }}</td>
            <td>{{ predio.recaud }}</td>
            <td>{{ predio.tipo }}</td>
            <td>{{ predio.cuenta }}</td>
            <td>{{ predio.cvecatastral }}</td>
            <td>{{ predio.subpredio }}</td>
            <td>{{ predio.propietario }}</td>
            <td>{{ predio.calle }}</td>
            <td>{{ predio.numext }}</td>
            <td>{{ predio.zona }}</td>
            <td>{{ predio.subzona }}</td>
            <td>{{ predio.status }}</td>
            <td>{{ predio.mensaje }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaPredioPage',
  data() {
    return {
      form: {
        s_idpredial: '',
        s_opcion: ''
      },
      loading: false,
      error: '',
      predios: []
    };
  },
  methods: {
    async consultarPredio() {
      this.loading = true;
      this.error = '';
      this.predios = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.consultaPredio',
          payload: {
            s_idpredial: this.form.s_idpredial,
            s_opcion: this.form.s_opcion
          }
        });
        if (res.data.status === 'success') {
          this.predios = res.data.data;
        } else {
          this.error = res.data.message || 'Error desconocido';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.predio-page {
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
