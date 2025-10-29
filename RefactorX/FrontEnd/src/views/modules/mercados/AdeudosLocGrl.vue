<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Adeudos Loc Grl</h1>
        <p>Mercados - Gestión de Adeudos</p>
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
      <div class="adeudos-loc-grl-page">
          <h1>Adeudos Generales del Mercado</h1>
          <div class="breadcrumb">
            <router-link to="/">Inicio</router-link> / Adeudos Generales
          </div>
          <form @submit.prevent="buscar">
            <div class="form-row">
              <label>Oficina:</label>
              <select v-model="selectedRec" @change="onRecChange">
                <option value="">Seleccione</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
              </select>
              <label>Mercado:</label>
              <select v-model="selectedMercado">
                <option value="">000-TODOS LOS MERCADOS</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
              </select>
            </div>
            <div class="form-row">
              <label>Año:</label>
              <input type="number" v-model.number="axo" min="1995" max="2999" />
              <label>Mes:</label>
              <input type="number" v-model.number="mes" min="1" max="12" />
              <button type="submit">Buscar</button>
              <button type="button" @click="exportarExcel">Exportar Excel</button>
            </div>
          </form>
          <div v-if="loading" class="loading">Cargando...</div>
          <div v-if="error" class="error">{{ error }}</div>
          <table v-if="adeudos.length" class="municipal-table">
            <thead class="municipal-table-header">
              <tr class="row-hover">
                <th>Oficina</th>
                <th>Mercado</th>
                <th>Cat.</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Bloque</th>
                <th>Nombre</th>
                <th>Superficie</th>
                <th>Clave Cuota</th>
                <th>Adeudo</th>
                <th>Recaudadora</th>
                <th>Descripción</th>
                <th>Meses</th>
                <th>Renta</th>
                <th>Folios Req.</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in adeudos" :key="row.id_local + '-' + row.axo" class="row-hover">
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local }}</td>
                <td>{{ row.bloque }}</td>
                <td>{{ row.nombre }}</td>
                <td>{{ row.superficie }}</td>
                <td>{{ row.clave_cuota }}</td>
                <td>{{ row.adeudo | currency }}</td>
                <td>{{ row.recaudadora }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.meses }}</td>
                <td>{{ row.renta | currency }}</td>
                <td>{{ row.folios }}</td>
              </tr>
            </tbody>
          </table>
          <div v-if="!loading && !adeudos.length && searched">No se encontraron resultados.</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'AdeudosLocGrl'"
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
  name: 'AdeudosLocGrlPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      selectedRec: '',
      selectedMercado: '',
      axo: new Date().getFullYear(),
      mes: new Date().getMonth() + 1,
      adeudos: [],
      loading: false,
      error: '',
      searched: false,
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }}
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return '$' + val.toLocaleString('es-MX', {minimumFractionDigits: 2});
      return val;
    }
  },
  created() {
    this.fetchRecaudadoras();
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
          body: JSON.stringify({ action: 'getRecaudadoras' })
        });
        const data = await res.json();
        if (data.success) {
          this.recaudadoras = data.data;
        } else {
          this.error = data.message || 'Error al cargar recaudadoras';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async onRecChange() {
      this.selectedMercado = '';
      if (!this.selectedRec) {
        this.mercados = [];
        return;
      }
      this.loading = true;
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getMercadosByRecaudadora', params: { id_rec: this.selectedRec } })
        });
        const data = await res.json();
        if (data.success) {
          this.mercados = data.data;
        } else {
          this.error = data.message || 'Error al cargar mercados';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      this.searched = false;
      try {
        if (!this.selectedRec) {
          this.error = 'Debe seleccionar una recaudadora';
          this.loading = false;
          return;
        }
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'getAdeudosLocalesGrl',
            params: {
              id_rec: this.selectedRec,
              num_mercado: this.selectedMercado || null,
              axo: this.axo,
              mes: this.mes
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.adeudos = data.data;
        } else {
          this.error = data.message || 'Error al consultar adeudos';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
        this.searched = true;
      }
    },
    exportarExcel() {
      alert('Exportación a Excel debe implementarse en backend o como descarga CSV en frontend.');
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
