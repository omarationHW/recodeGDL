<template>
  <div class="metrometer-form">
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
          <input v-model="search.axo" type="number" class="form-control" id="axo" required />
        </div>
        <div class="form-group col-md-2">
          <label for="folio">Folio</label>
          <input v-model="search.folio" type="number" class="form-control" id="folio" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="metrometer">
      <form @submit.prevent="onUpdate">
        <div class="form-row">
          <div class="form-group col-md-3">
            <label for="marca">Marca</label>
            <input v-model="metrometer.marca" type="text" class="form-control" id="marca" required />
          </div>
          <div class="form-group col-md-3">
            <label for="modelo">Modelo</label>
            <input v-model="metrometer.modelo" type="text" class="form-control" id="modelo" />
          </div>
          <div class="form-group col-md-6">
            <label for="direccion">Dirección de la Infracción</label>
            <input v-model="metrometer.direccion" type="text" class="form-control" id="direccion" required />
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-6">
            <label for="motivo">Motivo</label>
            <input v-model="metrometer.motivo" type="text" class="form-control" id="motivo" required />
          </div>
          <div class="form-group col-md-3">
            <label for="poslong">Longitud</label>
            <input v-model="metrometer.poslong" type="text" class="form-control" id="poslong" />
          </div>
          <div class="form-group col-md-3">
            <label for="poslat">Latitud</label>
            <input v-model="metrometer.poslat" type="text" class="form-control" id="poslat" />
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-6">
            <label for="linkfoto1">Link Foto 1</label>
            <input v-model="metrometer.linkfoto1" type="text" class="form-control" id="linkfoto1" />
          </div>
          <div class="form-group col-md-6">
            <label for="linkfoto2">Link Foto 2</label>
            <input v-model="metrometer.linkfoto2" type="text" class="form-control" id="linkfoto2" />
          </div>
        </div>
        <div class="form-row">
          <div class="form-group col-md-2">
            <label for="idmedio">ID Medio</label>
            <input v-model="metrometer.idmedio" type="number" class="form-control" id="idmedio" />
          </div>
        </div>
        <button type="submit" class="btn btn-success">Actualizar</button>
      </form>
      <hr />
      <div class="row">
        <div class="col-md-6">
          <h5>Foto 1</h5>
          <button class="btn btn-outline-secondary mb-2" @click="fetchPhoto(1)">Ver Foto 1</button>
          <div v-if="photo1">
            <img :src="'data:image/jpeg;base64,' + photo1" class="img-fluid" alt="Foto 1" />
          </div>
        </div>
        <div class="col-md-6">
          <h5>Foto 2</h5>
          <button class="btn btn-outline-secondary mb-2" @click="fetchPhoto(2)">Ver Foto 2</button>
          <div v-if="photo2">
            <img :src="'data:image/jpeg;base64,' + photo2" class="img-fluid" alt="Foto 2" />
          </div>
        </div>
      </div>
      <hr />
      <div>
        <h5>Ubicación de la infracción</h5>
        <div v-if="metrometer.poslat && metrometer.poslong">
          <iframe
            :src="mapUrl"
            width="100%"
            height="300"
            style="border:0;"
            allowfullscreen=""
            loading="lazy"
          ></iframe>
        </div>
        <div v-else>
          <em>No hay coordenadas disponibles.</em>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MetrometerForm',
  data() {
    return {
      search: {
        axo: '',
        folio: ''
      },
      metrometer: null,
      loading: false,
      error: '',
      photo1: '',
      photo2: ''
    };
  },
  computed: {
    mapUrl() {
      if (this.metrometer && this.metrometer.poslat && this.metrometer.poslong) {
        return `https://maps.google.com/maps?q=${this.metrometer.poslat},${this.metrometer.poslong}&z=17&output=embed`;
      }
      return '';
    }
  },
  methods: {
    async onSearch() {
      this.loading = true;
      this.error = '';
      this.metrometer = null;
      this.photo1 = '';
      this.photo2 = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.getMetrometerByAxoFolio',
          payload: {
            axo: this.search.axo,
            folio: this.search.folio
          }
        });
        if (res.data.status === 'success' && res.data.data.length > 0) {
          this.metrometer = { ...res.data.data[0] };
        } else {
          this.error = res.data.message || 'No se encontró el registro.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    async onUpdate() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.updateMetrometer',
          payload: {
            axo: this.metrometer.axo,
            folio: this.metrometer.folio,
            direccion: this.metrometer.direccion,
            marca: this.metrometer.marca,
            motivo: this.metrometer.motivo,
            modelo: this.metrometer.modelo,
            poslong: this.metrometer.poslong,
            poslat: this.metrometer.poslat,
            linkfoto1: this.metrometer.linkfoto1,
            linkfoto2: this.metrometer.linkfoto2,
            idmedio: this.metrometer.idmedio
          }
        });
        if (res.data.status === 'success') {
          alert('Registro actualizado correctamente.');
        } else {
          this.error = res.data.message || 'No se pudo actualizar.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    async fetchPhoto(photoNumber) {
      if (!this.metrometer || !this.metrometer.folio) {
        this.error = 'Debe buscar un registro primero.';
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'estacionamientos.getMetrometerPhoto',
          payload: {
            folio: this.metrometer.folio,
            photo_number: photoNumber
          }
        });
        if (res.data.status === 'success' && res.data.data.base64) {
          if (photoNumber === 1) {
            this.photo1 = res.data.data.base64;
          } else {
            this.photo2 = res.data.data.base64;
          }
        } else {
          this.error = res.data.message || 'No se pudo obtener la foto.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.metrometer-form {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
