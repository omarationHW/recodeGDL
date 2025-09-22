<template>
  <div class="passpropietario-page">
    <div class="form-container">
      <img src="/img/logo-catastro.png" alt="Logo" class="logo" />
      <h2>Autorización de Propietario</h2>
      <form @submit.prevent="onSubmit">
        <div class="form-group">
          <label for="usuario">Usuario</label>
          <input type="text" id="usuario" v-model="form.usuario" readonly />
        </div>
        <div class="form-group">
          <label for="password">Firma Electrónica</label>
          <input type="password" id="password" v-model="form.password" autocomplete="off" />
        </div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">Aceptar</button>
          <button type="button" class="btn btn-secondary" @click="onClear">Limpiar</button>
          <button type="button" class="btn btn-danger" @click="onClose">Cancelar</button>
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="success" class="alert alert-success">{{ success }}</div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PassPropietarioPage',
  data() {
    return {
      form: {
        usuario: '',
        password: ''
      },
      error: '',
      success: ''
    };
  },
  created() {
    // Simula obtener usuario actual (puede venir de store o API)
    this.form.usuario = this.$route.query.usuario || '';
    this.onShow();
  },
  methods: {
    async onShow() {
      // Llama a la API para inicializar (simula FormShow)
      const res = await this.api('show', { usuario: this.form.usuario });
      if (res && res.data) {
        this.form.usuario = res.data.usuario;
        this.form.password = '';
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      if (!this.form.password) {
        this.error = 'Debe ingresar la firma electrónica';
        return;
      }
      const res = await this.api('login', {
        usuario: this.form.usuario,
        password: this.form.password
      });
      if (res.success) {
        this.success = res.message;
        this.$emit('autorizado', this.form.usuario);
        // Aquí puedes redirigir o cerrar modal
      } else {
        this.error = res.message;
        this.form.password = '';
      }
    },
    async onClear() {
      this.form.password = '';
      this.error = '';
      this.success = '';
      await this.api('clear', {});
    },
    async onClose() {
      await this.api('close', {});
      this.$router.back();
    },
    async api(action, payload) {
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action,
            ...payload
          }
        });
        return response.data.eResponse;
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
        return {};
      }
    }
  }
};
</script>

<style scoped>
.passpropietario-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: #f5f5f5;
}
.form-container {
  background: #fff;
  padding: 2rem 2.5rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  width: 400px;
}
.logo {
  display: block;
  margin: 0 auto 1rem auto;
  width: 120px;
}
.form-group {
  margin-bottom: 1.2rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 1.5rem;
}
.alert {
  margin-top: 1rem;
}
</style>
