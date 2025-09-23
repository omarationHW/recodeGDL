<template>
  <div class="adeudo-corte-manzana-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Corte por Manzana</li>
      </ol>
    </nav>
    <h1>Reporte de Adeudo Corte por Manzana</h1>
    <form @submit.prevent="fetchReporte">
      <div class="row">
        <div class="col-md-3">
          <label>Subtipo</label>
          <select v-model="form.subtipo" class="form-control" required>
            <option v-for="st in subtipoOptions" :key="st.value" :value="st.value">{{ st.label }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Fecha Desde</label>
          <input type="date" v-model="form.fechadsd" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Fecha Hasta</label>
          <input type="date" v-model="form.fechahst" class="form-control" required />
        </div>
        <div class="col-md-3">
          <label>Estado</label>
          <select v-model="form.est" class="form-control">
            <option value="A">Vigentes</option>
            <option value="B">Dados de Baja</option>
            <option value="P">Pagados</option>
          </select>
        </div>
      </div>
      <div class="row mt-3">
        <div class="col-md-3">
          <label>Tipo de Reporte</label>
          <select v-model="form.rep" class="form-control">
            <option value="1">Adeudos</option>
            <option value="2">Saldos a Favor</option>
            <option value="3">Liquidados</option>
          </select>
        </div>
        <div class="col-md-9 d-flex align-items-end">
          <button type="submit" class="btn btn-primary mr-2">Consultar</button>
          <button type="button" class="btn btn-success mr-2" @click="exportar('excel')">Exportar Excel</button>
          <button type="button" class="btn btn-danger" @click="exportar('pdf')">Exportar PDF</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="mt-4">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>
    <div v-if="reporte.length" class="mt-4">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Num. Ext.</th>
            <th>Costo Total</th>
            <th>Pagos</th>
            <th>Recargos</th>
            <th>Saldo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reporte" :key="row.id_conv_predio">
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letracomp }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num_exterior }}</td>
            <td>{{ currency(row.cantidad_total) }}</td>
            <td>{{ currency(row.pagos) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.cantidad_total - row.pagos) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudoCorteManzanaPage',
  data() {
    return {
      form: {
        subtipo: '',
        fechadsd: '',
        fechahst: '',
        rep: 1,
        est: 'A'
      },
      subtipoOptions: [],
      reporte: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.loadSubtipos();
  },
  methods: {
    async loadSubtipos() {
      // Simulación: en producción, cargar desde API
      this.subtipoOptions = [
        { value: 1, label: 'Subtipo 1' },
        { value: 2, label: 'Subtipo 2' }
      ];
      this.form.subtipo = this.subtipoOptions[0].value;
    },
    async fetchReporte() {
      this.loading = true;
      this.error = '';
      this.reporte = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getAdeudoCorteManzana',
            params: { ...this.form }
          }
        });
        if (res.data.eResponse.success) {
          this.reporte = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error desconocido';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    },
    async exportar(tipo) {
      // tipo: 'excel' | 'pdf'
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'exportAdeudoCorteManzana',
            params: { ...this.form, tipo }
          }
        });
        if (res.data.eResponse.success) {
          window.open(res.data.eResponse.data.url, '_blank');
        } else {
          this.error = res.data.eResponse.message || 'Error al exportar';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      }
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.adeudo-corte-manzana-page {
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
