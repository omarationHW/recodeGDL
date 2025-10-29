<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Adeudos Generales</li>
      </ol>
    </nav>
    <h2 class="mb-3">Reporte de Adeudos Generales de Aseo Contratado</h2>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3 mb-2">
          <label>Empresa</label>
          <select v-model.number="form.sel_emp" class="form-control">
            <option :value="1">Todas</option>
            <option :value="2">Por Empresa</option>
          </select>
        </div>
        <div class="col-md-3 mb-2">
          <label>Número de Empresa</label>
          <input v-model.number="form.num_emp" type="number" class="form-control" :disabled="form.sel_emp !== 2">
        </div>
        <div class="col-md-3 mb-2">
          <label>Contrato</label>
          <select v-model.number="form.sel_cont" class="form-control">
            <option :value="1">Todos</option>
            <option :value="2">Por Contrato</option>
          </select>
        </div>
        <div class="col-md-3 mb-2">
          <label>Número de Contrato</label>
          <input v-model.number="form.num_cont" type="number" class="form-control" :disabled="form.sel_cont !== 2">
        </div>
      </div>
      <div class="row">
        <div class="col-md-3 mb-2">
          <label>Tipo de Aseo</label>
          <input v-model.number="form.sel_ctrol_aseo" type="number" class="form-control" placeholder="0 = Todos">
        </div>
        <div class="col-md-3 mb-2">
          <label>Vigencia Contrato</label>
          <select v-model="form.vig_cont" class="form-control">
            <option value="T">Todos</option>
            <option value="V">Vigente</option>
            <option value="C">Cancelado</option>
          </select>
        </div>
        <div class="col-md-3 mb-2">
          <label>Vigencia Adeudos</label>
          <select v-model="form.vig_adeudos" class="form-control">
            <option value="T">Todos</option>
            <option value="V">Vigente</option>
            <option value="C">Cancelado</option>
            <option value="P">Pagado</option>
            <option value="S">Condonado</option>
          </select>
        </div>
        <div class="col-md-3 mb-2">
          <label>Recaudadora (Ofna)</label>
          <input v-model.number="form.ofna" type="number" class="form-control" placeholder="0 = Todas">
        </div>
      </div>
      <div class="row">
        <div class="col-md-3 mb-2">
          <label>Clasificación</label>
          <select v-model.number="form.opcion" class="form-control">
            <option :value="1">Periodo de Adeudo</option>
            <option :value="2">Tipo de Operación</option>
            <option :value="3">Vigencia</option>
            <option :value="4">Fecha de Pago</option>
            <option :value="5">Recaudadora</option>
            <option :value="6">Caja</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn btn-primary mt-3">Consultar</button>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead class="thead-light">
            <tr>
              <th>No. Emp</th>
              <th>Tipo Empresa</th>
              <th>Nombre Empresa</th>
              <th>Representante</th>
              <th>No. Contrato</th>
              <th>Tipo Aseo</th>
              <th>Recolección</th>
              <th>Cant. Rec.</th>
              <th>Domicilio</th>
              <th>Sector</th>
              <th>Zona</th>
              <th>Subzona</th>
              <th>Alta</th>
              <th>Baja</th>
              <th>Periodo</th>
              <th>Tipo Adeudo</th>
              <th>Cant. Exed.</th>
              <th>Importe</th>
              <th>Vig.</th>
              <th>Fecha Pago</th>
              <th>Rec. Pago</th>
              <th>Caja</th>
              <th>Cons. Oper.</th>
              <th>Folio Rcbo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in report" :key="idx">
              <td>{{ row.num_empresa }}</td>
              <td>{{ row.tipo_empresa }}</td>
              <td>{{ row.descripcion }}</td>
              <td>{{ row.representante }}</td>
              <td>{{ row.num_contrato }}</td>
              <td>{{ row.descripcion_2 }}</td>
              <td>{{ row.descripcion_3 }}</td>
              <td>{{ row.cantidad_recolec }}</td>
              <td>{{ row.domicilio }}</td>
              <td>{{ row.sector }}</td>
              <td>{{ row.zona }}</td>
              <td>{{ row.sub_zona }}</td>
              <td>{{ formatDate(row.fecha_hora_alta) }}</td>
              <td>{{ formatDate(row.fecha_hora_baja) }}</td>
              <td>{{ formatDate(row.aso_mes_pago, 'YYYY-MM') }}</td>
              <td>{{ row.descripcion_5 }}</td>
              <td>{{ row.exedencias }}</td>
              <td>{{ formatCurrency(row.importe) }}</td>
              <td>{{ row.status_vigencia_1 }}</td>
              <td>{{ formatDate(row.fecha_hora_pago) }}</td>
              <td>{{ row.id_rec_1 }}</td>
              <td>{{ row.caja }}</td>
              <td>{{ row.consec_operacion }}</td>
              <td>{{ row.folio_rcbo }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="alert alert-secondary mt-3">
        <strong>Total registros:</strong> {{ report.length }}
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RptAdeudosGeneral',
  data() {
    return {
      form: {
        sel_emp: 1,
        num_emp: 0,
        sel_cont: 1,
        num_cont: 0,
        sel_ctrol_aseo: 0,
        vig_cont: 'T',
        vig_adeudos: 'T',
        ofna: 0,
        opcion: 1
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
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            procedure: 'rpt_adeudos_general',
            params: { ...this.form }
          }
        });
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse && data.eResponse.message ? data.eResponse.message : 'Error desconocido';
        }
      } catch (e) {
        this.error = e.response && e.response.data && e.response.data.eResponse && e.response.data.eResponse.message
          ? e.response.data.eResponse.message
          : e.message;
      } finally {
        this.loading = false;
      }
    },
    formatDate(val, fmt = 'YYYY-MM-DD') {
      if (!val) return '';
      const d = new Date(val);
      if (isNaN(d)) return val;
      if (fmt === 'YYYY-MM') {
        return d.getFullYear() + '-' + String(d.getMonth() + 1).padStart(2, '0');
      }
      return d.toISOString().slice(0, 10);
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.table th, .table td {
  font-size: 0.95em;
}
</style>
