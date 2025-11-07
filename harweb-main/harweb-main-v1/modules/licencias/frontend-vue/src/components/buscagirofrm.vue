<template>
  <div class="buscagiro-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Búsqueda de Giros</li>
      </ol>
    </nav>
    <h1>Búsqueda de Giros</h1>
    <form @submit.prevent="buscarGiros">
      <div class="form-group">
        <label for="descripcion">Descripción del giro</label>
        <input v-model="descripcion" id="descripcion" class="form-control" placeholder="Ingrese descripción..." />
      </div>
      <div class="form-group">
        <label for="tipo">Tipo</label>
        <select v-model="tipo" id="tipo" class="form-control">
          <option value="L">Licencia</option>
          <option value="A">Anuncio</option>
        </select>
      </div>
      <div class="form-check">
        <input type="checkbox" v-model="autoev" id="autoev" class="form-check-input" />
        <label class="form-check-label" for="autoev">Solo Autoevaluación</label>
      </div>
      <div class="form-check">
        <input type="checkbox" v-model="pacto" id="pacto" class="form-check-input" />
        <label class="form-check-label" for="pacto">Pacto para homologar requisitos</label>
      </div>
      <button type="submit" class="btn btn-primary mt-2">Buscar</button>
    </form>
    <div v-if="loading" class="mt-3">Buscando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="giros.length" class="mt-3">
      <h2>Resultados</h2>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Descripción</th>
            <th>Costo</th>
            <th>Características</th>
            <th>Clasificación</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="giro in giros" :key="giro.id_giro">
            <td>{{ giro.descripcion }}</td>
            <td>{{ giro.costo }}</td>
            <td>{{ giro.caracteristicas }}</td>
            <td>{{ giro.clasificacion }}</td>
            <td>
              <button class="btn btn-success btn-sm" @click="seleccionarGiro(giro)">Seleccionar</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="selectedGiro" class="mt-4">
      <h3>Giro seleccionado</h3>
      <pre>{{ selectedGiro }}</pre>
      <button class="btn btn-secondary" @click="selectedGiro = null">Quitar selección</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BuscagiroPage',
  data() {
    return {
      descripcion: '',
      tipo: 'L',
      autoev: false,
      pacto: false,
      giros: [],
      loading: false,
      error: '',
      selectedGiro: null
    };
  },
  methods: {
    async buscarGiros() {
      this.loading = true;
      this.error = '';
      this.giros = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ' + localStorage.getItem('token')
          },
          body: JSON.stringify({
            action: 'buscagiro_list',
            params: {
              descripcion: this.descripcion,
              tipo: this.tipo,
              autoev: this.autoev,
              pacto: this.pacto
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.giros = data.data;
        } else {
          this.error = data.message || 'Error al buscar giros';
        }
      } catch (e) {
        this.error = 'Error de red o del servidor';
      } finally {
        this.loading = false;
      }
    },
    async seleccionarGiro(giro) {
      this.selectedGiro = giro;

      // Guardar en localStorage para uso en otros formularios
      const giroData = {
        id: giro.id_giro,
        codigo: giro.cod_giro || giro.codigo,
        descripcion: giro.descripcion,
        tipo: giro.tipo,
        costo: giro.costo,
        timestamp: new Date().toISOString()
      };
      localStorage.setItem('giroSeleccionado', JSON.stringify(giroData));

      // Copiar descripción al portapapeles
      const textoParaCopiar = `${giroData.codigo} - ${giroData.descripcion}`;
      try {
        await navigator.clipboard.writeText(textoParaCopiar);
        alert(`Giro seleccionado y copiado al portapapeles:\n${giroData.descripcion}`);
      } catch (err) {
        console.warn('No se pudo copiar al portapapeles:', err);
        alert(`Giro seleccionado y guardado:\n${giroData.descripcion}`);
      }

      // Emitir evento para componente padre
      this.$emit('giro-seleccionado', giro);
    }
  }
};
</script>

<style scoped>
.buscagiro-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
