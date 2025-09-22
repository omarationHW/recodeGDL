<template>
  <div class="rpt-adeudos-predios-saldo-ant">
    <h1>Reporte de Adeudos Predios - Saldo Anterior</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudos Predios Saldo Anterior</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="subtipo">Subtipo</label>
          <select v-model="form.subtipo" id="subtipo" class="form-control" required>
            <option v-for="s in subtipos" :key="s.subtipo" :value="s.subtipo">{{ s.desc_subtipo }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="fechadsd">Fecha Desde</label>
          <input type="date" v-model="form.fechadsd" id="fechadsd" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="fechahst">Fecha Hasta</label>
          <input type="date" v-model="form.fechahst" id="fechahst" class="form-control" required />
        </div>
        <div class="form-group col-md-3">
          <label for="est">Estado</label>
          <select v-model="form.est" id="est" class="form-control" required>
            <option value="A">VIGENTES</option>
            <option value="B">DADOS DE BAJA</option>
            <option value="P">PAGADOS</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>
    <div v-if="loading" class="mt-3">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report.length" class="mt-4">
      <h3>Resultados</h3>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Ext.</th>
            <th>Saldo Anterior</th>
            <th>Pagos</th>
            <th>Saldo Actual</th>
            <th>Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_conv_predio">
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letracomp }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num_exterior }}</td>
            <td>{{ currency(row.saldoanterior) }}</td>
            <td>{{ currency(row.pagos) }}</td>
            <td>{{ currency(row.saldoanterior - row.pagos) }}</td>
            <td>{{ currency(row.recargos) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptAdeudosPrediosSaldoAnt',
  data() {
    return {
      form: {
        subtipo: '',
        fechadsd: '',
        fechahst: '',
        est: 'A'
      },
      subtipos: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.fetchSubtipos();
  },
  methods: {
    async fetchSubtipos() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getSubtipos',
              params: { tipo: 14 }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.subtipos = data.eResponse.data;
          if (this.subtipos.length) this.form.subtipo = this.subtipos[0].subtipo;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al cargar subtipos';
      }
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getReport',
              params: this.form
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = 'Error al consultar el reporte';
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
.rpt-adeudos-predios-saldo-ant {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>
