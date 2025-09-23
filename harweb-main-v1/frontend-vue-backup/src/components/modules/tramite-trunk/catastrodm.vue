<template>
  <div class="catastro-formulario">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catastro</li>
      </ol>
    </nav>
    <h1>Catastro - Consulta y Gestión</h1>
    <form @submit.prevent="buscarCuenta">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="recaud">Recaudadora</label>
          <input v-model="form.recaud" type="number" class="form-control" id="recaud" required />
        </div>
        <div class="form-group col-md-2">
          <label for="urbrus">Urb/Rus</label>
          <select v-model="form.urbrus" class="form-control" id="urbrus" required>
            <option value="U">Urbano</option>
            <option value="R">Rústico</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="cuenta">Cuenta</label>
          <input v-model="form.cuenta" type="number" class="form-control" id="cuenta" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="catastro">
      <h2>Datos de la Cuenta</h2>
      <table class="table table-bordered">
        <tr><th>CveCuenta</th><td>{{ catastro.cvecuenta }}</td></tr>
        <tr><th>Clave Catastral</th><td>{{ convcta.cvecatnva }}</td></tr>
        <tr><th>Subpredio</th><td>{{ convcta.subpredio }}</td></tr>
        <tr><th>Vigente</th><td>{{ convcta.vigente }}</td></tr>
        <tr><th>Asiento</th><td>{{ catastro.asiento }}</td></tr>
        <tr><th>Observación</th><td>{{ catastro.observacion }}</td></tr>
      </table>
      <h3>Propietarios</h3>
      <table class="table table-sm table-striped">
        <thead>
          <tr>
            <th>Nombre</th>
            <th>Porcentaje</th>
            <th>Encabeza</th>
            <th>Exento</th>
            <th>Vigencia</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="reg in regprop" :key="reg.cvecont">
            <td>{{ reg.nombre_completo }}</td>
            <td>{{ reg.porcentaje }}%</td>
            <td>{{ reg.encabeza }}</td>
            <td>{{ reg.exento }}</td>
            <td>{{ reg.vigencia }}</td>
          </tr>
        </tbody>
      </table>
      <h3>Saldos</h3>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Año</th>
            <th>Impuesto</th>
            <th>Recargos</th>
            <th>Total</th>
            <th>Saldo Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="saldo in saldos" :key="saldo.anio">
            <td>{{ saldo.anio }}</td>
            <td>{{ saldo.impfac }}</td>
            <td>{{ saldo.recfac }}</td>
            <td>{{ saldo.total }}</td>
            <td>{{ saldo.saldototal }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-success" @click="abrirExento">Exentar</button>
      <button class="btn btn-warning" @click="abrirModificarPropietario">Modificar Propietario</button>
    </div>
    <exento-modal v-if="showExento" :cvecuenta="catastro.cvecuenta" @close="showExento = false" @updated="onUpdated" />
    <modificar-propietario-modal v-if="showModificarPropietario" :cvecuenta="catastro.cvecuenta" @close="showModificarPropietario = false" @updated="onUpdated" />
  </div>
</template>

<script>
import ExentoModal from './ExentoModal.vue';
import ModificarPropietarioModal from './ModificarPropietarioModal.vue';
export default {
  name: 'CatastroFormulario',
  components: { ExentoModal, ModificarPropietarioModal },
  data() {
    return {
      form: {
        recaud: '',
        urbrus: 'U',
        cuenta: ''
      },
      loading: false,
      error: '',
      catastro: null,
      convcta: {},
      regprop: [],
      saldos: [],
      showExento: false,
      showModificarPropietario: false
    };
  },
  methods: {
    async buscarCuenta() {
      this.loading = true;
      this.error = '';
      this.catastro = null;
      try {
        // 1. Buscar convcta
        let resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getConvctaByCuenta',
            params: {
              recaud: this.form.recaud,
              urbrus: this.form.urbrus,
              cuenta: this.form.cuenta
            }
          }
        });
        if (!resp.data.eResponse.success || !resp.data.eResponse.data.length) {
          this.error = 'Cuenta no encontrada';
          this.loading = false;
          return;
        }
        this.convcta = resp.data.eResponse.data[0];
        // 2. Buscar catastro
        resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getCatastroByCuenta',
            params: { cvecuenta: this.convcta.cvecuenta }
          }
        });
        if (!resp.data.eResponse.success || !resp.data.eResponse.data.length) {
          this.error = 'No se encontró información de catastro';
          this.loading = false;
          return;
        }
        this.catastro = resp.data.eResponse.data[0];
        // 3. Buscar regprop
        resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getRegpropByCuenta',
            params: {
              cvecuenta: this.convcta.cvecuenta,
              cveregprop: this.catastro.cveregprop
            }
          }
        });
        this.regprop = resp.data.eResponse.data || [];
        // 4. Buscar saldos
        resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getSaldosByCuenta',
            params: { cvecuenta: this.convcta.cvecuenta }
          }
        });
        this.saldos = resp.data.eResponse.data || [];
      } catch (e) {
        this.error = 'Error al consultar: ' + (e.response?.data?.eResponse?.message || e.message);
      } finally {
        this.loading = false;
      }
    },
    abrirExento() {
      this.showExento = true;
    },
    abrirModificarPropietario() {
      this.showModificarPropietario = true;
    },
    onUpdated() {
      this.buscarCuenta();
    }
  }
};
</script>

<style scoped>
.catastro-formulario {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
