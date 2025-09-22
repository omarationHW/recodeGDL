<template>
  <div class="consreq400-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Requerimientos AS-400</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h4>Requerimientos realizados en el AS-400</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="buscar">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="recaud" class="form-label">Recaudadora</label>
              <input
                id="recaud"
                v-model="form.recaud"
                type="number"
                class="form-control"
                @keyup.enter="focusUr"
                min="0"
                max="99"
                required
              />
              <small class="text-muted">0 o 1</small>
            </div>
            <div class="col-md-4">
              <label for="ur" class="form-label">UR</label>
              <input
                id="ur"
                v-model="form.ur"
                type="number"
                class="form-control"
                @keyup.enter="focusCuenta"
                min="0"
                required
              />
            </div>
            <div class="col-md-4">
              <label for="cuenta" class="form-label">Cuenta</label>
              <input
                id="cuenta"
                v-model="form.cuenta"
                type="number"
                class="form-control"
                @keyup.enter="focusBuscar"
                min="0"
                required
              />
            </div>
          </div>
          <button ref="buscarBtn" type="submit" class="btn btn-primary">Buscar</button>
        </form>
        <div v-if="message" class="alert mt-3" :class="{'alert-danger': !success, 'alert-success': success}">
          {{ message }}
        </div>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Buscando...
        </div>
        <div v-if="results.length > 0" class="table-responsive mt-4">
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th v-for="col in columns" :key="col">{{ col }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in results" :key="idx">
                <td v-for="col in columns" :key="col">{{ row[col] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="!loading && searched" class="alert alert-info mt-4">
          No se localizaron requerimientos del AS400.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsReq400Page',
  data() {
    return {
      form: {
        recaud: '',
        ur: '',
        cuenta: ''
      },
      loading: false,
      message: '',
      success: false,
      results: [],
      columns: [],
      searched: false
    };
  },
  methods: {
    focusUr() {
      this.$nextTick(() => {
        this.$el.querySelector('#ur').focus();
      });
    },
    focusCuenta() {
      this.$nextTick(() => {
        this.$el.querySelector('#cuenta').focus();
      });
    },
    focusBuscar() {
      this.$nextTick(() => {
        this.$refs.buscarBtn.focus();
      });
    },
    padCuenta(cuenta) {
      // Delphi: algo := copy('000000',1,(6-largo)); algo := algo+cuenta.text;
      let c = String(cuenta);
      return c.padStart(6, '0');
    },
    padRecaud(recaud) {
      // Delphi: reca := '00'+recaud.text;
      let r = String(recaud);
      return r.padStart(2, '0');
    },
    async buscar() {
      this.loading = true;
      this.message = '';
      this.success = false;
      this.results = [];
      this.searched = false;
      try {
        const params = {
          ofnar: this.padRecaud(this.form.recaud),
          tpr: String(this.form.ur),
          ctarfc: this.padCuenta(this.form.cuenta)
        };
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              operation: 'getConsReq400',
              params
            }
          })
        });
        const data = await response.json();
        this.searched = true;
        if (data.eResponse.success) {
          this.results = data.eResponse.data;
          this.success = true;
          this.message = data.eResponse.message;
          if (this.results.length > 0) {
            this.columns = Object.keys(this.results[0]);
          }
        } else {
          this.success = false;
          this.message = data.eResponse.message || 'Error en la búsqueda.';
        }
      } catch (err) {
        this.success = false;
        this.message = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.consreq400-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
