<template>
  <div class="rep-a-cobrar-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Cementerios a Cobrar</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Reporte de Cementerios a Cobrar</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Mes:</label>
            <div class="col-sm-4">
              <select v-model="form.mes" class="form-control" required>
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">{{ mes.label }}</option>
              </select>
            </div>
          </div>
          <div class="form-group row">
            <label class="col-sm-2 col-form-label">Recaudadora:</label>
            <div class="col-sm-4">
              <input type="text" v-model="recaudadora.nomre" class="form-control" readonly />
            </div>
          </div>
          <div class="form-group row">
            <div class="col-sm-6">
              <button type="submit" class="btn btn-primary" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm"></span>
                Generar Reporte
              </button>
              <button type="button" class="btn btn-secondary ml-2" @click="onReset">Limpiar</button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
        <div v-if="report && report.length" class="mt-4">
          <h5>Resultados</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th>Año</th>
                <th>Mantenimiento</th>
                <th>Recargos</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in report" :key="row.ano">
                <td>{{ row.ano }}</td>
                <td>{{ row.mantenimiento | currency }}</td>
                <td>{{ row.recargos | currency }}</td>
                <td>{{ (row.mantenimiento + row.recargos) | currency }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-if="report && !report.length" class="alert alert-info mt-3">No hay datos para el mes seleccionado.</div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RepACobrarPage',
  data() {
    return {
      form: {
        mes: new Date().getMonth() + 1
      },
      meses: [],
      recaudadora: {
        nomre: '',
        titulo: '',
        d_zona: ''
      },
      report: null,
      loading: false,
      error: null,
      user: {
        id_rec: 1 // Simulación, debe obtenerse del login/session
      }
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  created() {
    this.fetchMeses();
    this.fetchRecaudadora();
  },
  methods: {
    async fetchMeses() {
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: { action: 'getMeses' }
        });
        this.meses = data.eResponse.meses;
      } catch (e) {
        this.error = 'Error cargando meses';
      }
    },
    async fetchRecaudadora() {
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: { action: 'getRecaudadora', params: { id_rec: this.user.id_rec } }
        });
        if (data.eResponse.recaudadora && data.eResponse.recaudadora.length) {
          this.recaudadora = data.eResponse.recaudadora[0];
        }
      } catch (e) {
        this.error = 'Error cargando recaudadora';
      }
    },
    async onSubmit() {
      this.error = null;
      this.loading = true;
      this.report = null;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'getReport',
            params: {
              mes: this.form.mes,
              id_rec: this.user.id_rec
            }
          }
        });
        this.report = data.eResponse.report;
      } catch (e) {
        this.error = e.response?.data?.eResponse?.error || 'Error generando reporte';
      } finally {
        this.loading = false;
      }
    },
    onReset() {
      this.form.mes = new Date().getMonth() + 1;
      this.report = null;
      this.error = null;
    }
  }
};
</script>

<style scoped>
.rep-a-cobrar-page {
  max-width: 700px;
  margin: 0 auto;
}
</style>
