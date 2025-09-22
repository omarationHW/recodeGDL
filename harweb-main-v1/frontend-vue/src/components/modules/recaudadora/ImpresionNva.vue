<template>
  <div class="impresion-nva-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Impresión Nueva</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Impresión Nueva</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <!-- No hay campos en el formulario original -->
          <div class="alert alert-info">
            Este formulario no contiene campos. Presione "Enviar" para continuar.
          </div>
          <button type="submit" class="btn btn-primary" :disabled="loading">
            {{ loading ? 'Enviando...' : 'Enviar' }}
          </button>
        </form>
        <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success, 'mt-3': true}">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImpresionNvaPage',
  data() {
    return {
      loading: false,
      message: '',
      success: false
    };
  },
  mounted() {
    this.loadForm();
  },
  methods: {
    async loadForm() {
      // Simula la carga de datos del formulario (aunque no hay campos)
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getFormData',
            params: {}
          }
        });
        // No hay datos que cargar
      } catch (e) {
        this.message = 'Error al cargar el formulario.';
        this.success = false;
      }
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'submitForm',
            params: {}
          }
        });
        const eResponse = response.data.eResponse;
        this.message = eResponse.message;
        this.success = eResponse.success;
      } catch (e) {
        this.message = 'Error al enviar el formulario.';
        this.success = false;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.impresion-nva-page {
  max-width: 500px;
  margin: 40px auto;
}
</style>
