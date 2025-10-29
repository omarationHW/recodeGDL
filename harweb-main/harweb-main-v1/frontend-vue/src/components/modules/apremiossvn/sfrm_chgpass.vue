<template>
  <div class="chgpass-page">
    <div class="chgpass-container">
      <h1>Actualizar Clave de Acceso</h1>
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label for="current_password">Clave Actual</label>
          <input type="password" id="current_password" v-model="form.current_password" maxlength="8" autocomplete="current-password" required />
        </div>
        <div class="form-group">
          <label for="new_password">Clave Nueva</label>
          <input type="password" id="new_password" v-model="form.new_password" maxlength="8" autocomplete="new-password" required />
        </div>
        <div class="form-group">
          <label for="confirm_password">Confirmación</label>
          <input type="password" id="confirm_password" v-model="form.confirm_password" maxlength="8" autocomplete="new-password" required />
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
        current_password: '',
        new_password: '',
        confirm_password: ''
      },
      loading: false,
      message: '',
      success: false
    };
  },
  methods: {
    async handleSubmit() {
      this.message = '';
      this.success = false;
      this.loading = true;
      // Validación frontend
      if (this.form.new_password !== this.form.confirm_password) {
        this.message = 'La nueva clave no es igual a la confirmación';
        this.loading = false;
        return;
      }
      if (this.form.new_password.length < 6 || this.form.new_password.length > 8) {
        this.message = 'La clave debe tener entre 6 y 8 caracteres';
        this.loading = false;
        return;
      }
      if (!(/[a-z]/.test(this.form.new_password) && /\d/.test(this.form.new_password))) {
        this.message = 'La clave debe contener letras y números';
        this.loading = false;
        return;
      }
      if (this.form.current_password === this.form.new_password) {
        this.message = 'La clave nueva no debe ser igual a la actual';
        this.loading = false;
        return;
      }
      if (this.form.current_password.substr(0,3) === this.form.new_password.substr(0,3)) {
        this.message = 'Los tres primeros caracteres de la nueva clave deben ser diferentes a la actual';
        this.loading = false;
        return;
      }
      // Llamada API
      try {
        const userId = this.$store.state.auth.user.id_usuario; // Ajustar según tu store
        const res = await this.$axios.post('/api/execute', {
          action: 'changePassword',
          params: {
            user_id: userId,
            current_password: this.form.current_password,
            new_password: this.form.new_password,
            confirm_password: this.form.confirm_password
          }
        });
        if (res.data.success) {
          this.success = true;
          this.message = res.data.message;
          this.form.current_password = '';
          this.form.new_password = '';
          this.form.confirm_password = '';
        } else {
          this.success = false;
          this.message = res.data.message;
        }
      } catch (e) {
        this.success = false;
        this.message = e.response?.data?.message || 'Error de conexión';
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.chgpass-page {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100vh;
  background: #f7f7f7;
}
.chgpass-container {
  background: #fff;
  margin-top: 60px;
  padding: 2rem 2.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.08);
  width: 400px;
}
h1 {
  text-align: center;
  margin-bottom: 2rem;
  font-size: 1.8rem;
}
.form-group {
  margin-bottom: 1.2rem;
}
label {
  display: block;
  margin-bottom: 0.3rem;
  font-weight: bold;
}
input[type="password"] {
  width: 100%;
  padding: 0.5rem;
  font-size: 1rem;
  border: 1px solid #bbb;
  border-radius: 4px;
}
.form-actions {
  text-align: center;
  margin-top: 1.5rem;
}
button {
  background: #1976d2;
  color: #fff;
  border: none;
  padding: 0.7rem 2.5rem;
  border-radius: 4px;
  font-size: 1.1rem;
  cursor: pointer;
  transition: background 0.2s;
}
button:disabled {
  background: #bbb;
  cursor: not-allowed;
}
.chgpass-message {
  margin-top: 1.2rem;
  padding: 0.8rem 1rem;
  border-radius: 4px;
  font-weight: bold;
  text-align: center;
}
.chgpass-message.error {
  background: #ffeaea;
  color: #b71c1c;
  border: 1px solid #f44336;
}
.chgpass-message.success {
  background: #e8f5e9;
  color: #388e3c;
  border: 1px solid #4caf50;
}
</style>
