<template>
  <div class="rpt-lista-mercados-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Adeudos de Mercados</li>
      </ol>
    </nav>
    <h1>Listado de Adeudos para Requerimientos de Pago y Embargo</h1>
    <form @submit.prevent="fetchReport">
      <div class="row">
        <div class="col-md-2">
          <label>Oficina</label>
          <input type="number" v-model.number="form.vofna" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Mercado Inicial</label>
          <input type="number" v-model.number="form.vmerc1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Mercado Final</label>
          <input type="number" v-model.number="form.vmerc2" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Local Inicial</label>
          <input type="number" v-model.number="form.vlocal1" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Local Final</label>
          <input type="number" v-model.number="form.vlocal2" class="form-control" required />
        </div>
        <div class="col-md-2">
          <label>Sección</label>
          <input type="text" v-model="form.vsecc" class="form-control" placeholder="todas" />
        </div>
      </div>
      <div class="mt-3">
        <button type="submit" class="btn btn-primary">Consultar</button>
      </div>
    </form>
    <div v-if="loading" class="mt-4">
      <span>Cargando...</span>
    </div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Oficina</th>
            <th>Mercado</th>
            <th>Sección</th>
            <th>Local</th>
            <th>Letra</th>
            <th>Bloque</th>
            <th>Nombre</th>
            <th>Renta</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Total Gastos</th>
            <th>Descripción Mercado</th>
            <th>Periodo</th>
            <th>Año</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_adeudo_local">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ currency(row.renta) }}</td>
            <td>{{ currency(row.importe) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.total_gasto) }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.periodo }}</td>
            <td>{{ row.axo }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-secondary" @click="exportToCSV">Exportar a CSV</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptListaMercadosPage',
  data() {
    return {
      form: {
        vofna: 1,
        vmerc1: 1,
        vmerc2: 2,
        vlocal1: 1,
        vlocal2: 9999,
        vsecc: 'todas'
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
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'RptListaMercados',
              params: {
                vofna: this.form.vofna,
                vmerc1: this.form.vmerc1,
                vmerc2: this.form.vmerc2,
                vlocal1: this.form.vlocal1,
                vlocal2: this.form.vlocal2,
                vsecc: this.form.vsecc || 'todas'
              }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al consultar el reporte';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    },
    currency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    exportToCSV() {
      if (!this.report.length) return;
      const header = [
        'Oficina','Mercado','Sección','Local','Letra','Bloque','Nombre','Renta','Importe','Recargos','Total Gastos','Descripción Mercado','Periodo','Año'
      ];
      const rows = this.report.map(row => [
        row.oficina, row.num_mercado, row.seccion, row.local, row.letra_local, row.bloque, row.nombre,
        row.renta, row.importe, row.recargos, row.total_gasto, row.descripcion, row.periodo, row.axo
      ]);
      let csvContent = header.join(',') + '\n';
      rows.forEach(r => {
        csvContent += r.map(x => '"'+(x==null?'':x)+'"').join(',') + '\n';
      });
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.setAttribute('download', 'RptListaMercados.csv');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
    }
  }
};
</script>

<style scoped>
.rpt-lista-mercados-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
