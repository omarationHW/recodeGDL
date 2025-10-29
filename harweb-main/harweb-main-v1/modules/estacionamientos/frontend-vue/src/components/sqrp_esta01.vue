<template>
  <div class="sqrp-esta01-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Informe Concentrado de Multas de Estacionómetros</li>
      </ol>
    </nav>
    <h1 class="mb-2">Municipio de Guadalajara</h1>
    <h2 class="mb-2">Dirección de Estacionamientos Públicos</h2>
    <h3 class="mb-4">Informe concentrado de multas de estacionómetros</h3>
    <form @submit.prevent="fetchReport" class="mb-4 row g-3 align-items-end">
      <div class="col-auto">
        <label for="axo_from" class="form-label">Año desde</label>
        <input type="number" class="form-control" id="axo_from" v-model="filters.axo_from" min="2000" max="2100" placeholder="Ej: 2020">
      </div>
      <div class="col-auto">
        <label for="axo_to" class="form-label">Año hasta</label>
        <input type="number" class="form-control" id="axo_to" v-model="filters.axo_to" min="2000" max="2100" placeholder="Ej: 2023">
      </div>
      <div class="col-auto">
        <button type="submit" class="btn btn-primary">Consultar</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0">
      <table class="table table-bordered table-striped">
        <thead class="table-light">
          <tr>
            <th>Año</th>
            <th>Clave</th>
            <th>Cantidad de infracciones</th>
            <th>Cantidad</th>
            <th>Total Importe</th>
          </tr>
        </thead>
        <tbody>
          <template v-for="(row, idx) in report" :key="idx">
            <tr>
              <td>{{ row.axo }}</td>
              <td>{{ row.infraccion }}</td>
              <td>{{ row.totfol }}</td>
              <td>{{ row.totfol }}</td>
              <td>{{ formatCurrency(row.totimp) }}</td>
            </tr>
          </template>
        </tbody>
        <tfoot>
          <tr class="table-secondary">
            <th colspan="2">Totales</th>
            <th>{{ totalInfracciones }}</th>
            <th>{{ totalInfracciones }}</th>
            <th>{{ formatCurrency(totalImporte) }}</th>
          </tr>
        </tfoot>
      </table>
      <div class="mt-3 text-muted">DPD - Análisis y programación</div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay datos para los filtros seleccionados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SqrpEsta01Report',
  data() {
    return {
      filters: {
        axo_from: '',
        axo_to: ''
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalInfracciones() {
      return this.report.reduce((sum, r) => sum + Number(r.totfol), 0);
    },
    totalImporte() {
      return this.report.reduce((sum, r) => sum + Number(r.totimp), 0);
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
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'sqrp_esta01_report',
            params: {
              axo_from: this.filters.axo_from || null,
              axo_to: this.filters.axo_to || null
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  mounted() {
    this.fetchReport();
  }
};
</script>

<style scoped>
.sqrp-esta01-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
}
</style>
