<template>
  <div class="rep-tipos-aseo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Tipos de Aseo</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Impresiones de Tipos de Aseo</h4>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label class="form-label">Ordenado Por:</label>
          <div class="btn-group" role="group">
            <button type="button" class="btn btn-outline-secondary" :class="{'active': order === 1}" @click="order = 1">Control</button>
            <button type="button" class="btn btn-outline-secondary" :class="{'active': order === 2}" @click="order = 2">Tipo</button>
            <button type="button" class="btn btn-outline-secondary" :class="{'active': order === 3}" @click="order = 3">Descripción</button>
          </div>
        </div>
        <div class="mb-3">
          <button class="btn btn-success me-2" @click="fetchReport"><i class="fa fa-search"></i> Vista Previa</button>
          <button class="btn btn-danger" @click="$router.back()"><i class="fa fa-times"></i> Salir</button>
        </div>
        <div v-if="loading" class="alert alert-info">Cargando...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="report.length > 0">
          <table class="table table-bordered table-striped mt-3">
            <thead class="table-light">
              <tr>
                <th style="width: 120px"># Control</th>
                <th style="width: 120px">Tipo</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in report" :key="row.ctrol_aseo">
                <td>{{ row.ctrol_aseo }}</td>
                <td>{{ row.tipo_aseo }}</td>
                <td>{{ row.descripcion }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="!loading && report.length === 0" class="alert alert-warning mt-3">
          No hay datos para mostrar.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RepTiposAseoPage',
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
        const resp = await this.$axios.post('/api/execute', {
          action: 'getTiposAseoReport',
          params: { order: this.order }
        });
        if (resp.data.success) {
          this.report = resp.data.data;
        } else {
          this.error = resp.data.message || 'Error al obtener el reporte.';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message || 'Error de red';
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
.rep-tipos-aseo-page {
  max-width: 700px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.07);
}
.breadcrumb {
  background: #f8f9fa;
  padding: 8px 16px;
  border-radius: 4px;
}
</style>
