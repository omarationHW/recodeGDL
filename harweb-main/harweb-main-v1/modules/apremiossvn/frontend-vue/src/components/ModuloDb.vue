<template>
  <div class="modulo-db-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Módulo DB</li>
      </ol>
    </nav>
    <h1>Módulo DB</h1>
    <section>
      <h2>Login de Usuario</h2>
      <form @submit.prevent="login">
        <div class="form-group">
          <label for="username">Usuario</label>
          <input v-model="loginForm.username" id="username" class="form-control" required />
        </div>
        <div class="form-group">
          <label for="password">Contraseña</label>
          <input v-model="loginForm.password" id="password" type="password" class="form-control" required />
        </div>
        <button type="submit" class="btn btn-primary">Ingresar</button>
      </form>
      <div v-if="loginError" class="alert alert-danger mt-2">{{ loginError }}</div>
      <div v-if="userData" class="alert alert-success mt-2">
        <strong>Bienvenido:</strong> {{ userData.nombre }}<br />
        Nivel: {{ userData.nivel }}<br />
        Recaudadora: {{ userData.recaudadora }}
      </div>
    </section>
    <section class="mt-4">
      <h2>Fecha y Hora del Servidor</h2>
      <button class="btn btn-secondary" @click="getCurrentTime">Obtener Fecha/Hora</button>
      <div v-if="currentTime" class="mt-2">Servidor: {{ currentTime }}</div>
    </section>
    <section class="mt-4">
      <h2>Fecha en Letras</h2>
      <input type="date" v-model="dateToWordsInput" class="form-control" style="max-width:200px;display:inline-block;" />
      <button class="btn btn-info ml-2" @click="getDateToWords">Convertir</button>
      <div v-if="dateToWordsResult" class="mt-2">{{ dateToWordsResult }}</div>
    </section>
    <section class="mt-4">
      <h2>Verificar Nueva Versión</h2>
      <form @submit.prevent="checkVersion">
        <div class="form-group">
          <label for="proyecto">Proyecto</label>
          <input v-model="versionForm.proyecto" id="proyecto" class="form-control" required />
        </div>
        <div class="form-group">
          <label for="version">Versión</label>
          <input v-model="versionForm.version" id="version" class="form-control" required />
        </div>
        <button type="submit" class="btn btn-warning">Verificar</button>
      </form>
      <div v-if="versionCheckResult !== null" class="mt-2">
        <span v-if="versionCheckResult.nueva_version">¡Hay una nueva versión disponible!</span>
        <span v-else>La versión está actualizada.</span>
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'ModuloDbPage',
  data() {
    return {
      loginForm: {
        username: '',
        password: ''
      },
      loginError: '',
      userData: null,
      currentTime: '',
      dateToWordsInput: '',
      dateToWordsResult: '',
      versionForm: {
        proyecto: '',
        version: ''
      },
      versionCheckResult: null
    };
  },
  methods: {
    async login() {
      this.loginError = '';
      this.userData = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'getUserByCredentials',
            params: {
              username: this.loginForm.username,
              password: this.loginForm.password
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.userData = data.eResponse.data;
        } else {
          this.loginError = data.eResponse.message || 'Error de autenticación';
        }
      } catch (e) {
        this.loginError = 'Error de red o servidor';
      }
    },
    async getCurrentTime() {
      this.currentTime = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: 'getCurrentTime' })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.currentTime = data.eResponse.data;
      } else {
        this.currentTime = 'Error obteniendo fecha/hora';
      }
    },
    async getDateToWords() {
      this.dateToWordsResult = '';
      if (!this.dateToWordsInput) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: 'dateToWords',
          params: { date: this.dateToWordsInput }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.dateToWordsResult = data.eResponse.data;
      } else {
        this.dateToWordsResult = 'Error convirtiendo fecha';
      }
    },
    async checkVersion() {
      this.versionCheckResult = null;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: 'checkNewVersion',
          params: {
            proyecto: this.versionForm.proyecto,
            version: this.versionForm.version
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.versionCheckResult = data.eResponse.data;
      } else {
        this.versionCheckResult = { nueva_version: false };
      }
    }
  }
};
</script>

<style scoped>
.modulo-db-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
}
</style>
