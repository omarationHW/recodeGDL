<template>
  <div class="chgpass-page">
    <div class="chgpass-container">
      <h2>Actualizar Clave de Acceso</h2>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label for="current_password">Clave Actual</label>
          <input type="password" v-model="form.current_password" maxlength="8" required autocomplete="current-password" />
        </div>
        <div class="form-group">
          <label for="new_password">Clave Nueva</label>
          <input type="password" v-model="form.new_password" maxlength="8" required autocomplete="new-password" />
        </div>
        <div class="form-group">
          <label for="confirm_password">Confirmación</label>
          <input type="password" v-model="form.confirm_password" maxlength="8" required autocomplete="new-password" />
        </div>
        <div class="form-actions">
          <button type="submit" :disabled="loading">Cambiar Clave</button>
        </div>
        <div v-if="message" :class="{'error': !success, 'success': success}" class="chgpass-message">
          {{ message }}
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ChgPassPage',
  data() {
    return {
      form: {
        username: '', // Se debe obtener del contexto de sesión
        current_password: '',
        new_password: '',
        confirm_password: ''
      },
      loading: false,
      message: '',
      success: false
    }
  },
  mounted() {
    // Aquí se debe obtener el usuario logueado (ejemplo: desde Vuex o localStorage)
    this.form.username = this.$store.state.auth.username || '';
  },
  methods: {
    async onSubmit() {
      this.message = '';
      this.success = false;
      this.loading = true;
      // Validación frontend
      if (this.form.new_password !== this.form.confirm_password) {
        this.message = 'La nueva clave no es igual a la confirmación';
        this.loading = false;
        return;
      }
      if (!/^(?=.*[a-z])(?=.*\d)[a-z\d]{6,8}$/.test(this.form.new_password)) {
        this.message = 'La nueva clave debe contener letras y números, y tener entre 6 y 8 caracteres';
        this.loading = false;
        return;
      }
      if (this.form.current_password === this.form.new_password) {
        this.message = 'La nueva clave no debe ser igual a la actual';
        this.loading = false;
        return;
      }
      if (this.form.current_password.substr(0,3) === this.form.new_password.substr(0,3)) {
        this.message = 'Los tres primeros caracteres deben ser diferentes a la clave actual';
        this.loading = false;
        return;
      }
      // Llamada API
      try {
        const eRequest = {
          action: 'changePassword',
          username: this.form.username,
          current_password: this.form.current_password,
          new_password: this.form.new_password,
          confirm_password: this.form.confirm_password
        };
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.message = data.message;
          this.success = true;
          this.form.current_password = '';
          this.form.new_password = '';
          this.form.confirm_password = '';
        } else {
          this.message = data.message;
          this.success = false;
        }
      } catch (err) {
        this.message = err.message || 'Error de red';
        this.success = false;
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.chgpass-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
  background: #f8f8f8;
}
.chgpass-container {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  width: 400px;
}
.chgpass-container h2 {
  text-align: center;
  margin-bottom: 1.5rem;
}
.form-group {
  margin-bottom: 1.2rem;
}
.form-group label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.4rem;
}
.form-group input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #bbb;
  border-radius: 4px;
  font-size: 1rem;
}
.form-actions {
  text-align: center;
  margin-top: 1.5rem;
}
.form-actions button {
  background: #1976d2;
  color: #fff;
  border: none;
  padding: 0.7rem 2.5rem;
  border-radius: 4px;
  font-size: 1.1rem;
  cursor: pointer;
}
.form-actions button:disabled {
  background: #bbb;
  cursor: not-allowed;
}
.chgpass-message {
  margin-top: 1.2rem;
  text-align: center;
  font-weight: bold;
}
.chgpass-message.error {
  color: #b71c1c;
}
.chgpass-message.success {
  color: #388e3c;
}
</style>
