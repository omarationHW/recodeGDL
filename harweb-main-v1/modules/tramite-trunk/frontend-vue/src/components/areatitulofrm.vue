<template>
  <div class="area-titulo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Área según título</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        Modifica área según título
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="cvecuenta" class="form-label">Cuenta catastral</label>
              <input v-model="form.cvecuenta" id="cvecuenta" type="number" class="form-control" :readonly="!!form.cvecuenta" required />
            </div>
            <div class="col-md-3">
              <label for="areatitulo" class="form-label">Área según título (m²)</label>
              <input v-model.number="form.areatitulo" id="areatitulo" type="number" step="0.01" min="1" class="form-control" required />
            </div>
            <div class="col-md-6">
              <label for="observacion" class="form-label">Observaciones</label>
              <textarea v-model="form.observacion" id="observacion" class="form-control" rows="3"></textarea>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <button type="submit" class="btn btn-success me-2" :disabled="loading">Actualizar</button>
              <button type="button" class="btn btn-secondary" @click="onCancel" :disabled="loading">Cancelar</button>
            </div>
          </div>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
          <div v-if="success" class="alert alert-success">{{ success }}</div>
        </form>
        <div v-if="catastro">
          <hr />
          <h5>Último comprobante</h5>
          <div class="row mb-2">
            <div class="col-md-3"><strong>Fecha:</strong> {{ catastro.feccap }}</div>
            <div class="col-md-3"><strong>Capturista:</strong> {{ catastro.capturista }}</div>
            <div class="col-md-3"><strong>Año:</strong> {{ catastro.axocomp }}</div>
            <div class="col-md-3"><strong>Comprobante:</strong> {{ catastro.nocomp }}</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AreaTituloPage',
  data() {
    return {
      form: {
        cvecuenta: '',
        areatitulo: '',
        observacion: ''
      },
      catastro: null,
      loading: false,
      error: '',
      success: ''
    };
  },
  created() {
    // Si viene por ruta con cvecuenta, cargar datos
    if (this.$route.query.cvecuenta) {
      this.form.cvecuenta = this.$route.query.cvecuenta;
      this.fetchCatastro();
    }
  },
  methods: {
    fetchCatastro() {
      this.loading = true;
      this.error = '';
      this.success = '';
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'get',
          cvecuenta: this.form.cvecuenta
        }
      }).then(resp => {
        if (resp.data.eResponse.success && resp.data.eResponse.data) {
          this.catastro = resp.data.eResponse.data;
          this.form.areatitulo = this.catastro.areatitulo;
          this.form.observacion = this.catastro.observacion || '';
        } else {
          this.error = 'Cuenta no encontrada';
        }
      }).catch(() => {
        this.error = 'Error al consultar la cuenta';
      }).finally(() => {
        this.loading = false;
      });
    },
    onSubmit() {
      this.loading = true;
      this.error = '';
      this.success = '';
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'update',
          cvecuenta: this.form.cvecuenta,
          areatitulo: this.form.areatitulo,
          observacion: this.form.observacion
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          this.success = resp.data.eResponse.message;
          this.fetchCatastro();
        } else {
          this.error = resp.data.eResponse.message || 'Error al actualizar';
        }
      }).catch(err => {
        this.error = err.response?.data?.eResponse?.message || 'Error de red';
      }).finally(() => {
        this.loading = false;
      });
    },
    onCancel() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.area-titulo-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
