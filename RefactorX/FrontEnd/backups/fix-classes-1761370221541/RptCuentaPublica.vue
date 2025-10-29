<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-bar" /></div>
      <div class="module-view-info">
        <h1>Reporte Cuenta Pública</h1>
        <p>Mercados - Reporte Cuenta Pública</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1 class="mb-4">Cuentas por Cobrar - Reporte Cuenta Pública</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="axo" class="municipal-form-label">Año Fiscal</label>
          <input type="number" v-model.number="form.axo" id="axo" class="municipal-form-control" required min="2000" max="2100">
        </div>
        <div class="col-md-3">
          <label for="oficina" class="municipal-form-label">Oficina/Recaudadora</label>
          <input type="number" v-model.number="form.oficina" id="oficina" class="municipal-form-control" required min="1">
        </div>
        <div class="col-md-3">
          <button type="submit" class="btn-municipal-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando reporte...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <div class="mb-3 text-center">
        <!-- <img src="/logo.png" alt="Logo" style="height: 80px;" /> -->
        <h2 class="mt-2">TESORERIA MUNICIPAL</h2>
        <h4>DIRECCION DE INGRESOS MUNICIPALES</h4>
        <h5>CUENTAS POR COBRAR</h5>
        <div class="mb-2"><strong>Recaudadora:</strong> {{ reportData[0].recaudadora }}</div>
      </div>
      <table class="table table-bordered table-striped">
        <thead class="table-light">
          <tr>
            <th rowspan="2" class="align-middle text-center">CONCEPTO</th>
            <th rowspan="2" class="align-middle text-center">SALDO MES ANTERIOR</th>
            <th colspan="2" class="text-center">ALTAS</th>
            <th colspan="2" class="text-center">MOVIMIENTOS DEL MES</th>
            <th colspan="2" class="text-center">BAJAS</th>
          </tr>
          <tr>
            <th class="text-center">DOCTOS</th>
            <th class="text-center">IMPORTE</th>
            <th class="text-center">DOCTOS</th>
            <th class="text-center">IMPORTE</th>
            <th class="text-center">DOCTOS</th>
            <th class="text-center">IMPORTE</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id || row.descripcion">
            <td>{{ row.descripcion }}</td>
            <td class="text-end">{{ formatCurrency(row.saldo_mes_anterior) }}</td>
            <td class="text-end">{{ row.altas_doctos }}</td>
            <td class="text-end">{{ formatCurrency(row.altas_importe) }}</td>
            <td class="text-end">{{ row.mov_mes_doctos }}</td>
            <td class="text-end">{{ formatCurrency(row.mov_mes_importe) }}</td>
            <td class="text-end">{{ row.bajas_doctos }}</td>
            <td class="text-end">{{ formatCurrency(row.bajas_importe) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="reportData && !reportData.length" class="alert alert-warning">
      No se encontraron datos para los parámetros seleccionados.
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptCuentaPublica',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        oficina: 1
      },
      loading: false,
      error: '',
      reportData: null
    };
  },
  methods: {
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
            eRequest: 'RptCuentaPublica.getReport',
            params: {
              axo: this.form.axo,
              oficina: this.form.oficina
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.reportData = data.eResponse.data;
        } else {
          this.error = data.eResponse.error || 'Error desconocido al consultar el reporte.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red o del servidor.';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(value) {
      if (typeof value !== 'number') return value;
      return value.toLocaleString('es-MX', { style: 'currency', currency: 'MXN', minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.rpt-cuenta-publica-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
