<template>
  <div class="rpt-liquidados-general-col-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Contratos Liquidados por Colonia</li>
      </ol>
    </nav>
    <h2 class="mb-4">Listado de Adeudos por Colonia y Calle</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="colonia" class="form-label">Colonia</label>
          <input type="number" v-model.number="form.colonia" id="colonia" class="form-control" required min="1">
        </div>
        <div class="col-md-3">
          <label for="importe" class="form-label">Importe máximo de saldo ($)</label>
          <input type="number" v-model.number="form.importe" id="importe" class="form-control" required min="0" step="0.01">
        </div>
        <div class="col-md-2">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>

    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="reportData && reportData.length">
      <div class="mb-3">
        <strong>Colonia:</strong> {{ reportData[0].colonia }} - {{ reportData[0].descripcion }}
      </div>
      <div class="mb-3">
        <strong>Contratos vigentes liquidados con saldo menor e igual a ${{ form.importe.toLocaleString(undefined, {minimumFractionDigits:2, maximumFractionDigits:2}) }}</strong>
      </div>
      <div class="table-responsive">
        <table class="table table-bordered table-sm align-middle">
          <thead class="table-light">
            <tr>
              <th>CALLE</th>
              <th>FOL</th>
              <th>NOMBRE</th>
              <th class="text-end">COSTO</th>
              <th class="text-end">PAGOS</th>
              <th class="text-end">SALDO</th>
              <th>CONCEPTO</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in reportData" :key="row.id_convenio">
              <td>{{ row.calle }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.nombre }}</td>
              <td class="text-end">{{ formatCurrency(row.pago_total) }}</td>
              <td class="text-end">{{ formatCurrency(row.pagosreal) }}</td>
              <td class="text-end">{{ formatCurrency(row.pago_total - row.pagosreal) }}</td>
              <td>{{ row.concepto }}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="fw-bold">
              <td colspan="3">TOTAL GENERAL:</td>
              <td class="text-end">{{ formatCurrency(totalPagoTotal) }}</td>
              <td class="text-end">{{ formatCurrency(totalPagosReal) }}</td>
              <td class="text-end">{{ formatCurrency(totalSaldo) }}</td>
              <td>{{ reportData.length }}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
    <div v-else-if="reportData && !reportData.length" class="alert alert-warning">
      No se encontraron registros para los parámetros indicados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptLiquidadosGeneralCol',
  data() {
    return {
      form: {
        colonia: '',
        importe: ''
      },
      loading: false,
      error: '',
      reportData: null
    };
  },
  computed: {
    totalPagoTotal() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, r) => sum + Number(r.pago_total), 0);
    },
    totalPagosReal() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, r) => sum + Number(r.pagosreal), 0);
    },
    totalSaldo() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, r) => sum + (Number(r.pago_total) - Number(r.pagosreal)), 0);
    }
  },
  methods: {
    formatCurrency(val) {
      return '$' + Number(val).toLocaleString(undefined, {minimumFractionDigits:2, maximumFractionDigits:2});
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'RptLiquidadosGeneralCol',
            params: {
              colonia: this.form.colonia,
              importe: this.form.importe
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          // Post-process: ensure numeric fields
          this.reportData = (data.data || []).map(row => ({
            ...row,
            pago_total: Number(row.pago_total),
            pagos: Number(row.pagos),
            devolucion: Number(row.devolucion),
            pagosreal: Number(row.pagosreal)
          }));
        } else {
          this.error = data.error || 'Error desconocido al consultar el reporte.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red o servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rpt-liquidados-general-col-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
