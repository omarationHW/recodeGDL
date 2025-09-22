<template>
  <div class="container py-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Relación de Folios</li>
      </ol>
    </nav>
    <h2 class="mb-3">Relación de folios de estacionómetros</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="opcion" class="form-label">Tipo de Fecha</label>
          <select v-model.number="form.opcion" id="opcion" class="form-select" required>
            <option :value="1">Por Fecha de Folio</option>
            <option :value="2">Por Fecha de Alta</option>
            <option :value="3">Por Fecha de Baja (Pago)</option>
            <option :value="4">Por Fecha de Baja (Cancelación)</option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="fecha" class="form-label">Fecha</label>
          <input type="date" v-model="form.fecha" id="fecha" class="form-control" required />
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary w-100">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <div class="table-responsive">
        <table class="table table-bordered table-striped">
          <thead class="table-light">
            <tr>
              <th>AÑO</th>
              <th>FOLIO</th>
              <th>PLACA</th>
              <th>CLAVE</th>
              <th>ESTADO</th>
              <th>TARIFA</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in report" :key="row.axo + '-' + row.folio">
              <td>{{ row.axo }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.placa }}</td>
              <td>{{ row.infraccion }}</td>
              <td>{{ row.estado }}</td>
              <td>{{ row.tarifa | currency }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-secondary">No hay datos para mostrar.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RelacionFoliosPage',
  data() {
    return {
      form: {
        opcion: 1,
        fecha: '',
      },
      report: [],
      loading: false,
      error: '',
    };
  },
  filters: {
    currency(value) {
      if (typeof value !== 'number') return value;
      return '$' + value.toFixed(2);
    },
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
            'Accept': 'application/json',
          },
          body: JSON.stringify({
            eRequest: 'sQRp_relacion_folios_report',
            params: {
              opcion: this.form.opcion,
              fecha: this.form.fecha,
            },
          }),
        });
        const data = await response.json();
        if (data.success) {
          this.report = data.data;
        } else {
          this.error = data.message || 'Error al obtener datos.';
        }
      } catch (err) {
        this.error = 'Error de red o del servidor.';
      } finally {
        this.loading = false;
      }
    },
  },
};
</script>

<style scoped>
.table th, .table td {
  vertical-align: middle;
}
</style>
