<template>
  <div class="rpt-pagos-capturados-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos Capturados</li>
      </ol>
    </nav>
    <h1>Reporte de Pagos Capturados - Regularización de Predios</h1>
    <form @submit.prevent="fetchPagos">
      <div class="form-group">
        <label for="subtipo">Subtipo de Regularización</label>
        <select v-model="subtipo" id="subtipo" class="form-control" required>
          <option value="">Seleccione...</option>
          <option v-for="item in subtipos" :key="item.value" :value="item.value">
            {{ item.label }}
          </option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>
    <div v-if="loading" class="mt-3">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="pagos.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Oficina</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Parcialidad</th>
            <th>Importe Pago</th>
            <th>Recargo</th>
            <th>Venc</th>
            <th>Desc</th>
            <th>Dev</th>
            <th>Usuario</th>
            <th>Actualización</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in pagos" :key="row.id_conv_pago">
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letracomp }}</td>
            <td>{{ row.oficina_pago }}</td>
            <td>{{ row.caja_pago }}</td>
            <td>{{ row.operacion_pago }}</td>
            <td>{{ row.parcialidad }}</td>
            <td>{{ row.importe_pago | currency }}</td>
            <td>{{ row.importe_recargo | currency }}</td>
            <td>{{ row.cve_venc }}</td>
            <td>{{ row.cve_descuento }}</td>
            <td>{{ row.cve_bonificacion }}</td>
            <td>{{ row.usuario }}</td>
            <td>{{ row.fecha_actual | datetime }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptPagosCapturadosPage',
  data() {
    return {
      subtipo: '',
      subtipos: [
        { value: 1, label: 'Predios Urbanos' },
        { value: 2, label: 'Predios Rústicos' },
        // ... completar según catálogo
      ],
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
          eRequest: {
            action: 'getPagosCapturados',
            params: { subtipo: this.subtipo }
          }
        });
        if (response.data.eResponse.success) {
          this.pagos = response.data.eResponse.data;
        } else {
          this.error = response.data.eResponse.message || 'Error al consultar pagos.';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    datetime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString('es-MX');
    }
  }
};
</script>

<style scoped>
.rpt-pagos-capturados-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
