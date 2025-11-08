<template>
  <div class="acceso-page">
    <div class="acceso-container">
      <div class="acceso-header">
        <img src="/img/escudo.svg" alt="Escudo" class="acceso-logo" />
        <h1>Tesorería Municipal</h1>
        <h2>Modulo Apremios</h2>
        <h3>Sistema de Ingresos</h3>
        <h4>Ayuntamiento de Guadalajara</h4>
      </div>
      <form @submit.prevent="onLogin" class="acceso-form">
        <div class="form-group">
          <label for="usuario">Usuario:</label>
          <input v-model="form.usuario" id="usuario" type="text" autocomplete="username" required />
        </div>
        <div class="form-group">
          <label for="clave">Contraseña:</label>
          <input v-model="form.clave" id="clave" type="password" autocomplete="current-password" required />
        </div>
        <div class="form-group">
          <label for="ejercicio">Ejercicio:</label>
          <input v-model.number="form.ejercicio" id="ejercicio" type="number" min="2001" :max="maxYear" required />
        </div>
        <div class="form-actions">
          <button type="submit" :disabled="loading">Aceptar</button>
          <button type="button" @click="onCancel">Cancelar</button>
        </div>
        <div v-if="loading" class="acceso-loading">Conectando al Sistema...</div>
        <div v-if="error" class="acceso-error">{{ error }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AccesoPage',
  data() {
    return {
      form: {
        usuario: '',
        clave: '',
        ejercicio: new Date().getFullYear()
      },
      loading: false,
      error: '',
      maxYear: new Date().getFullYear(),
      minYear: 2001
    };
  },
  mounted() {
    // Recuperar usuario del 'registro' (localStorage)
    const lastUser = localStorage.getItem('usuario_sistema');
    if (lastUser) {
      this.form.usuario = lastUser;
    }
  },
  methods: {
    async onLogin() {
      this.error = '';
      if (!this.form.usuario || !this.form.clave) {
        this.error = 'El Usuario o la Contraseña no pueden estar vacíos';
        return;
      }
      if (this.form.ejercicio < this.minYear || this.form.ejercicio > this.maxYear) {
        this.error = `El ejercicio debe estar entre ${this.minYear} y ${this.maxYear}`;
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'login',
            params: {
              usuario: this.form.usuario,
              clave: this.form.clave,
              ejercicio: this.form.ejercicio
            }
          }
        });
        if (res.data.eResponse.success) {
          // Guardar usuario en 'registro' (localStorage)
          localStorage.setItem('usuario_sistema', this.form.usuario);
          // Redirigir a menú principal o dashboard
          this.$router.push({ name: 'menu' });
        } else {
          this.error = res.data.eResponse.message || 'Usuario o contraseña incorrectos';
        }
      } catch (e) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.form.clave = '';
      this.error = '';
      // Opcional: cerrar sesión o limpiar estado
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
  background: #f5f7fa;
}
.acceso-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  padding: 2rem 2.5rem;
  width: 350px;
}
.acceso-header {
  text-align: center;
  margin-bottom: 1.5rem;
}
.acceso-logo {
  width: 80px;
  margin-bottom: 1rem;
}
.acceso-form .form-group {
  margin-bottom: 1rem;
}
.acceso-form label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.25rem;
}
.acceso-form input {
  width: 100%;
  padding: 0.5rem;
  border: 1px solid #bbb;
  border-radius: 4px;
  font-size: 1rem;
}
.acceso-form .form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 1rem;
}
.acceso-form button {
  padding: 0.5rem 1.5rem;
  border: none;
  border-radius: 4px;
  background: #1976d2;
  color: #fff;
  font-weight: bold;
  cursor: pointer;
}
.acceso-form button[type="button"] {
  background: #aaa;
}
.acceso-loading {
  margin-top: 1rem;
  color: #1976d2;
  font-weight: bold;
}
.acceso-error {
  margin-top: 1rem;
  color: #b71c1c;
  font-weight: bold;
}
</style>
