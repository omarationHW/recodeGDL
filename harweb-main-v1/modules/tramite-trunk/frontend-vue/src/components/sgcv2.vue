<template>
  <div class="sgcv2-formulario">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">SGCv2</li>
      </ol>
    </nav>
    <h1>Sistema de Gestión Catastral - Predial</h1>
    <form @submit.prevent="buscarCuenta">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="recaud">Recaudadora</label>
          <input v-model="form.recaud" type="number" class="form-control" id="recaud" required />
        </div>
        <div class="form-group col-md-2">
          <label for="urbrus">Urb/Rus</label>
          <input v-model="form.urbrus" type="text" class="form-control" id="urbrus" maxlength="1" required />
        </div>
        <div class="form-group col-md-2">
          <label for="cuenta">Cuenta</label>
          <input v-model="form.cuenta" type="number" class="form-control" id="cuenta" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button class="btn btn-primary" type="submit">Buscar Cuenta</button>
        </div>
      </div>
    </form>
    <div v-if="cuenta">
      <h3>Datos de la Cuenta</h3>
      <table class="table table-bordered">
        <tr><th>Clave UTM</th><td>{{ cuenta.claveutm }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ cuenta.recaud }}</td></tr>
        <tr><th>Urb/Rus</th><td>{{ cuenta.urbrus }}</td></tr>
        <tr><th>Cuenta</th><td>{{ cuenta.cuenta }}</td></tr>
        <tr><th>Subpredio</th><td>{{ cuenta.subpredio }}</td></tr>
        <tr><th>Vigente</th><td>{{ cuenta.vigente }}</td></tr>
      </table>
      <button class="btn btn-info" @click="consultarPropietarios">Ver Propietarios</button>
      <button class="btn btn-success ml-2" @click="consultarLiquidacion">Ver Liquidación</button>
    </div>
    <div v-if="propietarios && propietarios.length">
      <h3>Propietarios</h3>
      <table class="table table-striped">
        <thead>
          <tr><th>Nombre</th><th>RFC</th><th>Porcentaje</th><th>Tipo</th></tr>
        </thead>
        <tbody>
          <tr v-for="p in propietarios" :key="p.id">
            <td>{{ p.nombre }}</td>
            <td>{{ p.rfc }}</td>
            <td>{{ p.porcentaje }}</td>
            <td>{{ p.tipo }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="liquidacion && liquidacion.length">
      <h3>Liquidación</h3>
      <table class="table table-bordered">
        <thead>
          <tr><th>Concepto</th><th>Importe</th></tr>
        </thead>
        <tbody>
          <tr v-for="l in liquidacion" :key="l.id">
            <td>{{ l.concepto }}</td>
            <td>{{ l.importe | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'Sgcv2Formulario',
  data() {
    return {
      form: {
        recaud: '',
        urbrus: '',
        cuenta: ''
      },
      cuenta: null,
      propietarios: [],
      liquidacion: [],
      error: ''
    };
  },
  methods: {
    async buscarCuenta() {
      this.error = '';
      this.cuenta = null;
      this.propietarios = [];
      this.liquidacion = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscarCuenta',
            params: {
              recaud: this.form.recaud,
              urbrus: this.form.urbrus,
              cuenta: this.form.cuenta
            }
          }
        });
        if (res.data.eResponse.error) throw new Error(res.data.eResponse.error);
        this.cuenta = res.data.eResponse.cuenta;
      } catch (e) {
        this.error = e.message;
      }
    },
    async consultarPropietarios() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'consultarPropietarios',
            params: {
              cvecuenta: this.cuenta.cvecuenta
            }
          }
        });
        if (res.data.eResponse.error) throw new Error(res.data.eResponse.error);
        this.propietarios = res.data.eResponse.propietarios;
      } catch (e) {
        this.error = e.message;
      }
    },
    async consultarLiquidacion() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'consultarLiquidacion',
            params: {
              cvecuenta: this.cuenta.cvecuenta
            }
          }
        });
        if (res.data.eResponse.error) throw new Error(res.data.eResponse.error);
        this.liquidacion = res.data.eResponse.liquidacion;
      } catch (e) {
        this.error = e.message;
      }
    }
  },
  filters: {
    currency(val) {
      if (!val) return '$0.00';
      return '$' + parseFloat(val).toFixed(2);
    }
  }
};
</script>

<style scoped>
.sgcv2-formulario {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
