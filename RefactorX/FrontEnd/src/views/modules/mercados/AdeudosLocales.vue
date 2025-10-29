<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Locales</h1>
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
      <div class="adeudos-locales-page">
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
              <li class="breadcrumb-item active" aria-current="page">Adeudos de Mercados</li>
            </ol>
          </nav>
          <h2>Reporte de Adeudos de Mercados</h2>
          <form @submit.prevent="fetchAdeudos">
            <div class="form-row align-items-end">
              <div class="form-group">
                <label for="axo">Año</label>
                <input type="number" min="1992" max="2999" v-model.number="form.axo" class="municipal-form-control" id="axo" required>
              </div>
              <div class="form-group">
                <label for="oficina">Oficina</label>
                <select v-model="form.oficina" class="municipal-form-control" id="oficina" required>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }}</option>
                </select>
              </div>
              <div class="form-group">
                <label for="periodo">Periodo</label>
                <input type="number" min="1" max="12" v-model.number="form.periodo" class="municipal-form-control" id="periodo" required>
              </div>
              <div class="form-group">
                <button type="submit" class="btn-municipal-primary">Consultar</button>
              </div>
              <div class="form-group">
                <button type="button" class="btn btn-success" @click="exportExcel" :disabled="!adeudos.length">Exportar Excel</button>
              </div>
              <div class="form-group">
                <button type="button" class="btn-municipal-secondary" @click="printReport" :disabled="!adeudos.length">Imprimir</button>
              </div>
            </div>
          </form>
          <div v-if="loading" class="alert alert-info mt-3">Cargando datos...</div>
          <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
          <div v-if="adeudos.length" class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Control</th>
                  <th>Rec.</th>
                  <th>Merc.</th>
                  <th>Cat.</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Superficie</th>
                  <th>Renta</th>
                  <th>Adeudo</th>
                  <th>Meses Adeudo</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in adeudos" :key="row.id_local" class="row-hover">
                  <td>{{ row.id_local }}</td>
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td>{{ row.local }}</td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.superficie }}</td>
                  <td>{{ row.RentaCalc | currency }}</td>
                  <td>{{ row.adeudo | currency }}</td>
                  <td>{{ row.meses }}</td>
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
      :componentName="'AdeudosLocales'"
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
  name: 'AdeudosLocalesPage',
  data() {
    return {
      form: {
        axo: new Date().getFullYear(),
        oficina: '',
        periodo: new Date().getMonth() + 1,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      recaudadoras: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
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
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getRecaudadoras' });
        if (res.data.success) {
          this.recaudadoras = res.data.data;
          if (this.recaudadoras.length) this.form.oficina = this.recaudadoras[0].id_rec;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      }
    },
    async fetchAdeudos() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getAdeudosLocales',
          params: {
            axo: this.form.axo,
            oficina: this.form.oficina,
            periodo: this.form.periodo
          }
        });
        if (res.data.success) {
          this.adeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar adeudos';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      } finally {
        this.loading = false;
      }
    },
    async exportExcel() {
      // Puede ser una descarga directa o abrir un modal de progreso
      alert('Funcionalidad de exportación a Excel no implementada en demo.');
    },
    async printReport() {
      // Puede abrir una nueva ventana con el PDF generado
      alert('Funcionalidad de impresión no implementada en demo.');
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
