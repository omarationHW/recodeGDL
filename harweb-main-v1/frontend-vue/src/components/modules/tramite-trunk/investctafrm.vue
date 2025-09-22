<template>
  <div class="investcta-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Investigación de Cuentas</span>
    </div>
    <div class="card">
      <h2>Investigación de Cuentas</h2>
      <form @submit.prevent="onSubmit">
        <div class="form-row">
          <label for="cvecuenta">Cuenta Catastral</label>
          <input v-model="form.cvecuenta" id="cvecuenta" type="number" required @change="fetchCuenta" :disabled="loading" />
        </div>
        <div v-if="cuenta">
          <div class="form-row">
            <label>Fecha último comprobante</label>
            <input :value="cuenta.feccap" disabled />
          </div>
          <div class="form-row">
            <label>Capturista</label>
            <input :value="cuenta.capturista" disabled />
          </div>
          <div class="form-row">
            <label>Año comprobante</label>
            <input :value="cuenta.axocomp" disabled />
          </div>
          <div class="form-row">
            <label>Comprobante</label>
            <input :value="cuenta.nocomp" disabled />
          </div>
        </div>
        <div class="form-row">
          <label for="observacion">Observaciones</label>
          <textarea v-model="form.observacion" id="observacion" rows="6" required @input="toUppercase" :disabled="loading"></textarea>
        </div>
        <div class="form-actions">
          <button type="submit" :disabled="loading">Actualizar</button>
          <button type="button" @click="onCancel" :disabled="loading">Cancelar</button>
        </div>
        <div v-if="message" :class="{'success': success, 'error': !success}" class="form-message">{{ message }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'InvestCtaPage',
  data() {
    return {
      form: {
        cvecuenta: '',
        observacion: ''
      },
      cuenta: null,
      loading: false,
      message: '',
      success: false
    }
  },
  methods: {
    fetchCuenta() {
      if (!this.form.cvecuenta) return;
      this.loading = true;
      this.message = '';
      this.$axios.post('/api/execute', {
        action: 'get_last_comprobante',
        params: { cvecuenta: this.form.cvecuenta }
      }).then(res => {
        if (res.data.success) {
          this.cuenta = res.data.data;
        } else {
          this.cuenta = null;
          this.message = res.data.message;
        }
      }).catch(() => {
        this.cuenta = null;
        this.message = 'Error al consultar la cuenta';
      }).finally(() => {
        this.loading = false;
      });
    },
    onSubmit() {
      if (!this.form.cvecuenta || !this.form.observacion) {
        this.message = 'Todos los campos son obligatorios';
        this.success = false;
        return;
      }
      this.loading = true;
      this.message = '';
      this.$axios.post('/api/execute', {
        action: 'update_investcta',
        params: {
          cvecuenta: this.form.cvecuenta,
          observacion: this.form.observacion
        }
      }).then(res => {
        this.success = res.data.success;
        this.message = res.data.message;
        if (res.data.success) {
          this.fetchCuenta();
        }
      }).catch(() => {
        this.success = false;
        this.message = 'Error al actualizar';
      }).finally(() => {
        this.loading = false;
      });
    },
    onCancel() {
      this.form.observacion = '';
      this.message = '';
    },
    toUppercase(e) {
      this.form.observacion = this.form.observacion.toUpperCase();
    }
  }
}
</script>

<style scoped>
.investcta-page {
  max-width: 600px;
  margin: 0 auto;
}
.card {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  flex-direction: column;
}
.form-row label {
  font-weight: bold;
  margin-bottom: 0.25rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
}
.form-message {
  margin-top: 1rem;
}
.success {
  color: green;
}
.error {
  color: red;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
  color: #888;
}
</style>
