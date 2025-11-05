<template>
  <div class="firma-electronica-page">
    <div class="firma-form-container">
      <img src="/img/firma-electronica.png" alt="Firma Electrónica" class="firma-img" />
      <h1>Actualizar Firma Electrónica</h1>
      <form @submit.prevent="onSubmit">
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
        <div class="form-group">
          <label for="modulos_id">Módulo</label>
          <select id="modulos_id" v-model="form.modulos_id" required>
            <option :value="1">Licencias</option>
            <option :value="2">Ubicación</option>
          </select>
        </div>
        <div class="form-group">
          <button type="submit" :disabled="loading">Cambiar Firma</button>
        </div>
        <div v-if="message" :class="{'success': success, 'error': !success}" class="message">
          {{ message }}
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FirmaElectronicaPage',
  data() {
    return {
      form: {
        usuario: '', // Se debe obtener del contexto de sesión
        firma_actual: '',
        firma_nueva: '',
        firma_conf: '',
        modulos_id: 1
      },
      loading: false,
      message: '',
      success: false
    };
  },
  mounted() {
    // Aquí se debe obtener el usuario autenticado
    // Por ejemplo, desde Vuex o un endpoint de sesión
    this.form.usuario = this.$store.state.auth.user || '';
  },
  methods: {
    async onSubmit() {
      this.loading = true;
      this.message = '';
      this.success = false;
      try {
        const eRequest = {
          action: 'chg_firma',
          usuario: this.form.usuario,
          firma_actual: this.form.firma_actual,
          firma_nueva: this.form.firma_nueva,
          firma_conf: this.form.firma_conf,
          modulos_id: this.form.modulos_id
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        });
        const data = await response.json();
        const res = data.eResponse;
        this.success = res.success;
        this.message = res.message;
        if (res.success) {
          this.form.firma_actual = '';
          this.form.firma_nueva = '';
          this.form.firma_conf = '';
        }
      } catch (e) {
        this.success = false;
        this.message = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.firma-electronica-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f7f7f7;
}
.firma-form-container {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  max-width: 420px;
  width: 100%;
}
.firma-img {
  display: block;
  margin: 0 auto 1.5rem auto;
  width: 120px;
}
h1 {
  text-align: center;
  margin-bottom: 2rem;
  font-size: 1.5rem;
}
.form-group {
  margin-bottom: 1.2rem;
}
label {
  display: block;
  font-weight: 600;
  margin-bottom: 0.4rem;
}
input, select {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #bbb;
  border-radius: 4px;
  font-size: 1rem;
}
button {
  width: 100%;
  padding: 0.7rem;
  background: #1976d2;
  color: #fff;
  border: none;
  border-radius: 4px;
  font-size: 1.1rem;
  font-weight: bold;
  cursor: pointer;
}
button:disabled {
  background: #aaa;
  cursor: not-allowed;
}
.message {
  margin-top: 1rem;
  padding: 0.8rem;
  border-radius: 4px;
  text-align: center;
}
.success {
  background: #e0f7e9;
  color: #1b5e20;
  border: 1px solid #43a047;
}
.error {
  background: #ffebee;
  color: #b71c1c;
  border: 1px solid #e53935;
}
</style>
