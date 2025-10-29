<template>
  <div class="acceso-page">
    <div class="acceso-container">
      <div class="acceso-logo">
        <img src="/img/escudo.svg" alt="Escudo" style="max-width: 180px;" />
      </div>
      <div class="acceso-form">
        <h2>Ayuntamiento de Guadalajara</h2>
        <h3>Tesorería Municipal</h3>
        <h4>Dirección de Ingresos</h4>
        <h4>Modulo Aseo</h4>
        <form @submit.prevent="login">
          <div class="form-group">
            <label for="usuario">Usuario:</label>
            <input v-model="usuario" id="usuario" type="text" maxlength="10" autocomplete="username" required />
          </div>
          <div class="form-group">
            <label for="contrasena">Contraseña:</label>
            <input v-model="contrasena" id="contrasena" type="password" maxlength="10" autocomplete="current-password" required />
          </div>
          <div v-if="error" class="error-message">{{ error }}</div>
          <div v-if="loading" class="loading-message">Conectando al Sistema...</div>
          <div class="form-actions">
            <button type="submit" :disabled="loading">Aceptar</button>
            <button type="button" @click="cancelar" :disabled="loading">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AccesoPage',
  data() {
    return {
      usuario: '',
      contrasena: '',
      error: '',
      loading: false
    };
  },
  mounted() {
    // Simula recuperación del usuario del "registro" (localStorage)
    const lastUser = localStorage.getItem('usuarioSistema');
    if (lastUser) {
      this.usuario = lastUser;
    }
    this.$nextTick(() => {
      this.$refs.usuario && this.$refs.usuario.focus();
    });
  },
  methods: {
    async login() {
      this.error = '';
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'login',
              params: {
                usuario: this.usuario,
                contrasena: this.contrasena
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.status === 'ok') {
          // Guardar usuario en "registro" (localStorage)
          localStorage.setItem('usuarioSistema', this.usuario);
          // Redirigir a menú principal o dashboard
          this.$router.push({ name: 'MenuPrincipal' });
        } else {
          this.error = data.eResponse.message || 'Error de autenticación';
        }
      } catch (e) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    cancelar() {
      this.usuario = '';
      this.contrasena = '';
      this.error = '';
      this.loading = false;
      // Opcional: redirigir a página de inicio o limpiar
    }
  }
};
</script>

<style scoped>
.acceso-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f6fa;
}
.acceso-container {
  display: flex;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.08);
  overflow: hidden;
  max-width: 700px;
}
.acceso-logo {
  background: #e9ecef;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 32px 16px;
}
.acceso-form {
  flex: 1;
  padding: 32px 24px;
  min-width: 320px;
}
.acceso-form h2, .acceso-form h3, .acceso-form h4 {
  margin: 0;
  text-align: center;
}
.acceso-form h2 {
  color: #1a237e;
  font-size: 1.5rem;
  margin-bottom: 8px;
}
.acceso-form h3, .acceso-form h4 {
  color: #3949ab;
  font-size: 1.1rem;
  margin-bottom: 4px;
}
.form-group {
  margin-bottom: 18px;
}
.form-group label {
  display: block;
  font-weight: 600;
  margin-bottom: 6px;
}
.form-group input {
  width: 100%;
  padding: 8px 10px;
  font-size: 1rem;
  border: 1px solid #bdbdbd;
  border-radius: 4px;
}
.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
}
button {
  padding: 8px 18px;
  border: none;
  border-radius: 4px;
  background: #3949ab;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
  transition: background 0.2s;
}
button[disabled] {
  background: #bdbdbd;
  cursor: not-allowed;
}
.error-message {
  color: #c62828;
  margin-bottom: 10px;
  font-weight: 600;
}
.loading-message {
  color: #1976d2;
  margin-bottom: 10px;
  font-weight: 600;
}
</style>
