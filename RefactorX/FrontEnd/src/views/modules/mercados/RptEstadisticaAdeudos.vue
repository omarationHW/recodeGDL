<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="exclamation-triangle" /></div>
      <div class="module-view-info">
        <h1>Estadística de Adeudos</h1>
        <p>Mercados - Estadística de Adeudos</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1 class="mb-4">Estadística Global de Adeudos Vencidos</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-2">
          <label class="municipal-form-label" for="axo">Año</label>
          <input type="number" v-model.number="form.axo" id="axo" class="municipal-form-control" required min="2000" max="2100">
        </div>
        <div class="col-md-2">
          <label class="municipal-form-label" for="periodo">Periodo</label>
          <input type="number" v-model.number="form.periodo" id="periodo" class="municipal-form-control" required min="1" max="12">
        </div>
        <div class="col-md-3">
          <label class="municipal-form-label" for="importe">Importe mínimo (opcional)</label>
          <input type="number" v-model.number="form.importe" id="importe" class="municipal-form-control" step="0.01" min="0">
        </div>
        <div class="col-md-3">
          <label class="municipal-form-label" for="opc">Tipo de Reporte</label>
          <select v-model.number="form.opc" id="opc" class="form-select">
            <option :value="1">Global</option>
            <option :value="2">Sólo mayores o iguales a importe</option>
          </select>
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button type="submit" class="btn btn-municipal-primary w-100">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <div class="mb-3">
        <strong>
          {{ reportTitle }}
        </strong>
      </div>
      <div class="table-responsive">
        <table class="-bordered municipal-table-striped">
          <thead>
            <tr>
              <th>Oficina</th>
              <th>Mercado</th>
              <th>Local</th>
              <th>Nombre Mercado</th>
              <th>Importe Adeudo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in reportData" :key="row.oficina + '-' + row.num_mercado + '-' + row.local">
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.descripcion }}</td>
              <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ reportData.length }}<br>
        <strong>Total adeudo:</strong> {{ formatCurrency(totalAdeudo) }}
      </div>
    </div>
    <div v-else-if="reportData && !reportData.length && !loading">
      <div class="alert alert-warning">No se encontraron resultados para los criterios seleccionados.</div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptEstadisticaAdeudos',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        periodo: 1,
        importe: 0,
        opc: 1
      },
      loading: false,
      error: '',
      reportData: null
    };
  },
  computed: {
    reportTitle() {
      if (!this.form.opc || this.form.opc === 1) {
        return `ESTADÍSTICA GLOBAL DE ADEUDOS VENCIDOS AL PERIODO: ${this.form.axo}-${this.form.periodo}`;
      } else {
        return `ESTADÍSTICA GLOBAL DE ADEUDOS VENCIDOS AL PERIODO: ${this.form.axo}-${this.form.periodo} CON IMPORTE MAYOR E IGUAL A $${this.form.importe.toLocaleString(undefined, {minimumFractionDigits: 2})}`;
      }
    },
    totalAdeudo() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, row) => sum + Number(row.adeudo), 0);
    }
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
            eRequest: 'RptEstadisticaAdeudos',
            params: {
              axo: this.form.axo,
              periodo: this.form.periodo,
              importe: this.form.importe,
              opc: this.form.opc
            }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.reportData = data.data;
        } else {
          this.error = data.message || 'Error en la consulta';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(value) {
      return Number(value).toLocaleString(undefined, { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpt-estadistica-adeudos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
