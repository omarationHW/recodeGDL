<template>
  <div class="rep-zonas-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Zonas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Impresiones de Zonas</h3>
      </div>
      <div class="card-body">
        <div class="form-group">
          <label>Ordenado Por:</label>
          <div>
            <label class="mr-3"><input type="radio" v-model="order" :value="1" /> Control</label>
            <label class="mr-3"><input type="radio" v-model="order" :value="2" /> Zona</label>
            <label class="mr-3"><input type="radio" v-model="order" :value="3" /> Sub-Zona</label>
            <label class="mr-3"><input type="radio" v-model="order" :value="4" /> Descripción</label>
          </div>
        </div>
        <div class="mt-3">
          <button class="btn btn-primary mr-2" @click="fetchReport">Vista Previa</button>
          <button class="btn btn-secondary" @click="goBack">Salir</button>
        </div>
        <div v-if="loading" class="mt-3">
          <span>Cargando...</span>
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="reportData.length" class="mt-4">
          <h5>Reporte de Zonas</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th># Control</th>
                <th>Zona</th>
                <th>Sub-Zona</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in reportData" :key="row.ctrol_zona">
                <td>{{ row.ctrol_zona }}</td>
                <td>{{ row.zona }}</td>
                <td>{{ row.sub_zona }}</td>
                <td>{{ row.descripcion }}</td>
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
  name: 'RepZonasPage',
  data() {
    return {
      order: 1,
      reportData: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'getZonasReport',
          params: { order: this.order }
        }
      })
      .then(res => {
        if (res.data.eResponse.success) {
          this.reportData = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al obtener el reporte';
        }
      })
      .catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    goBack() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.rep-zonas-page {
  max-width: 700px;
  margin: 0 auto;
}
.card {
  margin-top: 20px;
}
</style>
