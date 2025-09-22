<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de TP AS400</li>
      </ol>
    </nav>
    <h2>Consulta de Transmisiones Patrimoniales AS400</h2>
    <form @submit.prevent="buscar">
      <div class="row mb-3">
        <div class="col-md-3">
          <label for="fecha" class="form-label">Fecha de pago</label>
          <input type="number" class="form-control" id="fecha" v-model.number="form.fecha" @keyup.enter="focusNext('recaud')" />
        </div>
        <div class="col-md-3">
          <label for="recaud" class="form-label">Recaudadora de pago</label>
          <input type="number" class="form-control" id="recaud" v-model.number="form.recaud" @keyup.enter="focusNext('caja')" />
        </div>
        <div class="col-md-3">
          <label for="caja" class="form-label">Caja</label>
          <input type="text" class="form-control" id="caja" v-model="form.caja" @input="toUpper('caja')" @keyup.enter="focusNext('operacion')" />
        </div>
        <div class="col-md-3">
          <label for="operacion" class="form-label">Operación</label>
          <input type="number" class="form-control" id="operacion" v-model.number="form.operacion" @keyup.enter="focusNext('buscarBtn')" />
        </div>
      </div>
      <button type="submit" class="btn btn-primary" ref="buscarBtn">Buscar</button>
    </form>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>

    <div v-if="pagos.length > 0" class="mt-4">
      <h5>Pagos de Transmisiones Patrimoniales realizados en el AS-400</h5>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th v-for="col in pagosColumns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in pagos" :key="idx">
              <td v-for="col in pagosColumns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="transmisiones.length > 0" class="mt-4">
      <h5>Datos de la Transmisión Patrimonial</h5>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th v-for="col in transmColumns" :key="col">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in transmisiones" :key="idx">
              <td v-for="col in transmColumns" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="pagos.length === 0 && transmisiones.length === 0 && searched" class="alert alert-warning mt-4">
      No se localizaron pagos de transmisiones patrimoniales en el AS400.
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaTPAS400',
  data() {
    return {
      form: {
        fecha: '',
        recaud: '',
        caja: '',
        operacion: ''
      },
      pagos: [],
      transmisiones: [],
      pagosColumns: [],
      transmColumns: [],
      error: '',
      searched: false
    };
  },
  methods: {
    async buscar() {
      this.error = '';
      this.pagos = [];
      this.transmisiones = [];
      this.pagosColumns = [];
      this.transmColumns = [];
      this.searched = false;
      try {
        // Consultar pagos
        const pagosResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'consultarPagosTransmisionesPatrimoniales',
            params: {
              fecha: this.form.fecha || null,
              recaud: this.form.recaud || null,
              operacion: this.form.operacion || null,
              caja: this.form.caja || null
            }
          })
        });
        const pagosData = await pagosResp.json();
        if (pagosData.eResponse.success && pagosData.eResponse.data.length > 0) {
          this.pagos = pagosData.eResponse.data;
          this.pagosColumns = Object.keys(this.pagos[0]);
        }
        // Consultar transmisiones
        const transmResp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'consultarTransmisionesPatrimoniales',
            params: {
              fecha: this.form.fecha || null,
              recaud: this.form.recaud || null,
              operacion: this.form.operacion || null,
              caja: this.form.caja || null
            }
          })
        });
        const transmData = await transmResp.json();
        if (transmData.eResponse.success && transmData.eResponse.data.length > 0) {
          this.transmisiones = transmData.eResponse.data;
          this.transmColumns = Object.keys(this.transmisiones[0]);
        }
        this.searched = true;
      } catch (err) {
        this.error = 'Error al consultar: ' + (err.message || err);
      }
    },
    focusNext(ref) {
      if (ref === 'buscarBtn') {
        this.$refs.buscarBtn.focus();
      } else {
        const el = document.getElementById(ref);
        if (el) el.focus();
      }
    },
    toUpper(field) {
      this.form[field] = this.form[field].toUpperCase();
    }
  }
};
</script>

<style scoped>
.table-responsive {
  max-height: 300px;
  overflow-y: auto;
}
</style>
