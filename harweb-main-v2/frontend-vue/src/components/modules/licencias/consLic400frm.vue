<template>
  <div class="container mt-4">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'Lic400Root',
};
</script>

<!--
Below are two separate Vue components for the two pages (Datos de la licencia y Pagos).
Assume these are registered in the router as:
  /lic400/datos  -> Lic400Datos.vue
  /lic400/pagos  -> Lic400Pagos.vue
-->

<!-- Lic400Datos.vue -->
<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Licencia 400</li>
      </ol>
    </nav>
    <h2 class="mb-4 text-center">CONSULTA DE LICENCIAS DEL AS/400</h2>
    <form @submit.prevent="buscarLicencia" class="form-inline mb-3 justify-content-center">
      <div class="form-group mr-2">
        <label for="licencia" class="mr-2">Licencia</label>
        <input type="number" v-model="licencia" id="licencia" class="form-control" required autofocus @keyup.enter="buscarLicencia" />
      </div>
      <button type="submit" class="btn btn-primary">Buscar</button>
    </form>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="licData">
      <table class="table table-bordered table-sm">
        <tbody>
          <tr><th>Recaud</th><td>{{ licData.ofna }}</td><th>Licencia</th><td>{{ licData.numlic }}</td><th>RFC</th><td>{{ licData.inirfc }}{{ licData.fnarfc }}</td><th>Homonimia</th><td>{{ licData.homono }}</td><th>Dighom</th><td>{{ licData.dighom }}</td></tr>
          <tr><th>Codgir</th><td>{{ licData.codgir }}</td><th>Ilgir1</th><td colspan="3">{{ licData.ilgir1 }}</td></tr>
          <tr><th>Ilgir2</th><td colspan="3">{{ licData.ilgir2 }}</td></tr>
          <tr><th>Ilgir3</th><td colspan="3">{{ licData.ilgir3 }}</td></tr>
          <tr><th>Nocars</th><td>{{ licData.nocars }}</td><th>Nugrub</th><td>{{ licData.nugrub }}</td></tr>
          <tr><th>Nomcal</th><td colspan="3">{{ licData.nomcal }}</td><th>Num. Ext.</th><td>{{ licData.nuext }}</td></tr>
          <tr><th>Letext</th><td>{{ licData.letext }}</td><th>Numint</th><td>{{ licData.numint }}</td><th>Letint</th><td>{{ licData.letint }}</td><th>Piso</th><td>{{ licData.piso }}</td></tr>
          <tr><th>Letsec</th><td>{{ licData.letsec }}</td><th>Numzon</th><td>{{ licData.numzon }}</td><th>Zonpos</th><td>{{ licData.zonpos }}</td></tr>
          <tr><th>Fecalt</th><td>{{ licData.fecalt }}</td><th>Fecbaj</th><td>{{ licData.fecbaj }}</td></tr>
          <tr><th>Tomesu</th><td>{{ licData.tomesu }}</td><th>Numanu</th><td>{{ licData.numanu }}</td><th>Nuayt</th><td>{{ licData.nuayt }}</td><th>Reint</th><td>{{ licData.reint }}</td><th>Reclt</th><td>{{ licData.reclt }}</td><th>Imlit</th><td>{{ licData.imlit }}</td></tr>
          <tr><th>Liimt</th><td>{{ licData.liimt }}</td><th>Vigenc</th><td>{{ licData.vigenc }}</td><th>Actgrl</th><td>{{ licData.actgrl }}</td><th>Grabo</th><td>{{ licData.grabo }}</td><th>Resta</th><td>{{ licData.resta }}</td><th>Fut1</th><td>{{ licData.fut1 }}</td><th>Fut2</th><td>{{ licData.fut2 }}</td></tr>
        </tbody>
      </table>
      <router-link :to="'/lic400/pagos?numlic=' + licData.numlic" class="btn btn-secondary mt-2">Ver Pagos</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Lic400Datos',
  data() {
    return {
      licencia: '',
      licData: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarLicencia() {
      this.error = '';
      this.licData = null;
      if (!this.licencia) {
        this.error = 'Ingrese el número de licencia';
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'getLic400',
          params: { licencia: this.licencia }
        });
        if (res.data.eResponse.success && res.data.eResponse.data.length > 0) {
          this.licData = res.data.eResponse.data[0];
        } else {
          this.error = 'No se encontró la licencia.';
        }
      } catch (e) {
        this.error = 'Error al consultar la licencia.';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<!-- Lic400Pagos.vue -->
<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item"><router-link to="/lic400/datos">Consulta Licencia 400</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos</li>
      </ol>
    </nav>
    <h2 class="mb-4 text-center">Pagos de Licencia 400</h2>
    <form @submit.prevent="buscarPagos" class="form-inline mb-3 justify-content-center">
      <div class="form-group mr-2">
        <label for="numlic" class="mr-2">Licencia</label>
        <input type="number" v-model="numlic" id="numlic" class="form-control" required autofocus @keyup.enter="buscarPagos" />
      </div>
      <button type="submit" class="btn btn-primary">Buscar Pagos</button>
    </form>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="pagos && pagos.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th v-for="(v, k) in pagos[0]" :key="k">{{ k }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(pago, idx) in pagos" :key="idx">
            <td v-for="(v, k) in pago" :key="k">{{ v }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="pagos && !pagos.length" class="alert alert-info">No hay pagos registrados para esta licencia.</div>
  </div>
</template>

<script>
export default {
  name: 'Lic400Pagos',
  data() {
    return {
      numlic: this.$route.query.numlic || '',
      pagos: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarPagos() {
      this.error = '';
      this.pagos = null;
      if (!this.numlic) {
        this.error = 'Ingrese el número de licencia';
        return;
      }
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'getPagoLic400',
          params: { numlic: this.numlic }
        });
        if (res.data.eResponse.success) {
          this.pagos = res.data.eResponse.data;
        } else {
          this.error = 'No se encontraron pagos.';
        }
      } catch (e) {
        this.error = 'Error al consultar los pagos.';
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    if (this.numlic) {
      this.buscarPagos();
    }
  }
};
</script>
