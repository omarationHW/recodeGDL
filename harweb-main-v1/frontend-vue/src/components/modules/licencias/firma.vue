<template>
  <div class="firma-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Firma Electrónica</li>
      </ol>
    </nav>
    <div class="card mx-auto" style="max-width: 400px;">
      <div class="card-body">
        <div class="d-flex align-items-center mb-3">
          <img :src="firmaIcon" alt="Firma Icon" width="48" height="48" class="me-3" />
          <h5 class="card-title mb-0">Inserte su firma electrónica:</h5>
        </div>
        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <input
              v-model="firma_digital"
              type="password"
              class="form-control"
              placeholder="Firma electrónica"
              @keyup.enter="focusAceptar"
              ref="firmaInput"
              autocomplete="off"
              required
            />
          </div>
          <div class="d-flex justify-content-between">
            <button type="button" class="btn btn-secondary" @click="onCancelar">Cancelar</button>
            <button type="submit" class="btn btn-primary" ref="aceptarBtn">Aceptar</button>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FirmaElectronicaPage',
  data() {
    return {
      firma_digital: '',
      error: '',
      success: '',
      firmaIcon: require('@/assets/firma_icon.png') // Replace with actual icon or base64 if needed
    };
  },
  mounted() {
    this.firma_digital = '';
    this.$refs.firmaInput.focus();
  },
  methods: {
    focusAceptar() {
      this.$refs.aceptarBtn.focus();
    },
    onCancelar() {
      this.firma_digital = '';
      this.error = '';
      this.success = '';
      // Optionally, navigate away or close modal
      this.$router.push('/');
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      if (!this.firma_digital) {
        this.error = 'Debe ingresar su firma electrónica.';
        return;
      }
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'firma_validate',
            data: {
              firma_digital: this.firma_digital
            }
          }
        });
        const eResponse = response.data.eResponse;
        if (eResponse.success) {
          this.success = 'Firma válida. Bienvenido.';
          // Aquí puedes emitir evento, guardar en store, o redirigir
        } else {
          this.error = eResponse.message || 'Firma inválida.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || 'Error de conexión.';
      }
    }
  }
};
</script>

<style scoped>
.firma-page {
  min-height: 100vh;
  background: #f8f9fa;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
