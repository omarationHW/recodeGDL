<template>
  <div class="prenomina-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Prenómina de Ejecutores</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">Prenómina de Ejecutores</div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="fecha_desde" class="form-label">Fecha Desde</label>
              <input type="date" v-model="form.fecha_desde" class="form-control" required />
            </div>
            <div class="col-md-3">
              <label for="fecha_hasta" class="form-label">Fecha Hasta</label>
              <input type="date" v-model="form.fecha_hasta" class="form-control" required />
            </div>
            <div class="col-md-3">
              <label class="form-label">Recaudadora</label>
              <div class="form-check">
                <input class="form-check-input" type="radio" id="todas" value="todas" v-model="form.recaudadora_tipo" />
                <label class="form-check-label" for="todas">Todas</label>
              </div>
              <div class="form-check">
                <input class="form-check-input" type="radio" id="determinada" value="determinada" v-model="form.recaudadora_tipo" />
                <label class="form-check-label" for="determinada">Determinada</label>
              </div>
              <select v-if="form.recaudadora_tipo==='determinada'" v-model="form.recaudadora" class="form-select mt-2">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.nombre || rec.recaudadora }}</option>
              </select>
            </div>
            <div class="col-md-3 d-flex align-items-end">
              <button type="submit" class="btn btn-success me-2">Procesar</button>
              <button type="button" class="btn btn-secondary" @click="onReset">Limpiar</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info">Procesando...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="report.length">
          <h5 class="mt-4">Resultados</h5>
          <div class="table-responsive">
            <table class="table table-bordered table-sm">
              <thead>
                <tr>
                  <th>Zona</th>
                  <th>Ejecutor</th>
                  <th>RFC</th>
                  <th>Nombre</th>
                  <th>Gastos</th>
                  <th>Folios</th>
                  <th>Recaudadora</th>
                  <th>Zona Nombre</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in report" :key="row.ejecutor + '-' + row.zona">
                  <td>{{ row.zona }}</td>
                  <td>{{ row.ejecutor }}</td>
                  <td>{{ row.ini_rfc }}{{ row.hom_rfc }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.gastos | currency }}</td>
                  <td>{{ row.cuantos }}</td>
                  <td>{{ row.recaudadora }}</td>
                  <td>{{ row.zona_1 }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PrenominaPage',
  data() {
    return {
      form: {
        fecha_desde: '',
        fecha_hasta: '',
        recaudadora_tipo: 'todas',
        recaudadora: null
      },
      recaudadoras: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  mounted() {
    this.fetchRecaudadoras();
  },
  methods: {
    fetchRecaudadoras() {
      this.$axios.post('/api/execute', { action: 'getRecaudadoras' })
        .then(res => {
          if (res.data.success) {
            this.recaudadoras = res.data.data;
          }
        });
    },
    onSubmit() {
      this.error = '';
      this.report = [];
      this.loading = true;
      let recDesde = 1, recHasta = 9;
      if (this.form.recaudadora_tipo === 'determinada' && this.form.recaudadora) {
        recDesde = recHasta = this.form.recaudadora;
      }
      this.$axios.post('/api/execute', {
        action: 'getPrenominaReport',
        params: {
          fecha_desde: this.form.fecha_desde,
          fecha_hasta: this.form.fecha_hasta,
          recaudadora_desde: recDesde,
          recaudadora_hasta: recHasta
        }
      }).then(res => {
        this.loading = false;
        if (res.data.success) {
          this.report = res.data.data;
        } else {
          this.error = res.data.message || 'Error al procesar.';
        }
      }).catch(err => {
        this.loading = false;
        this.error = err.response?.data?.message || err.message;
      });
    },
    onReset() {
      this.form.fecha_desde = '';
      this.form.fecha_hasta = '';
      this.form.recaudadora_tipo = 'todas';
      this.form.recaudadora = null;
      this.report = [];
      this.error = '';
    }
  }
};
</script>

<style scoped>
.prenomina-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-top: 20px;
}
</style>
