<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-bar" /></div>
      <div class="module-view-info">
        <h1>Desglose de Adeudos por Importe</h1>
        <p>Mercados - Desglose de Adeudos por Importe</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1 class="mb-4">Locales con Adeudos Vencidos Desglosado por Año</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label for="year">Año</label>
          <input v-model.number="form.year" type="number" min="2000" max="2100" class="municipal-form-control" id="year" required>
        </div>
        <div class="col-md-3">
          <label for="period">Periodo (Mes)</label>
          <input v-model.number="form.period" type="number" min="1" max="12" class="municipal-form-control" id="period" required>
        </div>
        <div class="col-md-3">
          <label for="amount">Importe mínimo ($)</label>
          <input v-model.number="form.amount" type="number" step="0.01" min="0" class="municipal-form-control" id="amount" required>
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn btn-primary w-100">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <h5 class="mb-3">
        Locales con adeudos vencidos desglosado por año al periodo: {{ form.year }}-{{ form.period }} Importe mayor e igual a ${{ form.amount.toLocaleString(undefined, {minimumFractionDigits:2}) }}
      </h5>
      <div class="table-responsive">
        <table class="table table-bordered table-sm table-hover">
          <thead class="thead-light">
            <tr>
              <th>Oficina</th>
              <th>Mercado</th>
              <th>Categoria</th>
              <th>Sección</th>
              <th>Local</th>
              <th>Letra</th>
              <th>Bloque</th>
              <th>Nombre</th>
              <th>Descripción</th>
              <th>Adeudo Ant.</th>
              <th>Adeudo 2004</th>
              <th>Adeudo 2005</th>
              <th>Adeudo 2006</th>
              <th>Adeudo 2007</th>
              <th>Adeudo 2008</th>
              <th>Total Adeudo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in report" :key="idx">
              <td>{{ row.spd_oficina }}</td>
              <td>{{ row.spd_mercado }}</td>
              <td>{{ row.spd_categoria }}</td>
              <td>{{ row.spd_seccion }}</td>
              <td>{{ row.spd_local }}</td>
              <td>{{ row.spd_letra }}</td>
              <td>{{ row.spd_bloque }}</td>
              <td>{{ row.spd_nombre }}</td>
              <td>{{ row.spd_descripcion }}</td>
              <td class="text-right">{{ money(row.spd_adeant) }}</td>
              <td class="text-right">{{ money(row.spd_ade2004) }}</td>
              <td class="text-right">{{ money(row.spd_ade2005) }}</td>
              <td class="text-right">{{ money(row.spd_ade2006) }}</td>
              <td class="text-right">{{ money(row.spd_ade2007) }}</td>
              <td class="text-right">{{ money(row.spd_ade2008) }}</td>
              <td class="text-right font-weight-bold">{{ money(row.spd_totade) }}</td>
            </tr>
          </tbody>
          <tfoot>
            <tr class="font-weight-bold bg-light">
              <td colspan="9" class="text-right">Totales:</td>
              <td class="text-right">{{ money(total('spd_adeant')) }}</td>
              <td class="text-right">{{ money(total('spd_ade2004')) }}</td>
              <td class="text-right">{{ money(total('spd_ade2005')) }}</td>
              <td class="text-right">{{ money(total('spd_ade2006')) }}</td>
              <td class="text-right">{{ money(total('spd_ade2007')) }}</td>
              <td class="text-right">{{ money(total('spd_ade2008')) }}</td>
              <td class="text-right">{{ money(total('spd_totade')) }}</td>
            </tr>
          </tfoot>
        </table>
      </div>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-warning">No se encontraron resultados para los parámetros indicados.</div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptDesgloceAdeporImporte',
  data() {
    return {
      form: {
        year: new Date().getFullYear(),
        period: new Date().getMonth() + 1,
        amount: 0,
        option: 0
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'RptDesgloceAdeporImporte',
          eParams: {
            year: this.form.year,
            period: this.form.period,
            amount: this.form.amount,
            option: this.form.option
          }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.success) {
            this.report = json.data;
          } else {
            this.error = json.message || 'Error al consultar el reporte';
          }
        })
        .catch(err => {
          this.error = err.message || 'Error de red';
        })
        .finally(() => {
          this.loading = false;
        });
    },
    money(val) {
      if (val == null) return '';
      return Number(val).toLocaleString(undefined, { style: 'currency', currency: 'MXN', minimumFractionDigits: 2 });
    },
    total(field) {
      return this.report.reduce((sum, row) => sum + (parseFloat(row[field]) || 0), 0);
    }
  }
};
</script>

<style scoped>
.rpt-desgloce-adepor-importe {
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
  font-size: 0.95rem;
}
</style>
