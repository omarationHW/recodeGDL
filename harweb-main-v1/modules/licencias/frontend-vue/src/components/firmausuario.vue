<template>
  <div class="firmausuario-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Firma Electrónica</li>
      </ol>
    </nav>
    <div class="card mx-auto" style="max-width: 420px;">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Firma electrónica</h5>
      </div>
      <div class="card-body">
        <div class="text-center mb-3">
          <img src="/firma-icon.png" alt="Firma" width="48" height="48" />
        </div>
        <p class="font-weight-bold mb-3">Ingrese usuario y firma electrónica autorizada:</p>
        <form @submit.prevent="onSubmit">
          <div class="form-group">
            <label for="usuario">Usuario:</label>
            <input
              id="usuario"
              v-model="form.usuario"
              type="text"
              class="form-control"
              :class="{'is-invalid': errors.usuario}"
              autocomplete="username"
              @keyup.enter="focusFirma"
              ref="usuarioInput"
              required
            />
            <div class="invalid-feedback" v-if="errors.usuario">{{ errors.usuario }}</div>
          </div>
          <div class="form-group">
            <label for="firma">Firma:</label>
            <input
              id="firma"
              v-model="form.firma"
              type="password"
              class="form-control"
              :class="{'is-invalid': errors.firma}"
              autocomplete="current-password"
              @keyup.enter="focusAceptar"
              ref="firmaInput"
              required
            />
            <div class="invalid-feedback" v-if="errors.firma">{{ errors.firma }}</div>
          </div>
          <div class="d-flex justify-content-between mt-4">
            <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
            <button type="submit" class="btn btn-primary" ref="aceptarBtn">Aceptar</button>
          </div>
        </form>
        <div v-if="message" :class="{'alert': true, 'alert-success': success, 'alert-danger': !success, 'mt-3': true}">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FirmaUsuarioPage',
  data() {
    return {
      form: {
        usuario: '',
        firma: ''
      },
      errors: {},
      message: '',
      success: false
    };
  },
  mounted() {
    this.$refs.usuarioInput.focus();
  },
  methods: {
    focusFirma() {
      this.$refs.firmaInput.focus();
    },
    focusAceptar() {
      this.$refs.aceptarBtn.focus();
    },
    onCancel() {
      this.form.usuario = '';
      this.form.firma = '';
      this.errors = {};
      this.message = '';
      this.success = false;
      this.$refs.usuarioInput.focus();
    },
    async onSubmit() {
      this.errors = {};
      this.message = '';
      this.success = false;
      // Validación simple en frontend
      if (!this.form.usuario) {
        this.errors.usuario = 'El usuario es obligatorio.';
      }
      if (!this.form.firma) {
        this.errors.firma = 'La firma es obligatoria.';
      }
      if (Object.keys(this.errors).length > 0) return;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'validate_firma_usuario',
              data: {
                usuario: this.form.usuario,
                firma: this.form.firma
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.message = data.eResponse.message || 'Firma validada correctamente.';
          this.success = true;
          // Aquí podrías emitir un evento o redirigir según el flujo de la app
        } else {
          this.message = data.eResponse.message || 'Error de validación.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de conexión con el servidor.';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
.firmausuario-page {
  background: #f8f9fa;
  min-height: 100vh;
  padding-top: 40px;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
