<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Ade Global Locales</h1>
        <p>Mercados - Gestión de Locales</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">
      <div class="ade-global-locales-page">
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
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Rec.</th><th>Merc.</th><th>Cat.</th><th>Sec.</th><th>Local</th><th>Letra</th><th>Bloque</th><th>Nombre</th><th>Importe Adeudo</th><th>Importe Recargos</th><th>Importe Multa</th><th>Importe Gastos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in adeGlobalLocales" :key="row.id_local" class="row-hover">
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
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Rec.</th><th>Merc.</th><th>Cat.</th><th>Sec.</th><th>Local</th><th>Letra</th><th>Bloque</th><th>Nombre</th><th>Importe Adeudo</th><th>Importe Recargos</th><th>Importe Multa</th><th>Importe Gastos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in localesSinAdeudo" :key="row.id_local" class="row-hover">
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
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'AdeGlobalLocales'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  components: {
    DocumentationModal
  },
  name: 'AdeGlobalLocalesPage',
  data() {
    return {
      offices: [],
      markets: [],
      selectedOffice: '',
      selectedMarket: '',
      year: new Date().getFullYear(),
      month: new Date().getMonth() + 1,
      adeGlobalLocales: [],
      localesSinAdeudo: [],
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }};
  },
  created() {
    this.fetchOffices();
  },
  methods: {
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = { show: true, type, message };
      setTimeout(() => this.hideToast(), 3000);
    },
    hideToast() {
      this.toast.show = false;
    },
    getToastIcon(type) {
      const icons = {
        success: 'check-circle',
        error: 'exclamation-circle',
        warning: 'exclamation-triangle',
        info: 'info-circle'
      };
      return icons[type] || 'info-circle';
    },
    async fetchOffices() {
      // Simulación: en producción, obtener de API
      this.offices = [
        { id: 1, name: 'Zona Centro' },
        { id: 2, name: 'Zona Olimpica' },
        { id: 3, name: 'Zona Oblatos' },
        { id: 4, name: 'Zona Minerva' },
        { id: 5, name: 'Cruz del Sur' }
      ];
    },
    async onOfficeChange() {
      this.selectedMarket = '';
      // Llamar API para obtener mercados de la oficina
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
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
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
