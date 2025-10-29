<template>
  <div class="traslados-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Traslado de Pagos</li>
      </ol>
    </nav>
    <h2>Traslado de pagos</h2>
    <div class="card mb-3">
      <div class="card-header">Datos del pago erróneo</div>
      <div class="card-body">
        <form @submit.prevent="buscarPago">
          <div class="row mb-2">
            <div class="col-md-2">
              <label>Rec</label>
              <input v-model="form.recaud" class="form-control" @keyup.enter="focusFecha" required />
            </div>
            <div class="col-md-2">
              <label>Folio</label>
              <input v-model="form.folio" class="form-control" @keyup.enter="focusCaja" required />
            </div>
            <div class="col-md-2">
              <label>Caja</label>
              <input v-model="form.caja" class="form-control" @keyup.enter="focusImporte" required />
            </div>
            <div class="col-md-2">
              <label>Fecha</label>
              <input type="date" v-model="form.fecha" ref="fecha" class="form-control" @keyup.enter="focusImporte" required />
            </div>
            <div class="col-md-2">
              <label>Importe</label>
              <input v-model="form.importe" class="form-control" ref="importe" required />
            </div>
            <div class="col-md-2 d-flex align-items-end">
              <button class="btn btn-primary w-100" type="submit">Buscar pago</button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
      </div>
    </div>

    <div v-if="pagoEncontrado">
      <div class="card mb-3">
        <div class="card-header">Saldo a la fecha del pago</div>
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-3">
              <label>Cuenta</label>
              <input v-model="pagoEncontrado.cuenta" class="form-control" readonly />
            </div>
            <div class="col-md-3">
              <label>Folio</label>
              <input v-model="pagoEncontrado.folio" class="form-control" readonly />
            </div>
            <div class="col-md-3">
              <label>Año</label>
              <input v-model="pagoEncontrado.anio" class="form-control" readonly />
            </div>
            <div class="col-md-3">
              <label>Importe</label>
              <input v-model="pagoEncontrado.importe" class="form-control" readonly />
            </div>
          </div>
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-header">Requerimientos</div>
        <div class="card-body">
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th>Concepto</th>
                <th>Importe</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="req in requerimientos" :key="req.id">
                <td>{{ req.concepto }}</td>
                <td>{{ req.importe }}</td>
                <td>{{ req.estado }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-header">Aplicar traslado</div>
        <div class="card-body">
          <form @submit.prevent="aplicarTraslado">
            <div class="row mb-2">
              <div class="col-md-4">
                <label>Tipo de aplicación</label>
                <select v-model="form.tipo_aplicacion" class="form-control" required>
                  <option value="futuros">Futuros pagos</option>
                  <option value="saldar">Saldar adeudos</option>
                  <option value="devolucion">Devolución</option>
                </select>
              </div>
              <div class="col-md-4">
                <label>Usuario</label>
                <input v-model="form.usuario" class="form-control" required />
              </div>
              <div class="col-md-4 d-flex align-items-end">
                <button class="btn btn-success w-100" type="submit">Aplicar</button>
              </div>
            </div>
          </form>
          <div v-if="aplicarResult" class="alert alert-success mt-2">{{ aplicarResult }}</div>
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-header">Liquidación</div>
        <div class="card-body">
          <button class="btn btn-warning" @click="liquidarPago">Liquidar</button>
          <div v-if="liquidarResult" class="alert alert-info mt-2">{{ liquidarResult }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TrasladosFrm',
  data() {
    return {
      form: {
        recaud: '',
        folio: '',
        caja: '',
        fecha: '',
        importe: '',
        tipo_aplicacion: 'futuros',
        usuario: ''
      },
      pagoEncontrado: null,
      requerimientos: [],
      aplicarResult: '',
      liquidarResult: '',
      error: ''
    };
  },
  methods: {
    focusFecha() {
      this.$refs.fecha.focus();
    },
    focusCaja() {
      // Not needed, handled by browser tab order
    },
    focusImporte() {
      this.$refs.importe.focus();
    },
    async buscarPago() {
      this.error = '';
      this.pagoEncontrado = null;
      this.requerimientos = [];
      this.aplicarResult = '';
      this.liquidarResult = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar_pago',
              params: {
                recaud: this.form.recaud,
                folio: this.form.folio,
                caja: this.form.caja,
                fecha: this.form.fecha,
                importe: this.form.importe
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          this.pagoEncontrado = data.eResponse.data[0];
          await this.obtenerRequerimientos(this.pagoEncontrado.id);
        } else {
          this.error = data.eResponse.message || 'Pago no encontrado';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async obtenerRequerimientos(pago_id) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'obtener_requerimientos',
              params: { pago_id }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.requerimientos = data.eResponse.data;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async aplicarTraslado() {
      if (!this.pagoEncontrado) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'aplicar_traslado',
              params: {
                pago_id: this.pagoEncontrado.id,
                tipo_aplicacion: this.form.tipo_aplicacion,
                usuario: this.form.usuario
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.aplicarResult = 'Traslado aplicado correctamente.';
        } else {
          this.aplicarResult = data.eResponse.message || 'Error al aplicar traslado.';
        }
      } catch (e) {
        this.aplicarResult = e.message;
      }
    },
    async liquidarPago() {
      if (!this.pagoEncontrado) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'liquidar_pago',
              params: {
                pago_id: this.pagoEncontrado.id,
                usuario: this.form.usuario
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.liquidarResult = 'Pago liquidado correctamente.';
        } else {
          this.liquidarResult = data.eResponse.message || 'Error al liquidar pago.';
        }
      } catch (e) {
        this.liquidarResult = e.message;
      }
    }
  }
};
</script>

<style scoped>
.traslados-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 6px rgba(0,0,0,0.05);
}
</style>
