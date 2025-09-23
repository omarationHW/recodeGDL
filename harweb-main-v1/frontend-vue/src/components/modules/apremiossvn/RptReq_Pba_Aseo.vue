<template>
  <div class="rptreq-pba-aseo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Requerimiento de Pago y Embargo - Aseo</li>
      </ol>
    </nav>
    <h1 class="mb-4">Orden de Requerimiento de Pago y Embargo - Derechos de Aseo Contratado</h1>
    <form @submit.prevent="fetchReport">
      <div class="row mb-3">
        <div class="col-md-3">
          <label for="id_rec" class="form-label">Oficina (id_rec)</label>
          <input type="number" v-model="form.id_rec" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label for="tipo_aseo" class="form-label">Tipo de Aseo</label>
          <select v-model="form.tipo_aseo" class="form-select">
            <option value="todos">Todos</option>
            <option v-for="tipo in tiposAseo" :key="tipo" :value="tipo">{{ tipo }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="fecha_corte" class="form-label">Fecha de Corte</label>
          <input type="date" v-model="form.fecha_corte" class="form-control" required />
        </div>
        <div class="col-md-3 d-flex align-items-end">
          <button type="submit" class="btn btn-primary">Generar Reporte</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length > 0">
      <h2 class="mt-4">Resultados</h2>
      <table class="table table-bordered table-sm mt-3">
        <thead>
          <tr>
            <th>Contrato</th>
            <th>Tipo Aseo</th>
            <th>Contribuyente</th>
            <th>Domicilio</th>
            <th>Zona</th>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Gastos</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.control_contrato + '-' + row.aso_mes_pago">
            <td>{{ row.num_contrato }}</td>
            <td>{{ row.tipo_aseo }}</td>
            <td>{{ row.descripcion_1 }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.aso_mes_pago }}</td>
            <td>{{ currency(row.importe) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.gastos) }}</td>
            <td>{{ currency(row.total) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-secondary" @click="printReport">Imprimir</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptReqPbaAseoPage',
  data() {
    return {
      form: {
        id_rec: '',
        tipo_aseo: 'todos',
        fecha_corte: ''
      },
      tiposAseo: ['ORDINARIO', 'ESPECIAL'],
      report: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'RptReqPbaAseo:getReport',
              params: {
                id_rec: this.form.id_rec,
                tipo_aseo: this.form.tipo_aseo,
                fecha_corte: this.form.fecha_corte
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al obtener datos';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    currency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    printReport() {
      window.print();
    }
  }
};
</script>

<style scoped>
.rptreq-pba-aseo-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
@media print {
  .breadcrumb, form, button { display: none !important; }
  table { font-size: 12px; }
}
</style>
