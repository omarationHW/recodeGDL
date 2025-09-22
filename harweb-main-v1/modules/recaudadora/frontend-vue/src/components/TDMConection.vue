<template>
  <div class="tdm-connection-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Conexión a Base de Datos</li>
      </ol>
    </nav>
    <h1>Conexión a Base de Datos</h1>
    <form @submit.prevent="testConnection">
      <div class="form-group">
        <label for="user">Usuario</label>
        <input v-model="form.user" type="text" id="user" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="password">Contraseña</label>
        <input v-model="form.password" type="password" id="password" class="form-control" required />
      </div>
      <button type="submit" class="btn btn-primary" :disabled="loading">Conectar</button>
      <button type="button" class="btn btn-secondary ml-2" @click="closeConnection" :disabled="loading">Cerrar Conexión</button>
    </form>
    <div v-if="message" class="alert mt-3" :class="{'alert-success': connected, 'alert-danger': !connected}">
      {{ message }}
    </div>
    <div v-if="connected">
      <h3 class="mt-4">Bases de Datos Disponibles</h3>
      <ul>
        <li v-for="db in databases" :key="db.database_name">{{ db.database_name }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TDMConnectionPage',
  data() {
    return {
      form: {
        user: '',
        password: ''
      },
      connected: false,
      message: '',
      databases: [],
      loading: false
    };
  },
  methods: {
    async testConnection() {
      this.loading = true;
      this.message = '';
      this.connected = false;
      this.databases = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'test_connection',
            params: {
              user: this.form.user,
              password: this.form.password
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.connected = true;
          this.message = data.eResponse.message || 'Conexión exitosa.';
          await this.getDatabases();
        } else {
          this.message = data.eResponse.message || 'No se pudo conectar.';
        }
      } catch (e) {
        this.message = 'Error de conexión.';
      } finally {
        this.loading = false;
      }
    },
    async getDatabases() {
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'get_databases'
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.databases = data.eResponse.data;
        } else {
          this.message = data.eResponse.message || 'No se pudieron obtener las bases de datos.';
        }
      } catch (e) {
        this.message = 'Error al obtener bases de datos.';
      }
    },
    async closeConnection() {
      this.connected = false;
      this.databases = [];
      this.message = '';
      // Optionally call API to close connection (stateless)
      await fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'close_connection'
        })
      });
      this.message = 'Conexión cerrada.';
    }
  }
};
</script>

<style scoped>
.tdm-connection-page {
  max-width: 500px;
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
