<template>
  <div class="sdosfavor-pagos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos a Favor</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h4>Datos Pago</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-row align-items-end">
            <div class="form-group col-md-2">
              <label for="reca"><strong>Rec. pago</strong></label>
              <input type="text" maxlength="3" class="form-control" id="reca" v-model="form.reca" required />
            </div>
            <div class="form-group col-md-2">
              <label for="caja"><strong>Caja</strong></label>
              <input type="text" maxlength="2" class="form-control" id="caja" v-model="form.caja" required />
            </div>
            <div class="form-group col-md-3">
              <label for="folio"><strong>Folio</strong></label>
              <input type="text" maxlength="10" class="form-control" id="folio" v-model="form.folio" required />
            </div>
            <div class="form-group col-md-3">
              <label for="fecha"><strong>Fecha Pago</strong></label>
              <input type="date" class="form-control" id="fecha" v-model="form.fecha" required />
            </div>
          </div>
          <div class="form-row align-items-end">
            <div class="form-group col-md-3">
              <label for="importe"><strong>Importe</strong></label>
              <input type="number" step="0.01" min="0" class="form-control" id="importe" v-model="form.importe" required />
            </div>
            <div class="form-group col-md-3">
              <button type="button" class="btn btn-secondary mt-4" @click="localizarPago" :disabled="!form.reca || !form.caja || !form.folio">
                Localizar Pago
              </button>
            </div>
            <div class="form-group col-md-6 text-right">
              <button type="submit" class="btn btn-primary mt-4 mr-2">Guardar</button>
              <button type="button" class="btn btn-danger mt-4" @click="eliminarPago" :disabled="!form.reca || !form.caja || !form.folio">Eliminar</button>
            </div>
          </div>
        </form>
        <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ message }}
        </div>
      </div>
    </div>
    <div class="card mt-4">
      <div class="card-header">
        <h5>Pagos Registrados</h5>
      </div>
      <div class="card-body p-0">
        <table class="table table-sm table-bordered mb-0">
          <thead>
            <tr>
              <th>Rec. pago</th>
              <th>Caja</th>
              <th>Folio</th>
              <th>Importe</th>
              <th>Fecha Pago</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pago in pagos" :key="pago.reca + '-' + pago.caja + '-' + pago.folio">
              <td>{{ pago.reca }}</td>
              <td>{{ pago.caja }}</td>
              <td>{{ pago.folio }}</td>
              <td>{{ pago.importe }}</td>
              <td>{{ pago.fecha }}</td>
              <td>
                <button class="btn btn-link btn-sm" @click="cargarPago(pago)">Editar</button>
              </td>
            </tr>
            <tr v-if="pagos.length === 0">
              <td colspan="6" class="text-center">No hay pagos registrados.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SdosFavorPagosPage',
  data() {
    return {
      form: {
        reca: '',
        caja: '',
        folio: '',
        importe: '',
        fecha: ''
      },
      pagos: [],
      message: '',
      success: true,
      oldFolio: null
    };
  },
  created() {
    this.cargarPagos();
  },
  methods: {
    async apiRequest(action, data = {}) {
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action,
              data
            }
          })
        });
        const json = await response.json();
        return json.eResponse;
      } catch (e) {
        return { success: false, message: e.message };
      }
    },
    async cargarPagos() {
      const res = await this.apiRequest('list');
      if (res.success) {
        this.pagos = res.data || [];
      } else {
        this.message = res.message;
        this.success = false;
      }
    },
    async localizarPago() {
      const { reca, caja, folio } = this.form;
      const res = await this.apiRequest('read', { reca, caja, folio });
      if (res.success && res.data) {
        this.form = { ...res.data };
        this.oldFolio = res.data.folio;
        this.message = 'Pago localizado.';
        this.success = true;
      } else {
        this.message = res.message || 'Pago no encontrado.';
        this.success = false;
      }
    },
    async onSubmit() {
      // Si oldFolio existe, es update, si no, create
      let action = this.oldFolio ? 'update' : 'create';
      let data = { ...this.form };
      if (action === 'update') data.old_folio = this.oldFolio;
      const res = await this.apiRequest(action, data);
      this.message = res.message;
      this.success = res.success;
      if (res.success) {
        this.cargarPagos();
        this.oldFolio = null;
        this.form = { reca: '', caja: '', folio: '', importe: '', fecha: '' };
      }
    },
    async eliminarPago() {
      if (!confirm('¿Está seguro de eliminar este pago?')) return;
      const { reca, caja, folio } = this.form;
      const res = await this.apiRequest('delete', { reca, caja, folio });
      this.message = res.message;
      this.success = res.success;
      if (res.success) {
        this.cargarPagos();
        this.form = { reca: '', caja: '', folio: '', importe: '', fecha: '' };
        this.oldFolio = null;
      }
    },
    cargarPago(pago) {
      this.form = { ...pago };
      this.oldFolio = pago.folio;
      this.message = '';
    }
  }
};
</script>

<style scoped>
.sdosfavor-pagos-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
