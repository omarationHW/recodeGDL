<template>
  <div class="alta-ubicaciones-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Alta de Ubicaciones</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Agregar Ubicaciones al Estacionamiento Exclusivo</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="tipo" class="form-label fw-bold">Tipo:</label>
              <select v-model="form.tipo_esta" id="tipo" class="form-select" required>
                <option value="C">Cordon</option>
                <option value="B">Bateria</option>
              </select>
            </div>
            <div class="col-md-3">
              <label for="extencion" class="form-label fw-bold">Medida:</label>
              <input type="number" min="0" max="9999" v-model.number="form.extencion" id="extencion" class="form-control" required />
            </div>
            <div class="col-md-6"></div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <label for="calle" class="form-label fw-bold">Calle:</label>
              <input type="text" v-model="form.calle" id="calle" class="form-control text-uppercase" maxlength="255" required />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="colonia" class="form-label fw-bold">Colonia:</label>
              <input type="text" v-model="form.colonia" id="colonia" class="form-control text-uppercase" maxlength="255" required />
            </div>
            <div class="col-md-6"></div>
          </div>
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="acera" class="form-label fw-bold">Acera:</label>
              <select v-model="form.acera" id="acera" class="form-select" required>
                <option value="N">NORTE</option>
                <option value="S">SUR</option>
                <option value="O">ORIENTE</option>
                <option value="P">PONIENTE</option>
              </select>
            </div>
            <div class="col-md-9"></div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <label for="inter" class="form-label fw-bold">Intersección:</label>
              <input type="text" v-model="form.inter" id="inter" class="form-control text-uppercase" maxlength="255" required />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="apartir" class="form-label fw-bold">A Partir de:</label>
              <input type="number" min="0" max="999999" v-model.number="form.apartir" id="apartir" class="form-control" required />
            </div>
            <div class="col-md-3">
              <label for="hacia" class="form-label fw-bold">Hacia:</label>
              <select v-model="form.hacia" id="hacia" class="form-select" required>
                <option value="N">NORTE</option>
                <option value="S">SUR</option>
                <option value="O">ORIENTE</option>
                <option value="P">PONIENTE</option>
              </select>
            </div>
            <div class="col-md-6"></div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label class="form-label fw-bold">Exclusivo (Contrato):</label>
              <span class="form-control-plaintext fw-bold">{{ contrato_num }}</span>
            </div>
          </div>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
          <div v-if="success" class="alert alert-success">{{ success }}</div>
          <div class="d-flex justify-content-end">
            <button type="submit" class="btn btn-primary me-2" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm"></span>
              Agregar
            </button>
            <router-link to="/" class="btn btn-secondary">Cancelar</router-link>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AltaUbicacionesPage',
  props: {
    contrato_id: {
      type: Number,
      required: true
    },
    contrato_num: {
      type: [String, Number],
      required: true
    },
    usuario_id: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      form: {
        opc: 1, // Alta
        id_ubic: 0,
        contrato_id: this.contrato_id,
        tipo_esta: 'C',
        calle: '',
        colonia: '',
        zona: 0,
        subzona: 0,
        extencion: 0,
        acera: 'N',
        inter: '',
        inter2: '',
        apartir: 0,
        hacia: 'N',
        usuario: this.usuario_id
      },
      loading: false,
      error: '',
      success: ''
    };
  },
  methods: {
    async onSubmit() {
      this.error = '';
      this.success = '';
      this.loading = true;
      try {
        // Normalizar campos
        this.form.calle = this.form.calle.toUpperCase();
        this.form.colonia = this.form.colonia.toUpperCase();
        this.form.inter = this.form.inter.toUpperCase();
        // API call
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              operation: 'alta_ubicacion',
              params: this.form
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.success) {
          this.success = data.eResponse.message || 'Alta de Ubicación realizada correctamente.';
          this.resetForm();
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error inesperado.';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    resetForm() {
      this.form.calle = '';
      this.form.colonia = '';
      this.form.extencion = 0;
      this.form.acera = 'N';
      this.form.inter = '';
      this.form.apartir = 0;
      this.form.hacia = 'N';
    }
  }
};
</script>

<style scoped>
.alta-ubicaciones-page {
  max-width: 700px;
  margin: 0 auto;
}
.text-uppercase {
  text-transform: uppercase;
}
</style>
