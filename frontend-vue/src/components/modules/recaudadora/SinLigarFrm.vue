<template>
  <div class="sinligar-page">
    <nav aria-label="breadcrumb" class="mb-4">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos Transmisiones Sin Ligar</li>
      </ol>
    </nav>
    <h1 class="mb-3">Listado de Pagos de Transmisiones Pat. sin ligar a Cuenta Predial</h1>
    <form @submit.prevent="fetchPagos" class="mb-4">
      <div class="row g-3 align-items-end">
        <div class="col-auto">
          <label for="fecha1" class="form-label">Fecha Desde</label>
          <input type="date" v-model="fecha1" id="fecha1" class="form-control" required />
        </div>
        <div class="col-auto">
          <label for="fecha2" class="form-label">Fecha Hasta</label>
          <input type="date" v-model="fecha2" id="fecha2" class="form-control" required />
        </div>
        <div class="col-auto">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="pagos && pagos.length > 0">
      <table class="table table-bordered table-sm mt-3">
        <thead>
          <tr>
            <th>Ofna</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Fecha</th>
            <th>Importe</th>
            <th>Contribuyente</th>
            <th>Concepto</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.cvepago">
            <td>{{ pago.recaud }}</td>
            <td>{{ pago.caja }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ pago.fecha ? pago.fecha.substring(0, 10) : '' }}</td>
            <td class="text-end">{{ pago.importe | currency }}</td>
            <td>{{ pago.contribuyente }}</td>
            <td style="white-space: pre-line; max-width: 300px;">{{ pago.concepto }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total registros:</strong> {{ pagos.length }}
      </div>
    </div>
    <div v-else-if="pagos && pagos.length === 0 && !loading">
      <div class="alert alert-warning">No se encuentra información con esas fechas.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'SinLigarPagosPage',
  data() {
    const today = new Date();
    const fecha2 = today.toISOString().substring(0, 10);
    const fecha1 = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000)
      .toISOString()
      .substring(0, 10);
    return {
      fecha1,
      fecha2,
      pagos: null,
      loading: false,
      error: null
    };
  },
  methods: {
    async fetchPagos() {
      this.loading = true;
      this.error = null;
      this.pagos = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            Accept: 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              operation: 'getSinLigarPagos',
              params: {
                fecha1: this.fecha1,
                fecha2: this.fecha2
              }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.success) {
          this.pagos = json.eResponse.data;
        } else {
          this.error = json.eResponse && json.eResponse.error
            ? json.eResponse.error
            : 'Error desconocido al consultar pagos.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(value) {
      if (typeof value !== 'number') return value;
      return value.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  mounted() {
    this.fetchPagos();
  }
};
</script>

<style scoped>
.sinligar-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table td {
  vertical-align: middle;
}
</style>
