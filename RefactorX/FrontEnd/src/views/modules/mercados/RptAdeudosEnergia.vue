<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bolt" /></div>
      <div class="module-view-info">
        <h1>Reporte de Adeudos de Energía</h1>
        <p>Mercados - Reporte de Adeudos de Energía</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1 class="mb-4">Listado de Adeudos de Energía Eléctrica</h1>
    <form @submit.prevent="fetchReport" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label class="municipal-form-label" for="axo">Año</label>
          <input type="number" v-model="form.axo" id="axo" class="municipal-form-control" required min="2000" max="2100">
        </div>
        <div class="col-md-3">
          <label class="municipal-form-label" for="oficina">Oficina</label>
          <select v-model="form.oficina" id="oficina" class="municipal-form-control" required>
            <option value="">Seleccione...</option>
            <option v-for="of in oficinas" :key="of.id" :value="of.id">{{ of.nombre }}</option>
          </select>
        </div>
        <div class="col-md-3 align-self-end">
          <button type="submit" class="btn-municipal-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="report.length">
      <div class="mb-3">
        <strong>Oficina Recaudadora:</strong>
        <span>{{ oficinaRecaudadora }}</span>
      </div>
      <table class="-bordered -sm municipal-table-hover">
        <thead class="table-light municipal-table-header">
          <tr>
            <th>Datos del Local</th>
            <th>Nombre Locatario</th>
            <th>Locales Adicionales</th>
            <th v-if="showCuota">{{ labelCuota }}</th>
            <th>{{ labelMeses }}</th>
            <th class="text-end">Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in report" :key="row.id_energia">
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.local_adicional }}</td>
            <td v-if="showCuota">{{ formatCurrency(row.cuota) }}</td>
            <td>{{ row.meses }}</td>
            <td class="text-end">{{ formatCurrency(row.adeudo) }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr class="table-secondary">
            <td colspan="5" class="text-end"><strong>Total Adeudo:</strong></td>
            <td class="text-end"><strong>{{ formatCurrency(totalAdeudo) }}</strong></td>
          </tr>
          <tr class="table-secondary">
            <td colspan="5" class="text-end"><strong>Locales con Adeudo:</strong></td>
            <td class="text-end"><strong>{{ report.length }}</strong></td>
          </tr>
        </tfoot>
      </table>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptAdeudosEnergiaPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        oficina: ''
      },
      oficinas: [
        { id: 1, nombre: 'Zona Centro' },
        { id: 2, nombre: 'Zona Olímpica' },
        { id: 3, nombre: 'Zona Oblatos' },
        { id: 4, nombre: 'Zona Minerva' },
        { id: 5, nombre: 'Cruz del Sur' }
      ],
      report: [],
      loading: false,
      error: '',
      oficinaRecaudadora: '',
      labelCuota: 'Cuota Mes.',
      labelMeses: 'Mes de Adeudo',
      showCuota: true
    };
  },
  computed: {
    totalAdeudo() {
      return this.report.reduce((sum, r) => sum + Number(r.adeudo || 0), 0);
    }
  },
  methods: {
    async fetchReport() {
      this.loading = true;
      this.error = '';
      this.report = [];
      this.oficinaRecaudadora = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'RptAdeudosEnergia.getReport',
            params: {
              axo: this.form.axo,
              oficina: this.form.oficina
            }
          })
        });
        const data = await response.json();
        if (data.eResponse && data.eResponse.status === 'ok') {
          this.report = data.eResponse.data;
          if (this.report.length > 0) {
            // Set recaudadora label
            this.oficinaRecaudadora = this.report[0].recaudadora || '';
            // Cuota/Meses label logic
            if (parseInt(this.form.oficina) === 5) {
              this.showCuota = false;
            } else {
              this.showCuota = true;
              if (parseInt(this.form.axo) <= 2002) {
                this.labelCuota = 'Cuota Bim.';
                this.labelMeses = 'Bimestre de Adeudo';
              } else {
                this.labelCuota = 'Cuota Mes.';
                this.labelMeses = 'Mes de Adeudo';
              }
            }
          }
        } else {
          this.error = data.eResponse ? data.eResponse.message : 'Error desconocido';
        }
      } catch (err) {
        this.error = err.message || 'Error de red';
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.rpt-adeudos-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
