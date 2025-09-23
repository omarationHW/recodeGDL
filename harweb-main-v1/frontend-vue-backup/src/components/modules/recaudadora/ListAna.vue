<template>
  <div class="listana-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Listado Analítico del Ingreso Diario</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4>Listado Analítico del Ingreso Diario</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onImprimir">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="fecha">Fecha de Ingreso:</label>
              <input type="date" v-model="form.fecha" id="fecha" class="form-control" @change="onFechaChange" required>
            </div>
            <div class="col-md-4">
              <label for="recaud">Recaudadora:</label>
              <select v-model="form.recaud" id="recaud" class="form-control" @change="onFechaChange" required>
                <option v-for="r in recaudadoras" :key="r" :value="r">{{ r }}</option>
              </select>
            </div>
            <div class="col-md-4">
              <label for="caja">Caja:</label>
              <select v-model="form.caja" id="caja" class="form-control" required>
                <option v-for="c in cajas" :key="c.caja" :value="c.caja">{{ c.caja }}</option>
              </select>
            </div>
          </div>
          <button type="submit" class="btn btn-success"><i class="fa fa-print"></i> Imprimir</button>
        </form>
        <div v-if="loading" class="mt-3">
          <i class="fa fa-spinner fa-spin"></i> Cargando datos...
        </div>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="showReport" class="mt-4">
          <h5>Resumen</h5>
          <table class="table table-bordered table-sm">
            <tr>
              <th>Fecha</th>
              <td>{{ form.fecha }}</td>
              <th>Recaudadora</th>
              <td>{{ form.recaud }}</td>
              <th>Caja</th>
              <td>{{ form.caja }}</td>
            </tr>
            <tr>
              <th>Total Importe</th>
              <td colspan="5">{{ resumen.tot_imp ? resumen.tot_imp.toLocaleString('es-MX', {style:'currency', currency:'MXN'}) : '-' }}</td>
            </tr>
            <tr>
              <th>Folio Mínimo</th>
              <td>{{ resumen.min_folio || '-' }}</td>
              <th>Folio Máximo</th>
              <td>{{ resumen.max_folio || '-' }}</td>
              <td colspan="2"></td>
            </tr>
          </table>
          <h5>Detalle de Pagos</h5>
          <table class="table table-striped table-bordered table-sm">
            <thead>
              <tr>
                <th>Folio</th>
                <th>Recaud</th>
                <th>Municipio</th>
                <th>Cuenta</th>
                <th>Importe</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in detalle" :key="row.folio">
                <td>{{ row.folio }}</td>
                <td>{{ row.reca }}</td>
                <td>{{ row.cvemunicipio }}</td>
                <td>{{ row.cuenta }}</td>
                <td>{{ row.importe ? row.importe.toLocaleString('es-MX', {style:'currency', currency:'MXN'}) : '-' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListAnaPage',
  data() {
    return {
      form: {
        fecha: '',
        recaud: '',
        caja: ''
      },
      recaudadoras: ['1', '2', '3', '4', '5'],
      cajas: [],
      resumen: {
        tot_imp: null,
        min_folio: null,
        max_folio: null
      },
      detalle: [],
      loading: false,
      error: '',
      showReport: false
    };
  },
  mounted() {
    this.form.fecha = this.formatDate(new Date());
    this.form.recaud = this.recaudadoras[0];
    this.onFechaChange();
  },
  methods: {
    formatDate(date) {
      // yyyy-mm-dd
      let d = new Date(date), month = '' + (d.getMonth() + 1), day = '' + d.getDate(), year = d.getFullYear();
      if (month.length < 2) month = '0' + month;
      if (day.length < 2) day = '0' + day;
      return [year, month, day].join('-');
    },
    async onFechaChange() {
      this.loading = true;
      this.error = '';
      this.cajas = [];
      this.form.caja = '';
      try {
        const resp = await this.apiRequest('getCajasByFechaRecaud', {
          fecha: this.form.fecha,
          recaud: this.form.recaud
        });
        this.cajas = resp.data || [];
        if (this.cajas.length > 0) {
          this.form.caja = this.cajas[0].caja;
        }
      } catch (e) {
        this.error = e.message || 'Error al cargar cajas';
      }
      this.loading = false;
    },
    async onImprimir() {
      this.loading = true;
      this.error = '';
      this.showReport = false;
      try {
        // Resumen
        const [totImp, minFolio, maxFolio, detalle] = await Promise.all([
          this.apiRequest('getTotImp', {
            fecha: this.form.fecha,
            caja: this.form.caja,
            recaud: this.form.recaud
          }),
          this.apiRequest('getMinFolio', {
            fecha: this.form.fecha,
            caja: this.form.caja,
            recaud: this.form.recaud
          }),
          this.apiRequest('getMaxFolio', {
            fecha: this.form.fecha,
            caja: this.form.caja,
            recaud: this.form.recaud
          }),
          this.apiRequest('getPagosDetalle', {
            fecha: this.form.fecha,
            caja: this.form.caja,
            recaud: this.form.recaud
          })
        ]);
        this.resumen.tot_imp = totImp.data ? parseFloat(totImp.data.tot_imp) : null;
        this.resumen.min_folio = minFolio.data ? minFolio.data.minimo : null;
        this.resumen.max_folio = maxFolio.data ? maxFolio.data.maximo : null;
        this.detalle = detalle.data || [];
        this.showReport = true;
      } catch (e) {
        this.error = e.message || 'Error al generar reporte';
      }
      this.loading = false;
    },
    async apiRequest(action, params) {
      const response = await fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: {
            action,
            params
          }
        })
      });
      const json = await response.json();
      if (!json.eResponse.success) {
        throw new Error(json.eResponse.message || 'Error en API');
      }
      return json.eResponse;
    }
  }
};
</script>

<style scoped>
.listana-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card-header {
  font-weight: bold;
  font-size: 1.2rem;
}
</style>
