<template>
  <div class="unit1-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Formulario Unit1</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Formulario Unit1</h3>
      </div>
      <div class="card-body">
        <p>Este es un formulario vacío migrado desde Delphi. No contiene campos editables.</p>
        <div v-if="loading" class="alert alert-info">Cargando...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="success" class="alert alert-success">{{ success }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Unit1Page',
  data() {
    return {
      loading: false,
      error: '',
      success: ''
    };
  },
  mounted() {
    this.fetchFormData();
  },
  methods: {
    async fetchFormData() {
      this.loading = true;
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'unit1_get_form_data',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.success = res.data.message || 'Datos cargados correctamente';
        } else {
          this.error = res.data.message || 'Error desconocido.';
        }
      } catch (error) {
        this.error = 'Error de conexión: ' + error.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.unit1-page {
  max-width: 600px;
  margin: 30px auto;
}
.card-header {
  background: #f8f9fa;
}
</style>
