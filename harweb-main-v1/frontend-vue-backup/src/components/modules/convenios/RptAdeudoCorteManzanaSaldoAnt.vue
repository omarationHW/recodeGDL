<template>
  <div class="rpt-adeudo-corte-manzana-saldo-ant">
    <h1>Reporte: Corte por Manzana con Saldo Anterior</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Corte Manzana Saldo Ant.</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="subtipo">Subtipo</label>
          <select v-model="form.subtipo" id="subtipo" class="form-control" required>
            <option v-for="st in subtipos" :key="st.subtipo" :value="st.subtipo">{{ st.desc_subtipo }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="fechadsd">Fecha Desde</label>
          <input type="date" v-model="form.fechadsd" id="fechadsd" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label for="fechahst">Fecha Hasta</label>
          <input type="date" v-model="form.fechahst" id="fechahst" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label for="est">Estado</label>
          <select v-model="form.est" id="est" class="form-control" required>
            <option value="A">VIGENTES</option>
            <option value="B">DADOS DE BAJA</option>
            <option value="P">PAGADOS</option>
          </select>
        </div>
        <div class="form-group col-md-1">
          <label for="rep">Tipo</label>
          <select v-model="form.rep" id="rep" class="form-control" required>
            <option value="1">Normal</option>
            <option value="2">Saldo Ant.</option>
          </select>
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary w-100">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="reportData.length" class="table-responsive mt-4">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Ext.</th>
            <th>Int.</th>
            <th>Inciso</th>
            <th>Costo</th>
            <th>Parc. Pag.</th>
            <th>Pagos</th>
            <th>Recargos</th>
            <th>Saldo Ant.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reportData" :key="row.id_conv_predio">
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letracomp }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num_exterior }}</td>
            <td>{{ row.num_interior }}</td>
            <td>{{ row.inciso }}</td>
            <td>{{ currency(row.cantidad_total) }}</td>
            <td>{{ row.parcpag }}</td>
            <td>{{ currency(row.pagos) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.SaldoAnterior) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptAdeudoCorteManzanaSaldoAnt',
  data() {
    return {
      form: {
        subtipo: '',
        fechadsd: '',
        fechahst: '',
        rep: 2,
        est: 'A'
      },
      subtipos: [],
      reportData: [],
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
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getSubtipos',
            params: { tipo: 14 }
          }
        });
        if (res.data.eResponse.success) {
          this.subtipos = res.data.eResponse.data;
          if (this.subtipos.length) {
            this.form.subtipo = this.subtipos[0].subtipo;
          }
        }
      } catch (e) {
        this.error = 'Error cargando subtipos';
      }
    },
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.reportData = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getReportData',
            params: { ...this.form }
          }
        });
        if (res.data.eResponse.success) {
          this.reportData = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor';
      }
      this.loading = false;
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.rpt-adeudo-corte-manzana-saldo-ant {
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
