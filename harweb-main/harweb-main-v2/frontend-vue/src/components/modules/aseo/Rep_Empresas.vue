<template>
  <div class="empresas-report-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Empresas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Impresiones de Empresas</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onPreview">
          <div class="form-group">
            <label for="order">Ordenado Por:</label>
            <div class="row">
              <div class="col-md-6">
                <div v-for="opt in options" :key="opt.id" class="form-check">
                  <input class="form-check-input" type="radio" :id="'opt'+opt.id" :value="opt.id" v-model="selectedOrder">
                  <label class="form-check-label" :for="'opt'+opt.id">{{ opt.label }}</label>
                </div>
              </div>
            </div>
          </div>
          <div class="form-group mt-3">
            <button type="submit" class="btn btn-primary mr-2">Vista Previa</button>
            <button type="button" class="btn btn-secondary" @click="onExit">Salir</button>
          </div>
        </form>
        <div v-if="loading" class="mt-3">
          <span class="spinner-border spinner-border-sm"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="reportData && reportData.length" class="mt-4">
          <h5>Resultados:</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th># Empresa</th>
                <th>Tipo Empresa</th>
                <th>Nombre</th>
                <th>Representante</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in reportData" :key="row.num_empresa + '-' + row.ctrol_emp">
                <td>{{ row.num_empresa }}</td>
                <td>{{ row.tipo_empresa }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.representante }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="reportData && !reportData.length" class="alert alert-info mt-3">
          No hay datos para mostrar.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmpresasReportPage',
  data() {
    return {
      options: [],
      selectedOrder: 1,
      reportData: null,
      loading: false,
      error: ''
    };
  },
  created() {
    this.fetchOptions();
  },
  methods: {
    fetchOptions() {
      this.loading = true;
      this.$axios.post('/api/execute', {
        action: 'getReportOptions',
        params: {}
      }).then(res => {
        if (res.data.status === 'success') {
          this.options = res.data.data;
          if (this.options.length) {
            this.selectedOrder = this.options[0].id;
          }
        } else {
          this.error = res.data.message;
        }
      }).catch(err => {
        this.error = err.message;
      }).finally(() => {
        this.loading = false;
      });
    },
    onPreview() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      this.$axios.post('/api/execute', {
        action: 'getEmpresasReport',
        params: { order: this.selectedOrder }
      }).then(res => {
        if (res.data.status === 'success') {
          this.reportData = res.data.data;
        } else {
          this.error = res.data.message;
        }
      }).catch(err => {
        this.error = err.message;
      }).finally(() => {
        this.loading = false;
      });
    },
    onExit() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.empresas-report-page {
  max-width: 700px;
  margin: 0 auto;
}
.card {
  margin-top: 30px;
}
</style>
