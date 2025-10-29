<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="chart-bar" /></div>
      <div class="module-view-info">
        <h1>Reporte Ingreso Zonificado</h1>
        <p>Mercados - Reporte Ingreso Zonificado</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Reporte de Ingreso Zonificado</h2>
    <form @submit.prevent="fetchReport" class="row g-3 mb-4">
      <div class="col-md-4">
        <label for="fecdesde" class="municipal-form-label">Fecha Desde</label>
        <input type="date" v-model="fecdesde" id="fecdesde" class="municipal-form-control" required />
      </div>
      <div class="col-md-4">
        <label for="fechasta" class="municipal-form-label">Fecha Hasta</label>
        <input type="date" v-model="fechasta" id="fechasta" class="municipal-form-control" required />
      </div>
      <div class="col-md-4 align-self-end">
        <button type="submit" class="btn-municipal-primary">Consultar</button>
        <button type="button" class="btn btn-secondary ms-2" @click="exportPDF" :disabled="!reportData.length">Exportar PDF</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData.length">
      <h5 class="mt-4">Resultados del {{ fecdesde }} al {{ fechasta }}</h5>
      <table class="table table-bordered table-striped mt-2">
        <thead>
          <tr>
            <th style="width: 10%">Zona ID</th>
            <th style="width: 60%">Zona</th>
            <th style="width: 30%" class="text-end">Ingreso</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id_zona">
            <td>{{ row.id_zona }}</td>
            <td>{{ row.zona }}</td>
            <td class="text-end">{{ formatCurrency(row.pagado) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th colspan="2" class="text-end">TOTAL</th>
            <th class="text-end">{{ formatCurrency(totalIngreso) }}</th>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'IngresoZonificadoPage',
  data() {
    return {
      fecdesde: '',
      fechasta: '',
      reportData: [],
      loading: false,
      error: '',
    };
  },
  computed: {
    totalIngreso() {
      return this.reportData.reduce((sum, r) => sum + Number(r.pagado), 0);
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getIngresoZonificado',
            params: {
              fecdesde: this.fecdesde,
              fechasta: this.fechasta
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.reportData = data.data;
        } else {
          this.error = data.message || 'Error al consultar el reporte';
        }
      } catch (e) {
        this.error = 'Error de red o del servidor';
      } finally {
        this.loading = false;
      }
    },
    async exportPDF() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'exportIngresoZonificadoPDF',
            params: {
              fecdesde: this.fecdesde,
              fechasta: this.fechasta
            }
          })
        });
        const data = await res.json();
        if (data.success && data.data && data.data.url) {
          window.open(data.data.url, '_blank');
        } else {
          this.error = data.message || 'No se pudo exportar el PDF';
        }
      } catch (e) {
        this.error = 'Error de red o del servidor';
      }
    },
    formatCurrency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.table th, .table td {
  vertical-align: middle;
}
</style>
