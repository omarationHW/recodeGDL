<template>
  <div class="container">
    <h1>Ligar Pago Diverso a Transmisión Patrimonial</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Liga Pago Transmisión</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarPago">
      <div class="row">
        <div class="col-md-2">
          <label>Fecha Pago</label>
          <input type="date" v-model="form.fecha" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Recaudadora</label>
          <input type="number" v-model="form.recaud" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Caja</label>
          <input type="text" v-model="form.caja" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Folio</label>
          <input type="number" v-model="form.folio" class="form-control" required />
        </div>
        <div class="col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar Pago</button>
        </div>
      </div>
    </form>
    <div v-if="pago">
      <h4 class="mt-4">Pago Encontrado</h4>
      <table class="table table-bordered">
        <tr><th>Fecha</th><td>{{ pago.fecha }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ pago.recaud }}</td></tr>
        <tr><th>Caja</th><td>{{ pago.caja }}</td></tr>
        <tr><th>Folio</th><td>{{ pago.folio }}</td></tr>
        <tr><th>Importe</th><td>{{ pago.importe }}</td></tr>
        <tr><th>Cajero</th><td>{{ pago.cajero }}</td></tr>
      </table>
      <form @submit.prevent="buscarTransmision">
        <div class="row">
          <div class="col-md-3">
            <label>Folio Transmisión</label>
            <input type="number" v-model="form.folio_transmision" class="form-control" required />
          </div>
          <div class="col-md-3 align-self-end">
            <button type="submit" class="btn btn-secondary">Buscar Transmisión</button>
          </div>
        </div>
      </form>
    </div>
    <div v-if="transmision">
      <h4 class="mt-4">Transmisión Encontrada</h4>
      <table class="table table-bordered">
        <tr><th>Folio</th><td>{{ transmision.folio }}</td></tr>
        <tr><th>Notaría</th><td>{{ transmision.idnotaria }}</td></tr>
        <tr><th>No. Escrituras</th><td>{{ transmision.noescrituras }}</td></tr>
        <tr><th>Fecha Otorgamiento</th><td>{{ transmision.fechaotorg }}</td></tr>
        <tr><th>Importe</th><td>{{ transmision.valortransm }}</td></tr>
        <tr><th>Status</th><td>{{ transmision.status }}</td></tr>
      </table>
      <form @submit.prevent="ligarPago">
        <div class="row">
          <div class="col-md-3">
            <label>Tipo de Liga</label>
            <select v-model="form.tipo" class="form-control" required>
              <option value="22">Completo</option>
              <option value="33">Convenio</option>
              <option value="2">Diferencia</option>
            </select>
          </div>
          <div class="col-md-3 align-self-end">
            <button type="submit" class="btn btn-success">Ligar Pago</button>
          </div>
        </div>
      </form>
    </div>
    <div v-if="message" class="alert mt-4" :class="{'alert-success': status==='ok', 'alert-danger': status==='error'}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'LigaPagoTransmision',
  data() {
    return {
      form: {
        fecha: '',
        recaud: '',
        caja: '',
        folio: '',
        folio_transmision: '',
        tipo: '22'
      },
      pago: null,
      transmision: null,
      message: '',
      status: ''
    };
  },
  methods: {
    async buscarPago() {
      this.message = '';
      this.status = '';
      this.pago = null;
      this.transmision = null;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'searchPago',
          params: {
            fecha: this.form.fecha,
            recaud: this.form.recaud,
            caja: this.form.caja,
            folio: this.form.folio
          }
        })
      });
      const data = await res.json();
      if (data.status === 'ok' && data.data.length) {
        this.pago = data.data[0];
      } else {
        this.message = data.message;
        this.status = 'error';
      }
    },
    async buscarTransmision() {
      this.message = '';
      this.status = '';
      this.transmision = null;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'searchTransmision',
          params: {
            folio: this.form.folio_transmision
          }
        })
      });
      const data = await res.json();
      if (data.status === 'ok' && data.data.length) {
        this.transmision = data.data[0];
      } else {
        this.message = data.message;
        this.status = 'error';
      }
    },
    async ligarPago() {
      this.message = '';
      this.status = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'ligarPagoTransmision',
          params: {
            cvepago: this.pago.cvepago,
            cvecta: this.transmision.cvecuenta,
            usuario: 'usuario_actual', // Reemplazar por usuario real
            tipo: this.form.tipo,
            fecha: this.form.fecha,
            folio_transmision: this.transmision.folio
          }
        })
      });
      const data = await res.json();
      this.message = data.message;
      this.status = data.status;
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>
