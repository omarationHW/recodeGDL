<template>
  <div class="polcon-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Póliza Diaria Consolidada</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Póliza Diaria Consolidada de las Recaudadoras</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="fetchReport">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="date_from" class="form-label fw-bold">Desde:</label>
              <input type="date" id="date_from" v-model="dateFrom" class="form-control" required />
            </div>
            <div class="col-md-3">
              <label for="date_to" class="form-label fw-bold">Hasta:</label>
              <input type="date" id="date_to" v-model="dateTo" class="form-control" required />
            </div>
            <div class="col-md-3 align-self-end">
              <button type="submit" class="btn btn-success">
                <i class="fa fa-print"></i> Imprimir
              </button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info">Cargando reporte...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="reportData && reportData.length">
          <div class="table-responsive">
            <table class="table table-bordered table-striped mt-4">
              <thead class="table-secondary">
                <tr>
                  <th>Cuenta de Aplicación</th>
                  <th>Cuentas</th>
                  <th>Parcial</th>
                  <th>Descripción</th>
                  <th>Total Parcial</th>
                  <th>Suma</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in reportData" :key="row.cvectaapl">
                  <td>{{ row.cvectaapl }}</td>
                  <td>{{ row.ctaaplicacion }}</td>
                  <td>{{ row.totpar }}</td>
                  <td>{{ row.ctaaplicacion }}</td>
                  <td>{{ row.totpar }}</td>
                  <td>{{ formatCurrency(row.suma) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="fw-bold">
                  <td colspan="2">TOTAL PRODUCTOS</td>
                  <td>{{ totalParcial }}</td>
                  <td></td>
                  <td></td>
                  <td>{{ formatCurrency(totalSuma) }}</td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
        <div v-else-if="reportData && !reportData.length" class="alert alert-warning mt-4">
          No se encontraron resultados para el rango de fechas seleccionado.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PolconReportPage',
  data() {
    const today = new Date().toISOString().substr(0, 10);
    return {
      dateFrom: today,
      dateTo: today,
      reportData: null,
      loading: false,
      error: null
    };
  },
  computed: {
    totalParcial() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, row) => sum + Number(row.totpar), 0);
    },
    totalSuma() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, row) => sum + Number(row.suma), 0);
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = null;
      this.reportData = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'polcon_report',
              params: {
                date_from: this.dateFrom,
                date_to: this.dateTo
              }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse.success) {
          this.reportData = json.eResponse.data;
        } else {
          this.error = json.eResponse.message || 'Error al obtener el reporte.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(value) {
      if (value == null) return '';
      return Number(value).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.polcon-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card-header {
  background: linear-gradient(90deg, #fff 0%, #003366 100%);
}
.table th, .table td {
  vertical-align: middle;
}
</style>
