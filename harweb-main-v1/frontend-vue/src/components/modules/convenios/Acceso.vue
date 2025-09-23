<template>
  <div class="login-page">
    <div class="login-container">
      <div class="login-header">
        <h1>MUNICIPIO DE GUADALAJARA</h1>
        <h2>Tesorería Municipal</h2>
        <h3>Sistema de Ingresos</h3>
        <h4>Módulo de Obra Pública / Convenios Gral.</h4>
      </div>
      <form @submit.prevent="onSubmit" class="login-form">
        <div class="form-group">
          <label for="username">Usuario:</label>
          <input
            id="username"
            v-model="form.username"
            type="text"
            maxlength="10"
            autocomplete="username"
            required
            @keyup.enter="focusPassword"
          />
        </div>
        <div class="form-group">
          <label for="password">Contraseña:</label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            maxlength="10"
            autocomplete="current-password"
            required
            ref="passwordInput"
            @keyup.enter="onSubmit"
          />
        </div>
        <div v-if="loading" class="loading">Conectando al Sistema...</div>
        <div v-if="error" class="error">{{ error }}</div>
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
  name: 'LoginPage',
  data() {
    return {
      form: {
        username: localStorage.getItem('lastUser') || '',
        password: ''
      },
      loading: false,
      error: ''
    };
  },
  methods: {
    focusPassword() {
      this.$refs.passwordInput.focus();
    },
    async onSubmit() {
      this.error = '';
      if (!this.form.username || !this.form.password) {
        this.error = 'El Usuario o la Contraseña no pueden estar vacíos';
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.login',
          payload: {
            username: this.form.username,
            password: this.form.password
          }
        });
        if (res.data.status === 'success') {
          localStorage.setItem('lastUser', this.form.username);
          localStorage.setItem('token', res.data.data.token);
          this.$router.push({ name: 'Home' });
        } else {
          this.error = res.data.message || 'Error de autenticación';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.form.password = '';
      this.error = '';
      this.$refs.usernameInput && this.$refs.usernameInput.focus();
    }
  },
  mounted() {
    if (!this.form.username) {
      this.$nextTick(() => {
        this.$refs.usernameInput && this.$refs.usernameInput.focus();
      });
    } else {
      this.$nextTick(() => {
        this.$refs.passwordInput && this.$refs.passwordInput.focus();
      });
    }
  }
};
</script>

<style scoped>
.login-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f6fa;
}
.login-container {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  padding: 2rem 2.5rem;
  min-width: 350px;
  max-width: 400px;
}
.login-header {
  text-align: center;
  margin-bottom: 2rem;
}
.login-header h1 {
  color: #003366;
  font-size: 1.3rem;
  margin-bottom: 0.2rem;
}
.login-header h2 {
  color: #003366;
  font-size: 1.1rem;
  margin-bottom: 0.2rem;
}
.login-header h3 {
  color: #003366;
  font-size: 1rem;
  margin-bottom: 0.2rem;
}
.login-header h4 {
  color: #003366;
  font-size: 0.95rem;
  margin-bottom: 0.2rem;
}
.form-group {
  margin-bottom: 1.2rem;
}
.form-group label {
  display: block;
  margin-bottom: 0.3rem;
  color: #003366;
  font-weight: 600;
}
.form-group input {
  width: 100%;
  padding: 0.5rem;
  font-size: 1rem;
  border: 1px solid #bfc9d1;
  border-radius: 4px;
}
.form-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 1.5rem;
}
.form-actions button {
  padding: 0.5rem 1.2rem;
  border: none;
  border-radius: 4px;
  background: #003366;
  color: #fff;
  font-weight: 600;
  cursor: pointer;
}
.form-actions button[disabled] {
  background: #bfc9d1;
  cursor: not-allowed;
}
.loading {
  color: #d35400;
  margin-bottom: 1rem;
  text-align: center;
}
.error {
  color: #c0392b;
  margin-bottom: 1rem;
  text-align: center;
}
</style>
