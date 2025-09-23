<template>
  <div class="und-recolec-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Unidades de Recolección</li>
      </ol>
    </nav>
    <h1>Impresiones de Unidades de Recolección</h1>
    <div class="card mb-3">
      <div class="card-body">
        <div class="form-row align-items-end">
          <div class="form-group col-md-3">
            <label for="ejercicio">Ejercicio</label>
            <input type="number" v-model="ejercicio" class="form-control" id="ejercicio" min="2000" max="2100" />
          </div>
          <div class="form-group col-md-5">
            <label for="order">Ordenado Por</label>
            <select v-model="order" class="form-control" id="order">
              <option :value="1">Control</option>
              <option :value="2">Clave</option>
              <option :value="3">Descripción</option>
              <option :value="4">Costo de Unidad</option>
            </select>
          </div>
          <div class="form-group col-md-4 text-right">
            <button class="btn btn-primary mr-2" @click="fetchReport">Vista Previa</button>
            <button class="btn btn-secondary" @click="$router.back()">Salir</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th># Control</th>
            <th>Ejercicio</th>
            <th>Clave</th>
            <th>Descripción</th>
            <th>Costo Unidad</th>
            <th>Costo Excedente</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.ctrol_recolec">
            <td>{{ row.ctrol_recolec }}</td>
            <td>{{ row.ejercicio_recolec }}</td>
            <td>{{ row.cve_recolec }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.costo_unidad | currency }}</td>
            <td>{{ row.costo_exed | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading">
      <div class="alert alert-warning">No hay datos para mostrar.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UndRecolecPage',
  data() {
    return {
      ejercicio: new Date().getFullYear(),
      order: 1,
      report: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const resp = await this.$axios.post('/api/execute', {
          action: 'und_recolec_report',
          params: {
            ejercicio: this.ejercicio,
            order: this.order
          }
        });
        if (resp.data.success) {
          this.report = resp.data.data;
        } else {
          this.error = resp.data.message || 'Error al obtener datos';
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
.und-recolec-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
</style>
