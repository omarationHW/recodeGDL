<template>
  <div class="cartonva-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Cartografía Predial</span>
    </div>
    <h1>Cartografía Predial</h1>
    <form @submit.prevent="buscarCuenta">
      <label for="cvecuenta">Clave de Cuenta Catastral:</label>
      <input v-model="cvecuenta" id="cvecuenta" type="number" required placeholder="Ej: 123456" />
      <button type="submit">Buscar</button>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="cuenta">
      <h2>Datos de la Cuenta</h2>
      <table class="cuenta-table">
        <tr><th>Cuenta</th><td>{{ cuenta.cvecuenta }}</td></tr>
        <tr><th>Municipio</th><td>{{ cuenta.cvemunicipio }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ cuenta.recaud }}</td></tr>
        <tr><th>Urb/Rus</th><td>{{ cuenta.urbrus }}</td></tr>
        <tr><th>Clave Catastral</th><td>{{ cuenta.cvecatnva }}</td></tr>
        <tr><th>Subpredio</th><td>{{ cuenta.subpredio }}</td></tr>
        <tr><th>Coordenada X</th><td>{{ cuenta.coordenada_x }}</td></tr>
        <tr><th>Coordenada Y</th><td>{{ cuenta.coordenada_y }}</td></tr>
        <tr><th>Vigente</th><td>{{ cuenta.vigente }}</td></tr>
      </table>
      <div class="visor-section">
        <h3>Visor Cartográfico</h3>
        <iframe :src="visorUrl" width="100%" height="500" frameborder="0"></iframe>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CartonvaPage',
  data() {
    return {
      cvecuenta: '',
      cuenta: null,
      visorUrl: '',
      loading: false,
      error: ''
    }
  },
  methods: {
    async buscarCuenta() {
      this.loading = true;
      this.error = '';
      this.cuenta = null;
      this.visorUrl = '';
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getCartografiaPredial',
              params: { cvecuenta: this.cvecuenta }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.cuenta = data.eResponse.cuenta;
          this.visorUrl = data.eResponse.visor_url;
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  }
}
</script>

<style scoped>
.cartonva-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.cuenta-table {
  border-collapse: collapse;
  margin-bottom: 2rem;
}
.cuenta-table th, .cuenta-table td {
  border: 1px solid #ccc;
  padding: 0.5rem 1rem;
}
.visor-section {
  margin-top: 2rem;
}
.loading { color: #007bff; }
.error { color: #c00; }
</style>
