<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Captura Fecha</h1>
        <p>Mercados - Consultas</p>
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
      <div class="cons-captura-fecha-page">
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> / Consulta de Pagos Capturados por Mercado
          </div>
          <h2>Detalle de Pagos Capturados</h2>
          <form class="form-inline" @submit.prevent="buscarPagos">
            <label>Fecha Pago:
              <input type="date" v-model="form.fecha" required />
            </label>
            <label>Oficina:
              <select v-model="form.oficina" @change="cargarCajas" required>
                <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">{{ of.recaudadora }}</option>
              </select>
            </label>
            <label>Caja:
              <select v-model="form.caja" required>
                <option v-for="cj in cajas" :key="cj.caja" :value="cj.caja">{{ cj.caja }}</option>
              </select>
            </label>
            <label>Operación:
              <input type="number" v-model="form.operacion" required />
            </label>
            <button type="submit">Buscar</button>
          </form>
          <div v-if="loading" class="loading">Cargando...</div>
          <div v-if="error" class="error">{{ error }}</div>
          <div v-if="pagos.length">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th><input type="checkbox" v-model="selectAll" @change="toggleAll" /></th>
                  <th>Control</th>
                  <th>Datos Local</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha</th>
                  <th>Rec</th>
                  <th>Caja</th>
                  <th>Oper.</th>
                  <th>Renta</th>
                  <th>Partida</th>
                  <th>Actualización</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(pago, idx) in pagos" :key="pago.id_local + '-' + pago.axo + '-' + pago.periodo" class="row-hover">
                  <td><input type="checkbox" v-model="selected" :value="pago" /></td>
                  <td>{{ pago.id_local }}</td>
                  <td>{{ pago.datoslocal }}</td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.fecha_pago | date }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td>{{ pago.importe_pago | currency }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>{{ pago.fecha_modificacion | datetime }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
            </table>
            <button @click="borrarPagos" :disabled="!selected.length">Borrar Pago(s)</button>
          </div>
          <div v-else-if="!loading">No hay pagos para los criterios seleccionados.</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsCapturaFecha'"
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
  name: 'ConsCapturaFechaPage',
  data() {
    return {
      form: {
        fecha: '',
        oficina: '',
        caja: '',
        operacion: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      oficinas: [],
      cajas: [],
      pagos: [],
      selected: [],
      selectAll: false,
      loading: false,
      error: ''
    };
  },
  created() {
    this.cargarOficinas();
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
    async cargarOficinas() {
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: { action: 'getOficinas' }
        });
        this.oficinas = resData.eResponse.data;
      } catch (e) {
        this.error = 'Error cargando oficinas';
      } finally {
        this.loading = false;
      }
    },
    async cargarCajas() {
      if (!this.form.oficina) return;
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: { action: 'getCajasByOficina', params: { oficina: this.form.oficina } }
        });
        this.cajas = resData.eResponse.data;
      } catch (e) {
        this.error = 'Error cargando cajas';
      } finally {
        this.loading = false;
      }
    },
    async buscarPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      this.selected = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'getPagosByFecha',
            params: {
              fecha: this.form.fecha,
              oficina: this.form.oficina,
              caja: this.form.caja,
              operacion: this.form.operacion
            }
          }
        });
        this.pagos = resData.eResponse.data || [];
      } catch (e) {
        this.error = 'Error consultando pagos';
      } finally {
        this.loading = false;
      }
    },
    toggleAll() {
      if (this.selectAll) {
        this.selected = [...this.pagos];
      } else {
        this.selected = [];
      }
    },
    async borrarPagos() {
      if (!confirm('¿Está seguro de borrar los pagos seleccionados?')) return;
      this.loading = true;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          eRequest: {
            action: 'deletePagos',
            params: {
              pagos: this.selected,
              usuario: this.$store.state.usuario.id_usuario
            }
          }
        });
        this.buscarPagos();
      } catch (e) {
        this.error = 'Error borrando pagos';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    datetime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
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
