<template>
  <div class="rpt-listado-aseo-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Adeudos Aseo</li>
      </ol>
    </nav>
    <h2>Listado de Adeudos para Requerimiento de Pago y Embargo, Derechos de Aseo Contratado</h2>
    <form @submit.prevent="fetchListado">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="fecha_corte">Fecha de Corte</label>
          <input type="date" v-model="form.fecha_corte" class="form-control" id="fecha_corte" required>
        </div>
        <div class="form-group col-md-3">
          <label for="vtipo">Tipo de Aseo</label>
          <select v-model="form.vtipo" class="form-control" id="vtipo">
            <option value="todos">Todos</option>
            <option v-for="tipo in tiposAseo" :key="tipo" :value="tipo">{{ tipo }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label for="xnum1">Contrato Inicial</label>
          <input type="number" v-model.number="form.xnum1" class="form-control" id="xnum1" min="0">
        </div>
        <div class="form-group col-md-2">
          <label for="xnum2">Contrato Final</label>
          <input type="number" v-model.number="form.xnum2" class="form-control" id="xnum2" min="0">
        </div>
        <div class="form-group col-md-2">
          <label for="vrec">ID Rec</label>
          <input type="number" v-model.number="form.vrec" class="form-control" id="vrec" min="1">
        </div>
      </div>
      <button type="submit" class="btn btn-primary">Consultar</button>
    </form>

    <div v-if="loading" class="mt-4">Cargando...</div>
    <div v-if="error" class="alert alert-danger mt-4">{{ error }}</div>

    <div v-if="rows.length" class="mt-4">
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Contrato</th>
            <th>Tipo Aseo</th>
            <th>Nombre Contribuyente</th>
            <th>Domicilio</th>
            <th>Zona</th>
            <th>Sub Zona</th>
            <th>Periodo Adeudo</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Multas</th>
            <th>Gastos</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in rows" :key="row.control_contrato + '-' + row.axoade + '-' + row.mesade">
            <td>{{ row.num_contrato }}</td>
            <td>{{ row.tipo_aseo }}</td>
            <td>{{ row.descripcion_1 }}</td>
            <td>{{ row.domicilio }}</td>
            <td>{{ row.zona }}</td>
            <td>{{ row.sub_zona }}</td>
            <td>{{ row.axoade }}-{{ row.mesade }}</td>
            <td class="text-right">{{ currency(row.importe) }}</td>
            <td class="text-right">{{ currency(row.recargos) }}</td>
            <td class="text-right">{{ currency(row.importe * 0.5) }}</td>
            <td class="text-right">{{ currency(row.total_gasto) }}</td>
            <td class="text-right">{{ currency(row.importe + row.recargos + row.total_gasto + (row.importe * 0.5)) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="font-weight-bold">
            <td colspan="7">Totales</td>
            <td class="text-right">{{ currency(totals.total_importe) }}</td>
            <td class="text-right">{{ currency(totals.total_recargos) }}</td>
            <td class="text-right">{{ currency(totals.total_multas) }}</td>
            <td class="text-right">{{ currency(totals.total_gastos) }}</td>
            <td class="text-right">{{ currency(totals.total_general) }}</td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptListadoAseoPage',
  data() {
    return {
      form: {
        fecha_corte: new Date().toISOString().substr(0, 10),
        vtipo: 'todos',
        xnum1: '',
        xnum2: '',
        vrec: 1
      },
      tiposAseo: ['ORDINARIO', 'ESPECIAL', 'INDUSTRIAL'], // Puede ser dinámico
      rows: [],
      totals: {
        total_importe: 0,
        total_recargos: 0,
        total_multas: 0,
        total_gastos: 0,
        total_general: 0
      },
      loading: false,
      error: ''
    };
  },
  methods: {
    currency(val) {
      if (typeof val !== 'number') return '';
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    async fetchListado() {
      this.loading = true;
      this.error = '';
      this.rows = [];
      this.totals = {
        total_importe: 0,
        total_recargos: 0,
        total_multas: 0,
        total_gastos: 0,
        total_general: 0
      };
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'RptListado_Aseo',
            params: this.form
          })
        });
        const data = await response.json();
        if (data.success) {
          this.rows = data.data.rows;
          this.totals = data.data.totals;
        } else {
          this.error = data.message || 'Error al consultar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.rpt-listado-aseo-page {
  max-width: 98vw;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
