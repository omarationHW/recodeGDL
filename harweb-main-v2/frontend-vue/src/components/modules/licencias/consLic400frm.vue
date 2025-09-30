<template>
  <div class="municipal-page">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'Lic400Root',
};
</script>

<style scoped>
.municipal-page {
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
  padding: 1.5rem;
}
</style>

<!--
Below are two separate Vue components for the two pages (Datos de la licencia y Pagos).
Assume these are registered in the router as:
  /lic400/datos  -> Lic400Datos.vue
  /lic400/pagos  -> Lic400Pagos.vue
-->

<!-- Lic400Datos.vue -->
<template>
  <div class="municipal-page">
    <!-- Municipal Header -->
    <div class="municipal-header">
      <div class="row align-items-center">
        <div class="col">
          <h2 class="municipal-title">
            <i class="fas fa-file-contract"></i>
            CONSULTA DE LICENCIAS DEL AS/400
          </h2>
          <p class="municipal-subtitle mb-0">
            Sistema de consulta de licencias del mainframe AS/400
          </p>
        </div>
      </div>
    </div>

    <nav aria-label="breadcrumb" class="municipal-breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/" class="text-decoration-none">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta Licencia 400</li>
      </ol>
    </nav>
    <!-- Municipal Search Form -->
    <div class="municipal-card mb-4">
      <div class="card-body">
        <form @submit.prevent="buscarLicencia" class="municipal-form">
          <div class="row justify-content-center align-items-end">
            <div class="col-md-4">
              <label for="licencia" class="form-label municipal-label">
                <i class="fas fa-search"></i> Número de Licencia:
              </label>
              <input
                type="number"
                v-model="licencia"
                id="licencia"
                class="form-control municipal-input"
                required
                autofocus
                @keyup.enter="buscarLicencia"
                placeholder="Ingrese número de licencia"
              />
            </div>
            <div class="col-md-3">
              <div class="btn-group municipal-group-btn" role="group">
                <button type="submit" class="btn btn-primary municipal-btn-primary" :disabled="loading">
                  <i class="fas fa-search"></i>
                  <span v-if="loading">Buscando...</span>
                  <span v-else>Buscar</span>
                </button>
              </div>
            </div>
          </div>
        </form>
      </div>
    </div>
    <!-- Municipal Loading and Error States -->
    <div v-if="loading" class="alert alert-info municipal-alert">
      <i class="fas fa-spinner fa-spin"></i> Cargando datos de la licencia...
    </div>

    <div v-if="error" class="alert alert-danger municipal-alert">
      <i class="fas fa-exclamation-triangle"></i> {{ error }}
    </div>

    <!-- Municipal Results -->
    <div v-if="licData" class="municipal-card">
      <div class="card-header municipal-table-header">
        <h5 class="mb-0">
          <i class="fas fa-file-contract"></i>
          Datos de la Licencia {{ licData.numlic }}
        </h5>
      </div>
      <div class="card-body p-0">
        <div class="table-responsive">
          <table class="table table-sm municipal-table">
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
        </div>
      </div>
      <div class="card-footer municipal-card-footer">
        <router-link :to="'/lic400/pagos?numlic=' + licData.numlic" class="btn btn-primary municipal-btn-primary">
          <i class="fas fa-money-bill-wave"></i>
          Ver Pagos
        </router-link>
      </div>
    </div>
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
