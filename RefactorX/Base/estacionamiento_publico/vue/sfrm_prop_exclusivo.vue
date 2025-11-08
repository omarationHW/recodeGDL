<template>
  <div class="container mt-4">
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
          <div class="form-group form-check mb-3">
            <input type="checkbox" class="form-check-input" id="sociedad" v-model="form.sociedad" />
            <label class="form-check-label" for="sociedad">Persona Moral (desmarcado = Física)</label>
          </div>
          <div class="form-group mb-3">
            <label for="rfc">R.F.C</label>
            <input type="text" class="form-control" id="rfc" v-model="form.rfc" maxlength="13" required @blur="validateRFC" />
            <small v-if="errors.rfc" class="text-danger">{{ errors.rfc }}</small>
          </div>
          <div class="form-group mb-3">
            <label for="propietario">Nombre o Razón Social</label>
            <input type="text" class="form-control" id="propietario" v-model="form.propietario" maxlength="60" required />
            <small v-if="errors.propietario" class="text-danger">{{ errors.propietario }}</small>
          </div>
          <div class="form-group mb-3">
            <label for="domicilio">Domicilio</label>
            <input type="text" class="form-control" id="domicilio" v-model="form.domicilio" maxlength="60" required />
            <small v-if="errors.domicilio" class="text-danger">{{ errors.domicilio }}</small>
          </div>
          <div class="form-group mb-3">
            <label for="colonia">Colonia</label>
            <input type="text" class="form-control" id="colonia" v-model="form.colonia" maxlength="50" />
          </div>
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="telefono">Teléfono</label>
              <input type="text" class="form-control" id="telefono" v-model="form.telefono" maxlength="15" />
            </div>
            <div class="col-md-6">
              <label for="celular">Celular</label>
              <input type="text" class="form-control" id="celular" v-model="form.celular" maxlength="15" />
            </div>
          </div>
          <div class="form-group mb-3">
            <label for="email">Email</label>
            <input type="email" class="form-control" id="email" v-model="form.email" maxlength="60" />
          </div>
          <div class="d-flex justify-content-end">
            <button type="submit" class="btn btn-success me-2">Aceptar</button>
            <button type="button" class="btn btn-secondary" @click="onCancel">Cancelar</button>
          </div>
        </form>
        <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ message }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PropietarioExclusivoForm',
  props: {
    id: {
      type: [Number, String],
      default: null
    }
  },
  data() {
    return {
      form: {
        sociedad: false, // false = Fisica, true = Moral
        rfc: '',
        propietario: '',
        domicilio: '',
        colonia: '',
        telefono: '',
        celular: '',
        email: ''
      },
      errors: {},
      message: '',
      success: false,
      loading: false,
      isEdit: false
    };
  },
  created() {
    if (this.id) {
      this.isEdit = true;
      this.fetchPropietario();
    }
  },
  methods: {
    validateRFC() {
      if (this.form.rfc.length < 9) {
        this.errors.rfc = 'Verificar el RFC (mínimo 9 caracteres)';
      } else {
        this.errors.rfc = '';
      }
    },
    async fetchPropietario() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'ex_propietario_by_id',
            params: { id: this.id }
          })
        });
        const data = await res.json();
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          const p = data.eResponse.data[0];
          this.form.sociedad = (p.sociedad === 'M');
          this.form.rfc = p.rfc;
          this.form.propietario = p.propietario;
          this.form.domicilio = p.domicilio;
          this.form.colonia = p.colonia;
          this.form.telefono = p.telefono;
          this.form.celular = p.celular;
          this.form.email = p.email;
        } else {
          this.message = 'No se encontró el registro.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error al cargar datos: ' + e.message;
        this.success = false;
      } finally {
        this.loading = false;
      }
    },
    async onSubmit() {
      this.errors = {};
      // Validaciones
      if (this.form.rfc.length < 9) {
        this.errors.rfc = 'Verificar el RFC (mínimo 9 caracteres)';
        return;
      }
      if (!this.form.propietario) {
        this.errors.propietario = 'Verificar el Nombre.';
        return;
      }
      if (!this.form.domicilio) {
        this.errors.domicilio = 'Verificar el Domicilio.';
        return;
      }
      this.loading = true;
      this.message = '';
      const payload = {
        sociedad: this.form.sociedad ? 'M' : 'F',
        rfc: this.form.rfc.trim().toUpperCase(),
        propietario: this.form.propietario.trim().toUpperCase(),
        domicilio: this.form.domicilio.trim().toUpperCase(),
        colonia: this.form.colonia.trim().toUpperCase(),
        telefono: this.form.telefono.trim(),
        celular: this.form.celular.trim(),
        email: this.form.email.trim().toLowerCase()
      };
      try {
        let eRequest = 'ex_propietario_create';
        let params = payload;
        if (this.isEdit) {
          eRequest = 'ex_propietario_update';
          params = { ...payload, id: this.id };
        }
        // Check RFC uniqueness only on create
        if (!this.isEdit) {
          const rfcRes = await fetch('/api/execute', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              eRequest: 'ex_propietario_by_rfc',
              params: { rfc: payload.rfc }
            })
          });
          const rfcData = await rfcRes.json();
          if (rfcData.eResponse.data && rfcData.eResponse.data.length > 0) {
            this.errors.rfc = 'Este RFC ya está registrado.';
            this.loading = false;
            return;
          }
        }
        // Create or update
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest, params })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.message = data.eResponse.message || (this.isEdit ? 'Cambio efectuado.' : 'Fue dado de alta el registro.');
          this.success = true;
          if (!this.isEdit) {
            this.form = {
              sociedad: false,
              rfc: '',
              propietario: '',
              domicilio: '',
              colonia: '',
              telefono: '',
              celular: '',
              email: ''
            };
          }
        } else {
          this.message = data.eResponse.message || 'Error en la operación.';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error: ' + e.message;
        this.success = false;
      } finally {
        this.loading = false;
      }
    },
    onCancel() {
      this.$router.back();
    }
  }
};
</script>

<style scoped>
.container {
  max-width: 600px;
}
.card-header h4 {
  margin-bottom: 0;
}
</style>
