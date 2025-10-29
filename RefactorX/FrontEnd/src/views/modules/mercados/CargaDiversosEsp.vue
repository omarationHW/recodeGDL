<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Carga Diversos Esp</h1>
        <p>Mercados - Carga de Información</p>
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
      <div class="carga-diversos-esp">
          <h1>Carga Especial de Pagos Realizados por Diversos</h1>
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
              <li class="breadcrumb-item active" aria-current="page">Carga Diversos Especial</li>
            </ol>
          </nav>
          <div class="form-group">
            <label class="municipal-form-label">Fecha de Pago:</label>
            <div class="col-sm-3">
              <input type="date" v-model="fechaPago" class="municipal-form-control" />
            </div>
            <div class="col-sm-2">
              <button class="btn-municipal-primary" @click="buscarAdeudos">Buscar</button>
            </div>
            <div class="col-sm-2">
              <button class="btn btn-success" :disabled="pagos.length === 0" @click="cargarPagos">Grabar</button>
            </div>
            <div class="col-sm-2">
              <button class="btn-municipal-secondary" @click="$router.push('/')">Salir</button>
            </div>
          </div>
          <div v-if="loading" class="alert alert-info">Cargando...</div>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
          <div v-if="adeudos.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th v-for="col in columns" :key="col">{{ col }}</th>
                  <th>Partida</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(row, idx) in adeudos" :key="idx" class="row-hover">
                  <td v-for="col in columns" :key="col">{{ row[col] }}</td>
                  <td>
                    <input type="text" v-model="pagos[idx].partida" class="municipal-form-control" />
                  </td>
                </tr>
              </tbody>
            </table>
            <div class="alert alert-info">
              <b>Nota:</b> Solo se grabarán los pagos con número de partida distinto de vacío o cero.
            </div>
          </div>
          <div v-if="successMsg" class="alert alert-success mt-3">{{ successMsg }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CargaDiversosEsp'"
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
  name: 'CargaDiversosEsp',
  data() {
    return {
      fechaPago: '',
      adeudos: [],
      pagos: [],
      columns: [
        'FECHA', 'REC', 'CAJA', 'OPER', 'AÑO', 'MES', 'RENTA', 'OFN', 'MER', 'CAT', 'SEC', 'LOCAL', 'LET'
      ],
      loading: false,
      error: '',
      successMsg: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }};
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
    async buscarAdeudos() {
      this.loading = true;
      this.error = '';
      this.successMsg = '';
      this.adeudos = [];
      this.pagos = [];
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'getAdeudos',
            data: { fecha_pago: this.fechaPago }
          }
        }
          )
        });
        const respData = await resp.json();
        if (respData.eResponse.status === 'ok') {
          this.adeudos = respData.eResponse.data;
          this.pagos = this.adeudos.map(row => ({ partida: '' }));
        } else {
          this.error = respData.eResponse.message || 'Error al buscar adeudos';
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async cargarPagos() {
      this.loading = true;
      this.error = '';
      this.successMsg = '';
      // Solo pagos con partida válida
      const pagosValidos = this.adeudos.map((row, idx) => {
        return {
          ...row,
          partida: this.pagos[idx].partida
        };
      }).filter(p => p.partida && p.partida !== '0');
      if (pagosValidos.length === 0) {
        this.error = 'No hay pagos válidos para grabar.';
        this.loading = false;
        return;
      }
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'cargarPagos',
            data: {
              pagos: pagosValidos,
              usuario: this.$store.state.usuario_id || 1,
              fecha_pago: this.fechaPago
            }
          }
        }
          )
        });
        const respData = await resp.json();
        if (respData.eResponse.status === 'ok') {
          this.successMsg = 'Pagos cargados correctamente.';
          this.buscarAdeudos();
        } else {
          this.error = respData.eResponse.message || 'Error al grabar pagos';
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
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
