<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Energia</h1>
        <p>Mercados - Gestión de Adeudos</p>
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
      <div class="adeudos-energia-page">
          <div class="breadcrumb">
            <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span class="active">Adeudos Energía</span>
          </div>
          <h1>Listado de Adeudos de Energía Eléctrica</h1>
          <div class="form-row">
            <label>Año de Adeudo</label>
            <input type="number" v-model="axo" min="1994" max="2999" />
            <label>Oficina</label>
            <select v-model="oficina">
              <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
            </select>
            <button @click="buscar" :disabled="loading">Buscar</button>
            <button @click="exportarExcel" :disabled="loading || !adeudos.length">Excel</button>
            <button @click="imprimir" :disabled="loading || !adeudos.length">Imprimir</button>
          </div>
          <div v-if="loading" class="loading">Cargando...</div>
          <div v-if="error" class="error">{{ error }}</div>
          <table v-if="adeudos.length" class="municipal-table">
            <thead class="municipal-table-header">
              <tr class="row-hover">
                <th>Rec.</th>
                <th>Merc.</th>
                <th>Cat.</th>
                <th>Sec.</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Bloque</th>
                <th>Consumo</th>
                <th>Nombre</th>
                <th>Adicionales</th>
                <th>Cuota Bim/Mes</th>
                <th>Año Adeudo</th>
                <th>Adeudo</th>
                <th>Periodo Adeudo</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in adeudos" :key="row.id_local + '-' + row.id_energia" class="row-hover">
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local }}</td>
                <td>{{ row.bloque }}</td>
                <td>{{ row.cve_consumo }}</td>
                <td>{{ row.nombre }}</td>
                <td>{{ row.local_adicional }}</td>
                <td>{{ row.cuota | currency }}</td>
                <td>{{ row.axo }}</td>
                <td>{{ row.adeudo | currency }}</td>
                <td>{{ row.meses }}</td>
              </tr>
            </tbody>
          </table>
          <div v-if="!loading && !adeudos.length" class="no-data">No hay datos para los filtros seleccionados.</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'AdeudosEnergia'"
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
  name: 'AdeudosEnergiaPage',
  data() {
    const currentYear = new Date().getFullYear();
    return {
      axo: currentYear,
      oficina: '',
      recaudadoras: [],
      adeudos: [],
      loading: false,
      error: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }};
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return '$' + val.toLocaleString('es-MX', {minimumFractionDigits: 2});
      return val;
    }
  },
  created() {
    this.fetchRecaudadoras();
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
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.getRecaudadoras',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length) this.oficina = this.recaudadoras[0].id_rec;
        } else {
          this.error = res.data.message || 'Error al cargar recaudadoras';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.getAdeudosEnergia',
          payload: {axo: this.axo, oficina: this.oficina}
        });
        if (res.data.status === 'success') {
          this.adeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar adeudos';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      // Puede implementarse descarga de archivo en backend, aquí solo ejemplo
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.exportExcel',
          payload: {axo: this.axo, oficina: this.oficina}
        });
        if (res.data.status === 'success') {
          // El frontend debe convertir res.data.data a Excel (puede usar SheetJS)
          alert('Exportación a Excel simulada. Integrar SheetJS para descarga real.');
        } else {
          this.error = res.data.message || 'Error al exportar';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async imprimir() {
      // Puede implementarse generación de PDF en backend, aquí solo ejemplo
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.printReport',
          payload: {axo: this.axo, oficina: this.oficina}
        });
        if (res.data.status === 'success') {
          // El frontend debe mostrar el PDF generado
          alert('Impresión simulada. Integrar generación de PDF para impresión real.');
        } else {
          this.error = res.data.message || 'Error al imprimir';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
