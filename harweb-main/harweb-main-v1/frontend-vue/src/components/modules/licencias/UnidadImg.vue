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
        const eRequest = {
          Operacion: 'sp_licencias_get_unidad_img',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: []
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const res = await response.json()
        if (res.eResponse.success && res.eResponse.data.result) {
          this.unidadImg = res.eResponse.data.result;
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
        const eRequest = {
          Operacion: 'sp_licencias_set_unidad_img',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_unidad_img', valor: this.unidadImg }
          ]
        }
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })
        const res = await response.json()
        this.exito = res.eResponse.success;
        this.mensaje = res.eResponse.success ? 'Unidad de imágenes guardada correctamente.' : (res.eResponse.message || 'Error al guardar.');
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
