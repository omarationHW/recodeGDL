<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Ingreso Captura</h1>
        <p>Mercados - Ingreso Captura</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Ingreso Capturado por Fecha de Pago</h1>
    <form @submit.prevent="fetchIngresoCaptura">
      <div class="row mb-3">
        <div class="col-md-2">
          <label>Número de Mercado</label>
          <input v-model.number="form.num_mercado" type="number" class="municipal-form-control" required />
        </div>
        <div class="col-md-2">
          <label>Fecha Pago</label>
          <input v-model="form.fecha_pago" type="date" class="municipal-form-control" required />
        </div>
        <div class="col-md-2">
          <label>Oficina Pago</label>
          <input v-model.number="form.oficina_pago" type="number" class="municipal-form-control" required />
        </div>
        <div class="col-md-2">
          <label>Caja Pago</label>
          <input v-model="form.caja_pago" type="text" maxlength="1" class="municipal-form-control" required />
        </div>
        <div class="col-md-2">
          <label>Operación Pago</label>
          <input v-model.number="form.operacion_pago" type="number" class="municipal-form-control" required />
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button class="btn btn-primary w-100" type="submit">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="results && results.length">
      <table class="table table-striped table-bordered mt-3">
        <thead>
          <tr>
            <th>Fecha Pago</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Periodos</th>
            <th>Renta Pagada</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in results" :key="row.fecha_pago + '-' + row.caja_pago + '-' + row.operacion_pago">
            <td>{{ row.fecha_pago }}</td>
            <td>{{ row.caja_pago }}</td>
            <td>{{ row.operacion_pago }}</td>
            <td>{{ row.pagos }}</td>
            <td>{{ row.importe | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else-if="results && !results.length" class="alert alert-warning">No hay resultados para los filtros seleccionados.</div>
    <div class="mt-4">
      <router-link class="btn-municipal-secondary" to="/">Regresar</router-link>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'IngresoCapturaPage',
  data() {
    return {
      form: {
        num_mercado: '',
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      },
      loading: false,
      error: '',
      results: null
    };
  },
  methods: {
    async fetchIngresoCaptura() {
      this.loading = true;
      this.error = '';
      this.results = null;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            action: 'getIngresoCaptura',
            params: { ...this.form }
          })
        });
        const data = await response.json();
        if (data.success) {
          this.results = data.data;
        } else {
          this.error = data.message || 'Error al consultar los datos.';
        }
      } catch (e) {
        this.error = e.message || 'Error de red.';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(value) {
      if (typeof value !== 'number') return value;
      return '$' + value.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.ingreso-captura-page {
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
