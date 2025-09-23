<template>
  <div class="pagos-espe-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Pagos Especiales
    </div>
    <h1>Autorización de Pagos Especiales</h1>
    <form @submit.prevent="onAuthorize">
      <fieldset>
        <legend>Datos de Autorización</legend>
        <div class="form-row">
          <label>Cve Cuenta:</label>
          <input v-model.number="form.cvecuenta" type="number" required />
        </div>
        <div class="form-row">
          <label>Bimestre Inicial:</label>
          <input v-model.number="form.bimini" type="number" min="1" max="6" required />
        </div>
        <div class="form-row">
          <label>Año Inicial:</label>
          <input v-model.number="form.axoini" type="number" min="1900" required />
        </div>
        <div class="form-row">
          <label>Bimestre Final:</label>
          <input v-model.number="form.bimfin" type="number" min="1" max="6" required />
        </div>
        <div class="form-row">
          <label>Año Final:</label>
          <input v-model.number="form.axofin" type="number" min="1900" required />
        </div>
        <button type="submit">Autorizar Pago Especial</button>
      </fieldset>
    </form>
    <div v-if="message" :class="{'success': success, 'error': !success}" class="message">{{ message }}</div>
    <h2>Pagos Especiales Autorizados</h2>
    <table class="pagos-table">
      <thead>
        <tr>
          <th>ID</th>
          <th>Bim Ini</th>
          <th>Año Ini</th>
          <th>Bim Fin</th>
          <th>Año Fin</th>
          <th>Fecha Aut.</th>
          <th>Usuario</th>
          <th>Estado</th>
          <th>Acción</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="pago in pagos" :key="pago.cveaut">
          <td>{{ pago.cveaut }}</td>
          <td>{{ pago.bimini }}</td>
          <td>{{ pago.axoini }}</td>
          <td>{{ pago.bimfin }}</td>
          <td>{{ pago.axofin }}</td>
          <td>{{ pago.fecaut ? pago.fecaut.substr(0,10) : '' }}</td>
          <td>{{ pago.autorizo }}</td>
          <td>
            <span v-if="pago.cvepago === 999999">CANCELADO</span>
            <span v-else-if="pago.cvepago === null">VIGENTE</span>
            <span v-else>PAGADO</span>
          </td>
          <td>
            <button v-if="pago.cvepago === null" @click="onCancel(pago.cveaut)">Cancelar</button>
            <span v-else>-</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
export default {
  name: 'PagosEspePage',
  data() {
    return {
      form: {
        cvecuenta: '',
        bimini: '',
        axoini: '',
        bimfin: '',
        axofin: ''
      },
      pagos: [],
      message: '',
      success: true
    };
  },
  methods: {
    fetchPagos() {
      if (!this.form.cvecuenta) return;
      this.$axios.post('/api/execute', {
        action: 'list',
        params: { cvecuenta: this.form.cvecuenta }
      }).then(res => {
        if (res.data.success) {
          this.pagos = res.data.data;
        } else {
          this.message = res.data.message;
          this.success = false;
        }
      });
    },
    onAuthorize() {
      this.message = '';
      this.$axios.post('/api/execute', {
        action: 'authorize',
        params: { ...this.form }
      }).then(res => {
        this.success = res.data.success;
        this.message = res.data.message;
        if (res.data.success) {
          this.fetchPagos();
        }
      });
    },
    onCancel(cveaut) {
      if (!confirm('¿Seguro que desea cancelar esta autorización?')) return;
      this.$axios.post('/api/execute', {
        action: 'cancel',
        params: { cveaut }
      }).then(res => {
        this.success = res.data.success;
        this.message = res.data.message;
        if (res.data.success) {
          this.fetchPagos();
        }
      });
    }
  },
  watch: {
    'form.cvecuenta'(val) {
      if (val) this.fetchPagos();
    }
  },
  mounted() {
    // Si hay cuenta prellenada, cargar pagos
    if (this.form.cvecuenta) this.fetchPagos();
  }
};
</script>

<style scoped>
.pagos-espe-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  margin-bottom: 1rem;
}
.pagos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.pagos-table th, .pagos-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
  text-align: center;
}
.success {
  color: green;
}
.error {
  color: red;
}
</style>
