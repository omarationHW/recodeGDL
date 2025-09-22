<template>
  <div class="adeudos-carga-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga de Adeudos</li>
      </ol>
    </nav>
    <h1>Carga de Adeudos (Ejercicio Completo)</h1>
    <form @submit.prevent="submitCarga">
      <div class="form-group">
        <label for="ejercicio">Ejercicio Fiscal</label>
        <input type="number" v-model="form.ejercicio" id="ejercicio" class="form-control" min="2000" required />
      </div>
      <div class="form-group">
        <label for="usuario_id">ID Usuario</label>
        <input type="number" v-model="form.usuario_id" id="usuario_id" class="form-control" min="1" required />
      </div>
      <div class="form-group mt-3">
        <button type="submit" class="btn btn-primary" :disabled="loading">
          <span v-if="loading" class="spinner-border spinner-border-sm"></span>
          Ejecutar Carga de Adeudos
        </button>
        <button type="button" class="btn btn-secondary ms-2" @click="resetForm" :disabled="loading">Cancelar</button>
      </div>
    </form>
    <div v-if="result" class="alert mt-4" :class="{'alert-success': result.success, 'alert-danger': !result.success}">
      <strong>{{ result.message }}</strong>
      <div v-if="result.error" class="mt-2"><code>{{ result.error }}</code></div>
      <div v-if="result.result && result.result.length">
        <pre>{{ result.result }}</pre>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosCargaPage',
  data() {
    return {
      form: {
        ejercicio: new Date().getFullYear(),
        usuario_id: 23
      },
      loading: false,
      result: null
    };
  },
  methods: {
    async submitCarga() {
      this.loading = true;
      this.result = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'carga_adeudos',
              ejercicio: this.form.ejercicio,
              usuario_id: this.form.usuario_id
            }
          })
        });
        const data = await response.json();
        this.result = data.eResponse;
      } catch (e) {
        this.result = { success: false, message: 'Error de red o servidor', error: e.message };
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      this.form.ejercicio = new Date().getFullYear();
      this.form.usuario_id = 23;
      this.result = null;
    }
  }
};
</script>

<style scoped>
.adeudos-carga-page {
  max-width: 500px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
