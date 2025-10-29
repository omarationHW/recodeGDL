<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Pagos Energia</h1>
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
      <div class="cons-pagos-energia-page">
          <h1>Consulta de Pagos de Energía</h1>
          <nav class="breadcrumb">
            <span>Inicio</span> &gt; <span>Consultas</span> &gt; <span>Pagos de Energía</span>
          </nav>
          <div class="municipal-card">
            <div class="municipal-card">
              <strong>Clasificación</strong>
            </div>
            <div class="municipal-card">
              <div class="form-group">
                <label><input type="radio" v-model="searchType" value="local" /> Por Local</label>
                <label><input type="radio" v-model="searchType" value="fecha_pago" /> Por Fecha de Pago</label>
              </div>
              <div v-if="searchType==='local'">
                <div class="row">
                  <div class="col">
                    <label>Recaudadora</label>
                    <select v-model="formLocal.oficina" @change="onRecaudadoraChange">
                      <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
                    </select>
                  </div>
                  <div class="col">
                    <label>Mercado</label>
                    <input v-model="formLocal.num_mercado" maxlength="3" />
                  </div>
                  <div class="col">
                    <label>Categoria</label>
                    <input v-model="formLocal.categoria" maxlength="1" />
                  </div>
                  <div class="col">
                    <label>Sección</label>
                    <select v-model="formLocal.seccion">
                      <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.descripcion }}</option>
                    </select>
                  </div>
                  <div class="col">
                    <label>Local</label>
                    <input v-model="formLocal.local" maxlength="5" />
                  </div>
                  <div class="col">
                    <label>Letra</label>
                    <input v-model="formLocal.letra_local" maxlength="1" />
                  </div>
                  <div class="col">
                    <label>Bloque</label>
                    <input v-model="formLocal.bloque" maxlength="1" />
                  </div>
                </div>
              </div>
              <div v-if="searchType==='fecha_pago'">
                <div class="row">
                  <div class="col">
                    <label>Fecha de Pago</label>
                    <input type="date" v-model="formFechaPago.fecha_pago" />
                  </div>
                  <div class="col">
                    <label>Oficina</label>
                    <select v-model="formFechaPago.oficina_pago" @change="onOficinaPagoChange">
                      <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
                    </select>
                  </div>
                  <div class="col">
                    <label>Caja</label>
                    <select v-model="formFechaPago.caja_pago">
                      <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
                    </select>
                  </div>
                  <div class="col">
                    <label>Operación</label>
                    <input v-model="formFechaPago.operacion_pago" maxlength="5" />
                  </div>
                </div>
              </div>
              <div class="form-group">
                <button @click="buscar" class="btn-municipal-primary">Buscar</button>
                <button @click="limpiar" class="btn-municipal-secondary">Limpiar</button>
              </div>
            </div>
          </div>
          <div class="municipal-card" v-if="resultados.length">
            <div class="municipal-card">
              <strong>Resultados</strong>
            </div>
            <div class="municipal-card">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr class="row-hover">
                    <th>Control</th>
                    <th>Rec.</th>
                    <th>Mercado</th>
                    <th>Cat.</th>
                    <th>Sec.</th>
                    <th>Local</th>
                    <th>Letra</th>
                    <th>Bloque</th>
                    <th>Año</th>
                    <th>Mes</th>
                    <th>Fecha Pago</th>
                    <th>Oficina Pago</th>
                    <th>Caja</th>
                    <th>Operación</th>
                    <th>Importe</th>
                    <th>Folio</th>
                    <th>Usuario</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="row in resultados" :key="row.id_pago_energia" class="row-hover">
                    <td>{{ row.id_local }}</td>
                    <td>{{ row.oficina }}</td>
                    <td>{{ row.num_mercado }}</td>
                    <td>{{ row.categoria }}</td>
                    <td>{{ row.seccion }}</td>
                    <td>{{ row.local }}</td>
                    <td>{{ row.letra_local }}</td>
                    <td>{{ row.bloque }}</td>
                    <td>{{ row.axo }}</td>
                    <td>{{ row.periodo }}</td>
                    <td>{{ row.fecha_pago }}</td>
                    <td>{{ row.oficina_pago }}</td>
                    <td>{{ row.caja_pago }}</td>
                    <td>{{ row.operacion_pago }}</td>
                    <td>{{ row.importe_pago }}</td>
                    <td>{{ row.folio }}</td>
                    <td>{{ row.usuario }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsPagosEnergia'"
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
  name: 'ConsPagosEnergiaPage',
  data() {
    return {
      searchType: 'local',
      recaudadoras: [],
      secciones: [],
      cajas: [],
      resultados: [],
      formLocal: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      formFechaPago: {
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      }
    }
  },
  mounted() {
    this.loadRecaudadoras();
    this.loadSecciones();
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
    async loadRecaudadoras() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'getRecaudadoras' } })
      });
      const data = await res.json();
      this.recaudadoras = data.eResponse.data;
    },
    async loadSecciones() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'getSecciones' } })
      });
      const data = await res.json();
      this.secciones = data.eResponse.data;
    },
    async onRecaudadoraChange() {
      // Opcional: cargar mercados si se requiere
    },
    async onOficinaPagoChange() {
      if (!this.formFechaPago.oficina_pago) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'getCajasByOficina', params: { oficina: this.formFechaPago.oficina_pago } } })
      });
      const data = await res.json();
      this.cajas = data.eResponse.data;
    },
    async buscar() {
      let action = '';
      let params = {};
      if (this.searchType === 'local') {
        action = 'searchByLocal';
        params = { ...this.formLocal, orden: 'axo,periodo' };
      } else {
        action = 'searchByFechaPago';
        params = { ...this.formFechaPago, orden: 'fecha_pago,oficina_pago,caja_pago,operacion_pago' };
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const data = await res.json();
      this.resultados = data.eResponse.data || [];
    },
    limpiar() {
      this.resultados = [];
      this.formLocal = { oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '' };
      this.formFechaPago = { fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '' };
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
