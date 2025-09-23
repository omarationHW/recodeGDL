<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Consulta Histórica de Cuenta</li>
      </ol>
    </nav>
    <h2>Consulta Histórica de Cuenta</h2>
    <div class="form-group">
      <label for="cvecuenta">Clave de Cuenta</label>
      <input v-model="cvecuenta" id="cvecuenta" class="form-control" placeholder="Ingrese clave de cuenta" />
      <button class="btn btn-primary mt-2" @click="buscarCuenta">Buscar</button>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="cuenta">
      <h4>Datos Generales</h4>
      <table class="table table-bordered">
        <tr><th>Cuenta</th><td>{{ cuenta.cuenta }}</td></tr>
        <tr><th>Clave Catastral</th><td>{{ cuenta.cvecatnva }}</td></tr>
        <tr><th>Subpredio</th><td>{{ cuenta.subpredio }}</td></tr>
        <tr><th>Recaudadora</th><td>{{ cuenta.recaud }}</td></tr>
        <tr><th>Urbano/Rústico</th><td>{{ cuenta.urbrus }}</td></tr>
        <tr><th>Asiento</th><td>{{ cuenta.asiento }}</td></tr>
        <tr><th>Movimiento</th><td>{{ cuenta.cmovto }}</td></tr>
        <tr><th>Observaciones</th><td>{{ cuenta.observacion }}</td></tr>
      </table>
      <div class="mt-4">
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('ubicacion')">Ubicación</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('regimen')">Régimen de Propiedad</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('valores')">Valores</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('pagos')">Pagos</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('diferencias')">Diferencias</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('obs400')">Obs. AS-400</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('cfs400')">C/F's</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('escrituras')">Escrituras</button>
        <button class="btn btn-outline-secondary mr-2" @click="verPagina('condominio')">Condominio</button>
      </div>
      <component :is="paginaActual" :cvecuenta="cvecuenta" :cvecatnva="cuenta.cvecatnva" />
    </div>
  </div>
</template>

<script>
import UbicacionPage from './PropuestaTab1Ubicacion.vue';
import RegimenPage from './PropuestaTab1Regimen.vue';
import ValoresPage from './PropuestaTab1Valores.vue';
import PagosPage from './PropuestaTab1Pagos.vue';
import DiferenciasPage from './PropuestaTab1Diferencias.vue';
import Obs400Page from './PropuestaTab1Obs400.vue';
import Cfs400Page from './PropuestaTab1Cfs400.vue';
import EscriturasPage from './PropuestaTab1Escrituras.vue';
import CondominioPage from './PropuestaTab1Condominio.vue';

export default {
  name: 'PropuestaTab1',
  components: {
    ubicacion: UbicacionPage,
    regimen: RegimenPage,
    valores: ValoresPage,
    pagos: PagosPage,
    diferencias: DiferenciasPage,
    obs400: Obs400Page,
    cfs400: Cfs400Page,
    escrituras: EscriturasPage,
    condominio: CondominioPage
  },
  data() {
    return {
      cvecuenta: '',
      cuenta: null,
      loading: false,
      error: '',
      paginaActual: null
    }
  },
  methods: {
    async buscarCuenta() {
      this.loading = true;
      this.error = '';
      this.cuenta = null;
      this.paginaActual = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'show',
            params: { cvecuenta: this.cvecuenta }
          }
        });
        if (res.data.eResponse.success) {
          this.cuenta = res.data.eResponse.data[0];
        } else {
          this.error = res.data.eResponse.message || 'No se encontró la cuenta';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    verPagina(pagina) {
      this.paginaActual = pagina;
    }
  }
}
</script>

<style scoped>
.breadcrumb {
  background: #f8f9fa;
}
</style>
