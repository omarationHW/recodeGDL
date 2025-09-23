<template>
  <div class="rfacturacion-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Facturación Rastro</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h3>Facturación Rastro</h3>
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="adeudoStatus" class="form-label">Tipo de Adeudo</label>
              <select v-model="form.adeudo_status" id="adeudoStatus" class="form-select" @change="onAdeudoStatusChange">
                <option value="A">Adeudos y Pagos</option>
                <option value="B">Solo Adeudos</option>
                <option value="C">Solo Pagados</option>
              </select>
            </div>
            <div class="col-md-4 align-self-end">
              <div v-if="form.adeudo_status !== 'C'">
                <input type="checkbox" id="adeudoRecargo" v-model="form.adeudo_recargo" true-value="S" false-value="N" />
                <label for="adeudoRecargo">Adeudos con recargos</label>
              </div>
            </div>
          </div>

          <div class="row mb-3">
            <div class="col-md-4">
              <label for="periodo" class="form-label">Periodo</label>
              <select v-model="form.periodo_actual" id="periodo" class="form-select" @change="onPeriodoChange">
                <option :value="true">Periodo Actual</option>
                <option :value="false">Otro Periodo</option>
              </select>
            </div>
            <div class="col-md-2" v-if="!form.periodo_actual">
              <label for="year" class="form-label">Año</label>
              <input type="number" v-model="form.year" id="year" class="form-control" min="2000" max="2100" />
            </div>
            <div class="col-md-2" v-if="!form.periodo_actual">
              <label for="month" class="form-label">Mes</label>
              <select v-model="form.month" id="month" class="form-select">
                <option v-for="(mes, idx) in meses" :key="idx" :value="idx+1">{{ mes }}</option>
              </select>
            </div>
          </div>

          <div class="mb-3">
            <button type="submit" class="btn btn-primary me-2" :disabled="loading">
              <i class="bi bi-printer"></i> Previa
            </button>
            <button type="button" class="btn btn-secondary" @click="onSalir">
              <i class="bi bi-x-circle"></i> Salir
            </button>
          </div>
        </form>

        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="report.length > 0">
          <h5 class="mt-4">Reporte de Facturación</h5>
          <table class="table table-bordered table-sm mt-2">
            <thead>
              <tr>
                <th>Control</th>
                <th>Nombre del Concesionario</th>
                <th>Superficie</th>
                <th>Tipo de Local</th>
                <th>Licencia</th>
                <th>Importe</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, idx) in report" :key="idx">
                <td>{{ row.control }}</td>
                <td>{{ row.concesionario }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ row.tipo }}</td>
                <td>{{ row.licencia }}</td>
                <td class="text-end">{{ formatCurrency(row.importe) }}</td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <th colspan="5" class="text-end">TOTAL ----------></th>
                <th class="text-end">{{ formatCurrency(totalImporte) }}</th>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RFacturacionPage',
  data() {
    const now = new Date();
    return {
      form: {
        adeudo_status: 'A',
        adeudo_recargo: 'N',
        periodo_actual: true,
        year: now.getFullYear(),
        month: now.getMonth() + 1
      },
      meses: [
        'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
        'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
      ],
      loading: false,
      error: '',
      report: []
    };
  },
  computed: {
    totalImporte() {
      return this.report.reduce((sum, row) => sum + Number(row.importe || 0), 0);
    }
  },
  methods: {
    onAdeudoStatusChange() {
      if (this.form.adeudo_status === 'C') {
        this.form.adeudo_recargo = 'N';
      }
    },
    onPeriodoChange() {
      if (this.form.periodo_actual) {
        const now = new Date();
        this.form.year = now.getFullYear();
        this.form.month = now.getMonth() + 1;
      } else {
        this.form.year = '';
        this.form.month = 1;
      }
    },
    formatCurrency(val) {
      return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(val);
    },
    async onSubmit() {
      this.error = '';
      this.report = [];
      if (!this.form.periodo_actual && (!this.form.year || !this.form.month)) {
        this.error = 'Falta el dato del AÑO o MES a consultar, intentalo de nuevo';
        return;
      }
      this.loading = true;
      try {
        const eRequest = {
          action: 'getRFacturacionReport',
          params: {
            adeudo_status: this.form.adeudo_status,
            adeudo_recargo: this.form.adeudo_recargo,
            year: Number(this.form.year),
            month: Number(this.form.month),
            periodo_actual: this.form.periodo_actual
          }
        };
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest })
        });
        const data = await resp.json();
        if (data.eResponse && data.eResponse.success) {
          this.report = data.eResponse.data;
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    onSalir() {
      this.$router.push('/');
    }
  }
};
</script>

<style scoped>
.rfacturacion-page {
  max-width: 1100px;
  margin: 0 auto;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
