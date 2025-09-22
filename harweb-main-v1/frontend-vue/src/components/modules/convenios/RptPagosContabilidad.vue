<template>
  <div class="rpt-pagos-contabilidad-page">
    <h1>Reporte de Pagos Contabilidad</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos Contabilidad</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-group">
        <label for="fecdesde">Fecha Desde</label>
        <input type="date" v-model="fecdesde" id="fecdesde" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="fechasta">Fecha Hasta</label>
        <input type="date" v-model="fechasta" id="fechasta" class="form-control" required />
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Fondo</th>
            <th>Año Obra</th>
            <th>Cuenta</th>
            <th>Ingreso</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.tipo + '-' + row.axo_obra + '-' + row.cuenta_ingreso">
            <td>{{ row.descripcion }}</td>
            <td>{{ row.axo_obra }}</td>
            <td>{{ row.cuenta_ingreso }}</td>
            <td>{{ row.ingreso | currency }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total General: </strong>
        {{ totalGeneral | currency }}
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPagosContabilidadPage',
  data() {
    return {
      fecdesde: '',
      fechasta: '',
      report: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    totalGeneral() {
      return this.report.reduce((sum, row) => sum + Number(row.ingreso), 0);
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
              action: 'getRptPagosContabilidad',
              params: {
                fecdesde: this.fecdesde,
                fechasta: this.fechasta
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al consultar el reporte';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.rpt-pagos-contabilidad-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
