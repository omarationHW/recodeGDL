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
              <input type="number" id="recaud" v-model="recaud" class="form-control" @keyup.enter="focusUr" min="0" required />
            </div>
            <div class="col-md-4">
              <label for="ur" class="form-label">0 o 1</label>
              <input type="number" id="ur" v-model="ur" class="form-control" @keyup.enter="focusCuenta" min="0" max="1" required />
            </div>
            <div class="col-md-4">
              <label for="cuenta" class="form-label">Cuenta</label>
              <input type="number" id="cuenta" v-model="cuenta" class="form-control" @keyup.enter="focusBuscar" min="0" required />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12 text-end">
              <button type="submit" ref="buscarBtn" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="mensaje" class="alert" :class="{'alert-danger': !success, 'alert-success': success}">
          {{ mensaje }}
        </div>
        <div v-if="resultados.length > 0" class="table-responsive">
          <table class="table table-bordered table-sm mt-3">
            <thead>
              <tr>
                <th v-for="col in columnas" :key="col">{{ col }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in resultados" :key="idx">
                <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
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
  name: 'ConsReq400Page',
  data() {
    return {
      recaud: '',
      ur: '',
      cuenta: '',
      resultados: [],
      mensaje: '',
      success: false,
      columnas: [
        'folreq','fecent1','fecent2','prareq','fecpra','horapra','feccita','horacit','vigreq','ejereq','dilreq','fecreq','fecpagr','ofnpagr','cajpag','opepagr','actreq','observr','axodesr','mesdesr','axohasr','meshasr','cvelet','cvenum','mesgas','zonreq','impgas','impcuo','cvesecr','cveremr','fecremr','mulreq','grabo02'
      ]
    };
  },
  methods: {
    focusUr() {
      this.$refs.ur && this.$refs.ur.focus();
    },
    focusCuenta() {
      this.$refs.cuenta && this.$refs.cuenta.focus();
    },
    focusBuscar() {
      this.$refs.buscarBtn && this.$refs.buscarBtn.focus();
    },
    async buscar() {
      // Formateo de parámetros como en Delphi
      let cuentaStr = this.cuenta.toString();
      let largo = cuentaStr.length;
      let algo = '000000'.substring(0, 6 - largo) + cuentaStr;
      let reca = '00' + this.recaud.toString();

      const payload = {
        eRequest: {
          operation: 'consreq400_search',
          params: {
            ofnar: reca,
            tpr: this.ur.toString(),
            ctarfc: algo
          }
        }
      };
      this.mensaje = '';
      this.success = false;
      this.resultados = [];
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify(payload)
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
          this.success = true;
          this.mensaje = data.eResponse.message;
        } else {
          this.mensaje = data.eResponse.message;
        }
      } catch (err) {
        this.mensaje = 'Error de comunicación con el servidor.';
      }
    }
  }
};
</script>

<style scoped>
.consreq400-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card-header h4 {
  margin: 0;
}
.table th, .table td {
  font-size: 0.95rem;
  vertical-align: middle;
}
</style>
