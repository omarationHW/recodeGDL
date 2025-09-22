<template>
  <div class="cons-tipos-aseo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consultas de Tipos de Aseo</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body d-flex align-items-center">
        <div class="me-3">
          <label for="orderBy" class="form-label mb-0 me-2">Clasificación por:</label>
          <select v-model="orderBy" id="orderBy" class="form-select d-inline-block w-auto" @change="fetchData">
            <option value="ctrol_aseo">Control</option>
            <option value="tipo_aseo">Tipo</option>
            <option value="descripcion">Descripción</option>
          </select>
        </div>
        <button class="btn btn-success ms-auto me-2" @click="exportExcel"><i class="bi bi-file-earmark-excel"></i> Exportar Excel</button>
        <button class="btn btn-secondary" @click="goBack">Salir</button>
      </div>
    </div>
    <div class="card">
      <div class="card-body p-0">
        <table class="table table-striped table-hover mb-0">
          <thead>
            <tr>
              <th>Control</th>
              <th>Tipo</th>
              <th>Descripción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in rows" :key="row.ctrol_aseo">
              <td>{{ row.ctrol_aseo }}</td>
              <td>{{ row.tipo_aseo }}</td>
              <td>{{ row.descripcion }}</td>
            </tr>
            <tr v-if="rows.length === 0">
              <td colspan="3" class="text-center">No hay registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="loading" class="text-center my-3">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsTiposAseoPage',
  data() {
    return {
      rows: [],
      orderBy: 'ctrol_aseo',
      loading: false,
      error: ''
    };
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      this.loading = true;
      this.error = '';
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'cons_tipos_aseo_list',
          params: { order: this.orderBy }
        }
      })
      .then(res => {
        if (res.data.eResponse.success) {
          this.rows = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al cargar datos';
        }
      })
      .catch(err => {
        this.error = err.message || 'Error de red';
      })
      .finally(() => {
        this.loading = false;
      });
    },
    exportExcel() {
      // Puede ser una descarga directa o abrir en nueva ventana
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'cons_tipos_aseo_export_excel',
          params: { order: this.orderBy }
        }
      }).then(res => {
        // Implementar descarga real según backend
        alert('Exportación a Excel generada (implementación pendiente)');
      });
    },
    goBack() {
      this.$router.back();
    }
  }
}
</script>

<style scoped>
.cons-tipos-aseo-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
</style>
