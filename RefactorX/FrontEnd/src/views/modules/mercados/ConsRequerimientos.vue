<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Cons Requerimientos</h1>
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
      <div class="cons-requerimientos-page">
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> / Consulta de Requerimientos
          </div>
          <h1>Consulta de Requerimientos</h1>
          <form @submit.prevent="buscarLocales">
            <div class="form-row">
              <label>Mercado:</label>
              <select v-model="form.oficinaMercado" required>
                <option v-for="m in mercados" :key="m.id" :value="m.oficina + '-' + m.num_mercado_nvo + '-' + m.categoria">
                  {{ m.oficina }} - {{ m.num_mercado_nvo }} - {{ m.categoria }} - {{ m.descripcion }}
                </option>
              </select>
              <label>Sección:</label>
              <input v-model="form.seccion" maxlength="2" style="width:40px" required />
              <label>Local:</label>
              <input v-model="form.local" maxlength="7" style="width:60px" required />
              <label>Letra:</label>
              <input v-model="form.letra_local" maxlength="1" style="width:30px" />
              <label>Bloque:</label>
              <input v-model="form.bloque" maxlength="1" style="width:30px" />
              <button type="submit">Buscar</button>
            </div>
          </form>
          <div v-if="locales.length">
            <h2>Locales encontrados</h2>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Registro</th>
                  <th>Oficina</th>
                  <th>Mercado</th>
                  <th>Cat</th>
                  <th>Sec</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(l, idx) in locales" :key="l.id_local" class="row-hover">
                  <td>{{ l.calcregistro }}</td>
                  <td>{{ l.oficina }}</td>
                  <td>{{ l.num_mercado }}</td>
                  <td>{{ l.categoria }}</td>
                  <td>{{ l.seccion }}</td>
                  <td>{{ l.local }}</td>
                  <td>{{ l.letra_local }}</td>
                  <td>{{ l.bloque }}</td>
                  <td><button @click="seleccionarLocal(l)">Ver Requerimientos</button></td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="requerimientos.length">
            <h2>Requerimientos del Local</h2>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Folio</th>
                  <th>Fecha Emisión</th>
                  <th>Vigencia</th>
                  <th>Diligencia</th>
                  <th>Practicado</th>
                  <th>Importe Global</th>
                  <th>Importe Multa</th>
                  <th>Importe Recargo</th>
                  <th>Importe Gastos</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(r, idx) in requerimientos" :key="r.id_control" class="row-hover">
                  <td>{{ r.folio }}</td>
                  <td>{{ r.fecha_emision }}</td>
                  <td>{{ r.vigencia }}</td>
                  <td>{{ r.diligencia }}</td>
                  <td>{{ r.clave_practicado }}</td>
                  <td>{{ r.importe_global | currency }}</td>
                  <td>{{ r.importe_multa | currency }}</td>
                  <td>{{ r.importe_recargo | currency }}</td>
                  <td>{{ r.importe_gastos | currency }}</td>
                  <td><button @click="verPeriodos(r)">Ver Periodos</button></td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="periodos.length">
            <h3>Periodos del Requerimiento</h3>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Recargos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="p in periodos" :key="p.id_control + '-' + p.ayo + '-' + p.periodo" class="row-hover">
                  <td>{{ p.ayo }}</td>
                  <td>{{ p.periodo }}</td>
                  <td>{{ p.importe | currency }}</td>
                  <td>{{ p.recargos | currency }}</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="error" class="alert alert-danger">{{ error }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'ConsRequerimientos'"
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
  name: 'ConsRequerimientosPage',
  data() {
    return {
      mercados: [],
      locales: [],
      requerimientos: [],
      periodos: [],
      form: {
        oficinaMercado: '',
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
      selectedLocal: null,
      error: ''
    }
  },
  filters: {
    currency(val) {
      if (val == null) return '';
      return '$' + parseFloat(val).toLocaleString('es-MX', {minimumFractionDigits: 2});
    }
  },
  mounted() {
    this.cargarMercados();
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
    async cargarMercados() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getMercados' });
        if (res.data.success) {
          this.mercados = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async buscarLocales() {
      this.error = '';
      this.locales = [];
      this.requerimientos = [];
      this.periodos = [];
      if (!this.form.oficinaMercado) {
        this.error = 'Seleccione un mercado';
        return;
      }
      const [oficina, num_mercado, categoria] = this.form.oficinaMercado.split('-');
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getLocalesByMercado',
          params: {
            oficina: oficina,
            num_mercado: num_mercado,
            categoria: categoria,
            seccion: this.form.seccion,
            local: this.form.local,
            letra_local: this.form.letra_local,
            bloque: this.form.bloque
          }
        });
        if (res.data.success) {
          this.locales = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async seleccionarLocal(local) {
      this.selectedLocal = local;
      this.requerimientos = [];
      this.periodos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getRequerimientosByLocal',
          params: {
            modulo: 11, // o 12 según el módulo
            control_otr: local.id_local
          }
        });
        if (res.data.success) {
          this.requerimientos = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async verPeriodos(requerimiento) {
      this.periodos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
          action: 'getPeriodosByRequerimiento',
          params: {
            control_otr: requerimiento.control_otr
          }
        });
        if (res.data.success) {
          this.periodos = res.data.data;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
