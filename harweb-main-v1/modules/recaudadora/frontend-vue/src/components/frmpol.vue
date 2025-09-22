<template>
  <div class="frmpol-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Póliza por Recaudadora</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Reporte de Póliza por Recaudadora</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="fecha" class="form-label">Fecha del Reporte:</label>
              <input type="date" v-model="form.fecha" id="fecha" class="form-control" required />
            </div>
            <div class="col-md-4">
              <label for="recaud" class="form-label">Recaudadora:</label>
              <select v-model="form.recaud" id="recaud" class="form-select" required>
                <option value="" disabled>Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.cvectaapl" :value="rec.cvectaapl">
                  {{ rec.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-4 d-flex align-items-end">
              <button type="submit" class="btn btn-success me-2">
                <i class="fa fa-print"></i> Imprimir
              </button>
              <button type="button" class="btn btn-secondary" @click="onClear">Limpiar</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info">Cargando reporte...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="reporte.length > 0">
          <h5 class="mt-4">Resultados para {{ form.fecha }} - Recaudadora: {{ recaudoraSeleccionada }}</h5>
          <table class="table table-bordered table-striped mt-2">
            <thead>
              <tr>
                <th>Cuenta Aplicación</th>
                <th>Descripción</th>
                <th class="text-end">Total Parcial</th>
                <th class="text-end">Suma</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in reporte" :key="row.cvectaapl">
                <td>{{ row.cvectaapl }}</td>
                <td>{{ row.ctaaplicacion }}</td>
                <td class="text-end">{{ row.totpar }}</td>
                <td class="text-end">{{ formatCurrency(row.suma) }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="fw-bold">
                <td colspan="2" class="text-end">TOTAL PRODUCTOS</td>
                <td class="text-end">{{ totalParcial }}</td>
                <td class="text-end">{{ formatCurrency(totalSuma) }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
        <div v-else-if="reporteRequested && !loading" class="alert alert-warning">
          No se encontraron resultados para los criterios seleccionados.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FrmPolReporte',
  data() {
    return {
      form: {
        fecha: this.formatDate(new Date()),
        recaud: ''
      },
      recaudadoras: [],
      reporte: [],
      loading: false,
      error: '',
      reporteRequested: false
    };
  },
  computed: {
    totalParcial() {
      return this.reporte.reduce((acc, row) => acc + Number(row.totpar), 0);
    },
    totalSuma() {
      return this.reporte.reduce((acc, row) => acc + Number(row.suma), 0);
    },
    recaudoraSeleccionada() {
      const rec = this.recaudadoras.find(r => r.cvectaapl === this.form.recaud);
      return rec ? rec.descripcion : '';
    }
  },
  methods: {
    formatDate(date) {
      // YYYY-MM-DD
      const d = new Date(date);
      return d.toISOString().slice(0, 10);
    },
    formatCurrency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    async fetchRecaudadoras() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.getRecaudadoras',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async onSubmit() {
      this.error = '';
      this.loading = true;
      this.reporteRequested = true;
      this.reporte = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.getPolizaReporte',
          payload: {
            fecha: this.form.fecha,
            recaud: this.form.recaud
          }
        });
        if (res.data.status === 'success') {
          this.reporte = res.data.data;
        } else {
          this.error = res.data.message || 'Error al obtener reporte';
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      } finally {
        this.loading = false;
      }
    },
    onClear() {
      this.form.fecha = this.formatDate(new Date());
      this.form.recaud = '';
      this.reporte = [];
      this.reporteRequested = false;
      this.error = '';
    }
  },
  mounted() {
    this.fetchRecaudadoras();
  }
};
</script>

<style scoped>
.frmpol-page {
  max-width: 900px;
  margin: 0 auto;
}
.card-header {
  background: linear-gradient(90deg, #e3e3e3 0%, #003366 100%);
}
.table th, .table td {
  vertical-align: middle;
}
</style>
