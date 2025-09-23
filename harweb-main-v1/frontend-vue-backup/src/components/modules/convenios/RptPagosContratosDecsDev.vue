<template>
  <div class="rpt-pagos-contratos-decs-dev-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Contratos con Descuento</li>
      </ol>
    </nav>
    <h2 class="mb-4">Listado de Contratos que Pagaron con Descuento</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="form-group row">
        <label for="colonia" class="col-sm-2 col-form-label">Colonia</label>
        <div class="col-sm-4">
          <input type="number" v-model.number="colonia" id="colonia" class="form-control" required min="1" />
        </div>
        <div class="col-sm-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reportData && reportData.length">
      <div class="mb-3">
        <strong>Colonia:</strong> {{ reportData[0].colonia }} - {{ reportData[0].descripcion }}
      </div>
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>CALLE</th>
            <th>FOLIO</th>
            <th>FECHA PAGO</th>
            <th>REC.</th>
            <th>CAJA</th>
            <th>OPER</th>
            <th>IMPORTE</th>
            <th>PARCIALIDAD</th>
            <th>DESC.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.folio">
            <td>{{ row.calle }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ formatDate(row.fecha_pago) }}</td>
            <td>{{ row.oficina_pago }}</td>
            <td>{{ row.caja_pago }}</td>
            <td>{{ row.operacion_pago }}</td>
            <td class="text-right">{{ formatCurrency(row.importe) }}</td>
            <td class="text-center">{{ row.pago_parcial }} - {{ row.total_parciales }}</td>
            <td>{{ row.cve_descuento }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="font-weight-bold">
            <td colspan="6" class="text-right">TOTAL GENERAL:</td>
            <td class="text-right">{{ formatCurrency(totalImporte) }}</td>
            <td class="text-center">{{ reportData.length }}</td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay datos para mostrar.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPagosContratosDecsDevPage',
  data() {
    return {
      colonia: '',
      reportData: null,
      loading: false,
      error: null
    };
  },
  computed: {
    totalImporte() {
      if (!this.reportData) return 0;
      return this.reportData.reduce((sum, row) => sum + Number(row.importe || 0), 0);
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
            eRequest: 'RptPagosContratosDecsDev',
            params: { colonia: this.colonia }
          })
        });
        const result = await response.json();
        if (result.success) {
          this.reportData = result.data;
        } else {
          this.error = result.message || 'Error al obtener datos.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    },
    formatCurrency(value) {
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
    }
  }
};
</script>

<style scoped>
.rpt-pagos-contratos-decs-dev-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
