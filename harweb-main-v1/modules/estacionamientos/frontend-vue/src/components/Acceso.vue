<template>
  <div class="acceso-formulario">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Acceso</li>
      </ol>
    </nav>
    <div class="card mx-auto mt-5" style="max-width: 420px;">
      <div class="card-header bg-primary text-white text-center">
        <h4>Acceso al Sistema</h4>
        <div class="small">Módulo de Estacionamientos</div>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <label for="usuario" class="form-label">Usuario</label>
            <input v-model="form.usuario" type="text" class="form-control" id="usuario" autocomplete="username" required autofocus />
          </div>
          <div class="mb-3">
            <label for="contrasena" class="form-label">Contraseña</label>
            <input v-model="form.contrasena" type="password" class="form-control" id="contrasena" autocomplete="current-password" required />
          </div>
          <div v-if="error" class="alert alert-danger py-2">{{ error }}</div>
          <div v-if="loading" class="alert alert-info py-2">Conectando al sistema...</div>
          <div class="d-flex justify-content-between">
            <button type="submit" class="btn btn-primary" :disabled="loading">Aceptar</button>
            <button type="button" class="btn btn-secondary" @click="onCancel" :disabled="loading">Cancelar</button>
          </div>
        </form>
      </div>
      <div class="card-footer text-center small">
        <span>Versión: 3.3.1.12</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AccesoFormulario',
  data() {
    return {
      form: {
        usuario: '',
        contrasena: ''
      },
      loading: false,
      error: ''
    };
  },
  mounted() {
    // Si se desea, recuperar usuario del localStorage
    const lastUser = localStorage.getItem('usuario');
    if (lastUser) {
      this.form.usuario = lastUser;
    }
    this.$nextTick(() => {
      this.$refs.usuario?.focus();
    });
  },
  methods: {
    async onSubmit() {
      this.error = '';
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.login',
          payload: {
            username: this.form.usuario,
            password: this.form.contrasena
          }
        });
        if (res.data.status === 'success') {
          // Guardar usuario en localStorage
          localStorage.setItem('usuario', this.form.usuario);
          // Redirigir a menú principal o dashboard
          this.$router.push({ name: 'menu' });
        } else {
          this.error = res.data.message || 'Usuario o contraseña incorrectos';
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
      this.$refs.usuario?.focus();
    }
  }
};
</script>

<style scoped>
.acceso-formulario {
  min-height: 100vh;
  background: #f8fafc;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.07);
}
</style>
