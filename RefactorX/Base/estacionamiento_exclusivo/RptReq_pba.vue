<template>
  <div class="rptreq-pba-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Requerimiento de Pago y Embargo</li>
      </ol>
    </nav>
    <h1>Orden de Requerimiento de Pago y Embargo</h1>
    <form @submit.prevent="fetchReport">
      <div class="row">
        <div class="col-md-2">
          <label>Mercado Inicial</label>
          <input v-model.number="form.vmerc1" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Mercado Final</label>
          <input v-model.number="form.vmerc2" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Local Inicial</label>
          <input v-model.number="form.vlocal1" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Local Final</label>
          <input v-model.number="form.vlocal2" type="number" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Sección</label>
          <input v-model="form.vsecc" type="text" class="form-control" placeholder="todas o nombre" />
        </div>
        <div class="col-md-2 align-self-end">
          <button class="btn btn-primary w-100" type="submit">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="mt-4">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>
    <div v-if="reportData.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Oficina</th>
            <th>Mercado</th>
            <th>Local</th>
            <th>Letra</th>
            <th>Sección</th>
            <th>Bloque</th>
            <th>Nombre</th>
            <th>Giro</th>
            <th>Descripción</th>
            <th>Periodo</th>
            <th>Año</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Renta</th>
            <th>Total Gastos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id_adeudo_local">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.giro }}</td>
            <td>{{ row.descripcion_local }}</td>
            <td>{{ row.periodo }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.importe | currency }}</td>
            <td>{{ row.recargos | currency }}</td>
            <td>{{ row.renta | currency }}</td>
            <td>{{ row.total_gasto | currency }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-success" @click="exportPDF">Exportar PDF</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptReqPbaPage',
  data() {
    return {
      form: {
        vmerc1: 1,
        vmerc2: 2,
        vlocal1: 1,
        vlocal2: 100,
        vsecc: 'todas'
      },
      reportData: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'RptReqPba_getReportData',
          params: { ...this.form }
        });
        if (res.data.success) {
          this.reportData = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar datos';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      } finally {
        this.loading = false;
      }
    },
    exportPDF() {
      // Implementar exportación a PDF (puede usar jsPDF o similar)
      alert('Funcionalidad de exportación a PDF pendiente de implementación.');
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
.rptreq-pba-page {
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
