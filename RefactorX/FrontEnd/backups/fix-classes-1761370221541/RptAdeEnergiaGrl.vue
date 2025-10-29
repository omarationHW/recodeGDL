<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="bolt" /></div>
      <div class="module-view-info">
        <h1>Adeudos Globales Energía</h1>
        <p>Mercados - Adeudos Globales Energía</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1 class="mb-4">Adeudos Globales de Energía Eléctrica</h1>
    <form @submit.prevent="fetchDebts" class="form-inline mb-3">
      <div class="form-group mr-2">
        <label for="office" class="mr-2">Recaudadora:</label>
        <select v-model="filters.office_id" @change="onOfficeChange" class="municipal-form-control" required>
          <option v-for="rec in offices" :key="rec.id" :value="rec.id">{{ rec.name }}</option>
        </select>
      </div>
      <div class="form-group mr-2">
        <label for="market" class="mr-2">Mercado:</label>
        <select v-model="filters.market_id" class="municipal-form-control" required>
          <option v-for="m in markets" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">{{ m.num_mercado_nvo }} - {{ m.descripcion }}</option>
        </select>
      </div>
      <div class="form-group mr-2">
        <label for="year" class="mr-2">Año:</label>
        <select v-model="filters.year" class="municipal-form-control" required>
          <option v-for="y in years" :key="y.axo" :value="y.axo">{{ y.axo }}</option>
        </select>
      </div>
      <div class="form-group mr-2">
        <label for="month" class="mr-2">Mes:</label>
        <select v-model="filters.month" class="municipal-form-control" required>
          <option v-for="m in months" :key="m.id" :value="m.id">{{ m.name }}</option>
        </select>
      </div>
      <button type="submit" class="btn btn-primary mr-2">Consultar</button>
      <button type="button" class="btn-municipal-success" @click="exportExcel" :disabled="debts.length === 0">Exportar Excel</button>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="debts.length > 0">
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Datos Local</th>
            <th>Nombre Locatario</th>
            <th>Locales Adicionales</th>
            <th>Año</th>
            <th>Periodo de Adeudo</th>
            <th>Cuota</th>
            <th>Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in debts" :key="row.id_energia">
            <td>{{ row.datoslocal }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.local_adicional }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.mesesadeudos }}</td>
            <td>{{ row.cuota | currency }}</td>
            <td>{{ row.adeudo | currency }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total de Adeudos:</strong> {{ totalAdeudo | currency }}<br>
        <strong>Locales con Adeudo:</strong> {{ debts.length }}
      </div>
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'AdeEnergiaGrlPage',
  data() {
    return {
      offices: [
        { id: 1, name: 'Zona Centro' },
        { id: 2, name: 'Zona Olímpica' },
        { id: 3, name: 'Zona Oblatos' },
        { id: 4, name: 'Zona Minerva' },
        { id: 5, name: 'Cruz del Sur' }
      ],
      markets: [],
      years: [],
      months: [],
      filters: {
        office_id: '',
        market_id: '',
        year: '',
        month: ''
      },
      debts: [],
      loading: false,
      error: '',
      totalAdeudo: 0
    };
  },
  created() {
    this.fetchYearsMonths();
  },
  methods: {
    async fetchYearsMonths() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getYearsMonths',
          params: {}
        });
        this.years = res.data.data.years;
        this.months = res.data.data.months;
        if (this.years.length > 0) this.filters.year = this.years[0].axo;
        if (this.months.length > 0) this.filters.month = this.months[0].id;
      } catch (e) {
        this.error = 'Error al cargar años y meses';
      } finally {
        this.loading = false;
      }
    },
    async onOfficeChange() {
      this.loading = true;
      this.markets = [];
      this.filters.market_id = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getMarketsByOffice',
          params: { office_id: this.filters.office_id }
        });
        this.markets = res.data.data;
        if (this.markets.length > 0) this.filters.market_id = this.markets[0].num_mercado_nvo;
      } catch (e) {
        this.error = 'Error al cargar mercados';
      } finally {
        this.loading = false;
      }
    },
    async fetchDebts() {
      this.loading = true;
      this.error = '';
      this.debts = [];
      this.totalAdeudo = 0;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getEnergyDebts',
          params: {
            office_id: this.filters.office_id,
            market_id: this.filters.market_id,
            year: this.filters.year,
            month: this.filters.month
          }
        });
        this.debts = res.data.data;
        this.totalAdeudo = this.debts.reduce((sum, row) => sum + Number(row.adeudo), 0);
      } catch (e) {
        this.error = 'Error al consultar adeudos';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      // Aquí se puede implementar la exportación real
      alert('Funcionalidad de exportación a Excel no implementada en este ejemplo.');
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.ade-energia-grl-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
  padding: 0.5rem 1rem;
  margin-bottom: 1rem;
}
</style>
