<template>
  <div class="rptfact-merc-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Facturación de Requerimientos de Mercados</li>
      </ol>
    </nav>
    <h1>Facturación de Requerimientos de Mercados</h1>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="rec">Zona (rec)</label>
          <input type="number" class="form-control" id="rec" v-model.number="form.rec" required />
        </div>
        <div class="form-group col-md-2">
          <label for="fol1">Folio Inicial</label>
          <input type="number" class="form-control" id="fol1" v-model.number="form.fol1" required />
        </div>
        <div class="form-group col-md-2">
          <label for="fol2">Folio Final</label>
          <input type="number" class="form-control" id="fol2" v-model.number="form.fol2" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="my-3">
      <span>Cargando...</span>
    </div>
    <div v-if="error" class="alert alert-danger my-3">
      {{ error }}
    </div>
    <div v-if="report.length > 0" class="table-responsive mt-4">
      <h5>Folios de {{ form.fol1 }} hasta {{ form.fol2 }}</h5>
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>OFNA</th>
            <th>MDO</th>
            <th>CAT</th>
            <th>SECC</th>
            <th>LOCAL</th>
            <th>LET</th>
            <th>BLOQ</th>
            <th>NOMBRE-ARRENDATARIO</th>
            <th>ZONA</th>
            <th>FOLIO</th>
            <th>OBSERVACIONES</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_local + '-' + row.folio">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.zona_apremio }}</td>
            <td>{{ row.folio }}</td>
            <td>{{ row.observaciones }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && report.length === 0 && submitted" class="alert alert-info mt-4">
      No se encontraron resultados para los parámetros ingresados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptFactMercPage',
  data() {
    return {
      form: {
        rec: '',
        fol1: '',
        fol2: ''
      },
      report: [],
      loading: false,
      error: '',
      submitted: false
    };
  },
  methods: {
    async fetchReport() {
      this.error = '';
      this.loading = true;
      this.submitted = true;
      this.report = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'RptFact_Merc.getReport',
              params: {
                rec: this.form.rec,
                fol1: this.form.fol1,
                fol2: this.form.fol2
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rptfact-merc-page {
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
