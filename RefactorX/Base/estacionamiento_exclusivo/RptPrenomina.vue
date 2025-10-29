<template>
  <div class="rpt-prenomina-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Prenómina</li>
      </ol>
    </nav>
    <h1>Listado de Pagos a Ejecutores de la Oficina</h1>
    <form @submit.prevent="fetchReport" class="form-inline mb-4">
      <div class="form-group mr-2">
        <label for="fec1">Fecha Inicio:</label>
        <input type="date" v-model="form.fec1" id="fec1" class="form-control ml-2" required />
      </div>
      <div class="form-group mr-2">
        <label for="fec2">Fecha Fin:</label>
        <input type="date" v-model="form.fec2" id="fec2" class="form-control ml-2" required />
      </div>
      <div class="form-group mr-2">
        <label for="recaud">Recaudadora Inicial:</label>
        <input type="number" v-model.number="form.recaud" id="recaud" class="form-control ml-2" min="1" required />
      </div>
      <div class="form-group mr-2">
        <label for="recaud1">Recaudadora Final:</label>
        <input type="number" v-model.number="form.recaud1" id="recaud1" class="form-control ml-2" min="1" required />
      </div>
      <button type="submit" class="btn btn-primary">Generar Reporte</button>
    </form>

    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>

    <div v-if="report.rows.length">
      <h3>Del periodo: {{ formatDate(form.fec1) }} al {{ formatDate(form.fec2) }}</h3>
      <h4 v-if="zonaLabel">Zona: {{ zonaLabel }}</h4>
      <table class="table table-bordered table-sm mt-3">
        <thead class="thead-dark">
          <tr>
            <th>Zona</th>
            <th>Recaudadora</th>
            <th>Ejecutor</th>
            <th>RFC (Ini)</th>
            <th>RFC (Fec)</th>
            <th>RFC (Hom)</th>
            <th>Nombre</th>
            <th>Requerimientos</th>
            <th>Importe Gastos</th>
            <th>Total al 75%</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report.rows" :key="row.zona + '-' + row.ejecutor">
            <td>{{ row.zona }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.ejecutor }}</td>
            <td>{{ row.ini_rfc }}</td>
            <td>{{ formatDate(row.fec_rfc) }}</td>
            <td>{{ row.hom_rfc }}</td>
            <td>{{ row.nombre }}</td>
            <td class="text-right">{{ row.cuantos }}</td>
            <td class="text-right">{{ currency(row.gastos) }}</td>
            <td class="text-right">{{ currency(row.gastos_75) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="font-weight-bold">
            <td colspan="7">Totales</td>
            <td class="text-right">{{ report.totals.total_cuantos }}</td>
            <td class="text-right">{{ currency(report.totals.total_gastos) }}</td>
            <td class="text-right">{{ currency(report.totals.total_gastos_75) }}</td>
          </tr>
        </tfoot>
      </table>
      <div class="mt-4">
        <h5>Totales por tipo:</h5>
        <ul>
          <li>Total Gastos por Sistema: <strong>{{ currency(report.totals.total_gastos_sistema) }}</strong></li>
          <li>Total Gastos por Ejecutor: <strong>{{ currency(report.totals.total_gastos_ejecutor) }}</strong></li>
          <li>Total Gastos al 75%: <strong>{{ currency(report.totals.total_gastos_75) }}</strong></li>
          <li>Total Requerimientos Ejecutor: <strong>{{ report.totals.total_cuantos_ejecutor }}</strong></li>
          <li>Total Requerimientos Sistema: <strong>{{ report.totals.total_cuantos_sistema }}</strong></li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPrenominaPage',
  data() {
    return {
      form: {
        fec1: '',
        fec2: '',
        recaud: 1,
        recaud1: 9
      },
      loading: false,
      error: '',
      report: {
        rows: [],
        totals: {}
      }
    };
  },
  computed: {
    zonaLabel() {
      if (this.form.recaud === 1 && this.form.recaud1 === 9) {
        return 'TODAS';
      }
      // Si hay datos, mostrar la zona del primer registro
      if (this.report.rows.length > 0) {
        return this.report.rows[0].zona_1 || this.report.rows[0].zona;
      }
      return '';
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = { rows: [], totals: {} };
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'RptPrenomina',
            eParams: this.form
          })
        });
        const data = await response.json();
        if (data.eResponse === 'OK') {
          // Agregar campo gastos_75 a cada fila
          data.eData.rows.forEach(row => {
            row.gastos_75 = (parseFloat(row.gastos) * 0.75).toFixed(2);
          });
          this.report.rows = data.eData.rows;
          this.report.totals = data.eData.totals || {};
        } else {
          this.error = data.eMessage || 'Error desconocido';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    formatDate(date) {
      if (!date) return '';
      const d = new Date(date);
      return d.toLocaleDateString('es-MX', { year: 'numeric', month: 'long', day: 'numeric' });
    },
    currency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpt-prenomina-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
