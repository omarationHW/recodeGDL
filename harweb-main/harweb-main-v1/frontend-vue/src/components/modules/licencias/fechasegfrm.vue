<template>
  <div class="fechasegfrm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Formulario Fecha Seguimiento</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h5>Seleccione la fecha</h5>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-6">
              <label for="fecha" class="form-label"><strong>Seleccione la fecha</strong></label>
              <input type="date" id="fecha" v-model="form.fecha" class="form-control" required />
            </div>
            <div class="col-md-6">
              <label for="oficio" class="form-label"><strong>Oficio:</strong></label>
              <input type="text" id="oficio" v-model="form.oficio" class="form-control" maxlength="255" required />
            </div>
          </div>
          <div class="d-flex justify-content-end mt-4">
            <button type="button" class="btn btn-secondary me-2" @click="onCancel">Cancelar</button>
            <button type="submit" class="btn btn-primary">Aceptar</button>
          </div>
        </form>
        <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">
          {{ message }}
        </div>
      </div>
    </div>
    <div class="card mt-4">
      <div class="card-header">
        <h6>Registros recientes</h6>
      </div>
      <div class="card-body p-0">
        <table class="table table-sm mb-0">
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Oficio</th>
              <th>Fecha de Registro</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in registros" :key="item.id">
              <td>{{ item.fecha }}</td>
              <td>{{ item.oficio }}</td>
              <td>{{ item.created_at }}</td>
            </tr>
            <tr v-if="registros.length === 0">
              <td colspan="3" class="text-center">Sin registros</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'FechasegfrmPage',
  data() {
    return {
      form: {
        fecha: '',
        oficio: ''
      },
      message: '',
      success: false,
      registros: []
    };
  },
  mounted() {
    this.loadRegistros();
  },
  methods: {
    async onSubmit() {
      this.message = '';
      this.success = false;
      try {
        const eRequest = {
          Operacion: 'SP_fechaseg_create',
          Parametros: [
            { nombre: 'p_fecha', valor: this.form.fecha },
            { nombre: 'p_oficio', valor: this.form.oficio }
          ]
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.message = 'Fecha de seguimiento registrada correctamente';
          this.success = true;
          this.form.fecha = '';
          this.form.oficio = '';
          this.loadRegistros();
        } else {
          this.message = data.eResponse.message || 'Error al guardar';
          this.success = false;
        }
      } catch (e) {
        this.message = 'Error de red o del servidor.';
        this.success = false;
      }
    },
    onCancel() {
      this.form.fecha = '';
      this.form.oficio = '';
      this.message = '';
      this.success = false;
    },
    async loadRegistros() {
      try {
        const eRequest = {
          Operacion: 'SP_fechaseg_list',
          Parametros: [
            { nombre: 'p_limite', valor: 50 },
            { nombre: 'p_offset', valor: 0 }
          ]
        };

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify(eRequest)
        });
        const data = await response.json();

        if (data.eResponse.success) {
          this.registros = data.eResponse.data || [];
        } else {
          this.registros = [];
        }
      } catch (e) {
        this.registros = [];
      }
    }
  }
};
</script>

<style scoped>
.fechasegfrm-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  margin-bottom: 1rem;
}
</style>
