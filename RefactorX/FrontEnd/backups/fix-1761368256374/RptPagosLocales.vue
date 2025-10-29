<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Reporte de Pagos Locales</h1>
        <p>Mercados - Reporte de Pagos Locales</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1 class="mb-4">Reporte de Pagos Locales</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-md-3">
          <label for="fecha_desde" class="municipal-form-label">Fecha Desde</label>
          <input type="date" v-model="form.fecha_desde" class="municipal-form-control" required />
        </div>
        <div class="col-md-3">
          <label for="fecha_hasta" class="municipal-form-label">Fecha Hasta</label>
          <input type="date" v-model="form.fecha_hasta" class="municipal-form-control" required />
        </div>
        <div class="col-md-3">
          <label for="oficina" class="municipal-form-label">Recaudadora</label>
          <select v-model="form.oficina" class="form-select" required>
            <option value="" disabled>Seleccione...</option>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.recaudadora }}
            </option>
          </select>
        </div>
        <div class="col-md-3">
          <button type="submit" class="btn btn-primary w-100">Generar Reporte</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0">
      <table class="table table-bordered table-striped table-sm mt-4">
        <thead>
          <tr>
            <th>Local</th>
            <th>Fecha Pago</th>
            <th>Oficina</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Partida</th>
            <th>Fecha Actualización</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_pago_local">
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.fecha_pago | formatDate }}</td>
            <td>{{ row.oficina_pago }}</td>
            <td>{{ row.caja_pago }}</td>
            <td>{{ row.operacion_pago }}</td>
            <td>{{ row.axoper }}</td>
            <td>{{ row.importe_pago | currency }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.fecha_modificacion | formatDateTime }}</td>
            <td>{{ row.usuario }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ report.length }}<br />
        <strong>Total importe:</strong> {{ totalImporte | currency }}
      </div>
    </div>
    <div v-else-if="!loading && !error" class="alert alert-warning mt-4">
      No hay datos para los filtros seleccionados.
    </div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPagosLocalesPage',
  data() {
    return {
      form: {
        fecha_desde: '',
        fecha_hasta: '',
        oficina: ''
      },
      recaudadoras: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalImporte() {
      return this.report.reduce((sum, row) => sum + Number(row.importe_pago || 0), 0);
    }
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    formatDateTime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
    },
    currency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  created() {
    this.fetchRecaudadoras();
    // Default dates: current month
    const today = new Date();
    this.form.fecha_desde = today.toISOString().slice(0, 10);
    this.form.fecha_hasta = today.toISOString().slice(0, 10);
  },
  methods: {
    async fetchRecaudadoras() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRecaudadoras' })
        });
        const data = await res.json();
        if (data.success) {
          this.recaudadoras = data.data;
        } else {
          this.error = data.message || 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getPagosLocalesReport',
            params: this.form
          })
        });
        const data = await res.json();
        if (data.success) {
          this.report = data.data;
        } else {
          this.error = data.message || 'Error al obtener el reporte';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rpt-pagos-locales-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
