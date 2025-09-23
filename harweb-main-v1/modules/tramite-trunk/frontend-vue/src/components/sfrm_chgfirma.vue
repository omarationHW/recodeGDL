<template>
  <div class="firma-electronica-page">
    <div class="firma-header">
      <img src="/img/firma-electronica.png" alt="Firma Electrónica" class="firma-img" />
      <h1>Actualizar Firma Electrónica</h1>
      <p class="firma-info">Máximo 100 caracteres para firma electrónica</p>
    </div>
    <form @submit.prevent="onSubmit" class="firma-form">
      <div class="form-group">
        <label for="firma_actual">Firma Actual</label>
        <input type="password" id="firma_actual" v-model="form.firma_actual" maxlength="100" required />
      </div>
      <div class="form-group">
        <label for="firma_nueva">Firma Nueva</label>
        <input type="password" id="firma_nueva" v-model="form.firma_nueva" maxlength="100" required />
      </div>
      <div class="form-group">
        <label for="firma_conf">Confirmación</label>
        <input type="password" id="firma_conf" v-model="form.firma_conf" maxlength="100" required />
      </div>
      <div class="form-actions">
        <button type="submit" :disabled="loading">Cambiar Firma</button>
      </div>
      <div v-if="message" :class="{'success': success, 'error': !success}" class="firma-message">
        {{ message }}
      </div>
    </form>
  </div>
</template>

<script>
export default {
  name: 'FirmaElectronicaPage',
  data() {
    return {
      form: {
        usuario: '', // Se debe setear desde el contexto de sesión
        firma_actual: '',
        firma_nueva: '',
        firma_conf: '',
        modulos_id: 3
      },
      loading: false,
      message: '',
      success: false
    }
  },
  created() {
    // Aquí deberías obtener el usuario autenticado
    // Por ejemplo, desde Vuex o un endpoint de sesión
    this.form.usuario = this.$store.state.auth.user || '';
  },
  methods: {
    async onSubmit() {
      this.message = '';
      this.success = false;
      if (this.form.firma_nueva !== this.form.firma_conf) {
        this.message = 'La nueva firma no coincide con la confirmación.';
        return;
      }
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'chg_firma',
            usuario: this.form.usuario,
            firma_actual: this.form.firma_actual,
            firma_nueva: this.form.firma_nueva,
            firma_conf: this.form.firma_conf,
            modulos_id: this.form.modulos_id
          }
        });
        const eResponse = response.data.eResponse;
        this.message = eResponse.message;
        this.success = eResponse.success;
        if (eResponse.success) {
          this.form.firma_actual = '';
          this.form.firma_nueva = '';
          this.form.firma_conf = '';
        }
      } catch (err) {
        this.message = err.response?.data?.eResponse?.message || 'Error de comunicación con el servidor.';
        this.success = false;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.firma-electronica-page {
  max-width: 500px;
  margin: 40px auto;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
  padding: 32px 24px;
}
.firma-header {
  text-align: center;
  margin-bottom: 24px;
}
.firma-img {
  width: 120px;
  margin-bottom: 12px;
}
.firma-info {
  color: #888;
  font-size: 13px;
}
.firma-form .form-group {
  margin-bottom: 18px;
}
.firma-form label {
  display: block;
  font-weight: bold;
  margin-bottom: 6px;
}
.firma-form input {
  width: 100%;
  padding: 8px 10px;
  border: 1px solid #bbb;
  border-radius: 4px;
  font-size: 15px;
}
.firma-form .form-actions {
  text-align: right;
}
.firma-form button {
  background: #1976d2;
  color: #fff;
  border: none;
  padding: 10px 22px;
  border-radius: 4px;
  font-size: 16px;
  cursor: pointer;
}
.firma-form button:disabled {
  background: #bbb;
  cursor: not-allowed;
}
.firma-message {
  margin-top: 18px;
  padding: 10px 14px;
  border-radius: 4px;
  font-size: 15px;
}
.firma-message.success {
  background: #e8f5e9;
  color: #388e3c;
  border: 1px solid #c8e6c9;
}
.firma-message.error {
  background: #ffebee;
  color: #c62828;
  border: 1px solid #ffcdd2;
}
</style>
