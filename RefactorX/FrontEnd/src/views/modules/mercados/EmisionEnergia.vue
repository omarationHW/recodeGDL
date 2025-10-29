<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice" />
      </div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Energía Eléctrica</h1>
        <p>Mercados - Emisión y Facturación de Energía</p>
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
      <!-- Filtros de Selección -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Parámetros de Emisión
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Recaudadora</label>
              <select
                class="municipal-form-control"
                v-model="form.oficina"
                @change="onRecaudadoraChange"
                :disabled="loading"
              >
                <option value="">Seleccione una recaudadora</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Mercado</label>
              <select
                class="municipal-form-control"
                v-model="form.mercado"
                :disabled="loading || !form.oficina"
              >
                <option value="">Seleccione un mercado</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Año</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="form.axo"
                min="2003"
                :max="new Date().getFullYear() + 1"
                :disabled="loading"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Periodo (Mes)</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="form.periodo"
                min="1"
                max="12"
                :disabled="loading"
              />
            </div>
          </div>
          <div class="button-group">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="onEjecutar"
              :disabled="loading || !form.oficina || !form.mercado"
            >
              <font-awesome-icon icon="file-invoice" />
              Emisión
            </button>
            <button
              type="button"
              class="btn-municipal-success"
              @click="onGrabar"
              :disabled="loading || !emision.length"
            >
              <font-awesome-icon icon="save" />
              Grabar
            </button>
            <button
              type="button"
              class="btn-municipal-info"
              @click="onFacturacion"
              :disabled="loading || !form.oficina || !form.mercado"
            >
              <font-awesome-icon icon="receipt" />
              Facturación
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="onSalir"
              :disabled="loading"
            >
              <font-awesome-icon icon="times" />
              Salir
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de Resultados -->
      <div class="municipal-card" v-if="emision.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Detalle de Emisión
            <span class="badge-info">{{ emision.length }} registros</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Local</th>
                  <th>Nombre</th>
                  <th>Descripción</th>
                  <th>Importe</th>
                  <th>Consumo</th>
                  <th>Cantidad</th>
                  <th>Importe Energía</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in emision" :key="row.id_energia" class="row-hover">
                  <td><strong class="text-primary">{{ row.local }}</strong></td>
                  <td>{{ row.nombre }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td><strong>{{ formatCurrency(row.importe) }}</strong></td>
                  <td><span class="badge-info">{{ row.cve_consumo }}</span></td>
                  <td>{{ row.cantidad }}</td>
                  <td><strong>{{ formatCurrency(row.importe_energia) }}</strong></td>
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
          <p>Procesando...</p>
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
      :componentName="'EmisionEnergia'"
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
  name: 'EmisionEnergiaPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      emision: [],
      form: {
        oficina: '',
        mercado: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1
      },
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      },
      loading: false
    };
  },
  created() {
    this.loadRecaudadoras();
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
    async api(action, params = {}) {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ eRequest: { action, params } })
        });
        const json = await res.json();
        return json.eResponse;
      } catch (error) {
        this.showToast('error', 'Error de conexión: ' + error.message);
        return { status: 'error', message: error.message };
      }
    },
    async loadRecaudadoras() {
      this.loading = true;
      const resp = await this.api('getRecaudadoras');
      if (resp.status === 'ok') {
        this.recaudadoras = resp.data || [];
        this.showToast('success', 'Recaudadoras cargadas');
      } else {
        this.showToast('error', 'Error al cargar recaudadoras');
      }
      this.loading = false;
    },
    async onRecaudadoraChange() {
      this.form.mercado = '';
      this.mercados = [];
      if (this.form.oficina) {
        this.loading = true;
        const resp = await this.api('getMercadosByRecaudadora', { oficina: this.form.oficina });
        if (resp.status === 'ok') {
          this.mercados = resp.data || [];
          this.showToast('success', `${this.mercados.length} mercados encontrados`);
        } else {
          this.showToast('error', 'Error al cargar mercados');
        }
        this.loading = false;
      }
    },
    async onEjecutar() {
      if (!this.form.oficina || !this.form.mercado) {
        this.showToast('warning', 'Debe seleccionar recaudadora y mercado');
        return;
      }

      this.loading = true;
      const resp = await this.api('getEmisionEnergia', {
        oficina: this.form.oficina,
        mercado: this.form.mercado,
        axo: this.form.axo,
        periodo: this.form.periodo
      });

      if (resp.status === 'ok') {
        this.emision = resp.data || [];
        if (this.emision.length === 0) {
          this.showToast('warning', 'No hay datos para la emisión');
        } else {
          this.showToast('success', `${this.emision.length} registros cargados`);
        }
      } else {
        this.emision = [];
        this.showToast('error', resp.message || 'Error al ejecutar emisión');
      }
      this.loading = false;
    },
    async onGrabar() {
      if (!this.form.oficina || !this.form.mercado) {
        this.showToast('warning', 'Debe seleccionar recaudadora y mercado');
        return;
      }

      if (!this.emision.length) {
        this.showToast('warning', 'No hay datos para grabar');
        return;
      }

      this.loading = true;
      const usuario = 1; // TODO: obtener usuario logueado
      const resp = await this.api('grabarEmisionEnergia', {
        oficina: this.form.oficina,
        mercado: this.form.mercado,
        axo: this.form.axo,
        periodo: this.form.periodo,
        usuario
      });

      if (resp.status === 'ok') {
        this.showToast('success', resp.message || 'Emisión grabada correctamente');
      } else {
        this.showToast('error', resp.message || 'Error al grabar emisión');
      }
      this.loading = false;
    },
    async onFacturacion() {
      if (!this.form.oficina || !this.form.mercado) {
        this.showToast('warning', 'Debe seleccionar recaudadora y mercado');
        return;
      }

      this.loading = true;
      const resp = await this.api('facturarEmisionEnergia', {
        oficina: this.form.oficina,
        mercado: this.form.mercado,
        axo: this.form.axo,
        periodo: this.form.periodo
      });

      if (resp.status === 'ok') {
        this.showToast('success', 'Facturación generada correctamente');
        // Aquí podría abrir un PDF, mostrar datos, etc.
      } else {
        this.showToast('error', resp.message || 'Error al generar facturación');
      }
      this.loading = false;
    },
    onSalir() {
      this.$router.push('/mercados');
    },
    formatCurrency(value) {
      if (value == null || value === '') return '$0.00';
      return '$' + parseFloat(value).toLocaleString('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    }
  }
};
</script>

<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
