<template>
  <div class="rep-oper-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado de Operaciones por Caja</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header font-weight-bold">Tiras de Auditoría</div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="form-row align-items-end">
            <div class="form-group col-md-3">
              <label for="fecha">Fecha de Ingreso</label>
              <input type="date" v-model="form.fecha" class="form-control" id="fecha" required @change="onFechaOrRecaudChange">
            </div>
            <div class="form-group col-md-3">
              <label for="recaud">Recaudadora</label>
              <select v-model="form.recaud" class="form-control" id="recaud" required @change="onFechaOrRecaudChange">
                <option v-for="r in recaudadoras" :key="r" :value="r">{{ r }}</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <label for="caja">Caja</label>
              <select v-model="form.caja" class="form-control" id="caja" required>
                <option v-for="c in cajas" :key="c.caja" :value="c.caja">{{ c.caja }}</option>
              </select>
            </div>
            <div class="form-group col-md-3">
              <button type="button" class="btn btn-primary mr-2" @click="getTotales">Totales</button>
              <button type="button" class="btn btn-secondary" @click="getDesglose">Desglose</button>
            </div>
          </div>
        </form>
      </div>
    </div>
    <div v-if="totales" class="card mb-3">
      <div class="card-header">Totales de Operaciones</div>
      <div class="card-body">
        <table class="table table-bordered table-sm">
          <tbody>
            <tr><th>CANCELADAS</th><td>{{ totales.canceladas }}</td><th>IMPORTE CANCELADAS</th><td>{{ formatCurrency(totales.total_canc) }}</td></tr>
            <tr><th>CHEQUES</th><td>{{ totales.cheques }}</td><th>IMPORTE CHEQUES</th><td>{{ formatCurrency(totales.tot_cheq) }}</td></tr>
            <tr><th>DOC CERO</th><td>{{ totales.doc_cero }}</td></tr>
            <tr><th>PURO EFECTIVO</th><td>{{ totales.puro_efec }}</td></tr>
            <tr><th>PURO EFECTIVO 2</th><td>{{ totales.puro_efec2 }}</td></tr>
            <tr><th>TOTAL OPERACIONES</th><td>{{ totales.num_oper }}</td></tr>
            <tr><th>IMPORTE TOTAL</th><td>{{ formatCurrency(totales.tot_total) }}</td></tr>
            <tr><th>IMPORTE EFECTIVO</th><td>{{ formatCurrency(totales.tot_efec) }}</td></tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="desglose.length" class="card mb-3">
      <div class="card-header">Desglose de Operaciones</div>
      <div class="card-body">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th>Folio</th>
              <th>Cuenta</th>
              <th>Importe</th>
              <th>Mensaje</th>
              <th>Aplicación</th>
              <th>Recaud Pago</th>
              <th>Monto</th>
              <th>Cancelación</th>
              <th>Año Pago</th>
              <th>Bimini</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in desglose" :key="row.cvepago">
              <td>{{ row.folio }}</td>
              <td>{{ row.cvecuenta }}</td>
              <td>{{ formatCurrency(row.importe) }}</td>
              <td>{{ row.mensaje }}</td>
              <td>{{ row.cvectaapl }}</td>
              <td>{{ row.recaudpago }}</td>
              <td>{{ formatCurrency(row.monto) }}</td>
              <td>{{ row.cancelacion }}</td>
              <td>{{ row.axopago }}</td>
              <td>{{ row.bimini }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'RepOperPage',
  data() {
    return {
      form: {
        fecha: '',
        recaud: '',
        caja: ''
      },
      recaudadoras: ['1', '2', '3', '4', '5'],
      cajas: [],
      totales: null,
      desglose: [],
      error: ''
    };
  },
  methods: {
    async onFechaOrRecaudChange() {
      this.form.caja = '';
      if (this.form.fecha && this.form.recaud) {
        try {
          const resp = await this.$axios.post('/api/execute', {
            eRequest: {
              operation: 'getCajasByFechaRecaud',
              params: {
                fecha: this.form.fecha,
                recaud: this.form.recaud
              }
            }
          });
          this.cajas = resp.data.eResponse.data || [];
        } catch (e) {
          this.error = 'Error al cargar cajas: ' + (e.response?.data?.eResponse?.error || e.message);
        }
      }
    },
    async getTotales() {
      this.error = '';
      this.totales = null;
      this.desglose = [];
      if (!this.form.fecha || !this.form.recaud || !this.form.caja) {
        this.error = 'Seleccione fecha, recaudadora y caja.';
        return;
      }
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getTotalesOperaciones',
            params: {
              fecha: this.form.fecha,
              recaud: this.form.recaud,
              caja: this.form.caja
            }
          }
        });
        if (resp.data.eResponse.success) {
          this.totales = resp.data.eResponse.data;
        } else {
          this.error = resp.data.eResponse.error;
        }
      } catch (e) {
        this.error = 'Error al obtener totales: ' + (e.response?.data?.eResponse?.error || e.message);
      }
    },
    async getDesglose() {
      this.error = '';
      this.totales = null;
      this.desglose = [];
      if (!this.form.fecha || !this.form.recaud || !this.form.caja) {
        this.error = 'Seleccione fecha, recaudadora y caja.';
        return;
      }
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            operation: 'getDesgloseOperaciones',
            params: {
              fecha: this.form.fecha,
              recaud: this.form.recaud,
              caja: this.form.caja
            }
          }
        });
        if (resp.data.eResponse.success) {
          this.desglose = resp.data.eResponse.data;
        } else {
          this.error = resp.data.eResponse.error;
        }
      } catch (e) {
        this.error = 'Error al obtener desglose: ' + (e.response?.data?.eResponse?.error || e.message);
      }
    },
    formatCurrency(val) {
      if (val === null || val === undefined) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    onSubmit() {
      // No submit, handled by buttons
    }
  }
};
</script>

<style scoped>
.rep-oper-page {
  max-width: 1200px;
  margin: 0 auto;
}
</style>
