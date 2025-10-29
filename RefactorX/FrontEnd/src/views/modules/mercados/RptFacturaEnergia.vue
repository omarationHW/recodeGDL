<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bolt" /></div>
      <div class="module-view-info">
        <h1>Factura Energía</h1>
        <p>Mercados - Factura Energía</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2 class="mb-4">Reporte de Factura de Energía</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3 mb-3">
          <label class="municipal-form-label" for="oficina">Oficina</label>
          <input v-model.number="form.oficina" type="number" class="municipal-form-control" id="oficina" required />
        </div>
        <div class="col-md-3 mb-3">
          <label class="municipal-form-label" for="mercado">Mercado</label>
          <input v-model.number="form.mercado" type="number" class="municipal-form-control" id="mercado" required />
        </div>
        <div class="col-md-3 mb-3">
          <label class="municipal-form-label" for="axo">Año</label>
          <input v-model.number="form.axo" type="number" class="municipal-form-control" id="axo" required />
        </div>
        <div class="col-md-3 mb-3">
          <label class="municipal-form-label" for="periodo">Periodo (Mes)</label>
          <select v-model.number="form.periodo" class="municipal-form-control" id="periodo" required>
            <option v-for="(mes, idx) in meses" :key="idx" :value="idx+1">{{ mes }}</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn-municipal-primary">Consultar</button>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando reporte...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <div class="mb-3">
        <strong>Periodo:</strong> {{ periodLabel.short }}<br />
        <strong>Descripción:</strong> {{ report[0]?.descripcion || '' }}
      </div>
      <table class="-bordered municipal-table-sm">
        <thead class="thead-light municipal-table-header">
          <tr>
            <th>NOMBRE</th>
            <th>LOCAL</th>
            <th>BLQ</th>
            <th>KW</th>
            <th>COSTO KW / HR</th>
            <th>LOCAL ADICIONAL</th>
            <th>IMPORTE</th>
            <th>IMPORTE 1</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in report" :key="idx">
            <td>{{ row.nombre }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.bloque }}</td>
            <td class="text-right">{{ formatNumber(row.cantidad, 2) }}</td>
            <td class="text-right">{{ formatCurrency(row.importe) }}</td>
            <td>{{ row.local_adicional }}</td>
            <td class="text-right">{{ formatCurrency(row.importe) }}</td>
            <td class="text-right">{{ formatCurrency(row.importe_1) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="font-weight-bold">
            <td colspan="3" class="text-right">TOTALES:</td>
            <td class="text-right">{{ formatNumber(totalCantidad, 2) }}</td>
            <td></td>
            <td></td>
            <td></td>
            <td class="text-right">{{ formatCurrency(totalImporte1) }}</td>
          </tr>
        </tfoot>
      </table>
      <div class="mt-3">
        <strong>Total Global de Facturación:</strong> {{ formatCurrency(totalImporte1) }}<br />
        <strong>Total KW:</strong> {{ formatNumber(totalCantidad, 2) }}<br />
        <strong>Locales:</strong> {{ report.length }}
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay datos para los parámetros seleccionados.</div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptFacturaEnergiaPage',
  data() {
    return {
      form: {
        oficina: '',
        mercado: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1
      },
      meses: [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ],
      report: [],
      loading: false,
      error: '',
      periodLabel: { short: '', long: '' }
    };
  },
  computed: {
    totalCantidad() {
      return this.report.reduce((sum, r) => sum + (parseFloat(r.cantidad) || 0), 0);
    },
    totalImporte1() {
      return this.report.reduce((sum, r) => sum + (parseFloat(r.importe_1) || 0), 0);
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        // Get period label
        const labelResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'RptFacturaEnergia.getPeriodLabel',
            eParams: {
              periodo: this.form.periodo,
              axo: this.form.axo
            }
          })
        });
        const labelData = await labelResp.json();
        if (labelData.success) {
          this.periodLabel = labelData.data;
        } else {
          this.periodLabel = { short: '', long: '' };
        }
        // Get report data
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'RptFacturaEnergia.getReport',
            eParams: {
              oficina: this.form.oficina,
              mercado: this.form.mercado,
              axo: this.form.axo,
              periodo: this.form.periodo
            }
          })
        });
        const data = await resp.json();
        if (data.success) {
          this.report = data.data;
        } else {
          this.error = data.message || 'Error al consultar el reporte';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    formatNumber(val, dec = 2) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString(undefined, { minimumFractionDigits: dec, maximumFractionDigits: dec });
    },
    formatCurrency(val) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpt-factura-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
