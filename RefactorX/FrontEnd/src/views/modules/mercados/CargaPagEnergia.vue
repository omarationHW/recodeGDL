<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Carga Pag Energia</h1>
        <p>Mercados - Gestión de Pagos</p>
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
      <div class="carga-pag-energia">
          <h1>Carga de Pagos de Energía Eléctrica</h1>
          <div class="form-section">
            <div class="row">
              <label>Recaudadora:</label>
              <select v-model="form.oficina" @change="onOficinaChange">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
              </select>
              <label>Mercado:</label>
              <input v-model="form.mercado" @keyup.enter="buscarAdeudos" />
              <label>Categoria:</label>
              <input v-model="form.categoria" disabled />
              <label>Sección:</label>
              <select v-model="form.seccion">
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.seccion }} - {{ sec.descripcion }}</option>
              </select>
              <label>Local:</label>
              <input v-model="form.local" />
            </div>
            <div class="row">
              <button @click="buscarAdeudos">Buscar Adeudos</button>
            </div>
          </div>
          <div v-if="adeudos.length > 0" class="adeudos-section">
            <h2>Adeudos Encontrados</h2>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Seleccionar</th>
                  <th>Control</th>
                  <th>Rec</th>
                  <th>Merc</th>
                  <th>Cat</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Consumo</th>
                  <th>Kilowhatts</th>
                  <th>Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, idx) in adeudos" :key="adeudo.id_adeudo_energia" class="row-hover">
                  <td><input type="checkbox" v-model="adeudo.selected" /></td>
                  <td>{{ adeudo.id_energia }}</td>
                  <td>{{ adeudo.oficina }}</td>
                  <td>{{ adeudo.num_mercado }}</td>
                  <td>{{ adeudo.categoria }}</td>
                  <td>{{ adeudo.seccion }}</td>
                  <td>{{ adeudo.local }}</td>
                  <td>{{ adeudo.letra_local }}</td>
                  <td>{{ adeudo.bloque }}</td>
                  <td>{{ adeudo.axo }}</td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ adeudo.cve_consumo }}</td>
                  <td>{{ adeudo.cantidad }}</td>
                  <td>{{ adeudo.importe }}</td>
                </tr>
              </tbody>
            </table>
            <div class="form-section">
              <div class="row">
                <label>Fecha de Pago:</label>
                <input type="date" v-model="form.fecha_pago" />
                <label>Oficina Pago:</label>
                <select v-model="form.oficina_pago" @change="onOficinaPagoChange">
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
                </select>
                <label>Caja Pago:</label>
                <select v-model="form.caja_pago">
                  <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
                </select>
                <label>Operación:</label>
                <input v-model="form.operacion_pago" />
                <label>Folio:</label>
                <input v-model="form.folio" />
              </div>
              <div class="row">
                <button @click="cargarPagos">Cargar Pagos</button>
              </div>
            </div>
          </div>
          <div v-if="pagos.length > 0" class="pagos-section">
            <h2>Pagos Cargados</h2>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha Pago</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Operación</th>
                  <th>Importe</th>
                  <th>Consumo</th>
                  <th>Kilowhatts</th>
                  <th>Folio</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="pago.id_pago_energia" class="row-hover">
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.fecha_pago }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td>{{ pago.importe_pago }}</td>
                  <td>{{ pago.cve_consumo }}</td>
                  <td>{{ pago.cantidad }}</td>
                  <td>{{ pago.folio }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="error" class="error">{{ error }}</div>
          <div v-if="success" class="success">{{ success }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CargaPagEnergia'"
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
  name: 'CargaPagEnergia',
  data() {
    return {
      form: {
        oficina: '',
        mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: '',
        folio: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      recaudadoras: [],
      secciones: [],
      cajas: [],
      adeudos: [],
      pagos: [],
      error: '',
      success: ''
    }
  },
  mounted() {
    this.fetchRecaudadoras();
    this.fetchSecciones();
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
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarRecaudadoras' })
      });
      const data = await res.json();
      this.recaudadoras = data.data || [];
    },
    async fetchSecciones() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarSecciones' })
      });
      const data = await res.json();
      this.secciones = data.data || [];
    },
    async onOficinaChange() {
      // Buscar cajas para la recaudadora seleccionada
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarCajas', payload: { oficina: this.form.oficina } })
      });
      const data = await res.json();
      this.cajas = data.data || [];
    },
    async onOficinaPagoChange() {
      // Buscar cajas para la oficina de pago seleccionada
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarCajas', payload: { oficina: this.form.oficina_pago } })
      });
      const data = await res.json();
      this.cajas = data.data || [];
    },
    async buscarAdeudos() {
      this.error = '';
      this.success = '';
      this.adeudos = [];
      this.pagos = [];
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'buscarAdeudosEnergia',
          payload: {
            oficina: this.form.oficina,
            mercado: this.form.mercado,
            categoria: this.form.categoria,
            seccion: this.form.seccion,
            local: this.form.local
          }
        })
      });
      const data = await res.json();
      if (data.error) {
        this.error = data.error;
      } else {
        this.adeudos = (data.data || []).map(a => ({ ...a, selected: false }));
        if (this.adeudos.length > 0) {
          this.form.categoria = this.adeudos[0].categoria;
        }
      }
    },
    async cargarPagos() {
      this.error = '';
      this.success = '';
      const pagosSeleccionados = this.adeudos.filter(a => a.selected);
      if (pagosSeleccionados.length === 0) {
        this.error = 'Debe seleccionar al menos un adeudo para cargar el pago.';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'cargarPagosEnergia',
          payload: {
            pagos: pagosSeleccionados.map(a => ({
              id_energia: a.id_energia,
              axo: a.axo,
              periodo: a.periodo,
              importe: a.importe,
              cve_consumo: a.cve_consumo,
              cantidad: a.cantidad
            })),
            fecha_pago: this.form.fecha_pago,
            oficina_pago: this.form.oficina_pago,
            caja_pago: this.form.caja_pago,
            operacion_pago: this.form.operacion_pago,
            folio: this.form.folio
          }
        })
      });
      const data = await res.json();
      if (data.error) {
        this.error = data.error;
      } else {
        this.success = data.message || 'Pagos cargados correctamente';
        // Consultar pagos cargados
        if (pagosSeleccionados.length > 0) {
          await this.consultarPagos(pagosSeleccionados[0].id_energia);
        }
      }
    },
    async consultarPagos(id_energia) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'consultarPagosEnergia',
          payload: { id_energia }
        })
      });
      const data = await res.json();
      this.pagos = data.data || [];
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
