<template>
  <div class="rpt-pagos-desarrollo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Pagos Desarrollo</li>
      </ol>
    </nav>
    <h1 class="mb-4">Reporte de Pagos de Desarrollo</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="fecdesde" class="form-label">Fecha Desde</label>
          <input type="date" v-model="form.fecdesde" id="fecdesde" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label for="fechasta" class="form-label">Fecha Hasta</label>
          <input type="date" v-model="form.fechasta" id="fechasta" class="form-control" required />
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0">
      <h5 class="mt-4">Resultados del Reporte</h5>
      <table class="table table-bordered table-striped mt-2">
        <thead>
          <tr>
            <th>Fondo</th>
            <th>Año de Obra</th>
            <th class="text-end">Ingreso</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.tipo + '-' + row.axo_obra">
            <td>{{ row.descripcion }}</td>
            <td>{{ row.axo_obra }}</td>
            <td class="text-end">{{ formatCurrency(row.ingreso) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th colspan="2" class="text-end">Total General</th>
            <th class="text-end">{{ formatCurrency(totalGeneral) }}</th>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay datos para el rango seleccionado.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPagosDesarrolloPage',
  data() {
    return {
      form: {
        fecdesde: '',
        fechasta: ''
      },
      report: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    totalGeneral() {
      return this.report.reduce((sum, row) => sum + Number(row.ingreso || 0), 0);
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getReport',
              params: {
                fecdesde: this.form.fecdesde,
                fechasta: this.form.fechasta
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data.map(row => ({
            ...row,
            ingreso: Number(row.ingreso),
            axo_obra: row.axo_obra,
            descripcion: row.descripcion
          }));
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido.';
        }
      } catch (err) {
        this.error = 'Error de red o del servidor.';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(val || 0);
    }
  }
};
</script>

<style scoped>
.rpt-pagos-desarrollo-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
