<template>
  <div class="page-container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Parcialidades Vencidas Convenios Diversos</li>
      </ol>
    </nav>
    <h1>Reporte de Parcialidades Vencidas de Convenios Diversos</h1>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label for="tipo">Tipo</label>
          <input v-model="form.tipo" type="number" class="form-control" id="tipo" required>
        </div>
        <div class="form-group col-md-2">
          <label for="subtipo">Subtipo</label>
          <input v-model="form.subtipo" type="number" class="form-control" id="subtipo" required>
        </div>
        <div class="form-group col-md-3">
          <label for="fechahst">Fecha Hasta</label>
          <input v-model="form.fechahst" type="date" class="form-control" id="fechahst" required>
        </div>
        <div class="form-group col-md-2">
          <label for="letras">Zona (Letras)</label>
          <select v-model="form.letras" class="form-control" id="letras" required>
            <option value="ZC1">ZONA CENTRO</option>
            <option value="ZO2">ZONA OLIMPICA</option>
            <option value="ZO3">ZONA OBLATOS</option>
            <option value="ZM4">ZONA MINERVA</option>
            <option value="ZC5">ZONA CRUZ DEL SUR</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="est">Estado</label>
          <select v-model="form.est" class="form-control" id="est" required>
            <option value="A">VIGENTES</option>
            <option value="B">DADOS DE BAJA</option>
            <option value="P">PAGADOS</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Generar Reporte</button>
      <button type="button" class="btn btn-success ml-2" @click="exportExcel" :disabled="loading">Exportar Excel</button>
    </form>
    <div v-if="loading" class="mt-3 alert alert-info">Cargando...</div>
    <div v-if="error" class="mt-3 alert alert-danger">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>Oficio</th>
            <th>Nombre</th>
            <th>Costo</th>
            <th>Pagos al Corriente</th>
            <th>Pagos Vencidos</th>
            <th>Recargos</th>
            <th>Pagos Realizados</th>
            <th>Adeudo por Cobrar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_conv_diver">
            <td>{{ row.oficio }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ currency(row.costo) }}</td>
            <td>{{ row.parcpag }}</td>
            <td>{{ row.venc == 2 ? row.parcpag : '' }}</td>
            <td>{{ row.venc == 2 ? currency(row.recargos) : '' }}</td>
            <td>{{ currency(row.pagos) }}</td>
            <td>{{ row.venc == 3 ? currency(row.adeudos) : '' }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ParcialidadesVencidasConvDiversos',
  data() {
    return {
      form: {
        tipo: '',
        subtipo: '',
        fechahst: '',
        letras: 'ZC1',
        est: 'A'
      },
      report: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getReport',
          params: this.form
        });
        if (res.data.status === 'success') {
          this.report = res.data.data;
        } else {
          this.error = res.data.message || 'Error al obtener el reporte';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'exportExcel',
          params: this.form
        });
        // Aquí deberías manejar la descarga del archivo Excel
        // Por simplicidad, mostramos los datos
        alert('Excel exportado (simulado).');
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
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
.page-container {
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
