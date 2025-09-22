<template>
  <div class="listdesctomulta-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Descuentos en Multa</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header bg-primary text-white font-weight-bold">
        Listado de Desctos. otorgados en Multas Mpales
      </div>
      <div class="card-body">
        <form @submit.prevent="fetchReport">
          <div class="form-row align-items-end">
            <div class="form-group col-md-3">
              <label for="recaudadora">Recaudadora</label>
              <input type="number" class="form-control" id="recaudadora" v-model.number="form.recaud" min="1" required />
            </div>
            <div class="form-group col-md-3">
              <label for="fini">Desde</label>
              <input type="date" class="form-control" id="fini" v-model="form.fini" required />
            </div>
            <div class="form-group col-md-3">
              <label for="ffin">Hasta</label>
              <input type="date" class="form-control" id="ffin" v-model="form.ffin" required />
            </div>
            <div class="form-group col-md-3">
              <button type="submit" class="btn btn-success btn-block">
                <i class="fa fa-print"></i> Imprimir
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length" class="card">
      <div class="card-header bg-secondary text-white">
        Informe de Descuentos Otorgados en Multas del {{ form.fini }} al {{ form.ffin }}<br>
        En la Recaudadora: {{ form.recaud }}
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-sm table-bordered mb-0">
            <thead class="thead-light">
              <tr>
                <th>Fecha</th>
                <th>Rec</th>
                <th>Caja</th>
                <th>Folio</th>
                <th>Importe</th>
                <th>Dep</th>
                <th>Año</th>
                <th>Acta</th>
                <th>Calificación</th>
                <th>Descto</th>
                <th>Multa a Pag</th>
                <th>Gastos</th>
                <th>Total</th>
                <th>Usuario</th>
                <th>Fecha Captura</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in report" :key="idx">
                <td>{{ formatDate(row.fecha) }}</td>
                <td>{{ row.recaud }}</td>
                <td>{{ row.caja }}</td>
                <td>{{ row.folio }}</td>
                <td>{{ formatCurrency(row.importe) }}</td>
                <td>{{ row.abrevia }}</td>
                <td>{{ row.axo_acta }}</td>
                <td>{{ row.num_acta }}</td>
                <td>{{ formatCurrency(row.calificacion) }}</td>
                <td>{{ formatCurrency(row.descto) }}</td>
                <td>{{ formatCurrency(row.multa) }}</td>
                <td>{{ formatCurrency(row.gastos) }}</td>
                <td>{{ formatCurrency(row.total) }}</td>
                <td>{{ row.capturista }}</td>
                <td>{{ formatDate(row.feccap) }}</td>
                <td>{{ row.descripcion }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr class="font-weight-bold">
                <td colspan="16">Total de pagos: {{ report.length }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
    <div v-if="report.length" class="mt-3 text-right">
      <button class="btn btn-outline-primary" @click="printPage"><i class="fa fa-print"></i> Imprimir Reporte</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListDesctoMultaPage',
  data() {
    return {
      form: {
        recaud: '',
        fini: '',
        ffin: ''
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    fetchReport() {
      this.error = '';
      this.report = [];
      this.loading = true;
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'getDescuentosMulta',
          params: {
            recaud: this.form.recaud,
            fini: this.form.fini,
            ffin: this.form.ffin
          }
        }
      })
      .then(res => {
        if (res.data.eResponse.success) {
          this.report = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error al obtener datos';
        }
      })
      .catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    printPage() {
      window.print();
    }
  }
};
</script>

<style scoped>
.listdesctomulta-page {
  max-width: 100%;
  margin: 0 auto;
  padding: 1.5rem;
}
.table th, .table td {
  vertical-align: middle;
  font-size: 0.95rem;
}
@media print {
  .breadcrumb, form, .btn, .card-header, .mt-3 { display: none !important; }
  .card { border: none !important; }
  .table { font-size: 0.85rem; }
}
</style>
