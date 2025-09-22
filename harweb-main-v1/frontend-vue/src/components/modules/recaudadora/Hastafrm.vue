<template>
  <div class="hasta-form-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagar hasta</li>
      </ol>
    </nav>
    <div class="card mx-auto" style="max-width: 400px;">
      <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Pagar hasta</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="mb-3">
            <label for="bimestre" class="form-label">Bimestre:</label>
            <input
              type="number"
              min="1"
              max="6"
              class="form-control"
              id="bimestre"
              v-model="form.bimestre"
              @keypress="onBimestreKeyPress"
              :class="{'is-invalid': errors.bimestre}"
              autocomplete="off"
              required
            >
            <div class="invalid-feedback" v-if="errors.bimestre">
              {{ errors.bimestre }}
            </div>
          </div>
          <div class="mb-3">
            <label for="anio" class="form-label">Año:</label>
            <input
              type="number"
              min="1970"
              :max="currentYear"
              class="form-control"
              id="anio"
              v-model="form.anio"
              :class="{'is-invalid': errors.anio}"
              autocomplete="off"
              required
            >
            <div class="invalid-feedback" v-if="errors.anio">
              {{ errors.anio }}
            </div>
          </div>
          <div class="d-flex justify-content-between">
            <button type="submit" class="btn btn-success">Aceptar</button>
            <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
          </div>
        </form>
        <div v-if="serverMessage" class="alert mt-3" :class="{'alert-success': serverSuccess, 'alert-danger': !serverSuccess}">
          {{ serverMessage }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HastaFormPage',
  data() {
    return {
      form: {
        bimestre: '',
        anio: ''
      },
      errors: {},
      serverMessage: '',
      serverSuccess: false,
      currentYear: new Date().getFullYear()
    }
  },
  methods: {
    onBimestreKeyPress(e) {
      // Permitir solo 1-6 y teclas de control
      const allowed = ['1','2','3','4','5','6'];
      if (!allowed.includes(e.key) && e.key !== 'Backspace' && e.key !== 'Tab' && e.key !== 'Enter') {
        e.preventDefault();
        this.errors.bimestre = 'El bimestre solo puede ser de 1 a 6';
      } else {
        this.errors.bimestre = '';
      }
      // Si presiona Enter, pasar al campo año
      if (e.key === 'Enter') {
        this.$nextTick(() => {
          this.$refs.anio && this.$refs.anio.focus();
        });
      }
    },
    validateForm() {
      this.errors = {};
      let valid = true;
      if (!this.form.bimestre || isNaN(this.form.bimestre) || this.form.bimestre < 1 || this.form.bimestre > 6) {
        this.errors.bimestre = 'El bimestre solo puede ser de 1 a 6';
        valid = false;
      }
      if (!this.form.anio || isNaN(this.form.anio) || this.form.anio < 1970 || this.form.anio > this.currentYear) {
        this.errors.anio = `El año debe estar entre 1970 y ${this.currentYear}`;
        valid = false;
      }
      return valid;
    },
    async onSubmit() {
      this.serverMessage = '';
      this.serverSuccess = false;
      if (!this.validateForm()) {
        return;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              operation: 'validate_hasta_form',
              params: {
                bimestre: Number(this.form.bimestre),
                anio: Number(this.form.anio)
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.serverMessage = data.eResponse.message;
          this.serverSuccess = true;
        } else {
          this.serverMessage = data.eResponse.errors ? data.eResponse.errors.join(' ') : data.eResponse.message;
          this.serverSuccess = false;
        }
      } catch (err) {
        this.serverMessage = 'Error de comunicación con el servidor.';
        this.serverSuccess = false;
      }
    },
    onCancel() {
      // Simula el comportamiento Delphi: pone valores de salida y "cierra"
      this.form.bimestre = 9;
      this.form.anio = 9999;
      this.serverMessage = 'Operación cancelada.';
      this.serverSuccess = false;
    }
  },
  mounted() {
    // Limpiar campos al mostrar
    this.form.bimestre = '';
    this.form.anio = '';
    this.errors = {};
    this.serverMessage = '';
    this.serverSuccess = false;
  }
}
</script>

<style scoped>
.hasta-form-page {
  padding-top: 40px;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
