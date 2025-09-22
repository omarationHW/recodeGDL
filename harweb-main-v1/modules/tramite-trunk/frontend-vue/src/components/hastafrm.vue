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
          <div class="mb-3 row align-items-center">
            <label for="bimestre" class="col-sm-4 col-form-label">Bimestre:</label>
            <div class="col-sm-8">
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
              <div class="invalid-feedback" v-if="errors.bimestre">{{ errors.bimestre }}</div>
            </div>
          </div>
          <div class="mb-3 row align-items-center">
            <label for="anio" class="col-sm-4 col-form-label">Año:</label>
            <div class="col-sm-8">
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
              <div class="invalid-feedback" v-if="errors.anio">{{ errors.anio }}</div>
            </div>
          </div>
          <div class="d-flex justify-content-between mt-4">
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
    };
  },
  methods: {
    onBimestreKeyPress(e) {
      // Only allow 1-6
      const char = String.fromCharCode(e.which);
      if (!/[1-6]/.test(char) && e.which !== 8 && e.which !== 13) {
        e.preventDefault();
        this.errors.bimestre = 'El bimestre solo puede ser de 1 a 6';
      } else {
        this.errors.bimestre = '';
      }
    },
    validateForm() {
      this.errors = {};
      let valid = true;
      if (!this.form.bimestre || isNaN(this.form.bimestre) || this.form.bimestre < 1 || this.form.bimestre > 6) {
        this.errors.bimestre = 'El bimestre debe ser un número entre 1 y 6';
        valid = false;
      }
      if (!this.form.anio || isNaN(this.form.anio) || this.form.anio < 1970 || this.form.anio > this.currentYear) {
        this.errors.anio = `El año debe ser entre 1970 y ${this.currentYear}`;
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
              action: 'validate_hasta_form',
              params: {
                bimestre: parseInt(this.form.bimestre),
                anio: parseInt(this.form.anio)
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.serverSuccess = true;
          this.serverMessage = data.eResponse.message;
        } else {
          this.serverSuccess = false;
          this.serverMessage = data.eResponse.message;
        }
      } catch (err) {
        this.serverSuccess = false;
        this.serverMessage = 'Error de comunicación con el servidor.';
      }
    },
    onCancel() {
      this.form.bimestre = '9';
      this.form.anio = '9999';
      this.serverMessage = 'Operación cancelada.';
      this.serverSuccess = false;
    }
  }
};
</script>

<style scoped>
.hasta-form-page {
  padding-top: 40px;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
