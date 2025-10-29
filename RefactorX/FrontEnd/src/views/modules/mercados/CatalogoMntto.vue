<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Catalogo Mntto</h1>
        <p>Mercados - Catálogos del Sistema</p>
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
      <div class="catalogo-mntto-page">
          <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
              <li class="breadcrumb-item active" aria-current="page">Catálogo de Mercados</li>
            </ol>
          </nav>
          <h2>Catálogo de Mercados</h2>
          <form @submit.prevent="onSubmit">
            <div class="form-group">
              <label for="oficina">Oficina</label>
              <select v-model="form.oficina" class="municipal-form-control" required>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label for="num_mercado_nvo">Mercado</label>
                <input type="number" v-model="form.num_mercado_nvo" class="municipal-form-control" maxlength="3" required />
              </div>
              <div class="form-group">
                <label for="descripcion">Nombre</label>
                <input type="text" v-model="form.descripcion" class="municipal-form-control" maxlength="30" required />
              </div>
            </div>
            <div class="form-group">
              <label for="categoria">Categoría</label>
              <select v-model="form.categoria" class="municipal-form-control" required>
                <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                  {{ cat.categoria }} - {{ cat.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label for="zona">Zona</label>
              <select v-model="form.zona" class="municipal-form-control" required>
                <option v-for="zona in zonas" :key="zona.id_zona" :value="zona.id_zona">
                  {{ zona.id_zona }} - {{ zona.zona }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label for="cuenta_ingreso">Cuenta Ingreso</label>
              <select v-model="form.cuenta_ingreso" class="municipal-form-control" required>
                <option v-for="cta in cuentas" :key="cta.cta_aplicacion" :value="cta.cta_aplicacion">
                  {{ cta.cta_aplicacion }} - {{ cta.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label>¿El Mercado cobra Energía Eléctrica?</label>
              <select v-model="form.pregunta" class="municipal-form-control" required>
                <option value="S">Sí</option>
                <option value="N">No</option>
              </select>
            </div>
            <div v-if="form.pregunta === 'S'" class="form-group">
              <label for="cuenta_energia">Cuenta Energía</label>
              <select v-model="form.cuenta_energia" class="municipal-form-control">
                <option v-for="cta in cuentas" :key="cta.cta_aplicacion" :value="cta.cta_aplicacion">
                  {{ cta.cta_aplicacion }} - {{ cta.descripcion }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label for="emision">Tipo de Emisión</label>
              <select v-model="form.emision" class="municipal-form-control" required>
                <option value="MASIVA">Masiva</option>
                <option value="DISKETTE">Diskette</option>
                <option value="BAJA">Baja</option>
              </select>
            </div>
            <div class="form-group">
              <button type="submit" class="btn-municipal-primary">{{ editMode ? 'Actualizar' : 'Agregar' }}</button>
              <button type="button" class="btn-municipal-secondary" @click="resetForm">Cancelar</button>
            </div>
          </form>
          <hr />
          <h3>Lista de Mercados</h3>
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr class="row-hover">
                <th>Oficina</th>
                <th>Mercado</th>
                <th>Nombre</th>
                <th>Categoría</th>
                <th>Zona</th>
                <th>Cuenta Ingreso</th>
                <th>Cuenta Energía</th>
                <th>Emisión</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="item in catalogo" :key="item.oficina + '-' + item.num_mercado_nvo" class="row-hover">
                <td>{{ item.oficina }}</td>
                <td>{{ item.num_mercado_nvo }}</td>
                <td>{{ item.descripcion }}</td>
                <td>{{ item.categoria }}</td>
                <td>{{ item.id_zona }}</td>
                <td>{{ item.cuenta_ingreso }}</td>
                <td>{{ item.cuenta_energia || '-' }}</td>
                <td>{{ emisionLabel(item.tipo_emision) }}</td>
                <td>
                  <button class="btn-municipal-info" @click="editItem(item)">Editar</button>
                </td>
              </tr>
            </tbody>
          </table>
          <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">
            {{ message }}
          </div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CatalogoMntto'"
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
  name: 'CatalogoMnttoPage',
  data() {
    return {
      catalogo: [],
      recaudadoras: [],
      categorias: [],
      zonas: [],
      cuentas: [],
      form: {
        oficina: '',
        num_mercado_nvo: '',
        categoria: '',
        descripcion: '',
        cuenta_ingreso: '',
        pregunta: 'N',
        cuenta_energia: '',
        zona: '',
        emision: 'MASIVA',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      editMode: false,
      editKey: null,
      message: '',
      success: true
    }
  },
  created() {
    this.loadCatalogo();
    this.loadRecaudadoras();
    this.loadCategorias();
    this.loadZonas();
    this.loadCuentas();
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
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      });
      return await res.json();
    },
    async loadCatalogo() {
      const res = await this.api('getCatalogoList');
      if (res.success) this.catalogo = res.data;
    },
    async loadRecaudadoras() {
      const res = await this.api('getRecaudadoras');
      if (res.success) this.recaudadoras = res.data;
    },
    async loadCategorias() {
      const res = await this.api('getCategorias');
      if (res.success) this.categorias = res.data;
    },
    async loadZonas() {
      const res = await this.api('getZonas');
      if (res.success) this.zonas = res.data;
    },
    async loadCuentas() {
      const res = await this.api('getCuentas');
      if (res.success) this.cuentas = res.data;
    },
    async onSubmit() {
      this.message = '';
      let params = { ...this.form };
      if (this.form.pregunta !== 'S') params.cuenta_energia = null;
      let action = this.editMode ? 'updateCatalogo' : 'insertCatalogo';
      const res = await this.api(action, params);
      this.success = res.success;
      this.message = res.message || (res.success ? 'Operación exitosa' : 'Error en la operación');
      if (res.success) {
        this.resetForm();
        this.loadCatalogo();
      }
    },
    editItem(item) {
      this.editMode = true;
      this.editKey = item.oficina + '-' + item.num_mercado_nvo;
      this.form = {
        oficina: item.oficina,
        num_mercado_nvo: item.num_mercado_nvo,
        categoria: item.categoria,
        descripcion: item.descripcion,
        cuenta_ingreso: item.cuenta_ingreso,
        pregunta: item.cuenta_energia ? 'S' : 'N',
        cuenta_energia: item.cuenta_energia || '',
        zona: item.id_zona,
        emision: this.emisionLabel(item.tipo_emision, true)
      };
    },
    resetForm() {
      this.editMode = false;
      this.editKey = null;
      this.form = {
        oficina: '',
        num_mercado_nvo: '',
        categoria: '',
        descripcion: '',
        cuenta_ingreso: '',
        pregunta: 'N',
        cuenta_energia: '',
        zona: '',
        emision: 'MASIVA'
      };
    },
    emisionLabel(val, reverse = false) {
      if (reverse) {
        if (val === 'M') return 'MASIVA';
        if (val === 'D') return 'DISKETTE';
        if (val === 'B') return 'BAJA';
        return val;
      }
      if (val === 'M' || val === 'MASIVA') return 'Masiva';
      if (val === 'D' || val === 'DISKETTE') return 'Diskette';
      if (val === 'B' || val === 'BAJA') return 'Baja';
      return val;
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
