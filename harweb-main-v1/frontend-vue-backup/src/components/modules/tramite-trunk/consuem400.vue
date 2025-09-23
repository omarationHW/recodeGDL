<template>
  <div class="consuem400-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta UEM-400</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Consulta de Datos Históricos del UEM-400</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSearch">
          <div class="form-row">
            <div class="form-group col-md-4">
              <label for="recaud">Recaudadora</label>
              <input type="number" class="form-control" id="recaud" v-model="form.recaud" required @keyup.enter="focusUr" />
            </div>
            <div class="form-group col-md-4">
              <label for="ur">UR (0 o 1)</label>
              <input type="number" class="form-control" id="ur" v-model="form.ur" required @keyup.enter="focusCuenta" />
            </div>
            <div class="form-group col-md-4">
              <label for="cuenta">Cuenta</label>
              <input type="number" class="form-control" id="cuenta" v-model="form.cuenta" required @keyup.enter="onSearch" />
            </div>
          </div>
          <button type="submit" class="btn btn-primary" :disabled="loading">Buscar</button>
        </form>
        <div v-if="message" class="alert mt-3" :class="{'alert-danger': !success, 'alert-success': success}">
          {{ message }}
        </div>
        <div v-if="results.length > 0" class="table-responsive mt-4">
          <h5>Histórico del UEM AS-400</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th v-for="col in columns" :key="col">{{ col }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in results" :key="idx">
                <td v-for="col in columns" :key="col">{{ row[col] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Consuem400Page',
  data() {
    return {
      form: {
        recaud: '',
        ur: '',
        cuenta: ''
      },
      results: [],
      columns: [],
      message: '',
      success: true,
      loading: false
    };
  },
  methods: {
    focusUr() {
      this.$refs.ur && this.$refs.ur.focus();
    },
    focusCuenta() {
      this.$refs.cuenta && this.$refs.cuenta.focus();
    },
    async onSearch() {
      this.loading = true;
      this.message = '';
      this.results = [];
      this.columns = [];
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'search',
            params: {
              recaud: this.form.recaud,
              ur: this.form.ur,
              cuenta: this.form.cuenta
            }
          }
        });
        const eResponse = response.data.eResponse;
        this.success = eResponse.success;
        this.message = eResponse.message;
        if (eResponse.success && eResponse.data && eResponse.data.length > 0) {
          this.results = eResponse.data;
          this.columns = Object.keys(this.results[0]);
        } else {
          this.results = [];
          this.columns = [];
        }
      } catch (err) {
        this.success = false;
        this.message = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.consume400-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-top: 20px;
}
.table-responsive {
  max-height: 400px;
  overflow-y: auto;
}
</style>
