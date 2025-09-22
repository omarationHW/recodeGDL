<template>
  <div class="modulo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Módulo</li>
      </ol>
    </nav>
    <h1>Módulo General</h1>
    <section>
      <h2>Validar Usuario</h2>
      <form @submit.prevent="validaUsuario">
        <div class="form-group">
          <label for="usuario">Usuario</label>
          <input v-model="usuario" id="usuario" class="form-control" required />
        </div>
        <div class="form-group">
          <label for="clave">Clave</label>
          <input v-model="clave" id="clave" type="password" class="form-control" required />
        </div>
        <button type="submit" class="btn btn-primary">Validar</button>
      </form>
      <div v-if="usuarioResult" class="alert mt-2" :class="{'alert-success': usuarioResult.success, 'alert-danger': !usuarioResult.success}">
        {{ usuarioResult.message }}
      </div>
    </section>
    <section class="mt-4">
      <h2>Consultar Hora Actual</h2>
      <button @click="getCurrentTime" class="btn btn-secondary">Obtener Hora</button>
      <div v-if="currentTime" class="mt-2">
        <strong>Hora actual del servidor:</strong> {{ currentTime }}
      </div>
    </section>
    <section class="mt-4">
      <h2>Verificar Nueva Versión</h2>
      <form @submit.prevent="checkVersion">
        <div class="form-group">
          <label for="proyecto">Proyecto</label>
          <input v-model="proyecto" id="proyecto" class="form-control" required />
        </div>
        <div class="form-group">
          <label for="version">Versión</label>
          <input v-model="version" id="version" class="form-control" required />
        </div>
        <button type="submit" class="btn btn-info">Verificar</button>
      </form>
      <div v-if="versionResult" class="alert mt-2" :class="{'alert-success': !versionResult.hayNueva, 'alert-warning': versionResult.hayNueva}">
        {{ versionResult.message }}
      </div>
    </section>
  </div>
</template>

<script>
export default {
  name: 'ModuloPage',
  data() {
    return {
      usuario: '',
      clave: '',
      usuarioResult: null,
      currentTime: '',
      proyecto: '',
      version: '',
      versionResult: null
    };
  },
  methods: {
    async validaUsuario() {
      this.usuarioResult = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getUserByCredentials',
            params: { usuario: this.usuario, clave: this.clave }
          })
        });
        const data = await res.json();
        if (data.success && data.data && data.data.length > 0 && data.data[0].valido) {
          this.usuarioResult = { success: true, message: 'Usuario válido. ID: ' + data.data[0].id_usuario };
        } else {
          this.usuarioResult = { success: false, message: 'Usuario o clave incorrectos.' };
        }
      } catch (e) {
        this.usuarioResult = { success: false, message: 'Error de conexión.' };
      }
    },
    async getCurrentTime() {
      this.currentTime = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getCurrentTime' })
        });
        const data = await res.json();
        if (data.success) {
          this.currentTime = data.data;
        } else {
          this.currentTime = 'No disponible';
        }
      } catch (e) {
        this.currentTime = 'Error de conexión';
      }
    },
    async checkVersion() {
      this.versionResult = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'checkNewVersion',
            params: { proyecto: this.proyecto, version: this.version }
          })
        });
        const data = await res.json();
        let hayNueva = true;
        if (data.success && data.data && data.data.length > 0 && data.data[0].hay_nueva === false) {
          hayNueva = false;
        }
        this.versionResult = {
          hayNueva,
          message: hayNueva ? '¡Hay una nueva versión disponible!' : 'La versión está actualizada.'
        };
      } catch (e) {
        this.versionResult = { hayNueva: false, message: 'Error de conexión.' };
      }
    }
  }
};
</script>

<style scoped>
.modulo-page {
  max-width: 600px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
