<template>
  <div class="rpt-adeudos-anteriores">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Adeudos Anteriores</li>
      </ol>
    </nav>
    <h1 class="mb-4">Listado de Adeudos de Años Anteriores a 1996 de Mercados</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label for="axo">Año</label>
          <input v-model.number="form.axo" type="number" min="1900" max="2099" class="form-control" id="axo" required />
        </div>
        <div class="col-md-3">
          <label for="oficina">Oficina</label>
          <input v-model.number="form.oficina" type="number" min="1" max="99" class="form-control" id="oficina" required />
        </div>
        <div class="col-md-3">
          <label for="periodo">Periodo (Mes)</label>
          <input v-model.number="form.periodo" type="number" min="1" max="12" class="form-control" id="periodo" required />
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn btn-primary w-100">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <table class="table table-bordered table-sm table-hover">
        <thead class="thead-light">
          <tr>
            <th>ID Local</th>
            <th>Datos Local</th>
            <th>Nombre</th>
            <th>Año</th>
            <th>Meses</th>
            <th>Renta</th>
            <th>Adeudo</th>
            <th>Mercado</th>
            <th>Recaudadora</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_local + '-' + row.axo">
            <td>{{ row.id_local }}</td>
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.axo }}</td>
            <td>
              <span v-if="row.meses">{{ row.meses }}</span>
              <span v-else>-</span>
            </td>
            <td>{{ currency(row.renta) }}</td>
            <td>{{ currency(row.adeudo) }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.recaudadora }}</td>
          </tr>
        </tbody>
      </table>
      <div class="row mt-3">
        <div class="col-md-3">
          <strong>Total de Registros:</strong> {{ report.length }}
        </div>
        <div class="col-md-3">
          <strong>Total Adeudo:</strong> {{ currency(totalAdeudo) }}
        </div>
        <div class="col-md-3">
          <strong>Total Renta:</strong> {{ currency(totalRenta) }}
        </div>
      </div>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-warning">No hay datos para los parámetros seleccionados.</div>
  </div>
</template>

<script>
export default {
  name: 'RptAdeudosAnteriores',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        oficina: '',
        periodo: new Date().getMonth() + 1
      },
      report: [],
      loading: false,
      error: '',
      totalAdeudo: 0,
      totalRenta: 0
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      this.totalAdeudo = 0;
      this.totalRenta = 0;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'get_report',
            params: {
              axo: this.form.axo,
              oficina: this.form.oficina,
              periodo: this.form.periodo
            }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.report = json.data;
          this.totalAdeudo = this.report.reduce((sum, r) => sum + (parseFloat(r.adeudo) || 0), 0);
          this.totalRenta = this.report.reduce((sum, r) => sum + (parseFloat(r.renta) || 0), 0);
        } else {
          this.error = json.message || 'Error al consultar el reporte.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    currency(val) {
      if (val === null || val === undefined) return '-';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpt-adeudos-anteriores {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
