<template>
  <div class="web-browser-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Localiza predio</li>
      </ol>
    </nav>
    <h1 class="mb-4">Localiza predio</h1>
    <div class="mb-3">
      <label for="urlInput" class="form-label">URL a navegar:</label>
      <input
        id="urlInput"
        v-model="url"
        @blur="onUrlBlur"
        type="text"
        class="form-control"
        placeholder="Ingrese la URL"
      />
      <div v-if="error" class="text-danger mt-2">{{ error }}</div>
    </div>
    <div class="browser-frame">
      <iframe
        v-if="iframeUrl"
        :src="iframeUrl"
        width="100%"
        height="500"
        frameborder="0"
        allowfullscreen
        title="Web Browser"
      ></iframe>
    </div>
  </div>
</template>

<script>
export default {
  name: 'WebBrowserPage',
  data() {
    return {
      url: 'https://modulos.guadalajara.gob.mx/ubicacion/frame.html',
      iframeUrl: 'https://modulos.guadalajara.gob.mx/ubicacion/posxybus.php',
      error: ''
    };
  },
  mounted() {
    // On show, navigate to default URL (as in FormShow)
    this.iframeUrl = 'https://modulos.guadalajara.gob.mx/ubicacion/posxybus.php';
  },
  methods: {
    async onUrlBlur() {
      this.error = '';
      if (!this.url) {
        this.error = 'La URL es obligatoria.';
        return;
      }
      // Call API to validate and get the URL (simulate navigation)
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.navigate_url',
          payload: { url: this.url }
        });
        if (res.data.status === 'success') {
          this.iframeUrl = res.data.eResponse.data.result.url;
        } else {
          this.error = res.data.message || 'Error al navegar.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor.';
      }
    }
  }
};
</script>

<style scoped>
.web-browser-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.browser-frame {
  border: 1px solid #ccc;
  border-radius: 4px;
  overflow: hidden;
  background: #f9f9f9;
}
</style>
