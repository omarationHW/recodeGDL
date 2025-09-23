<template>
  <div class="chgpass-page">
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Actualizar Clave de Acceso</li>
      </ol>
    </nav>
    <div class="card mx-auto" style="max-width: 600px;">
      <div class="card-body">
        <h2 class="card-title text-center mb-4">Actualizar Clave de Acceso</h2>
        <form @submit.prevent="handleSubmit">
          <div class="mb-3">
            <label for="username" class="form-label">Usuario</label>
            <input v-model="form.username" id="username" type="text" class="form-control" autocomplete="username" required :disabled="step > 1">
          </div>
          <div class="mb-3">
            <label for="current_password" class="form-label">Clave Actual</label>
            <input v-model="form.current_password" id="current_password" type="password" class="form-control" maxlength="8" autocomplete="current-password" required :disabled="step > 1" @keyup.enter="validateCurrentPassword">
          </div>
          <div v-if="step > 1" class="mb-3">
            <label for="new_password" class="form-label">Clave Nueva</label>
            <input v-model="form.new_password" id="new_password" type="password" class="form-control" maxlength="8" autocomplete="new-password" required :disabled="step > 2" @keyup.enter="validateNewPassword">
            <div class="form-text">Debe contener letras y números, diferente a la actual, y los 3 primeros caracteres no deben coincidir con la actual.</div>
          </div>
          <div v-if="step > 2" class="mb-3">
            <label for="confirm_password" class="form-label">Confirmación</label>
            <input v-model="form.confirm_password" id="confirm_password" type="password" class="form-control" maxlength="8" autocomplete="new-password" required @keyup.enter="handleSubmit">
          </div>
          <div class="mb-3">
            <span class="text-danger" v-if="error">{{ error }}</span>
            <span class="text-success" v-if="success">{{ success }}</span>
          </div>
          <div class="d-flex justify-content-between">
            <button v-if="step === 1" type="button" class="btn btn-primary" @click="validateCurrentPassword">Validar Clave Actual</button>
            <button v-if="step === 2" type="button" class="btn btn-primary" @click="validateNewPassword">Validar Nueva Clave</button>
            <button v-if="step === 3" type="submit" class="btn btn-success">Cambiar Clave</button>
            <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ChgPassPage',
  data() {
    return {
      form: {
        username: '',
        current_password: '',
        new_password: '',
        confirm_password: ''
      },
      step: 1, // 1: current, 2: new, 3: confirm
      error: '',
      success: ''
    };
  },
  methods: {
    resetForm() {
      this.form.current_password = '';
      this.form.new_password = '';
      this.form.confirm_password = '';
      this.error = '';
      this.success = '';
      this.step = 1;
    },
    async validateCurrentPassword() {
      this.error = '';
      this.success = '';
      if (!this.form.username || !this.form.current_password) {
        this.error = 'Debe ingresar usuario y clave actual.';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'chgpass.validate_current',
          params: {
            username: this.form.username,
            current_password: this.form.current_password
          }
        });
        if (res.data.eResponse.success) {
          this.step = 2;
          this.success = 'Clave actual validada. Ingrese la nueva clave.';
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || 'Error de validación.';
      }
    },
    async validateNewPassword() {
      this.error = '';
      this.success = '';
      if (!this.form.new_password) {
        this.error = 'Debe ingresar la nueva clave.';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'chgpass.validate_new',
          params: {
            current_password: this.form.current_password,
            new_password: this.form.new_password
          }
        });
        if (res.data.eResponse.success) {
          this.step = 3;
          this.success = 'Nueva clave válida. Confirme la clave.';
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || 'Error de validación.';
      }
    },
    async handleSubmit() {
      this.error = '';
      this.success = '';
      if (this.form.new_password !== this.form.confirm_password) {
        this.error = 'La confirmación de la clave no es igual.';
        this.form.confirm_password = '';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'chgpass.update',
          params: {
            username: this.form.username,
            current_password: this.form.current_password,
            new_password: this.form.new_password,
            confirm_password: this.form.confirm_password
          }
        });
        if (res.data.eResponse.success) {
          this.success = res.data.eResponse.message;
          setTimeout(() => {
            this.$router.push('/');
          }, 2000);
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.response?.data?.eResponse?.message || 'Error al cambiar la clave.';
      }
    }
  }
};
</script>

<style scoped>
.chgpass-page {
  background: #f8f9fa;
  min-height: 100vh;
  padding-top: 40px;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
