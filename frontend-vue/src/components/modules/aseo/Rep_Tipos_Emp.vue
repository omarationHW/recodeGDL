<template>
  <div class="rep-tipos-emp-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Tipos de Empresas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Impresiones de Tipos de Empresas</h4>
      </div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-6">
            <label for="orderSelect"><strong>Ordenado Por:</strong></label>
            <select v-model="order" id="orderSelect" class="form-control w-75 d-inline-block ml-2">
              <option v-for="opt in orderOptions" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>
          </div>
          <div class="col-md-6 text-right">
            <button class="btn btn-success mr-2" @click="fetchReport"><i class="fa fa-search"></i> Vista Previa</button>
            <button class="btn btn-danger" @click="$router.back()"><i class="fa fa-times"></i> Salir</button>
          </div>
        </div>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="report.length > 0">
          <table class="table table-bordered table-striped table-sm">
            <thead class="thead-light">
              <tr>
                <th># Control</th>
                <th>Tipo Empresa</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in report" :key="row.ctrol_emp">
                <td>{{ row.ctrol_emp }}</td>
                <td>{{ row.tipo_empresa }}</td>
                <td>{{ row.descripcion }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="!loading && report.length === 0" class="alert alert-info">
          No hay datos para mostrar.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepTiposEmpPage',
  data() {
    return {
      order: 1,
      orderOptions: [
        { value: 1, label: 'Control' },
        { value: 2, label: 'Tipo' },
        { value: 3, label: 'Descripción' }
      ],
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
          action: 'getTiposEmpReport',
          params: { order: this.order }
        });
        if (res.data.success) {
          this.report = res.data.data;
        } else {
          this.error = res.data.message || 'Error al obtener datos';
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
.rep-tipos-emp-page {
  max-width: 800px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
