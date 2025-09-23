<template>
  <div class="rpt-titulos-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Títulos</li>
      </ol>
    </nav>
    <h1>Reporte de Títulos</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="form-row">
        <div class="form-group col-md-4">
          <label for="fecha">Fecha de Pago</label>
          <input type="date" v-model="form.fecha" id="fecha" class="form-control" required />
        </div>
        <div class="form-group col-md-4">
          <label for="folio">Folio</label>
          <input type="number" v-model="form.folio" id="folio" class="form-control" required />
        </div>
        <div class="form-group col-md-4 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Exterior</th>
            <th>Interior</th>
            <th>Colonia</th>
            <th>Metros</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Importe</th>
            <th>Cementerio</th>
            <th>Clase</th>
            <th>Clase Alfa</th>
            <th>Sección</th>
            <th>Sección Alfa</th>
            <th>Línea</th>
            <th>Línea Alfa</th>
            <th>Fosa</th>
            <th>Fosa Alfa</th>
            <th>Observaciones</th>
            <th>Tipo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in report" :key="idx">
            <td>{{ row.nombre }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.exterior }}</td>
            <td>{{ row.interior }}</td>
            <td>{{ row.colonia }}</td>
            <td>{{ row.metros }}</td>
            <td>{{ row.caja }}</td>
            <td>{{ row.operacion }}</td>
            <td>{{ row.importe | currency }}</td>
            <td>{{ row.cementerio }}</td>
            <td>{{ row.clase }}</td>
            <td>{{ row.clase_alfa }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.seccion_alfa }}</td>
            <td>{{ row.linea }}</td>
            <td>{{ row.linea_alfa }}</td>
            <td>{{ row.fosa }}</td>
            <td>{{ row.fosa_alfa }}</td>
            <td>{{ row.observaciones }}</td>
            <td>{{ row.tipo }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-4">
        <button class="btn btn-secondary" @click="printReport">Imprimir</button>
      </div>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay resultados para los criterios seleccionados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptTitulosPage',
  data() {
    return {
      form: {
        fecha: '',
        folio: ''
      },
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
        const res = await this.$axios.post('/api/execute', {
          action: 'cementerios.RptTitulos.getReport',
          payload: {
            fecha: this.form.fecha,
            folio: this.form.folio
          }
        });
        if (res.data.status === 'success') {
          this.report = res.data.data;
        } else {
          throw new Error(res.data.message || 'Error en la solicitud');
        }
      } catch (error) {
        this.error = error.response?.data?.message || error.message || 'Error de conexión';
      } finally {
        this.loading = false;
      }
    },
    printReport() {
      window.print();
    }
  },
  filters: {
    currency(value) {
      if (typeof value !== 'number') return value;
      return '$' + value.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.rpt-titulos-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
@media print {
  .breadcrumb, form, .btn, .alert {
    display: none !important;
  }
  table {
    font-size: 12px;
  }
}
</style>
