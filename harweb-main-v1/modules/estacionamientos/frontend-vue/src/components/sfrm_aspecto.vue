<template>
  <div class="aspecto-page">
    <h1>Cambiar Aspecto Visual</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Cambiar Aspecto
    </div>
    <div class="aspecto-form">
      <label for="aspecto">Selecciona un aspecto:</label>
      <select v-model="selectedAspecto" @change="onAspectoChange" id="aspecto">
        <option v-for="asp in aspectos" :key="asp.nombre" :value="asp.nombre">
          {{ asp.nombre }}
        </option>
      </select>
      <div v-if="loading" class="loading">Cargando...</div>
      <div v-if="message" class="message">{{ message }}</div>
    </div>
    <div class="current-aspecto">
      <strong>Aspecto actual:</strong> {{ currentAspecto || 'No definido' }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'AspectoPage',
  data() {
    return {
      aspectos: [],
      selectedAspecto: '',
      currentAspecto: '',
      loading: false,
      message: ''
    };
  },
  created() {
    this.fetchAspectos();
    this.fetchCurrentAspecto();
  },
  methods: {
    async fetchAspectos() {
      this.loading = true;
      this.message = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getAspectos',
            params: {}
          }
        });
        if (res.data.eResponse.success) {
          this.aspectos = res.data.eResponse.data;
          if (this.aspectos.length > 0) {
            this.selectedAspecto = this.aspectos[0].nombre;
          }
        } else {
          this.message = res.data.eResponse.message || 'Error al cargar aspectos';
        }
      } catch (e) {
        this.message = 'Error de red al cargar aspectos';
      }
      this.loading = false;
    },
    async fetchCurrentAspecto() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getCurrentAspecto',
            params: {}
          }
        });
        if (res.data.eResponse.success && res.data.eResponse.data.length > 0) {
          this.currentAspecto = res.data.eResponse.data[0].nombre;
        }
      } catch (e) {
        // Silenciar error
      }
    },
    async onAspectoChange() {
      this.loading = true;
      this.message = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'setAspecto',
            params: { aspecto: this.selectedAspecto }
          }
        });
        if (res.data.eResponse.success) {
          this.message = 'Aspecto cambiado correctamente';
          this.currentAspecto = this.selectedAspecto;
        } else {
          this.message = res.data.eResponse.message || 'Error al cambiar aspecto';
        }
      } catch (e) {
        this.message = 'Error de red al cambiar aspecto';
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.aspecto-page {
  max-width: 500px;
  margin: 40px auto;
  background: #fff;
  border-radius: 8px;
  padding: 32px;
  box-shadow: 0 2px 8px #ccc;
}
.breadcrumb {
  font-size: 0.9em;
  margin-bottom: 16px;
}
.aspecto-form {
  margin-bottom: 24px;
}
.loading {
  color: #888;
  margin-top: 8px;
}
.message {
  color: #1976d2;
  margin-top: 8px;
}
.current-aspecto {
  margin-top: 16px;
  font-size: 1.1em;
}
</style>
