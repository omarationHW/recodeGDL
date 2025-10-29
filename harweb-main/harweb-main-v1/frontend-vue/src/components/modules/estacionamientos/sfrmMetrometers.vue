<template>
  <div class="metrometers-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Metrometers</li>
      </ol>
    </nav>
    <h2>Datos Adicionales MetroMeters</h2>
    <form @submit.prevent="onSearch">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="axo">Año</label>
          <input type="number" v-model="search.axo" class="form-control" id="axo" required />
        </div>
        <div class="form-group col-md-2">
          <label for="folio">Folio</label>
          <input type="number" v-model="search.folio" class="form-control" id="folio" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="record" class="card mt-3">
      <div class="card-body">
        <div class="row">
          <div class="col-md-4">
            <label>Marca:</label>
            <input type="text" class="form-control" :value="record.marca" readonly />
          </div>
          <div class="col-md-8">
            <label>Dirección de la Infracción:</label>
            <input type="text" class="form-control" :value="record.direccion" readonly />
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-12">
            <label>Motivo:</label>
            <input type="text" class="form-control" :value="record.motivo" readonly />
          </div>
        </div>
      </div>
    </div>
    <div v-if="record" class="row mt-4">
      <div class="col-md-6">
        <router-link :to="{ name: 'MetrometersPhoto', params: { axo: search.axo, folio: search.folio, photo: 1 } }" class="btn btn-outline-secondary btn-block">Ver Foto 1</router-link>
      </div>
      <div class="col-md-6">
        <router-link :to="{ name: 'MetrometersPhoto', params: { axo: search.axo, folio: search.folio, photo: 2 } }" class="btn btn-outline-secondary btn-block">Ver Foto 2</router-link>
      </div>
    </div>
    <div v-if="record" class="row mt-4">
      <div class="col-md-12">
        <router-link :to="{ name: 'MetrometersMap', params: { axo: search.axo, folio: search.folio } }" class="btn btn-outline-info btn-block">Ver Ubicación en Mapa</router-link>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'MetrometersPage',
  data() {
    return {
      search: {
        axo: '',
        folio: ''
      },
      loading: false,
      error: '',
      record: null
    };
  },
  methods: {
    async onSearch() {
      this.loading = true;
      this.error = '';
      this.record = null;
      try {
        const response = await axios.post('/api/execute', {
          eRequest: 'getMetrometersByAxoFolio',
          params: {
            axo: this.search.axo,
            folio: this.search.folio
          }
        });
        if (response.data.eResponse.success && response.data.eResponse.data.length > 0) {
          this.record = response.data.eResponse.data[0];
        } else {
          this.error = 'No se encontraron datos para los parámetros indicados.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.metrometers-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
</style>

<!--

Para las páginas de Foto 1, Foto 2 y Mapa, crear componentes similares:

- MetrometersPhoto.vue: muestra la imagen (usa /api/execute con eRequest: 'getMetrometersPhoto', params: {axo, folio, photo_number})
- MetrometersMap.vue: muestra el mapa (usa /api/execute con eRequest: 'getMetrometersMapUrl', params: {axo, folio})

Cada uno debe ser una página independiente con su propia ruta y breadcrumb.

-->
