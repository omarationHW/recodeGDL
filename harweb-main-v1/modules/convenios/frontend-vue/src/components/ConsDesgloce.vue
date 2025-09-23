<template>
  <div class="cons-desgloce-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Desgloce de Cuentas</li>
      </ol>
    </nav>
    <h1>Consulta Desgloce de Cuentas de Aplicación</h1>
    <form @submit.prevent="buscarDesgloce">
      <div class="form-group row">
        <label for="id_adeudo" class="col-sm-2 col-form-label">ID Adeudo</label>
        <div class="col-sm-4">
          <input type="number" v-model="id_adeudo" class="form-control" id="id_adeudo" required />
        </div>
        <div class="col-sm-2">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="my-3">
      <span class="spinner-border spinner-border-sm"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="desgloce.length > 0">
      <table class="table table-bordered table-striped mt-4">
        <thead>
          <tr>
            <th>Parcialidad</th>
            <th>Importe</th>
            <th>Cuenta</th>
            <th>Descripción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in desgloce" :key="row.id_desgloce">
            <td class="text-center">{{ row.pago_parcial }}</td>
            <td class="text-right">{{ formatCurrency(row.importe) }}</td>
            <td class="text-center">{{ row.cuenta_apl }}</td>
            <td>{{ row.descripcion }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && !error">
      <p class="text-muted">No hay datos para mostrar.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsDesglocePage',
  data() {
    return {
      id_adeudo: '',
      desgloce: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    buscarDesgloce() {
      this.loading = true;
      this.error = '';
      this.desgloce = [];
      this.$axios.post('/api/execute', {
        eRequest: {
          action: 'getDesgloce',
          params: { id_adeudo: this.id_adeudo }
        }
      })
      .then(resp => {
        if (resp.data.eResponse.success) {
          this.desgloce = resp.data.eResponse.data;
        } else {
          this.error = resp.data.eResponse.message || 'Error desconocido';
        }
      })
      .catch(err => {
        this.error = err.response?.data?.eResponse?.message || err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.cons-desgloce-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
