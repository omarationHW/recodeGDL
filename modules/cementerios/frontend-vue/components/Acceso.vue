<template>
  <div class="acceso-page">
    <div class="acceso-container">
      <div class="acceso-header">
        <h2>Tesorería Municipal</h2>
        <h3>Sistema de Ingresos</h3>
        <h4>Módulo Cementerios</h4>
        <h5>Ayuntamiento de Guadalajara</h5>
      </div>
      <form @submit.prevent="onSubmit" class="acceso-form">
        <div class="form-group">
          <label for="usuario">Usuario:</label>
          <input v-model="usuario" id="usuario" type="text" maxlength="10" autocomplete="username" required />
        </div>
        <div class="form-group">
          <label for="clave">Contraseña:</label>
          <input v-model="clave" id="clave" type="password" maxlength="10" autocomplete="current-password" required />
        </div>
        <div v-if="conectando" class="conectando">Conectando al Sistema...</div>
        <div v-if="error" class="error">{{ error }}</div>
        <div class="form-actions">
          <button type="submit" :disabled="conectando">Aceptar</button>
          <button type="button" @click="onCancel" :disabled="conectando">Salir</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AccesoPage',
  data() {
    return {
      usuario: '',
      clave: '',
      conectando: false,
      error: '',
      intentos: 0
    };
  },
  mounted() {
    // Simula cargar usuario del "registro" (localStorage)
    const lastUser = localStorage.getItem('acceso_usuario');
    if (lastUser) {
      this.usuario = lastUser;
    }
    this.clave = '';
    this.$nextTick(() => {
      this.$refs && this.$refs.clave && this.$refs.clave.focus();
    });
  },
  methods: {
    async onSubmit() {
      this.error = '';
      if (!this.usuario || !this.clave) {
        this.error = 'El Usuario o la Contraseña no pueden estar vacíos';
        return;
      }
      this.conectando = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'login',
            params: {
              usuario: this.usuario,
              clave: this.clave
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          // Guardar usuario en "registro" (localStorage)
          localStorage.setItem('acceso_usuario', this.usuario);
          // Redirigir a menú principal o dashboard
          this.$router.push({ name: 'MenuPrincipal' });
        } else {
          this.intentos++;
          this.error = data.message || 'Usuario y/o contraseña incorrectos';
          if (this.intentos >= 3) {
            this.error = 'Demasiados intentos fallidos';
          }
        }
      } catch (e) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.conectando = false;
      }
    },
    onCancel() {
      this.usuario = '';
      this.clave = '';
      this.error = '';
      this.intentos = 0;
      // Opcional: cerrar sesión global, limpiar tokens, etc.
      this.$router.push({ name: 'Salir' });
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
  background: #f5f5f5;
}
.acceso-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  padding: 2rem 2.5rem;
  min-width: 350px;
}
.acceso-header {
  text-align: center;
  margin-bottom: 1.5rem;
}
.acceso-header h2, .acceso-header h3, .acceso-header h4, .acceso-header h5 {
  margin: 0.2em 0;
}
.acceso-form .form-group {
  margin-bottom: 1rem;
}
.acceso-form label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.3em;
}
.acceso-form input {
  width: 100%;
  padding: 0.5em;
  font-size: 1em;
  border: 1px solid #bbb;
  border-radius: 4px;
}
.form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 1.5rem;
}
.form-actions button {
  min-width: 90px;
  padding: 0.5em 1em;
  font-size: 1em;
  border: none;
  border-radius: 4px;
  background: #1976d2;
  color: #fff;
  cursor: pointer;
  transition: background 0.2s;
}
.form-actions button[type="button"] {
  background: #888;
}
.form-actions button:disabled {
  background: #ccc;
  cursor: not-allowed;
}
.conectando {
  color: #1976d2;
  margin-bottom: 1em;
  font-weight: bold;
}
.error {
  color: #d32f2f;
  margin-bottom: 1em;
  font-weight: bold;
}
</style>
