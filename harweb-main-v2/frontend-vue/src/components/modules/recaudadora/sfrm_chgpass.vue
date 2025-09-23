<template>
  <div class="chgpass-page">
    <div class="chgpass-container">
      <h1 class="chgpass-title">Actualizar Clave de Acceso</h1>
      <div class="chgpass-form">
        <form @submit.prevent="onSubmit">
          <div class="form-group">
            <label for="current_password">Clave Actual</label>
            <input
              id="current_password"
              v-model="form.current_password"
              type="password"
              maxlength="8"
              minlength="6"
              autocomplete="current-password"
              :disabled="step !== 1"
              @keyup.enter="validateCurrentPassword"
              class="form-control"
            />
          </div>
          <div class="form-group" v-if="step > 1">
            <label for="new_password">Clave Nueva</label>
            <input
              id="new_password"
              v-model="form.new_password"
              type="password"
              maxlength="8"
              minlength="6"
              autocomplete="new-password"
              :disabled="step !== 2"
              @keyup.enter="focusConfirm"
              class="form-control"
            />
          </div>
          <div class="form-group" v-if="step > 2">
            <label for="confirm_password">Confirmación</label>
            <input
              id="confirm_password"
              v-model="form.confirm_password"
              type="password"
              maxlength="8"
              minlength="6"
              autocomplete="new-password"
              :disabled="step !== 3"
              @keyup.enter="onSubmit"
              class="form-control"
            />
          </div>
          <div class="chgpass-message" v-if="message">
            <span :class="{'text-success': success, 'text-danger': !success}">{{ message }}</span>
          </div>
          <div class="chgpass-actions">
            <button
              v-if="step === 1"
              type="button"
              class="btn btn-primary"
              @click="validateCurrentPassword"
            >
              Validar Clave Actual
            </button>
            <button
              v-if="step === 2"
              type="button"
              class="btn btn-primary"
              @click="focusConfirm"
            >
              Siguiente
            </button>
            <button
              v-if="step === 3"
              type="submit"
              class="btn btn-success"
            >
              Cambiar Clave
            </button>
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
        current_password: '',
        new_password: '',
        confirm_password: ''
      },
      step: 1, // 1: actual, 2: nueva, 3: confirmación
      message: '',
      success: false,
      loading: false,
      user_id: null // Debe obtenerse del contexto de autenticación
    };
  },
  mounted() {
    // Simulación: obtener user_id del contexto de autenticación
    // En producción, usar Vuex/store o props
    this.user_id = this.$store?.state?.auth?.user?.id || 1;
    this.resetForm();
  },
  methods: {
    resetForm() {
      this.form.current_password = '';
      this.form.new_password = '';
      this.form.confirm_password = '';
      this.step = 1;
      this.message = '';
      this.success = false;
    },
    async validateCurrentPassword() {
      this.message = '';
      if (!this.form.current_password || this.form.current_password.length < 6) {
        this.message = 'La clave actual debe tener al menos 6 caracteres.';
        this.success = false;
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'chgpass.validate_current',
          params: {
            user_id: this.user_id,
            current_password: this.form.current_password
          }
        });
        if (res.data.eResponse.success) {
          this.step = 2;
          this.message = 'Clave actual válida. Introduce la nueva clave.';
          this.success = true;
          this.$nextTick(() => {
            this.$el.querySelector('#new_password').focus();
          });
        } else {
          this.message = res.data.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.message = e.response?.data?.eResponse?.message || 'Error de conexión.';
        this.success = false;
      }
      this.loading = false;
    },
    focusConfirm() {
      if (!this.form.new_password || this.form.new_password.length < 6) {
        this.message = 'La nueva clave debe tener al menos 6 caracteres.';
        this.success = false;
        return;
      }
      // Validaciones locales
      if (this.form.current_password === this.form.new_password) {
        this.message = 'La clave nueva no debe ser igual a la actual.';
        this.success = false;
        return;
      }
      if (this.form.new_password.length < 6) {
        this.message = 'La clave debe ser mayor a 5 dígitos.';
        this.success = false;
        return;
      }
      if (this.form.new_password.substr(0, 3) === this.form.current_password.substr(0, 3)) {
        this.message = 'Los tres primeros caracteres deben ser diferentes al actual.';
        this.success = false;
        return;
      }
      if (!(/[a-z]/.test(this.form.new_password) && /\d/.test(this.form.new_password))) {
        this.message = 'La clave debe contener números y letras.';
        this.success = false;
        return;
      }
      this.step = 3;
      this.message = 'Introduce la confirmación de la clave.';
      this.success = true;
      this.$nextTick(() => {
        this.$el.querySelector('#confirm_password').focus();
      });
    },
    async onSubmit() {
      this.message = '';
      if (this.form.new_password !== this.form.confirm_password) {
        this.message = 'La confirmación de la clave no es igual.';
        this.success = false;
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'chgpass.change_password',
          params: {
            user_id: this.user_id,
            current_password: this.form.current_password,
            new_password: this.form.new_password,
            confirm_password: this.form.confirm_password
          }
        });
        if (res.data.eResponse.success) {
          this.message = 'Clave cambiada satisfactoriamente.';
          this.success = true;
          setTimeout(() => {
            this.resetForm();
          }, 2000);
        } else {
          this.message = res.data.eResponse.message;
          this.success = false;
        }
      } catch (e) {
        this.message = e.response?.data?.eResponse?.message || 'Error de conexión.';
        this.success = false;
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.chgpass-page {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100vh;
  background: #f8f9fa;
}
.chgpass-container {
  background: #fff;
  padding: 2rem 2.5rem;
  margin-top: 3rem;
  border-radius: 8px;
  box-shadow: 0 2px 12px rgba(0,0,0,0.08);
  min-width: 400px;
}
.chgpass-title {
  font-family: 'Trebuchet MS', Arial, sans-serif;
  font-size: 2rem;
  font-weight: bold;
  color: #333;
  margin-bottom: 2rem;
  text-align: center;
}
.chgpass-form {
  width: 100%;
}
.form-group {
  margin-bottom: 1.5rem;
}
label {
  font-weight: bold;
  font-size: 1rem;
  color: #444;
}
input.form-control {
  width: 100%;
  padding: 0.5rem 0.75rem;
  font-size: 1rem;
  border: 1px solid #bbb;
  border-radius: 4px;
  margin-top: 0.25rem;
}
.chgpass-message {
  margin-bottom: 1rem;
  text-align: center;
}
.text-success {
  color: #28a745;
}
.text-danger {
  color: #dc3545;
}
.chgpass-actions {
  display: flex;
  justify-content: center;
  gap: 1rem;
}
.btn {
  min-width: 140px;
}
</style>
