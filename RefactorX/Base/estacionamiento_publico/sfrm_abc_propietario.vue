<template>
  <div class="container mt-5">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Registro de Personas Físicas o Morales</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4>Registro de Personas Físicas o Morales</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-group mb-3">
            <label for="rfc">R.F.C</label>
            <input type="text" v-model="form.rfc" id="rfc" maxlength="13" class="form-control text-uppercase" :class="{'is-invalid': errors.rfc}" @blur="checkRfc" required>
            <div class="invalid-feedback" v-if="errors.rfc">{{ errors.rfc }}</div>
          </div>
          <div class="form-group mb-3">
            <label>
              <input type="checkbox" v-model="form.sociedad" true-value="M" false-value="F" /> Persona Física / Moral
            </label>
          </div>
          <div class="form-group mb-3">
            <label for="nombre">Nombre o Razón Social</label>
            <input type="text" v-model="form.nombre" id="nombre" maxlength="60" class="form-control text-uppercase" :class="{'is-invalid': errors.nombre}" required>
            <div class="invalid-feedback" v-if="errors.nombre">{{ errors.nombre }}</div>
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="ap_pater">Paterno</label>
              <input type="text" v-model="form.ap_pater" id="ap_pater" maxlength="15" class="form-control text-uppercase">
            </div>
            <div class="col-md-6">
              <label for="ap_mater">Materno</label>
              <input type="text" v-model="form.ap_mater" id="ap_mater" maxlength="15" class="form-control text-uppercase">
            </div>
          </div>
          <div class="form-group mb-3">
            <label for="ife">IFE</label>
            <input type="text" v-model="form.ife" id="ife" maxlength="15" class="form-control text-uppercase">
          </div>
          <div class="form-group mb-3">
            <label for="direccion">Dirección</label>
            <input type="text" v-model="form.direccion" id="direccion" maxlength="255" class="form-control text-uppercase">
          </div>
          <div class="d-flex justify-content-end">
            <button type="submit" class="btn btn-success me-2" :disabled="loading">Aceptar</button>
            <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
          </div>
        </form>
        <div v-if="alert.message" :class="['alert', alert.type, 'mt-3']">{{ alert.message }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropietarioForm',
  data() {
    return {
      form: {
        rfc: '',
        sociedad: 'F', // F: Física, M: Moral
        nombre: '',
        ap_pater: '',
        ap_mater: '',
        ife: '',
        direccion: '',
        usu_inicial: 1 // Simulación, debe obtenerse del contexto de usuario autenticado
      },
      errors: {},
      loading: false,
      alert: {
        message: '',
        type: ''
      },
      rfcChecked: false
    };
  },
  methods: {
    async checkRfc() {
      this.errors.rfc = '';
      if (!this.form.rfc || this.form.rfc.length < 9) {
        this.errors.rfc = 'Verificar el RFC (mínimo 9 caracteres).';
        return;
      }
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'check_rfc_exists',
              data: { rfc: this.form.rfc }
            }
          })
        });
        const result = await response.json();
        if (result.eResponse.success && result.eResponse.data.exists) {
          this.errors.rfc = 'Este RFC ya está registrado, verifique.';
          this.rfcChecked = false;
        } else {
          this.rfcChecked = true;
        }
      } catch (e) {
        this.errors.rfc = 'Error al verificar RFC.';
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.errors = {};
      this.alert = { message: '', type: '' };
      // Validación básica
      if (!this.form.rfc || this.form.rfc.length < 9) {
        this.errors.rfc = 'Verificar el RFC (mínimo 9 caracteres).';
        return;
      }
      if (!this.form.nombre) {
        this.errors.nombre = 'El nombre o razón social es obligatorio.';
        return;
      }
      // Verificar RFC duplicado
      await this.checkRfc();
      if (this.errors.rfc) return;
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'insert_persona',
              data: this.form
            }
          })
        });
        const result = await response.json();
        if (result.eResponse.success) {
          this.alert = { message: result.eResponse.message || 'Fue dado de alta el registro', type: 'alert-success' };
          this.resetForm();
        } else {
          this.alert = { message: result.eResponse.message || 'Error al guardar.', type: 'alert-danger' };
        }
      } catch (e) {
        this.alert = { message: 'Error de red o servidor.', type: 'alert-danger' };
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.alert = { message: 'Operación cancelada', type: 'alert-warning' };
      this.resetForm();
    },
    resetForm() {
      this.form = {
        rfc: '',
        sociedad: 'F',
        nombre: '',
        ap_pater: '',
        ap_mater: '',
        ife: '',
        direccion: '',
        usu_inicial: 1
      };
      this.errors = {};
      this.rfcChecked = false;
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 600px;
}
.card-header {
  font-size: 1.2rem;
}
</style>
