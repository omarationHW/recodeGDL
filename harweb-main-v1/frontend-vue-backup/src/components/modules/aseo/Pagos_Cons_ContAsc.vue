<template>
  <div class="pagos-cons-cont-asc">
    <h1>Consulta de Pagos por Contrato y Tipo de Aseo (Ascendente)</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Pagos por Contrato Ascendente
    </div>
    <form @submit.prevent="buscarContratos">
      <div class="form-row">
        <label for="contrato">No. Contrato:</label>
        <input v-model="contrato" id="contrato" maxlength="10" required pattern="\\d+" />
        <label for="ctrolAseo">Tipo de Aseo:</label>
        <select v-model="ctrolAseo" id="ctrolAseo" required>
          <option v-for="ta in tipoAseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="contratos.length">
      <h2>Contratos encontrados</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Contrato</th>
            <th>Tipo Aseo</th>
            <th>Descripción</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="cont in contratos" :key="cont.control_contrato">
            <td>{{ cont.num_contrato }}</td>
            <td>{{ cont.tipo_aseo }}</td>
            <td>{{ cont.descripcion }}</td>
            <td>
              <button @click="verPagos(cont.control_contrato)">Ver Pagos</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="pagos.length">
      <h2>Pagos del Contrato</h2>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Operación</th>
            <th>Exed.</th>
            <th>Importe</th>
            <th>Status</th>
            <th>Fecha Pago</th>
            <th>Ofna</th>
            <th>Caja</th>
            <th>Consec. Operación</th>
            <th>Folio Rcbo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.aso_mes_pago + '-' + pago.ctrol_operacion">
            <td>{{ pago.aso_mes_pago | formatPeriodo }}</td>
            <td>{{ pago.descripcion }}</td>
            <td>{{ pago.exedencias }}</td>
            <td>{{ pago.importe | currency }}</td>
            <td>{{ pago.status_vigencia }}</td>
            <td>{{ pago.fecha_hora_pago | formatFecha }}</td>
            <td>{{ pago.id_rec }}</td>
            <td>{{ pago.caja }}</td>
            <td>{{ pago.consec_operacion }}</td>
            <td>{{ pago.folio_rcbo }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div class="actions">
      <router-link class="btn btn-secondary" to="/">Salir</router-link>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PagosConsContAsc',
  data() {
    return {
      tipoAseo: [],
      contrato: '',
      ctrolAseo: '',
      contratos: [],
      pagos: [],
      error: ''
    };
  },
  created() {
    this.loadTipoAseo();
  },
  methods: {
    async loadTipoAseo() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getTipoAseo'
        });
        if (res.data.success) {
          this.tipoAseo = res.data.data;
          if (this.tipoAseo.length > 0) {
            this.ctrolAseo = this.tipoAseo[0].ctrol_aseo;
          }
        } else {
          this.error = res.data.message || 'Error cargando tipos de aseo';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async buscarContratos() {
      this.error = '';
      this.contratos = [];
      this.pagos = [];
      if (!this.contrato || !this.ctrolAseo) {
        this.error = 'Debe ingresar el número de contrato y tipo de aseo';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'buscarContratos',
          params: {
            contrato: this.contrato,
            ctrol_aseo: this.ctrolAseo
          }
        });
        if (res.data.success) {
          this.contratos = res.data.data;
          if (this.contratos.length === 1) {
            this.verPagos(this.contratos[0].control_contrato);
          }
        } else {
          this.error = res.data.message || 'No se encontraron contratos';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async verPagos(control_contrato) {
      this.error = '';
      this.pagos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'pagosPorContrato',
          params: {
            control_contrato
          }
        });
        if (res.data.success) {
          this.pagos = res.data.data;
        } else {
          this.error = res.data.message || 'No se encontraron pagos';
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  },
  filters: {
    formatPeriodo(val) {
      if (!val) return '';
      // Espera formato YYYY-MM-DD o YYYY-MM
      return val.substr(0, 7);
    },
    formatFecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.pagos-cons-cont-asc {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
  text-align: left;
}
.actions {
  margin-top: 2rem;
}
.alert {
  color: #a94442;
  background: #f2dede;
  border: 1px solid #ebccd1;
  padding: 0.5rem;
  margin-top: 1rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
}
</style>
