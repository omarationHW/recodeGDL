<template>
  <div class="rpt-padron-energia-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón Energía Eléctrica</li>
      </ol>
    </nav>
    <h1 class="mb-4">Padrón de Energía Eléctrica del Mercado</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="oficina" class="form-label">Oficina</label>
          <input type="number" v-model.number="form.oficina" id="oficina" class="form-control" required min="1">
        </div>
        <div class="col-md-3">
          <label for="mercado" class="form-label">Mercado</label>
          <input type="number" v-model.number="form.mercado" id="mercado" class="form-control" required min="1">
        </div>
        <div class="col-md-3">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando reporte...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report">
      <div class="mb-3">
        <strong>Mercado:</strong> {{ report.descripcion_mercado }}
      </div>
      <div class="table-responsive">
        <table class="table table-bordered table-striped">
          <thead class="table-light">
            <tr>
              <th>ID</th>
              <th>Datos del Local</th>
              <th>Nombre</th>
              <th>Locales Adicionales</th>
              <th>K / Cuota</th>
              <th>Vigencia</th>
              <th>F/K</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in report.registros" :key="row.id_local">
              <td class="text-end">{{ row.id_local }}</td>
              <td>{{ row.datoslocal }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.local_adicional }}</td>
              <td class="text-end">{{ formatCurrency(row.cantidad) }}</td>
              <td class="text-center">{{ row.vigencia }}</td>
              <td class="text-center">{{ row.cve_consumo }}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="table-secondary">
              <td colspan="4"><strong>Total de Registros:</strong> {{ report.total_registros }}</td>
              <td class="text-end"><strong>{{ formatCurrency(report.total_cuota) }}</strong></td>
              <td colspan="2"></td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPadronEnergiaPage',
  data() {
    return {
      form: {
        oficina: '',
        mercado: ''
      },
      loading: false,
      error: '',
      report: null
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'RptPadronEnergia.getReport',
              data: {
                oficina: this.form.oficina,
                mercado: this.form.mercado
              }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          this.report = json.eResponse.data;
        } else {
          this.error = json.eResponse && json.eResponse.message ? json.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(value) {
      if (typeof value !== 'number') value = parseFloat(value);
      return value.toLocaleString('es-MX', { style: 'currency', currency: 'MXN', minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.rpt-padron-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
