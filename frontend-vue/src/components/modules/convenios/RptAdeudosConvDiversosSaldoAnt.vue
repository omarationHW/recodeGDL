<template>
  <div class="rpt-adeudos-conv-diversos-saldo-ant">
    <h1>Reporte de Convenios Diversos - Saldo Anterior</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte Convenios Diversos Saldo Ant.</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label>Tipo</label>
          <input v-model.number="form.tipo" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Subtipo</label>
          <input v-model.number="form.subtipo" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Letras (Zona)</label>
          <select v-model="form.letras" class="form-control" required>
            <option value="ZC1">ZONA CENTRO</option>
            <option value="ZO2">ZONA OLIMPICA</option>
            <option value="ZO3">ZONA OBLATOS</option>
            <option value="ZM4">ZONA MINERVA</option>
            <option value="ZC5">ZONA CRUZ DEL SUR</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label>Estado</label>
          <select v-model="form.estado" class="form-control" required>
            <option value="A">VIGENTES</option>
            <option value="B">DADOS DE BAJA</option>
            <option value="P">PAGADOS</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label>Fecha Desde</label>
          <input v-model="form.fechadsd" type="date" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Fecha Hasta</label>
          <input v-model="form.fechahst" type="date" class="form-control" required />
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Generar Reporte</button>
    </form>
    <div v-if="loading" class="mt-3 alert alert-info">Cargando...</div>
    <div v-if="error" class="mt-3 alert alert-danger">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Convenio</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Ext.</th>
            <th>Saldo Ant.</th>
            <th>Pagos</th>
            <th>Saldo Act.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_conv_diver">
            <td>{{ row.letras_exp }}/{{ row.numero_exp }}/{{ row.axo_exp }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }} {{ row.num_exterior }}</td>
            <td>{{ row.num_exterior }}</td>
            <td class="text-right">{{ formatCurrency(row.SaldoAnterior) }}</td>
            <td class="text-right">{{ formatCurrency(row.pagos) }}</td>
            <td class="text-right">{{ formatCurrency(row.SaldoAnterior - row.pagos) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-secondary" @click="exportCSV">Exportar CSV</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptAdeudosConvDiversosSaldoAnt',
  data() {
    return {
      form: {
        tipo: '',
        subtipo: '',
        letras: 'ZC1',
        estado: 'A',
        fechadsd: '',
        fechahst: ''
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
          eRequest: {
            action: 'getReport',
            params: { ...this.form }
          }
        });
        if (res.data.eResponse.status === 'success') {
          this.report = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message || 'Error de comunicación con el servidor';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    exportCSV() {
      if (!this.report.length) return;
      const header = ['Convenio','Nombre','Domicilio','Ext.','Saldo Ant.','Pagos','Saldo Act.'];
      const rows = this.report.map(row => [
        `${row.letras_exp}/${row.numero_exp}/${row.axo_exp}`,
        row.nombre,
        `${row.calle} ${row.num_exterior}`,
        row.num_exterior,
        row.SaldoAnterior,
        row.pagos,
        row.SaldoAnterior - row.pagos
      ]);
      let csv = header.join(',') + '\n';
      rows.forEach(r => {
        csv += r.join(',') + '\n';
      });
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'reporte_convenios_diversos_saldo_ant.csv';
      a.click();
      window.URL.revokeObjectURL(url);
    }
  }
};
</script>

<style scoped>
.rpt-adeudos-conv-diversos-saldo-ant {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
