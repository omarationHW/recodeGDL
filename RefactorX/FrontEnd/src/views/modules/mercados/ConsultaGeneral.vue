<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Consulta General</h1>
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
      <div class="consulta-general-page">
          <nav class="breadcrumb">
            <router-link to="/">Inicio</router-link> /
            <span>Consulta General de Locales</span>
          </nav>
          <h1>Consulta General de Locales</h1>
          <form @submit.prevent="buscarLocal">
            <div class="form-row">
              <label>Recaudadora:</label>
              <select v-model="form.oficina" required>
                <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
              </select>
              <label>Mercado:</label>
              <input v-model="form.num_mercado" type="number" required />
              <label>Categoria:</label>
              <input v-model="form.categoria" type="number" required />
              <label>Sección:</label>
              <select v-model="form.seccion" required>
                <option v-for="sec in secciones" :key="sec.id" :value="sec.id">{{ sec.nombre }}</option>
              </select>
              <label>Local:</label>
              <input v-model="form.local" type="number" required />
              <label>Letra:</label>
              <input v-model="form.letra_local" maxlength="1" />
              <label>Bloque:</label>
              <input v-model="form.bloque" maxlength="1" />
              <button type="submit">Buscar</button>
            </div>
          </form>
          <div v-if="locales.length">
            <h2>Resultados</h2>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Control</th>
                  <th>Nombre</th>
                  <th>Arrendatario</th>
                  <th>Domicilio</th>
                  <th>Sector</th>
                  <th>Zona</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="loc in locales" :key="loc.id_local" class="row-hover">
                  <td>{{ loc.id_local }}</td>
                  <td>{{ loc.nombre }}</td>
                  <td>{{ loc.arrendatario }}</td>
                  <td>{{ loc.domicilio }}</td>
                  <td>{{ loc.sector }}</td>
                  <td>{{ loc.zona }}</td>
                  <td>
                    <button @click="verDetalle(loc.id_local)">Detalle</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="detalle">
            <h2>Detalle del Local</h2>
            <table class="municipal-table">
              <tr class="row-hover"><th>Mercado</th><td>{{ detalle.mercado }}</td></tr>
              <tr class="row-hover"><th>Control</th><td>{{ detalle.id_local }}</td></tr>
              <tr class="row-hover"><th>Nombre</th><td>{{ detalle.nombre }}</td></tr>
              <tr class="row-hover"><th>Arrendatario</th><td>{{ detalle.arrendatario }}</td></tr>
              <tr class="row-hover"><th>Domicilio</th><td>{{ detalle.domicilio }}</td></tr>
              <tr class="row-hover"><th>Sector</th><td>{{ detalle.sector }}</td></tr>
              <tr class="row-hover"><th>Zona</th><td>{{ detalle.zona }}</td></tr>
              <tr class="row-hover"><th>Descripción</th><td>{{ detalle.descripcion_local }}</td></tr>
              <tr class="row-hover"><th>Superficie</th><td>{{ detalle.superficie }}</td></tr>
              <tr class="row-hover"><th>Giro</th><td>{{ detalle.giro }}</td></tr>
              <tr class="row-hover"><th>Fecha Alta</th><td>{{ detalle.fecha_alta }}</td></tr>
              <tr class="row-hover"><th>Fecha Baja</th><td>{{ detalle.fecha_baja }}</td></tr>
              <tr class="row-hover"><th>Vigencia</th><td>{{ detalle.vigencia }}</td></tr>
              <tr class="row-hover"><th>Usuario</th><td>{{ detalle.usuario }}</td></tr>
              <tr class="row-hover"><th>Renta</th><td>{{ detalle.renta }}</td></tr>
            </table>
            <div class="tabs">
              <button :class="{active: tab==='adeudos'}" @click="tab='adeudos'">Adeudos</button>
              <button :class="{active: tab==='pagos'}" @click="tab='pagos'">Pagos</button>
              <button :class="{active: tab==='requerimientos'}" @click="tab='requerimientos'">Requerimientos</button>
            </div>
            <div v-if="tab==='adeudos'">
              <h3>Adeudos</h3>
              <table class="municipal-table">
                <thead class="municipal-table-header"><tr class="row-hover"><th>Año</th><th>Mes</th><th>Importe</th><th>Recargos</th></tr></thead>
                <tbody>
                  <tr v-for="a in adeudos" :key="a.axo+'-'+a.periodo" class="row-hover">
                    <td>{{ a.axo }}</td><td>{{ a.periodo }}</td><td>{{ a.importe }}</td><td>{{ a.recargos }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-if="tab==='pagos'">
              <h3>Pagos</h3>
              <table class="municipal-table">
                <thead class="municipal-table-header"><tr class="row-hover"><th>Año</th><th>Mes</th><th>Fecha Pago</th><th>Importe</th><th>Usuario</th></tr></thead>
                <tbody>
                  <tr v-for="p in pagos" :key="p.axo+'-'+p.periodo" class="row-hover">
                    <td>{{ p.axo }}</td><td>{{ p.periodo }}</td><td>{{ p.fecha_pago }}</td><td>{{ p.importe_pago }}</td><td>{{ p.usuario }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div v-if="tab==='requerimientos'">
              <h3>Requerimientos</h3>
              <table class="municipal-table">
                <thead class="municipal-table-header"><tr class="row-hover"><th>Folio</th><th>Fecha Emisión</th><th>Importe Multa</th><th>Importe Gastos</th><th>Vigencia</th></tr></thead>
                <tbody>
                  <tr v-for="r in requerimientos" :key="r.folio" class="row-hover">
                    <td>{{ r.folio }}</td><td>{{ r.fecha_emision }}</td><td>{{ r.importe_multa }}</td><td>{{ r.importe_gastos }}</td><td>{{ r.vigencia }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsultaGeneral'"
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
  name: 'ConsultaGeneralPage',
  data() {
    return {
      form: {
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
      recaudadoras: [],
      secciones: [],
      locales: [],
      detalle: null,
      adeudos: [],
      pagos: [],
      requerimientos: [],
      tab: 'adeudos',
      error: ''
    }
  },
  created() {
    this.fetchCatalogs();
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
    async fetchCatalogs() {
      // Simulación: en producción, usar API
      this.recaudadoras = [
        {id: 1, nombre: 'Centro'},
        {id: 2, nombre: 'Olimpica'},
        {id: 3, nombre: 'Oblatos'},
        {id: 4, nombre: 'Minerva'},
        {id: 5, nombre: 'Cruz del Sur'}
      ];
      this.secciones = [
        {id: 'SS', nombre: 'Sección SS'},
        {id: 'PS', nombre: 'Sección PS'}
      ];
    },
    async buscarLocal() {
      this.error = '';
      this.locales = [];
      this.detalle = null;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.buscar_local',
          payload: this.form
        }
          )
        });
        const resData = await res.json();
        if (resData.status === 'success') {
          this.locales = resData.data;
        } else {
          this.error = resData.message;
        }
      } catch (error) {
        this.error = error.message;
      }
    },
    async verDetalle(id_local) {
      this.error = '';
      this.detalle = null;
      this.adeudos = [];
      this.pagos = [];
      this.requerimientos = [];
      try {
        // Detalle
        let res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.detalle_local',
          payload: {id_local}
        }
          )
        });
        const resData = await res.json();
        if (resData.status === 'success' && resData.data.length) {
          this.detalle = resData.data[0];
        } else {
          this.error = resData.message;
          return;
        }
        // Adeudos
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.adeudos_local',
          payload: {id_local}
        }
          )
        });
        const resData = await res.json();
        if (resData.status === 'success') {
          this.adeudos = resData.data;
        }
        // Pagos
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.pagos_local',
          payload: {id_local}
        }
          )
        });
        const resData = await res.json();
        if (resData.status === 'success') {
          this.pagos = resData.data;
        }
        // Requerimientos
        res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'mercados.requerimientos_local',
          payload: {id_local}
        }
          )
        });
        const resData = await res.json();
        if (resData.status === 'success') {
          this.requerimientos = resData.data;
        }
      } catch (error) {
        this.error = error.message;
      }
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
