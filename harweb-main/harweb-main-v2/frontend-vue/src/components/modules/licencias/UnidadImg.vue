<template>
  <div class="unidad-img-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Unidad de Imágenes</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Unidad de Imágenes</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="guardarUnidadImg">
          <div class="form-group">
            <label for="unidadImg">Unidad de Imágenes</label>
            <select v-model="unidadImg" id="unidadImg" class="form-control" required>
              <option v-for="unidad in unidades" :key="unidad" :value="unidad">
                {{ unidad }}
              </option>
            </select>
            <small class="form-text text-muted">Seleccione la unidad de disco donde se almacenan las imágenes.</small>
          </div>
          <button type="submit" class="btn btn-primary mt-3">Guardar</button>
        </form>
        <div v-if="mensaje" class="alert mt-3" :class="{'alert-success': exito, 'alert-danger': !exito}">
          {{ mensaje }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'UnidadImgPage',
  data() {
    return {
      unidadImg: '',
      unidades: [],
      mensaje: '',
      exito: false
    };
  },
  created() {
    this.obtenerUnidades();
    this.cargarUnidadImg();
  },
  methods: {
    obtenerUnidades() {
      // Simulación de unidades de disco (A-Z)
      this.unidades = Array.from({length: 26}, (_, i) => String.fromCharCode(65 + i));
    },
    async cargarUnidadImg() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.getUnidadImg',
          payload: {}
        });
        if (res.data.status === 'success' && res.data.data) {
          this.unidadImg = res.data.data;
        } else {
          this.unidadImg = 'N'; // valor por defecto
        }
      } catch (error) {
        this.unidadImg = 'N';
      }
    },
    async guardarUnidadImg() {
      this.mensaje = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.setUnidadImg',
          payload: {
            unidad_img: this.unidadImg
          }
        });
        this.exito = res.data.status === 'success';
        this.mensaje = res.data.status === 'success' ? 'Unidad de imágenes guardada correctamente.' : (res.data.message || 'Error al guardar.');
      } catch (error) {
        this.exito = false;
        this.mensaje = 'Error de comunicación con el servidor.';
      }
    }
  }
};
</script>

<style scoped>
.unidad-img-page {
  max-width: 500px;
  margin: 40px auto;
}
</style>
