<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Captura Fecha Energia</h1>
        <p>Mercados - Gestión de Energía</p>
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
      <div class="cons-captura-fecha-energia">
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> / Consulta de Pagos Capturados de Energía Eléctrica
          </div>
          <h1>Detalle de Pagos Capturados de Energía Eléctrica</h1>
          <div class="form-row">
            <label>Fecha de Pago:</label>
            <input type="date" v-model="filters.fecha_pago" />
            <label>Oficina:</label>
            <select v-model="filters.oficina_pago">
              <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">{{ of.id_rec }} - {{ of.recaudadora }}</option>
            </select>
            <label>Caja:</label>
            <select v-model="filters.caja_pago">
              <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
            </select>
            <label>Operación:</label>
            <input type="number" v-model="filters.operacion_pago" />
            <button @click="buscarPagos">Buscar</button>
          </div>
          <div class="municipal-table">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th><input type="checkbox" v-model="selectAll" @change="toggleSelectAll" /></th>
                  <th>Control</th>
                  <th>Datos Local</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha</th>
                  <th>Rec</th>
                  <th>Caja</th>
                  <th>Oper.</th>
                  <th>Cuota Energía</th>
                  <th>Partida</th>
                  <th>Actualización</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_pago_energia" class="row-hover">
                  <td><input type="checkbox" v-model="selected" :value="pago.id_pago_energia" /></td>
                  <td>{{ pago.id_energia }}</td>
                  <td>{{ pago.datoslocal }}</td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.fecha_pago }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td>{{ pago.importe_pago }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>{{ pago.fecha_modificacion }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="actions">
            <button @click="borrarPagos" :disabled="selected.length === 0">Borrar Pago(s)</button>
            <button @click="$router.push('/')">Salir</button>
          </div>
          <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsCapturaFechaEnergia'"
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
  name: 'ConsCapturaFechaEnergia',
  data() {
    return {
      filters: {
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: '',
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
      message: '',
      success: true
    };
  },
  watch: {
    'filters.oficina_pago'(val) {
      this.loadCajas();
    }
  },
  created() {
    this.loadOficinas();
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
    async loadOficinas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getOficinas' })
      });
      const data = await res.json();
      if (data.success) this.oficinas = data.data;
    },
    async loadCajas() {
      if (!this.filters.oficina_pago) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCajasByOficina', params: { oficina: this.filters.oficina_pago } })
      });
      const data = await res.json();
      if (data.success) this.cajas = data.data;
    },
    async buscarPagos() {
      this.message = '';
      this.success = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'getPagosByFecha',
          params: this.filters
        })
      });
      const data = await res.json();
      if (data.success) {
        this.pagos = data.data;
        this.selected = [];
        this.selectAll = false;
      } else {
        this.message = data.message || 'Error al buscar pagos';
        this.success = false;
      }
    },
    toggleSelectAll() {
      if (this.selectAll) {
        this.selected = this.pagos.map(p => p.id_pago_energia);
      } else {
        this.selected = [];
      }
    },
    async borrarPagos() {
      if (!confirm('¿Está seguro de borrar los pagos seleccionados?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'deletePagosEnergia',
          params: {
            pagos_ids: this.selected,
            fecha_pago: this.filters.fecha_pago,
            oficina_pago: this.filters.oficina_pago,
            operacion_pago: this.filters.operacion_pago
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.message = 'Pago(s) eliminado(s) correctamente';
        this.success = true;
        this.buscarPagos();
      } else {
        this.message = data.message || 'Error al borrar pagos';
        this.success = false;
      }
    }
  }
};
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
