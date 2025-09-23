<template>
  <div class="ctrol-imp-cat-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Impresión de Claves de Operación
    </div>
    <h1>Impresión de Claves de Operación</h1>
    <div class="panel panel-top">
      <p>Seleccione el orden para la impresión del catálogo de claves de operación.</p>
    </div>
    <div class="panel panel-main">
      <div class="form-group">
        <label for="order">Ordenado Por:</label>
        <div>
          <label v-for="opt in options" :key="opt.value" class="radio-inline">
            <input type="radio" v-model="selectedOrder" :value="opt.value"> {{ opt.label }}
          </label>
        </div>
      </div>
      <div class="form-actions">
        <button class="btn btn-primary" @click="previewReport">Vista Previa</button>
        <button class="btn btn-secondary" @click="goBack">Salir</button>
      </div>
      <div v-if="loading" class="loading">Cargando...</div>
      <div v-if="error" class="alert alert-danger">{{ error }}</div>
      <div v-if="reportData.length > 0" class="report-preview">
        <h3>Vista Previa del Reporte</h3>
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th># Control</th>
              <th>Clave</th>
              <th>Descripción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in reportData" :key="row.ctrol_operacion">
              <td>{{ row.ctrol_operacion }}</td>
              <td>{{ row.cve_operacion }}</td>
              <td>{{ row.descripcion }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CtrolImpCatPage',
  data() {
    return {
      options: [],
      selectedOrder: 1,
      reportData: [],
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
        action: 'getOptions'
      }).then(res => {
        if (res.data.success) {
          this.options = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar opciones';
        }
      }).catch(() => {
        this.error = 'Error de red al cargar opciones';
      }).finally(() => {
        this.loading = false;
      });
    },
    previewReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      this.$axios.post('/api/execute', {
        action: 'previewReport',
        params: {
          order: this.selectedOrder
        }
      }).then(res => {
        if (res.data.success) {
          this.reportData = res.data.data;
        } else {
          this.error = res.data.message || 'Error al obtener el reporte';
        }
      }).catch(() => {
        this.error = 'Error de red al obtener el reporte';
      }).finally(() => {
        this.loading = false;
      });
    },
    goBack() {
      this.$router.push('/');
    }
  }
}
</script>

<style scoped>
.ctrol-imp-cat-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
}
.panel {
  background: #f8f9fa;
  border-radius: 4px;
  padding: 1rem;
  margin-bottom: 1rem;
}
.panel-main {
  border: 1px solid #e0e0e0;
}
.form-group {
  margin-bottom: 1rem;
}
.form-actions {
  margin-bottom: 1rem;
}
.loading {
  color: #007bff;
}
.report-preview {
  margin-top: 2rem;
}
.table {
  background: #fff;
}
</style>
