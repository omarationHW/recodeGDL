<template>
  <div class="rpt-adeudos-contratos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Adeudos por Contrato</li>
      </ol>
    </nav>
    <h2 class="mb-4">Listado de Adeudos por Colonia y Calle</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="colonia" class="form-label">Colonia</label>
          <input type="number" v-model.number="form.colonia" id="colonia" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label for="calle" class="form-label">Calle</label>
          <input type="number" v-model.number="form.calle" id="calle" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label for="rep" class="form-label">Tipo de Reporte</label>
          <select v-model.number="form.rep" id="rep" class="form-select">
            <option :value="1">Contratos Vigentes con Adeudos</option>
            <option :value="2">Contratos Vigentes con Saldos a Favor</option>
            <option :value="3">Contratos Vigentes Liquidados</option>
          </select>
        </div>
        <div class="col-md-3">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0">
      <div class="mb-3">
        <strong>Colonia:</strong> {{ report[0].colonia }} - {{ report[0].descripcion }}<br />
        <strong>Calle:</strong> {{ report[0].calle }} - {{ report[0].desc_calle }}
      </div>
      <table class="table table-bordered table-sm">
        <thead class="table-light">
          <tr>
            <th>Folio</th>
            <th>Nombre</th>
            <th class="text-end">Costo</th>
            <th class="text-end">Pagos</th>
            <th class="text-end">Saldo</th>
            <th>Concepto</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_convenio">
            <td>{{ row.folio }}</td>
            <td>{{ row.nombre }}</td>
            <td class="text-end">{{ money(row.pago_total) }}</td>
            <td class="text-end">{{ money(row.pagosreal) }}</td>
            <td class="text-end">{{ money(row.pago_total - row.pagosreal) }}</td>
            <td>{{ row.concepto }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="table-secondary">
            <td colspan="2"><strong>Total General:</strong></td>
            <td class="text-end"><strong>{{ money(total('pago_total')) }}</strong></td>
            <td class="text-end"><strong>{{ money(total('pagosreal')) }}</strong></td>
            <td class="text-end"><strong>{{ money(totalSaldo) }}</strong></td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-warning">No se encontraron resultados.</div>
  </div>
</template>

<script>
export default {
  name: 'RptAdeudosContratos',
  data() {
    return {
      form: {
        colonia: '',
        calle: '',
        rep: 1
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalSaldo() {
      return this.report.reduce((sum, r) => sum + (r.pago_total - r.pagosreal), 0);
    }
  },
  methods: {
    money(val) {
      if (typeof val !== 'number') return '';
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    total(field) {
      return this.report.reduce((sum, r) => sum + (parseFloat(r[field]) || 0), 0);
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'RptAdeudosContratos',
            params: {
              colonia: this.form.colonia,
              calle: this.form.calle,
              rep: this.form.rep
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rpt-adeudos-contratos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
