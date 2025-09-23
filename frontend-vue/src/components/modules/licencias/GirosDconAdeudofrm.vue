<template>
  <div class="giros-dcon-adeudo-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Giros Restringidos con Adeudos</li>
      </ol>
    </nav>
    <div class="card mb-4">
      <div class="card-header text-center font-weight-bold">
        REPORTE DE GIROS RESTRINGIDOS CON ADEUDOS ANTERIORES
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-group row align-items-center">
            <label for="year" class="col-sm-2 col-form-label">Año del adeudo:</label>
            <div class="col-sm-3">
              <input
                type="number"
                min="1900"
                max="2100"
                class="form-control"
                id="year"
                v-model.number="year"
                required
                placeholder="Ej: 2022"
              />
            </div>
            <div class="col-sm-2">
              <button type="submit" class="btn btn-primary">
                <i class="fa fa-print"></i> Imprimir
              </button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="message && !error" class="alert alert-info mt-3">{{ message }}</div>
      </div>
    </div>
    <div v-if="reportData && reportData.length > 0" class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <span>
          Licencias con adeudo desde el año: <strong>{{ year }}</strong>
        </span>
        <button class="btn btn-outline-secondary btn-sm" @click="printReport">
          <i class="fa fa-print"></i> Imprimir Reporte
        </button>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-bordered table-sm mb-0">
            <thead class="thead-light">
              <tr>
                <th>Licencia</th>
                <th>Nombre</th>
                <th>Ubicación</th>
                <th>Giro</th>
                <th>Año</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in reportData" :key="row.licencia">
                <td>{{ row.licencia }}</td>
                <td>{{ row.propietarionvo }}</td>
                <td>{{ row.domCompleto }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.axo }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="4" class="text-right font-weight-bold">Total de giros:</td>
                <td class="font-weight-bold">{{ reportData.length }}</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
    <div v-else-if="reportData && reportData.length === 0 && !error" class="alert alert-warning mt-3">
      No se encontraron licencias...
    </div>
  </div>
</template>

<script>
export default {
  name: 'GirosDconAdeudoReport',
  data() {
    return {
      year: new Date().getFullYear(),
      reportData: null,
      error: '',
      message: ''
    };
  },
  methods: {
    async onSubmit() {
      this.error = '';
      this.message = '';
      this.reportData = null;
      if (!this.year || this.year < 1900 || this.year > 2100) {
        this.error = 'Ingrese un año válido.';
        return;
      }
      try {
        const response = await this.$axios.post('/api/generic', {
          eRequest: {
            Operacion: 'report_giros_dcon_adeudo',
            Base: 'padron_licencias',
            Parametros: [
              { nombre: 'p_year', valor: this.year }
            ],
            Tenant: 'public'
          }
        });

        if (response.data && response.data.success) {
          this.reportData = response.data.data;
          this.message = response.data.data.length > 0 ?
            `Se encontraron ${response.data.data.length} licencias con adeudos desde el año ${this.year}` :
            'No se encontraron licencias con adeudos para el año especificado';
        } else {
          this.error = response.data?.message || 'Error al obtener el reporte.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      }
    },
    printReport() {
      // Simple print of the table
      const printContents = this.$el.querySelector('.card').outerHTML;
      const win = window.open('', '', 'width=900,height=700');
      win.document.write('<html><head><title>Reporte de Giros Restringidos con Adeudos</title>');
      win.document.write('<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">');
      win.document.write('</head><body>');
      win.document.write(printContents);
      win.document.write('</body></html>');
      win.document.close();
      win.focus();
      win.print();
      win.close();
    }
  }
};
</script>

<style scoped>
.giros-dcon-adeudo-page {
  max-width: 1200px;
  margin: 0 auto;
}
.card-header {
  background: #f8f9fa;
  font-size: 1.1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
