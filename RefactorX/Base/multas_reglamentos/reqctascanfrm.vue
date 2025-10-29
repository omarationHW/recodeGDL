<template>
  <div class="reqctascanfrm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de folios de requerimiento de cuentas canceladas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        Listado de folios de requerimiento de cuentas canceladas
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="recaudadora" class="form-label"><b>Recaudadora</b></label>
              <div>
                <div v-for="r in recaudadoras" :key="r.id" class="form-check">
                  <input class="form-check-input" type="radio" :id="'recaudadora'+r.id" v-model="form.recaud" :value="r.id">
                  <label class="form-check-label" :for="'recaudadora'+r.id">{{ r.name }}</label>
                </div>
              </div>
              <div v-if="errors.recaud" class="text-danger small">{{ errors.recaud }}</div>
            </div>
            <div class="col-md-4">
              <label for="fini" class="form-label"><b>Fecha Inicial</b></label>
              <input type="date" id="fini" v-model="form.fini" class="form-control">
              <div v-if="errors.fini" class="text-danger small">{{ errors.fini }}</div>
            </div>
            <div class="col-md-4">
              <label for="ffin" class="form-label"><b>Fecha Final</b></label>
              <input type="date" id="ffin" v-model="form.ffin" class="form-control">
              <div v-if="errors.ffin" class="text-danger small">{{ errors.ffin }}</div>
            </div>
          </div>
          <button type="submit" class="btn btn-success"><i class="fa fa-print"></i> Imprimir</button>
        </form>
        <div v-if="loading" class="mt-3">
          <span class="spinner-border spinner-border-sm"></span> Cargando...
        </div>
        <div v-if="errorMsg" class="alert alert-danger mt-3">{{ errorMsg }}</div>
        <div v-if="results.length" class="mt-4">
          <h5>Resultados (Recaudadora: {{ recaudadoraName }})</h5>
          <p>Del {{ form.fini }} al {{ form.ffin }}</p>
          <table class="table table-bordered table-sm">
            <thead class="table-light">
              <tr>
                <th>Cve Cuenta</th>
                <th>Recaud</th>
                <th>Cuenta</th>
                <th>Cuenta UTM</th>
                <th>Folios</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in results" :key="row.cvecuenta">
                <td>{{ row.cvecuenta }}</td>
                <td>{{ row.recaud }}</td>
                <td>{{ row.cuenta }}</td>
                <td>{{ row.cuenta_utm }}</td>
                <td>
                  <ul class="mb-0 ps-3">
                    <li v-for="folio in row.folios" :key="folio.folioreq">{{ folio.folioreq }}</li>
                  </ul>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReqCtasCanFrm',
  data() {
    const today = new Date().toISOString().substr(0, 10);
    return {
      recaudadoras: [],
      form: {
        recaud: '',
        fini: today,
        ffin: today
      },
      errors: {},
      loading: false,
      errorMsg: '',
      results: []
    };
  },
  computed: {
    recaudadoraName() {
      const r = this.recaudadoras.find(x => x.id === Number(this.form.recaud));
      return r ? r.name : '';
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    fetchRecaudadoras() {
      // Hardcoded or via API
      this.loading = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: 'reqctascanfrm.get_recaudadoras' })
      })
        .then(r => r.json())
        .then(json => {
          this.recaudadoras = json.eResponse.data || [];
        })
        .catch(() => {
          this.recaudadoras = [
            { id: 1, name: 'Zona Centro' },
            { id: 2, name: 'Zona Olimpica' },
            { id: 3, name: 'Zona Oblatos' },
            { id: 4, name: 'Zona Minerva' }
          ];
        })
        .finally(() => {
          this.loading = false;
        });
    },
    validate() {
      this.errors = {};
      if (!this.form.recaud) this.errors.recaud = 'Seleccione una recaudadora';
      if (!this.form.fini) this.errors.fini = 'Ingrese la fecha inicial';
      if (!this.form.ffin) this.errors.ffin = 'Ingrese la fecha final';
      return Object.keys(this.errors).length === 0;
    },
    async onSubmit() {
      if (!this.validate()) return;
      this.loading = true;
      this.errorMsg = '';
      this.results = [];
      try {
        // 1. Obtener cuentas canceladas
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'reqctascanfrm.get_cancelled_accounts',
            params: {
              recaud: this.form.recaud,
              fini: this.form.fini,
              ffin: this.form.ffin
            }
          })
        });
        const json = await resp.json();
        if (!json.eResponse.success) throw new Error(json.eResponse.message);
        const cuentas = json.eResponse.data;
        // 2. Para cada cuenta, obtener folios
        for (let row of cuentas) {
          const folioResp = await fetch('/api/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              eRequest: 'reqctascanfrm.get_folios_by_cvecuenta',
              params: { cvecuenta: row.cvecuenta }
            })
          });
          const folioJson = await folioResp.json();
          row.folios = folioJson.eResponse.data || [];
        }
        this.results = cuentas;
      } catch (e) {
        this.errorMsg = e.message || 'Error al consultar datos';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.reqctascanfrm-page {
  max-width: 1100px;
  margin: 0 auto;
}
</style>
