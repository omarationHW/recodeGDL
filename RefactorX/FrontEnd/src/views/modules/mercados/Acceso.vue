<template>
  <div class="acceso-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Acceso</span>
    </div>
    <div class="acceso-form-container">
      <h2>Acceso al Sistema</h2>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label for="usuario">Usuario</label>
          <input v-model="form.usuario" id="usuario" type="text" autocomplete="username" required />
        </div>
        <div class="form-group">
          <label for="contrasena">Contraseña</label>
          <input v-model="form.contrasena" id="contrasena" type="password" autocomplete="current-password" required />
        </div>
        <div class="form-group">
          <label for="ejercicio">Ejercicio</label>
          <input v-model.number="form.ejercicio" id="ejercicio" type="number" :min="minEjercicio" :max="maxEjercicio" required />
        </div>
        <div v-if="error" class="error-message">{{ error }}</div>
        <div v-if="loading" class="loading-message">Conectando al sistema...</div>
        <div class="form-actions">
          <button type="submit" :disabled="loading">Aceptar</button>
          <button type="button" @click="onCancel" :disabled="loading">Cancelar</button>
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
      form: {
        usuario: '',
        contrasena: '',
        ejercicio: new Date().getFullYear()
      },
      minEjercicio: 2003,
      maxEjercicio: new Date().getFullYear(),
      loading: false,
      error: '',
      intentos: 0
    };
  },
  mounted() {
    // Opcional: cargar min/max ejercicio desde API
    this.fetchEjercicioMinMax();
    // Opcional: cargar usuario recordado de localStorage
    const lastUser = localStorage.getItem('usuario');
    if (lastUser) this.form.usuario = lastUser;
  },
  methods: {
    async fetchEjercicioMinMax() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getEjercicioMinMax',
          payload: {}
        });
        if (res.data.status === 'success' && res.data.data) {
          this.minEjercicio = res.data.data.min_ejercicio;
          this.maxEjercicio = res.data.data.max_ejercicio;
          if (this.form.ejercicio < this.minEjercicio) this.form.ejercicio = this.minEjercicio;
          if (this.form.ejercicio > this.maxEjercicio) this.form.ejercicio = this.maxEjercicio;
        }
      } catch (error) {}
    },
    async onSubmit() {
      this.error = '';
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.login',
          payload: {
            usuario: this.form.usuario,
            contrasena: this.form.contrasena,
            ejercicio: this.form.ejercicio
          }
        });
        if (res.data.status === 'success') {
          localStorage.setItem('usuario', this.form.usuario);
          this.$router.push({ name: 'menu' });
        } else {
          this.intentos++;
          if (this.intentos >= 3) {
            this.error = 'No está autorizado para ingresar al sistema, verifique su acceso';
            setTimeout(() => window.location.reload(), 2000);
          } else {
            this.error = res.data.message || 'Usuario o contraseña incorrectos';
          }
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.form.usuario = '';
      this.form.contrasena = '';
      this.error = '';
      this.intentos = 0;
    }
  }
};
</script>

<style scoped>
.acceso-page {
  max-width: 400px;
  margin: 40px auto;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
  padding: 32px 24px;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 16px;
}
.acceso-form-container h2 {
  text-align: center;
  margin-bottom: 24px;
}
.form-group {
  margin-bottom: 18px;
}
.form-group label {
  display: block;
  font-weight: bold;
  margin-bottom: 6px;
}
.form-group input {
  width: 100%;
  padding: 7px 10px;
  border: 1px solid #bbb;
  border-radius: 4px;
  font-size: 1em;
}
.form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 18px;
}
.form-actions button {
  min-width: 100px;
  padding: 8px 0;
  border: none;
  border-radius: 4px;
  background: #1976d2;
  color: #fff;
  font-weight: bold;
  cursor: pointer;
}
.form-actions button[disabled] {
  background: #aaa;
  cursor: not-allowed;
}
.error-message {
  color: #c00;
  margin-bottom: 10px;
  text-align: center;
}
.loading-message {
  color: #1976d2;
  margin-bottom: 10px;
  text-align: center;
}
</style>
