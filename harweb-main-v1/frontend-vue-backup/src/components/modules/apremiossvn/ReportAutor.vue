<template>
  <div class="report-autor-page">
    <h1>Reporte de Descuentos Autorizados</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Descuentos Autorizados</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-4">
          <label for="rec">Oficina Recaudadora</label>
          <select v-model="form.rec" class="form-control" required>
            <option v-for="rec in recs" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.id_rec }} - {{ rec.zona }}
            </option>
          </select>
        </div>
        <div class="form-group col-md-4">
          <label for="fecha1">Fecha Inicial</label>
          <input type="date" v-model="form.fecha1" class="form-control" required />
        </div>
        <div class="form-group col-md-4">
          <label for="fecha2">Fecha Final</label>
          <input type="date" v-model="form.fecha2" class="form-control" required />
        </div>
      </div>
      <button type="submit" class="btn btn-primary" :disabled="loading">
        <span v-if="loading" class="spinner-border spinner-border-sm"></span>
        Generar Reporte
      </button>
    </form>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Importe Multa</th>
            <th>% Autorizado</th>
            <th>Usuario Alta</th>
            <th>Datos Registro</th>
            <th>Vigencia</th>
            <th>Usuario Mod</th>
            <th>Fecha Pago</th>
            <th>Ofna</th>
            <th>Caja</th>
            <th>Operac.</th>
            <th>Fecha Alta</th>
            <th>Fecha Baja</th>
            <th>Fecha Mod</th>
            <th>Autorizado por</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.folio">
            <td>{{ row.folio }}</td>
            <td>{{ row.importe_multa | currency }}</td>
            <td>{{ row.porcentaje }}%</td>
            <td>{{ row.usu_alta }}</td>
            <td>{{ row.datos }}</td>
            <td>{{ row.vigautoriza }}</td>
            <td>{{ row.usu_mod }}</td>
            <td>{{ row.fecha_pago }}</td>
            <td>{{ row.recaudadora }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ row.fecha_alta }}</td>
            <td>{{ row.fecha_baja }}</td>
            <td>{{ row.fecha_actual }}</td>
            <td>{{ row.quien }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'ReportAutorPage',
  data() {
    return {
      form: {
        rec: '',
        fecha1: '',
        fecha2: ''
      },
      recs: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  created() {
    this.fetchRecs();
  },
  methods: {
    async fetchRecs() {
      // Llama al API para obtener oficinas recaudadoras
      try {
        const res = await axios.post('/api/execute', {
          action: 'getRecInfo',
          params: { reca: 1 } // Por defecto, o usar usuario actual
        });
        this.recs = res.data.data;
        if (this.recs.length) {
          this.form.rec = this.recs[0].id_rec;
        }
      } catch (e) {
        this.error = 'Error al cargar oficinas recaudadoras';
      }
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const res = await axios.post('/api/execute', {
          action: 'getReport',
          params: {
            rec: this.form.rec,
            fecha1: this.form.fecha1,
            fecha2: this.form.fecha2
          }
        });
        if (res.data.status === 'success') {
          this.report = res.data.data;
          if (!this.report.length) {
            this.error = 'No se encontraron registros con esa fecha.';
          }
        } else {
          this.error = res.data.message || 'Error al generar reporte';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.report-autor-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
