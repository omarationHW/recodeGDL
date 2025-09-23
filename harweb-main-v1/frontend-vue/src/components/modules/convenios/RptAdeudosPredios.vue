<template>
  <div class="adeudos-predios-page">
    <h1>Reporte de Adeudos de Predios</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudos Predios</li>
      </ol>
    </nav>
    <form @submit.prevent="fetchReport">
      <div class="form-row">
        <div class="form-group col-md-4">
          <label for="subtipo">Subtipo</label>
          <select v-model="form.subtipo" class="form-control" id="subtipo" required>
            <option v-for="s in subtipos" :key="s.subtipo" :value="s.subtipo">{{ s.desc_subtipo }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="fecha_hasta">Fecha Hasta</label>
          <input type="date" v-model="form.fecha_hasta" class="form-control" id="fecha_hasta" required />
        </div>
        <div class="form-group col-md-3">
          <label for="estado">Estado</label>
          <select v-model="form.estado" class="form-control" id="estado" required>
            <option value="A">VIGENTES</option>
            <option value="B">DADOS DE BAJA</option>
            <option value="P">PAGADOS</option>
          </select>
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary btn-block">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info mt-3">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="report.length" class="table-responsive mt-4">
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Ext.</th>
            <th>Costo</th>
            <th>Pagos</th>
            <th>Recargos</th>
            <th>Saldo</th>
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
            <td class="text-right">{{ currency(row.cantidad_total) }}</td>
            <td class="text-right">{{ currency(row.pagos) }}</td>
            <td class="text-right">{{ currency(row.recargos) }}</td>
            <td class="text-right">{{ currency(row.cantidad_total - row.pagos) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="font-weight-bold">
            <td colspan="6" class="text-right">TOTAL</td>
            <td class="text-right">{{ currency(total('cantidad_total')) }}</td>
            <td class="text-right">{{ currency(total('pagos')) }}</td>
            <td class="text-right">{{ currency(total('recargos')) }}</td>
            <td class="text-right">{{ currency(totalSaldo) }}</td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosPrediosPage',
  data() {
    return {
      form: {
        subtipo: '',
        fecha_hasta: '',
        estado: 'A'
      },
      subtipos: [],
      report: [],
      loading: false,
      error: ''
    };
  },
  computed: {
    totalSaldo() {
      return this.report.reduce((acc, r) => acc + (parseFloat(r.cantidad_total) - parseFloat(r.pagos)), 0);
    }
  },
  methods: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    total(field) {
      return this.report.reduce((acc, r) => acc + parseFloat(r[field] || 0), 0);
    },
    async fetchSubtipos() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getSubtipos' })
        });
        const json = await res.json();
        if (json.success) {
          this.subtipos = json.data;
          if (this.subtipos.length) this.form.subtipo = this.subtipos[0].subtipo;
        }
      } catch (e) {
        this.error = 'Error cargando subtipos';
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
            action: 'getAdeudosPredios',
            params: {
              subtipo: this.form.subtipo,
              fecha_hasta: this.form.fecha_hasta,
              estado: this.form.estado
            }
          })
        });
        const json = await res.json();
        if (json.success) {
          this.report = json.data;
        } else {
          this.error = json.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    this.fetchSubtipos();
    // Default fecha_hasta = hoy
    this.form.fecha_hasta = new Date().toISOString().substr(0, 10);
  }
};
</script>

<style scoped>
.adeudos-predios-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
