<template>
  <div class="rpagados-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagados</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">Pagados</h5>
        <button class="btn btn-secondary" @click="goBack">
          <i class="fa fa-sign-out-alt"></i> Salir
        </button>
      </div>
      <div class="card-body">
        <form @submit.prevent="fetchPagados">
          <div class="form-group row">
            <label for="p_Control" class="col-sm-2 col-form-label">ID Control</label>
            <div class="col-sm-4">
              <input type="number" v-model.number="p_Control" id="p_Control" class="form-control" required />
            </div>
            <div class="col-sm-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="pagados.length > 0" class="table-responsive mt-3">
          <table class="table table-bordered table-hover">
            <thead class="thead-light">
              <tr>
                <th>ID Pago</th>
                <th>ID Datos</th>
                <th>Periodo</th>
                <th>Importe</th>
                <th>Recargo</th>
                <th>Fecha/Hora Pago</th>
                <th>ID Recaudadora</th>
                <th>Caja</th>
                <th>Operación</th>
                <th>Folio Recibo</th>
                <th>Usuario</th>
                <th>ID Status</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in pagados" :key="row.id_34_pagos">
                <td>{{ row.id_34_pagos }}</td>
                <td>{{ row.id_datos }}</td>
                <td>{{ formatDate(row.periodo) }}</td>
                <td>{{ formatCurrency(row.importe) }}</td>
                <td>{{ formatCurrency(row.recargo) }}</td>
                <td>{{ formatDateTime(row.fecha_hora_pago) }}</td>
                <td>{{ row.id_recaudadora }}</td>
                <td>{{ row.caja }}</td>
                <td>{{ row.operacion }}</td>
                <td>{{ row.folio_recibo }}</td>
                <td>{{ row.usuario }}</td>
                <td>{{ row.id_stat }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div v-else-if="!loading && pagados.length === 0 && searched" class="alert alert-info mt-3">
          No se encontraron registros para el ID Control ingresado.
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RPagadosPage',
  data() {
    return {
      p_Control: '',
      pagados: [],
      loading: false,
      error: '',
      searched: false
    };
  },
  methods: {
    fetchPagados() {
      this.error = '';
      this.pagados = [];
      this.loading = true;
      this.searched = false;
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            operation: 'getPagadosByControl',
            params: {
              p_Control: this.p_Control
            }
          }
        })
      })
        .then(async response => {
          const data = await response.json();
          if (data.eResponse && data.eResponse.success) {
            this.pagados = data.eResponse.data;
            this.searched = true;
          } else {
            this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
            this.searched = true;
          }
        })
        .catch(err => {
          this.error = 'Error de comunicación con el servidor';
          this.searched = true;
        })
        .finally(() => {
          this.loading = false;
        });
    },
    goBack() {
      this.$router.back();
    },
    formatDate(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString();
    },
    formatDateTime(dateStr) {
      if (!dateStr) return '';
      const d = new Date(dateStr);
      return d.toLocaleDateString() + ' ' + d.toLocaleTimeString();
    },
    formatCurrency(val) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpagados-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card-header h5 {
  margin-bottom: 0;
}
.table th, .table td {
  vertical-align: middle;
  font-size: 0.95rem;
}
</style>
