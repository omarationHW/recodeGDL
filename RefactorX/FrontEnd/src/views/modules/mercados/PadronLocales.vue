<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Padrón de Locales</h1>
        <p>Mercados - Gestión del Padrón de Locales por Recaudadora</p>
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
            Filtros de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Oficina Recaudadora:</label>
              <select class="municipal-form-control" v-model="selectedRecaudadora" id="recaudadora">
                <option value="">Seleccione una recaudadora</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="fetchPadron"
              :disabled="loading || !selectedRecaudadora"
            >
              <font-awesome-icon icon="search" />
              Generar Padrón
            </button>
            <button
              class="btn-municipal-secondary"
              @click="exportPadron('excel')"
              :disabled="loading || !padron.length"
            >
              <font-awesome-icon icon="file-excel" />
              Exportar a Excel
            </button>
            <button
              class="btn-municipal-secondary"
              @click="exportPadron('txt')"
              :disabled="loading || !padron.length"
            >
              <font-awesome-icon icon="file-alt" />
              Exportar a Texto
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de resultados -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Resultados del Padrón
            <span class="badge-info" v-if="padron.length > 0">{{ padron.length }} registros</span>
          </h5>
          <div v-if="loading" class="spinner-border" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
        </div>

        <div class="municipal-card-body table-container" v-if="!loading">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Rec.</th>
                  <th>Merc.</th>
                  <th>Nombre Mercado</th>
                  <th>Cat.</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre Locatario</th>
                  <th>Superficie</th>
                  <th>Renta</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in padron" :key="row.id_local" class="row-hover">
                  <td><span class="badge-secondary">{{ row.oficina }}</span></td>
                  <td><strong class="text-primary">{{ row.num_mercado }}</strong></td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.seccion }}</td>
                  <td><code class="text-muted">{{ row.local }}</code></td>
                  <td>{{ row.letra_local }}</td>
                  <td>{{ row.bloque }}</td>
                  <td>{{ row.nombre }}</td>
                  <td><small class="text-muted">{{ row.superficie }} m²</small></td>
                  <td><strong>{{ currency(row.renta) }}</strong></td>
                </tr>
                <tr v-if="padron.length === 0 && !loading">
                  <td colspan="11" class="text-center text-muted">
                    <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                    <p>No se encontraron registros. Seleccione una recaudadora y genere el padrón.</p>
                  </td>
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
          <p>Cargando padrón de locales...</p>
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
      :componentName="'PadronLocales'"
      :moduleName="'mercados'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

export default {
  name: 'PadronLocalesPage',
  components: {
    DocumentationModal
  },
  data() {
    return {
      recaudadoras: [],
      selectedRecaudadora: '',
      padron: [],
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
  },
  methods: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    openDocumentation() {
      this.showDocumentation = true;
    },
    closeDocumentation() {
      this.showDocumentation = false;
    },
    showToast(type, message) {
      this.toast = {
        show: true,
        type: type,
        message: message
      };
      setTimeout(() => {
        this.hideToast();
      }, 3000);
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
          body: JSON.stringify({ action: 'getRecaudadoras' })
        });
        const data = await res.json();
        if (data.success) {
          this.recaudadoras = data.data;
          if (this.recaudadoras.length) {
            this.selectedRecaudadora = this.recaudadoras[0].id_rec;
          }
          this.showToast('success', 'Recaudadoras cargadas correctamente');
        } else {
          this.error = data.message;
          this.showToast('error', 'Error al cargar recaudadoras');
        }
      } catch (e) {
        this.error = e.message;
        this.showToast('error', `Error: ${e.message}`);
      } finally {
        this.loading = false;
      }
    },
    async fetchPadron() {
      if (!this.selectedRecaudadora) {
        this.showToast('warning', 'Seleccione una recaudadora');
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getPadronLocales',
            params: { recaudadora: this.selectedRecaudadora }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.padron = data.data;
          this.showToast('success', `Padrón cargado: ${this.padron.length} registros`);
        } else {
          this.error = data.message;
          this.showToast('error', 'Error al cargar el padrón');
        }
      } catch (e) {
        this.error = e.message;
        this.showToast('error', `Error: ${e.message}`);
      } finally {
        this.loading = false;
      }
    },
    async exportPadron(format) {
      if (!this.selectedRecaudadora) {
        this.showToast('warning', 'Seleccione una recaudadora');
        return;
      }
      if (!this.padron.length) {
        this.showToast('warning', 'No hay datos para exportar');
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'exportPadronLocales',
            params: { recaudadora: this.selectedRecaudadora, format }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.showToast('success', `Exportación a ${format.toUpperCase()} completada`);
          // Aquí se puede implementar la descarga del archivo
        } else {
          this.error = data.message;
          this.showToast('error', 'Error al exportar');
        }
      } catch (e) {
        this.error = e.message;
        this.showToast('error', `Error: ${e.message}`);
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
