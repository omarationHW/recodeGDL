<template>
  <div class="passwdfrm-page">
    <div class="passwdfrm-container">
      <div class="passwdfrm-header">
        <img src="/img/user-lock.png" alt="Autorización" class="passwdfrm-icon" />
        <h2>Autorización</h2>
      </div>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label for="usuario"><b>Usuario</b></label>
          <input v-model="usuario" id="usuario" type="text" autocomplete="username" required />
        </div>
        <div class="form-group">
          <label for="password"><b>Passwd</b></label>
          <input v-model="password" id="password" type="password" autocomplete="current-password" required />
        </div>
        <div class="form-actions">
          <button type="submit" :disabled="loading">Aceptar</button>
          <button type="button" @click="onCancel">Cancelar</button>
        </div>
        <div v-if="error" class="error-message">{{ error }}</div>
        <div v-if="success" class="success-message">{{ success }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PasswdFrmPage',
  data() {
    return {
      usuario: '',
      password: '',
      loading: false,
      error: '',
      success: ''
    };
  },
  mounted() {
    // Si se requiere, obtener usuario actual de la API
    // this.getUsuarioActual();
  },
  methods: {
    async onSubmit() {
      this.error = '';
      this.success = '';
      this.loading = true;
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'login',
            params: {
              usuario: this.usuario,
              password: this.password
            }
          }
        });
        const res = response.data.eResponse;
        if (res.success) {
          this.success = res.message;
          this.$emit('autorizado', res.usuario);
          // Opcional: redirigir o cerrar modal
        } else {
          this.error = res.message;
        }
      } catch (e) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.password = '';
      this.error = '';
      this.success = '';
      this.$emit('cancelar');
    },
    async getUsuarioActual() {
      // Opcional: obtener usuario actual para autocompletar
      // const response = await this.$axios.post('/api/execute', { eRequest: { action: 'getUser', params: { usuario: '...' } } });
    }
  }
};
</script>

<style scoped>
.passwdfrm-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f6fa;
}
.passwdfrm-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  padding: 2rem 2.5rem;
  min-width: 320px;
}
.passwdfrm-header {
  display: flex;
  align-items: center;
  margin-bottom: 1.5rem;
}
.passwdfrm-icon {
  width: 40px;
  height: 40px;
  margin-right: 1rem;
}
.form-group {
  margin-bottom: 1rem;
}
.form-group label {
  display: block;
  margin-bottom: 0.25rem;
}
.form-group input {
  width: 100%;
  padding: 0.5rem;
  border-radius: 4px;
  border: 1px solid #ccc;
}
.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
}
button {
  padding: 0.5rem 1.5rem;
  border: none;
  border-radius: 4px;
  background: #3498db;
  color: #fff;
  font-weight: bold;
  cursor: pointer;
}
button[type="button"] {
  background: #aaa;
}
button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.error-message {
  color: #e74c3c;
  margin-top: 1rem;
}
.success-message {
  color: #27ae60;
  margin-top: 1rem;
}
</style>
