<template>
  <div class="reghfrm-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Registros Históricos</li>
      </ol>
    </nav>
    <h1>Registros Históricos de Cuenta Catastral</h1>
    <div class="form-group row">
      <label for="cvecuenta" class="col-sm-2 col-form-label">Cuenta Catastral</label>
      <div class="col-sm-4">
        <input v-model="cvecuenta" type="number" class="form-control" id="cvecuenta" placeholder="Ingrese número de cuenta" />
      </div>
      <div class="col-sm-2">
        <button class="btn btn-primary" @click="fetchHistory">Buscar</button>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="history.length">
      <h3>Historial de Movimientos</h3>
      <table class="table table-striped table-bordered">
        <thead>
          <tr>
            <th>Año</th>
            <th>No. Comp.</th>
            <th>Movimiento</th>
            <th>Fecha Captura</th>
            <th>Capturista</th>
            <th>Observación</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in history" :key="row.axocomp + '-' + row.nocomp">
            <td>{{ row.axocomp }}</td>
            <td>{{ row.nocomp }}</td>
            <td>{{ row.cvemov }}</td>
            <td>{{ row.feccap | date }}</td>
            <td>{{ row.capturista }}</td>
            <td>{{ row.observacion }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="showDetail(row)">Ver</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="selected">
      <h4>Detalle de Movimiento</h4>
      <table class="table table-sm table-bordered">
        <tr><th>Año</th><td>{{ selected.axocomp }}</td></tr>
        <tr><th>No. Comp.</th><td>{{ selected.nocomp }}</td></tr>
        <tr><th>Movimiento</th><td>{{ selected.cvemov }}</td></tr>
        <tr><th>Fecha Captura</th><td>{{ selected.feccap | date }}</td></tr>
        <tr><th>Capturista</th><td>{{ selected.capturista }}</td></tr>
        <tr><th>Observación</th><td>{{ selected.observacion }}</td></tr>
        <tr><th>Vigente</th><td>{{ selected.vigente }}</td></tr>
      </table>
      <button class="btn btn-secondary" @click="selected = null">Cerrar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RegHfrmPage',
  data() {
    return {
      cvecuenta: '',
      history: [],
      loading: false,
      error: '',
      selected: null
    };
  },
  methods: {
    async fetchHistory() {
      this.loading = true;
      this.error = '';
      this.history = [];
      this.selected = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'list',
            params: { cvecuenta: this.cvecuenta }
          }
        });
        if (resp.data.eResponse.success) {
          this.history = resp.data.eResponse.data;
        } else {
          this.error = resp.data.eResponse.message || 'Error al consultar.';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    async showDetail(row) {
      this.loading = true;
      this.error = '';
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'show',
            params: {
              cvecuenta: this.cvecuenta,
              axocomp: row.axocomp,
              nocomp: row.nocomp
            }
          }
        });
        if (resp.data.eResponse.success && resp.data.eResponse.data.length) {
          this.selected = resp.data.eResponse.data[0];
        } else {
          this.error = resp.data.eResponse.message || 'No se encontró el registro.';
        }
      } catch (e) {
        this.error = e.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  }
};
</script>

<style scoped>
.reghfrm-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
