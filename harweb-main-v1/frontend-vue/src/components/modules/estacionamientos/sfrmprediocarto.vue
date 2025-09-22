<template>
  <div class="predio-carto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Ubicación del Predio</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Ubicación del Predio</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="loadCarto">
          <div class="form-group">
            <label for="cvecatastro">Clave Catastral</label>
            <input
              type="text"
              id="cvecatastro"
              v-model="cvecatastro"
              class="form-control"
              placeholder="Ingrese la clave catastral"
              required
            />
          </div>
          <button type="submit" class="btn btn-primary mt-2">Mostrar Ubicación</button>
          <button type="button" class="btn btn-secondary mt-2 ml-2" @click="closePage">Cerrar</button>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="cartoUrl" class="mt-4">
          <iframe
            :src="cartoUrl"
            width="100%"
            height="500"
            frameborder="0"
            allowfullscreen
          ></iframe>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PredioCartoPage',
  data() {
    return {
      cvecatastro: '',
      cartoUrl: '',
      error: ''
    };
  },
  methods: {
    async loadCarto() {
      this.error = '';
      this.cartoUrl = '';
      if (!this.cvecatastro) {
        this.error = 'Debe ingresar la clave catastral.';
        return;
      }
      try {
        const response = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getPredioCartoUrl',
            data: {
              cvecatastro: this.cvecatastro
            }
          }
        });
        if (response.data.eResponse.success) {
          this.cartoUrl = response.data.eResponse.url;
        } else {
          this.error = response.data.eResponse.message || 'Error al obtener la URL.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || 'Error de comunicación con el servidor.';
      }
    },
    closePage() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.predio-carto-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
iframe {
  border: 1px solid #ddd;
  border-radius: 4px;
}
</style>
