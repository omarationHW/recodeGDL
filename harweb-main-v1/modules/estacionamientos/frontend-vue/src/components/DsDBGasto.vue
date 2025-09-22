<template>
  <div class="dsdb-gasto-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Conexión de Gasto</li>
      </ol>
    </nav>
    <h1>Conexión de Gasto</h1>
    <form @submit.prevent="handleLogin">
      <div class="form-group">
        <label for="user">Usuario Seguridad</label>
        <input v-model="user" id="user" type="text" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="pass">Contraseña Seguridad</label>
        <input v-model="pass" id="pass" type="password" class="form-control" required />
      </div>
      <button type="submit" class="btn btn-primary" :disabled="loading">Conectar</button>
    </form>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">
      ¡Conexión exitosa a ambas bases de datos!
    </div>
  </div>
</template>

<script>
export default {
  name: 'DsDBGastoPage',
  data() {
    return {
      user: '',
      pass: '',
      loading: false,
      error: '',
      success: false
    };
  },
  methods: {
    async handleLogin() {
      this.error = '';
      this.success = false;
      this.loading = true;
      try {
        // Paso 1: Login seguridad
        const res1 = await this.$axios.post('/api/execute', {
          eRequest: 'login_seguridad',
          params: {
            user: this.user,
            pass: this.pass
          }
        });
        if (!res1.data.eResponse.success) {
          this.error = res1.data.eResponse.error || 'Error de autenticación';
          this.loading = false;
          return;
        }
        // Paso 2: Conexión a estacion
        const res2 = await this.$axios.post('/api/execute', {
          eRequest: 'connect_estacion',
          params: {}
        });
        if (!res2.data.eResponse.success) {
          this.error = res2.data.eResponse.error || 'Error al conectar a estación';
          this.loading = false;
          return;
        }
        this.success = true;
      } catch (e) {
        this.error = e.response?.data?.eResponse?.error || e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.dsdb-gasto-page {
  max-width: 400px;
  margin: 40px auto;
  padding: 24px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 16px;
}
</style>
