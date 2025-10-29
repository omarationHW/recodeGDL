<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="dollar-sign" /></div>
      <div class="module-view-info">
        <h1>Estadística de Pagos y Adeudos</h1>
        <p>Mercados - Estadística de Pagos y Adeudos</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Estadística de Pagos, Captura y Adeudos de Mercados</h1>
    <form @submit.prevent="fetchEstadistica">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label class="municipal-form-label" for="recaudadora">Recaudadora</label>
          <select v-model="selectedRecaudadora" class="municipal-form-control" id="recaudadora" @change="fetchMercados">
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label class="municipal-form-label" for="mercado">Mercado</label>
          <select v-model="selectedMercado" class="municipal-form-control" id="mercado">
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.descripcion }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label class="municipal-form-label" for="axo">Año</label>
          <input type="number" v-model="axo" class="municipal-form-control" id="axo" min="2000" max="2100">
        </div>
        <div class="form-group col-md-2">
          <label class="municipal-form-label" for="mes">Mes</label>
          <input type="number" v-model="mes" class="municipal-form-control" id="mes" min="1" max="12">
        </div>
      </div>
      <div class="form-row">
        <div class="form-group col-md-3">
          <label class="municipal-form-label" for="fec3">Fecha Desde</label>
          <input type="date" v-model="fec3" class="municipal-form-control" id="fec3">
        </div>
        <div class="form-group col-md-3">
          <label class="municipal-form-label" for="fec4">Fecha Hasta</label>
          <input type="date" v-model="fec4" class="municipal-form-control" id="fec4">
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn-municipal-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="mt-3">
      <span>Cargando datos...</span>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="estadistica.length" class="mt-4">
      <h3>Resumen por Mercado</h3>
      <table class="-bordered municipal-table-sm">
        <thead>
          <tr>
            <th>Mercado</th>
            <th>Nombre</th>
            <th>Locales Pagados</th>
            <th>Importe Pagado</th>
            <th>Periodos Pagados</th>
            <th>Locales Capturados</th>
            <th>Importe Capturado</th>
            <th>Periodos Capturados</th>
            <th>Locales con Adeudo</th>
            <th>Importe Adeudo</th>
            <th>Periodos Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in estadistica" :key="row.num_mercado">
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.localpag }}</td>
            <td>{{ row.pagospag | currency }}</td>
            <td>{{ row.periodospag }}</td>
            <td>{{ row.localcap }}</td>
            <td>{{ row.pagoscap | currency }}</td>
            <td>{{ row.periodoscap }}</td>
            <td>{{ row.localade }}</td>
            <td>{{ row.pagosade | currency }}</td>
            <td>{{ row.periodosade }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'EstadPagosyAdeudosPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      selectedRecaudadora: '',
      selectedMercado: '',
      axo: new Date().getFullYear(),
      mes: new Date().getMonth() + 1,
      fec3: '',
      fec4: '',
      estadistica: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') {
        return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      }
      return val;
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getRecaudadoras'
        });
        if (res.data.success) {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length) {
            this.selectedRecaudadora = this.recaudadoras[0].id_rec;
            this.fetchMercados();
          }
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async fetchMercados() {
      if (!this.selectedRecaudadora) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getMercadosByRecaudadora',
          params: { id_rec: this.selectedRecaudadora }
        });
        if (res.data.success) {
          this.mercados = res.data.data;
          if (this.mercados.length) {
            this.selectedMercado = this.mercados[0].num_mercado_nvo;
          }
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async fetchEstadistica() {
      this.loading = true;
      this.error = '';
      this.estadistica = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getEstadisticaPagosyAdeudos',
          params: {
            id_rec: this.selectedRecaudadora,
            axo: this.axo,
            mes: this.mes,
            fec3: this.fec3,
            fec4: this.fec4
          }
        });
        if (res.data.success) {
          this.estadistica = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.estad-pagosy-adeudos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
