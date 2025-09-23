<template>
  <div class="login-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="/">Inicio</a></li>
        <li class="breadcrumb-item active" aria-current="page">Acceso al Sistema</li>
      </ol>
    </nav>
    <div class="login-form-container">
      <div class="card">
        <div class="card-header">
          <h3>Acceso al Sistema</h3>
        </div>
        <div class="card-body">
          <form @submit.prevent="onLogin">
            <div class="form-group">
              <label for="username">Usuario</label>
              <input
                type="text"
                id="username"
                v-model="form.username"
                class="form-control"
                autocomplete="username"
                required
              />
            </div>
            <div class="form-group">
              <label for="password">Contraseña</label>
              <input
                type="password"
                id="password"
                v-model="form.password"
                class="form-control"
                autocomplete="current-password"
                required
              />
            </div>
            <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
            <div v-if="success" class="alert alert-success mt-2">{{ success }}</div>
            <div class="form-group mt-3">
              <button type="submit" class="btn btn-primary" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm"></span>
                Ingresar
              </button>
              <button type="button" class="btn btn-secondary ml-2" @click="onCancel">Cancelar</button>
            </div>
          </form>
        </div>
        <div class="card-footer text-muted">
          Último usuario: <span v-if="lastUser">{{ lastUser }}</span>
          <span v-else>No disponible</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoginPage',
  data() {
    return {
      form: {
        username: '',
        password: ''
      },
      lastUser: '',
      error: '',
      success: '',
      loading: false
    };
  },
  created() {
    this.fetchLastUser();
  },
  methods: {
    async fetchLastUser() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: 'get_last_user' })
        });
        const data = await res.json();
        if (data.eResponse && data.eResponse.data && data.eResponse.data.last_user) {
          this.lastUser = data.eResponse.data.last_user;
          this.form.username = this.lastUser;
        }
      } catch (e) {
        // ignore
      }
    },
    async onLogin() {
      this.error = '';
      this.success = '';
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'login',
            params: {
              username: this.form.username,
              password: this.form.password
            }
          })
        });
        const data = await res.json();
        if (data.eResponse && data.eResponse.success) {
          this.success = 'Ingreso exitoso. Bienvenido, ' + data.eResponse.data.fullname + '!';
          // Guardar usuario como último usuario
          await fetch('/api/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              eRequest: 'set_last_user',
              params: { username: this.form.username }
            })
          });
          setTimeout(() => {
            this.$router.push({ name: 'home' });
          }, 1200);
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error de autenticación.';
        }
      } catch (e) {
        this.error = 'Error de red o servidor.';
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.form.username = '';
      this.form.password = '';
      this.error = '';
      this.success = '';
    }
  }
};
</script>

<style scoped>
.login-page {
  max-width: 400px;
  margin: 40px auto;
}
.login-form-container {
  margin-top: 30px;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
