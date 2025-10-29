<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="chart-bar" />
      </div>
      <div class="module-view-info">
        <h1>Estadística de Pagos y Adeudos</h1>
        <p>Mercados - Reportes Estadísticos de Pagos y Adeudos</p>
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
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Consulta
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="onConsultar">
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label" for="recaudadora">Recaudadora:</label>
                <select class="municipal-form-control" v-model="form.rec" id="recaudadora" required>
                  <option value="">Seleccione una recaudadora</option>
                  <option v-for="r in recs" :key="r.id_rec" :value="r.id_rec">
                    {{ r.id_rec }} - {{ r.recaudadora }}
                  </option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label" for="axo">Año:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.axo"
                  id="axo"
                  min="1995"
                  max="2100"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label" for="mes">Mes:</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="form.mes"
                  id="mes"
                  min="1"
                  max="12"
                  required
                />
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label" for="fecdsd">Fecha Desde:</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="form.fecdsd"
                  id="fecdsd"
                  required
                />
              </div>
              <div class="form-group">
                <label class="municipal-form-label" for="fechst">Fecha Hasta:</label>
                <input
                  type="date"
                  class="municipal-form-control"
                  v-model="form.fechst"
                  id="fechst"
                  required
                />
              </div>
            </div>
            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                Consultar
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="onExport"
                :disabled="loading || !result.length"
              >
                <font-awesome-icon icon="file-export" />
                Exportar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card" v-if="result && result.length">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Resultados de la Consulta
            <span class="badge-info">{{ result.length }} mercados</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
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
                <tr v-for="row in result" :key="row.num_mercado_nvo" class="row-hover">
                  <td><strong class="text-primary">{{ row.num_mercado_nvo }}</strong></td>
                  <td>{{ row.descripcion }}</td>
                  <td><span class="badge-success">{{ row.localpag }}</span></td>
                  <td><strong>{{ currency(row.pagospag) }}</strong></td>
                  <td>{{ row.periodospag }}</td>
                  <td><span class="badge-info">{{ row.localcap }}</span></td>
                  <td><strong>{{ currency(row.pagoscap) }}</strong></td>
                  <td>{{ row.periodoscap }}</td>
                  <td><span class="badge-danger">{{ row.localade }}</span></td>
                  <td><strong class="text-danger">{{ currency(row.pagosade) }}</strong></td>
                  <td>{{ row.periodosade }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando estadísticas...</p>
        </div>
      </div>

      <!-- Toast Notifications -->
      <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
        <button class="toast-close" @click="hideToast">
          <font-awesome-icon icon="times" />
        </button>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'EstadPagosyAdeudos'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  name: 'EstadPagosyAdeudosPage',
  components: {
    DocumentationModal
  },
  data() {
    return {
      recs: [],
      form: {
        rec: '',
        axo: new Date().getFullYear(),
        mes: new Date().getMonth() + 1,
        fecdsd: '',
        fechst: ''
      },
      result: [],
      loading: false,
      error: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }
    };
  },
  created() {
    this.fetchRecaudadoras();
    this.form.fecdsd = this.formatDate(new Date());
    this.form.fechst = this.formatDate(new Date());
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
            eRequest: {
              action: 'getRecaudadoras',
              params: {}
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.recs = data.eResponse.data;
          if (this.recs.length) this.form.rec = this.recs[0].id_rec;
          this.showToast('success', 'Recaudadoras cargadas correctamente');
        } else {
          this.error = data.eResponse.message;
          this.showToast('error', 'Error al cargar recaudadoras');
        }
      } catch (e) {
        this.error = e.message;
        this.showToast('error', `Error: ${e.message}`);
      } finally {
        this.loading = false;
      }
    },
    async onConsultar() {
      this.loading = true;
      this.error = '';
      this.result = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'getEstadisticaPagosyAdeudos',
              params: {
                rec: this.form.rec,
                axo: this.form.axo,
                mes: this.form.mes,
                fecdsd: this.form.fecdsd,
                fechst: this.form.fechst
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.result = data.eResponse.data;
          this.showToast('success', `Consulta exitosa: ${this.result.length} mercados encontrados`);
        } else {
          this.error = data.eResponse.message;
          this.showToast('error', 'Error al consultar estadísticas');
        }
      } catch (e) {
        this.error = e.message;
        this.showToast('error', `Error: ${e.message}`);
      } finally {
        this.loading = false;
      }
    },
    onExport() {
      this.showToast('info', 'Funcionalidad de exportación próximamente');
    },
    formatDate(date) {
      const d = new Date(date);
      const month = '' + (d.getMonth() + 1).toString().padStart(2, '0');
      const day = '' + d.getDate().toString().padStart(2, '0');
      const year = d.getFullYear();
      return `${year}-${month}-${day}`;
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
