<template>
  <div class="chgpass-page">
    <div class="chgpass-container">
      <h1 class="chgpass-title">Actualizar Clave de Acceso</h1>
      <form @submit.prevent="handleSubmit">
        <div class="form-group">
          <label for="current_password">Clave Actual</label>
          <input
            id="current_password"
            v-model="form.current_password"
            type="password"
            maxlength="8"
            autocomplete="current-password"
            @keyup.enter="validateCurrentPassword"
            :disabled="step !== 1"
            required
          />
        </div>
        <div class="form-group" v-if="step >= 2">
          <label for="new_password">Clave Nueva</label>
          <input
            id="new_password"
            v-model="form.new_password"
            type="password"
            maxlength="8"
            autocomplete="new-password"
            @keyup.enter="focusConfirm"
            :disabled="step !== 2"
            required
          />
        </div>
        <div class="form-group" v-if="step >= 3">
          <label for="confirm_password">Confirmación</label>
          <input
            id="confirm_password"
            v-model="form.confirm_password"
            type="password"
            maxlength="8"
            autocomplete="new-password"
            @keyup.enter="handleSubmit"
            :disabled="step !== 3"
            required
          />
        </div>
        <div class="chgpass-message" v-if="message">
          <span :class="{'error': !success, 'success': success}">{{ message }}</span>
        </div>
        <div class="form-actions">
          <button v-if="step === 1" type="button" @click="validateCurrentPassword">Validar Clave Actual</button>
          <button v-if="step === 2" type="button" @click="focusConfirm">Siguiente</button>
          <button v-if="step === 3" type="submit">Cambiar Clave</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
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
      success: false
    };
  },
  methods: {
    async validateCurrentPassword() {
      this.message = '';
      if (!this.form.current_password || this.form.current_password.length < 2) {
        this.message = 'La clave actual debe tener al menos 2 caracteres.';
        this.success = false;
        return;
      }
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'chgpass.validate_current',
            data: { current_password: this.form.current_password }
          }
        });
        if (data.eResponse.success && data.eResponse.data.is_valid) {
          this.step = 2;
          this.message = 'Clave actual válida. Introduce la nueva clave.';
          this.success = true;
          this.$nextTick(() => {
            this.$refs.new_password && this.$refs.new_password.focus();
          });
        } else {
          this.message = 'La clave actual no es correcta, vuelve a intentar...';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de validación.';
        this.success = false;
      }
    },
    focusConfirm() {
      if (!this.form.new_password) {
        this.message = 'La nueva clave no puede estar vacía.';
        this.success = false;
        return;
      }
      // Validaciones de nueva clave
      if (this.form.new_password.length < 6) {
        this.message = 'La clave debe ser mayor a 5 dígitos.';
        this.success = false;
        return;
      }
      if (this.form.new_password === this.form.current_password) {
        this.message = 'La clave no debe ser igual a la actual.';
        this.success = false;
        return;
      }
      if (!(/[a-z]/.test(this.form.new_password) && /[0-9]/.test(this.form.new_password))) {
        this.message = 'La clave debe contener números y letras.';
        this.success = false;
        return;
      }
      if (this.form.new_password.substr(0,3) === this.form.current_password.substr(0,3)) {
        this.message = 'Los tres primeros caracteres deben ser diferentes al actual.';
        this.success = false;
        return;
      }
      this.step = 3;
      this.message = 'Introduce la confirmación de la clave y presiona Enter.';
      this.success = true;
      this.$nextTick(() => {
        this.$refs.confirm_password && this.$refs.confirm_password.focus();
      });
    },
    async handleSubmit() {
      this.message = '';
      if (this.form.new_password !== this.form.confirm_password) {
        this.message = 'La confirmación de la clave no es igual.';
        this.success = false;
        return;
      }
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'chgpass.change',
            data: {
              current_password: this.form.current_password,
              new_password: this.form.new_password,
              confirm_password: this.form.confirm_password
            }
          }
        });
        if (data.eResponse.success) {
          this.message = data.eResponse.message || 'Clave cambiada satisfactoriamente.';
          this.success = true;
          setTimeout(() => {
            this.$router.push({ name: 'home' });
          }, 2000);
        } else {
          this.message = data.eResponse.message || 'No fue posible cambiar la clave.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error al cambiar la clave.';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
.chgpass-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 80vh;
  background: #f9f9f9;
}
.chgpass-container {
  background: #fff;
  border-radius: 8px;
  padding: 2rem 2.5rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  min-width: 350px;
}
.chgpass-title {
  text-align: center;
  font-size: 2rem;
  margin-bottom: 1.5rem;
}
.form-group {
  margin-bottom: 1.2rem;
}
.form-group label {
  display: block;
  font-weight: bold;
  margin-bottom: 0.3rem;
}
.form-group input {
  width: 100%;
  padding: 0.5rem;
  font-size: 1rem;
  border: 1px solid #bbb;
  border-radius: 4px;
}
.chgpass-message {
  margin-bottom: 1rem;
  text-align: center;
}
.chgpass-message .error {
  color: #b71c1c;
}
.chgpass-message .success {
  color: #388e3c;
}
.form-actions {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
}
button {
  background: #1976d2;
  color: #fff;
  border: none;
  padding: 0.6rem 1.2rem;
  border-radius: 4px;
  font-size: 1rem;
  cursor: pointer;
}
button:disabled {
  background: #aaa;
  cursor: not-allowed;
}
</style>
