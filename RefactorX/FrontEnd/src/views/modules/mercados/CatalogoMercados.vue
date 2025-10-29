<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Catalogo Mercados</h1>
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
      <div class="catalogo-mercados-page">
          <nav aria-label="breadcrumb" class="mb-3">
            <ol class="breadcrumb">
              <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
              <li class="breadcrumb-item active" aria-current="page">Catálogo de Mercados</li>
            </ol>
          </nav>
          <h2>Catálogo de Mercados</h2>
          <div class="mb-3">
            <button class="btn-municipal-primary" @click="showForm('create')">Agregar Mercado</button>
            <button class="btn-municipal-secondary" @click="fetchData">Refrescar</button>
            <button class="btn-municipal-info" @click="showReport">Reporte</button>
          </div>
          <div v-if="showFormMode">
            <div class="municipal-card">
              <div class="municipal-card">
                {{ formMode === 'create' ? 'Agregar Mercado' : 'Modificar Mercado' }}
              </div>
              <div class="municipal-card">
                <form @submit.prevent="submitForm">
                  <div class="form-row">
                    <div class="form-group">
                      <label>Oficina</label>
                      <input type="number" v-model.number="form.oficina" class="municipal-form-control" required :readonly="formMode==='update'" />
                    </div>
                    <div class="form-group">
                      <label>Núm. Mercado</label>
                      <input type="number" v-model.number="form.num_mercado_nvo" class="municipal-form-control" required :readonly="formMode==='update'" />
                    </div>
                    <div class="form-group">
                      <label>Categoría</label>
                      <input type="number" v-model.number="form.categoria" class="municipal-form-control" required />
                    </div>
                    <div class="form-group">
                      <label>Descripción</label>
                      <input type="text" v-model="form.descripcion" class="municipal-form-control" required maxlength="30" />
                    </div>
                  </div>
                  <div class="form-row">
                    <div class="form-group">
                      <label>Cuenta Ingreso</label>
                      <input type="number" v-model.number="form.cuenta_ingreso" class="municipal-form-control" required />
                    </div>
                    <div class="form-group">
                      <label>Cuenta Energía</label>
                      <input type="number" v-model.number="form.cuenta_energia" class="municipal-form-control" />
                    </div>
                    <div class="form-group">
                      <label>ID Zona</label>
                      <input type="number" v-model.number="form.id_zona" class="municipal-form-control" required />
                    </div>
                    <div class="form-group">
                      <label>Tipo Emisión</label>
                      <select v-model="form.tipo_emision" class="municipal-form-control" required>
                        <option value="M">Masiva</option>
                        <option value="D">Disquette</option>
                        <option value="B">Baja</option>
                      </select>
                    </div>
                  </div>
                  <div class="form-group">
                    <button type="submit" class="btn btn-success">Guardar</button>
                    <button type="button" class="btn-municipal-secondary" @click="cancelForm">Cancelar</button>
                  </div>
                </form>
              </div>
            </div>
          </div>
          <div v-if="!showFormMode">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr class="row-hover">
                  <th>Oficina</th>
                  <th>Núm. Mercado</th>
                  <th>Categoría</th>
                  <th>Descripción</th>
                  <th>Cuenta Ingreso</th>
                  <th>Cuenta Energía</th>
                  <th>ID Zona</th>
                  <th>Tipo Emisión</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in rows" :key="row.oficina + '-' + row.num_mercado_nvo" class="row-hover">
                  <td>{{ row.oficina }}</td>
                  <td>{{ row.num_mercado_nvo }}</td>
                  <td>{{ row.categoria }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.cuenta_ingreso }}</td>
                  <td>{{ row.cuenta_energia }}</td>
                  <td>{{ row.id_zona }}</td>
                  <td>{{ tipoEmisionLabel(row.tipo_emision) }}</td>
                  <td>
                    <button class="btn btn-sm btn-warning" @click="showForm('update', row)">Editar</button>
                    <button class="btn btn-sm btn-danger ml-1" @click="deleteRow(row)">Eliminar</button>
                  </td>
                </tr>
                <tr v-if="rows.length === 0" class="row-hover">
                  <td colspan="9" class="text-center">No hay registros</td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-if="showReportDialog">
            <div class="modal-backdrop show"></div>
            <div class="modal d-block" tabindex="-1">
              <div class="modal-dialog modal-lg">
                <div class="modal-content">
                  <div class="modal-header">
                    <h5 class="modal-title">Reporte Catálogo de Mercados</h5>
                    <button type="button" class="close" @click="showReportDialog=false">&times;</button>
                  </div>
                  <div class="modal-body">
                    <table class="municipal-table">
                      <thead class="municipal-table-header">
                        <tr class="row-hover">
                          <th>Oficina</th>
                          <th>Núm. Mercado</th>
                          <th>Categoría</th>
                          <th>Descripción</th>
                          <th>Cuenta Ingreso</th>
                          <th>Cuenta Energía</th>
                          <th>ID Zona</th>
                          <th>Tipo Emisión</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr v-for="row in reportRows" :key="row.oficina + '-' + row.num_mercado_nvo" class="row-hover">
                          <td>{{ row.oficina }}</td>
                          <td>{{ row.num_mercado_nvo }}</td>
                          <td>{{ row.categoria }}</td>
                          <td>{{ row.descripcion }}</td>
                          <td>{{ row.cuenta_ingreso }}</td>
                          <td>{{ row.cuenta_energia }}</td>
                          <td>{{ row.id_zona }}</td>
                          <td>{{ tipoEmisionLabel(row.tipo_emision) }}</td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                  <div class="modal-footer">
                    <button class="btn-municipal-secondary" @click="showReportDialog=false">Cerrar</button>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div v-if="errorMessage" class="alert alert-danger mt-3">{{ errorMessage }}</div>
          <div v-if="successMessage" class="alert alert-success mt-3">{{ successMessage }}</div>
        </div>
    </div>
    <!-- /module-view-content -->

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'CatalogoMercados'"
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
  name: 'CatalogoMercadosPage',
  data() {
    return {
      rows: [],
      reportRows: [],
      showFormMode: false,
      formMode: 'create',
      form: {
        oficina: '',
        num_mercado_nvo: '',
        categoria: '',
        descripcion: '',
        cuenta_ingreso: '',
        cuenta_energia: '',
        id_zona: '',
        tipo_emision: 'M',
      showDocumentation: false,
      toast: {
        show: false,
        type: 'info',
        message: ''
      }},
      errorMessage: '',
      successMessage: '',
      showReportDialog: false
    }
  },
  created() {
    this.fetchData();
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
    tipoEmisionLabel(val) {
      if (val === 'M') return 'Masiva';
      if (val === 'D') return 'Disquette';
      if (val === 'B') return 'Baja';
      return val;
    },
    fetchData() {
      this.errorMessage = '';
      this.successMessage = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list', module: 'catalogo_mercados' })
      })
        .then(r => r.json())
        .then(json => {
          if (json.success) {
            this.rows = json.data;
          } else {
            this.errorMessage = json.message || 'Error al cargar datos';
          }
        })
        .catch(() => this.errorMessage = 'Error de red');
    },
    showForm(mode, row = null) {
      this.formMode = mode;
      this.showFormMode = true;
      this.errorMessage = '';
      this.successMessage = '';
      if (mode === 'create') {
        this.form = {
          oficina: '',
          num_mercado_nvo: '',
          categoria: '',
          descripcion: '',
          cuenta_ingreso: '',
          cuenta_energia: '',
          id_zona: '',
          tipo_emision: 'M'
        };
      } else if (mode === 'update' && row) {
        this.form = { ...row };
      }
    },
    cancelForm() {
      this.showFormMode = false;
    },
    submitForm() {
      this.errorMessage = '';
      this.successMessage = '';
      const action = this.formMode === 'create' ? 'create' : 'update';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, module: 'catalogo_mercados', payload: this.form })
      })
        .then(r => r.json())
        .then(json => {
          if (json.success) {
            this.successMessage = 'Guardado correctamente';
            this.showFormMode = false;
            this.fetchData();
          } else {
            this.errorMessage = json.message || 'Error al guardar';
          }
        })
        .catch(() => this.errorMessage = 'Error de red');
    },
    deleteRow(row) {
      if (!confirm('¿Está seguro de eliminar este mercado?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete', module: 'catalogo_mercados', payload: { oficina: row.oficina, num_mercado_nvo: row.num_mercado_nvo } })
      })
        .then(r => r.json())
        .then(json => {
          if (json.success) {
            this.successMessage = 'Eliminado correctamente';
            this.fetchData();
          } else {
            this.errorMessage = json.message || 'Error al eliminar';
          }
        })
        .catch(() => this.errorMessage = 'Error de red');
    },
    showReport() {
      this.showReportDialog = true;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'report', module: 'catalogo_mercados', payload: { oficina: null } })
      })
        .then(r => r.json())
        .then(json => {
          if (json.success) {
            this.reportRows = json.data;
          } else {
            this.reportRows = [];
          }
        });
    }
  }
}
</script>


<style scoped>
/* Los estilos municipales se heredan de las clases globales */
/* Estilos específicos del componente si son necesarios */
</style>
