<template>
  <div class="ade-global-locales-page">
    <div v-if="loading" class="global-loading-overlay">
      <div class="spinner"></div>
      <p>Cargando...</p>
    </div>
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span>Adeudo Global con Accesorios</span>
    </div>
    <h1>Listado de Adeudo Global con Accesorios</h1>
    <div class="filters">
      <label>Oficina:
        <select v-model="selectedOffice" @change="onOfficeChange">
          <option v-for="office in offices" :key="office.id" :value="office.id">{{ office.name }}</option>
        </select>
      </label>
      <label>Mercado:
        <select v-model="selectedMarket">
          <option v-for="market in markets" :key="market.num_mercado_nvo" :value="market.num_mercado_nvo">
            {{ market.num_mercado_nvo }} - {{ market.descripcion }}
          </option>
        </select>
      </label>
      <label>Año:
        <input type="number" v-model.number="year" min="1993" max="2999" />
      </label>
      <label>Mes:
        <input type="number" v-model.number="month" min="1" max="12" />
      </label>
      <button @click="fetchAdeGlobalLocales">Buscar</button>
      <button @click="fetchLocalesSinAdeudoConAccesorios">Locales sin Adeudo con Accesorios</button>
      <button @click="exportExcel('adeudos')">Excel 1</button>
      <button @click="exportExcel('sin_adeudo')">Excel 2</button>
    </div>
    <div class="results">
      <h2>Locales con Adeudos y Accesorios</h2>
      <table class="data-table">
        <thead>
          <tr>
            <th>Rec.</th><th>Merc.</th><th>Cat.</th><th>Sec.</th><th>Local</th><th>Letra</th><th>Bloque</th><th>Nombre</th><th>Importe Adeudo</th><th>Importe Recargos</th><th>Importe Multa</th><th>Importe Gastos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeGlobalLocales" :key="row.id_local">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ currency(row.adeudo) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.multa) }}</td>
            <td>{{ currency(row.gastos) }}</td>
          </tr>
        </tbody>
      </table>
      <h2>Locales sin Adeudos con Accesorios</h2>
      <table class="data-table">
        <thead>
          <tr>
            <th>Rec.</th><th>Merc.</th><th>Cat.</th><th>Sec.</th><th>Local</th><th>Letra</th><th>Bloque</th><th>Nombre</th><th>Importe Adeudo</th><th>Importe Recargos</th><th>Importe Multa</th><th>Importe Gastos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in localesSinAdeudo" :key="row.id_local">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ currency(row.adeudo) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.multas) }}</td>
            <td>{{ currency(row.gastos) }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeGlobalLocalesPage',
  data() {
    return {
      loading: true,
      offices: [],
      markets: [],
      selectedOffice: '',
      selectedMarket: '',
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
      adeGlobalLocales: [],
      localesSinAdeudo: []
    };
  },
  created() {
    this.fetchOffices();
  },
  methods: {
    async fetchOffices() {
      try {
        // Simulación: en producción, obtener de API
        this.offices = [
          { id: 1, name: 'Zona Centro' },
          { id: 2, name: 'Zona Olimpica' },
          { id: 3, name: 'Zona Oblatos' },
          { id: 4, name: 'Zona Minerva' },
          { id: 5, name: 'Cruz del Sur' }
        ];
      } finally {
        this.loading = false;
      }
    },
    async onOfficeChange() {
      this.selectedMarket = '';
      // Llamar API para obtener mercados de la oficina
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getMarketsByOffice',
          payload: { office_id: this.selectedOffice }
        });
        if (res.data.status === 'success') {
          this.markets = res.data.data || [];
        }
      } catch (error) {
        console.error('Error loading markets:', error);
        this.markets = [];
      }
    },
    async fetchAdeGlobalLocales() {
      if (!this.selectedOffice || !this.selectedMarket) {
        alert('Seleccione oficina y mercado');
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getAdeGlobalLocales',
          payload: {
            office_id: this.selectedOffice,
            market_id: this.selectedMarket,
            year: this.year,
            month: this.month
          }
        });
        if (res.data.status === 'success') {
          this.adeGlobalLocales = res.data.data || [];
        }
      } catch (error) {
        console.error('Error loading ade global locales:', error);
        this.adeGlobalLocales = [];
      }
    },
    async fetchLocalesSinAdeudoConAccesorios() {
      if (!this.selectedMarket) {
        alert('Seleccione mercado');
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getLocalesSinAdeudoConAccesorios',
          payload: {
            market_id: this.selectedMarket,
            year: this.year,
            month: this.month
          }
        });
        if (res.data.status === 'success') {
          this.localesSinAdeudo = res.data.data || [];
        }
      } catch (error) {
        console.error('Error loading locales sin adeudo:', error);
        this.localesSinAdeudo = [];
      }
    },
    exportExcel(type) {
      // Implementar exportación a Excel si es necesario
      alert('Funcionalidad de exportación a Excel no implementada en este demo.');
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.ade-global-locales-page {
  padding: 24px;
  position: relative;
}
.breadcrumb {
  font-size: 0.9em;
  color: #888;
  margin-bottom: 12px;
}
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
  align-items: center;
}
.filters label {
  font-weight: bold;
}
.results {
  margin-top: 24px;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 32px;
}
.data-table th, .data-table td {
  border: 1px solid #ccc;
  padding: 4px 8px;
  text-align: left;
}
.data-table th {
  background: #f0f0f0;
}
</style>
