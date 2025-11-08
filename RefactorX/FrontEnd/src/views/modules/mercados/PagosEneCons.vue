<template>
  <div class="pagos-ene-cons-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos Energía Eléctrica</li>
      </ol>
    </nav>
    <h2>Consulta de Pagos de Energía Eléctrica</h2>
    <div class="card mb-3">
      <div class="card-body">
        <form @submit.prevent="fetchPagos">
          <div class="row g-2 align-items-end">
            <div class="col-md-4">
              <label for="id_energia" class="form-label">ID Energía</label>
              <input v-model="form.id_energia" type="number" class="form-control" id="id_energia" required />
            </div>
            <div class="col-md-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="pagos.length">
      <table class="table table-striped table-bordered">
        <thead>
          <tr>
            <th>Control</th>
            <th>Año</th>
            <th>Mes</th>
            <th>Fecha</th>
            <th>Rec</th>
            <th>Caja</th>
            <th>Oper.</th>
            <th>Importe</th>
            <th>Partida</th>
            <th>Actualización</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.id_pago_energia">
            <td>{{ pago.id_energia }}</td>
            <td>{{ pago.axo }}</td>
            <td>{{ pago.periodo }}</td>
            <td>{{ formatDate(pago.fecha_pago) }}</td>
            <td>{{ pago.oficina_pago }}</td>
            <td>{{ pago.caja_pago }}</td>
            <td>{{ pago.operacion_pago }}</td>
            <td>{{ pago.importe_pago | currency }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ formatDateTime(pago.fecha_modificacion) }}</td>
            <td>{{ pago.usuario }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="!loading && !error">
      <div class="alert alert-warning">No hay pagos registrados para este ID Energía.</div>
    </div>
    <div class="mt-4">
      <router-link class="btn btn-secondary" to="/">Regresar</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosEneConsPage',
  data() {
    return {
      form: {
        id_energia: ''
      },
      pagos: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      try {
        const response = await this.$axios.post('/api/execute', {
          action: 'getPagosEnergia',
          params: { id_energia: this.form.id_energia }
        });
        if (response.data.success) {
          this.pagos = response.data.data;
        } else {
          this.error = response.data.message || 'Error al consultar pagos.';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      return new Date(dateStr).toLocaleDateString();
    },
    formatDateTime(dateStr) {
      if (!dateStr) return '';
      return new Date(dateStr).toLocaleString();
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.pagos-ene-cons-page {
  max-width: 900px;
  margin: 0 auto;
}
</style>
