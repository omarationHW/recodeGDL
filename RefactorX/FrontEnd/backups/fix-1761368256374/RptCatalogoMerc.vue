<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="book" /></div>
      <div class="module-view-info">
        <h1>Catálogo de Mercados</h1>
        <p>Mercados - Catálogo de Mercados</p>
      </div>
    </div>

    <div class="module-view-content">
    <h1>Catálogo de Mercados Municipales</h1>
    <div class="mb-3">
      <button class="btn-municipal-primary" @click="showCreateForm = true">Agregar Mercado</button>
    </div>
    <table class="municipal-table">
      <thead>
        <tr>
          <th>Oficina</th>
          <th>Núm. Mercado</th>
          <th>Nombre</th>
          <th>Categoría</th>
          <th>Cuenta Ingreso</th>
          <th>Cuenta Energía</th>
          <th>Zona</th>
          <th>Tipo Emisión</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="mercado in mercados" :key="mercado.oficina + '-' + mercado.num_mercado_nvo">
          <td>{{ mercado.oficina }}</td>
          <td>{{ mercado.num_mercado_nvo }}</td>
          <td>{{ mercado.descripcion }}</td>
          <td>{{ mercado.categoria }}</td>
          <td>{{ mercado.cuenta_ingreso }}</td>
          <td>{{ mercado.cuenta_energia }}</td>
          <td>{{ mercado.id_zona }}</td>
          <td>{{ mercado.tipo_emision }}</td>
          <td>
            <button class="btn-icon btn-warning" @click="editMercado(mercado)">Editar</button>
            <button class="btn-icon btn-danger" @click="deleteMercado(mercado)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <!-- Crear/Editar Formulario -->
    <div v-if="showCreateForm || showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEditForm ? 'Editar Mercado' : 'Agregar Mercado' }}</h3>
          <form @submit.prevent="showEditForm ? updateMercado() : createMercado()">
            <div class="form-group">
              <label>Oficina</label>
              <input v-model="form.oficina" type="number" class="municipal-form-control" required :readonly="showEditForm">
            </div>
            <div class="form-group">
              <label>Núm. Mercado</label>
              <input v-model="form.num_mercado_nvo" type="number" class="municipal-form-control" required :readonly="showEditForm">
            </div>
            <div class="form-group">
              <label>Nombre</label>
              <input v-model="form.descripcion" type="text" class="municipal-form-control" required>
            </div>
            <div class="form-group">
              <label>Categoría</label>
              <input v-model="form.categoria" type="number" class="municipal-form-control" required>
            </div>
            <div class="form-group">
              <label>Cuenta Ingreso</label>
              <input v-model="form.cuenta_ingreso" type="number" class="municipal-form-control" required>
            </div>
            <div class="form-group">
              <label>Cuenta Energía</label>
              <input v-model="form.cuenta_energia" type="number" class="municipal-form-control">
            </div>
            <div class="form-group">
              <label>Zona</label>
              <input v-model="form.id_zona" type="number" class="municipal-form-control" required>
            </div>
            <div class="form-group">
              <label>Tipo Emisión</label>
              <select v-model="form.tipo_emision" class="municipal-form-control" required>
                <option value="M">Masiva</option>
                <option value="D">Diskette</option>
                <option value="B">Baja</option>
              </select>
            </div>
            <div class="form-group text-right">
              <button type="submit" class="btn-municipal-success">Guardar</button>
              <button type="button" class="btn-municipal-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- Reporte -->
    <div class="mt-4">
      <button class="btn-municipal-info" @click="generarReporte">Generar Reporte PDF</button>
      <a v-if="reporteUrl" :href="reporteUrl" target="_blank" class="btn btn-success ml-2">Descargar PDF</a>
    </div>
  </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CatalogoMercadosPage',
  data() {
    return {
      mercados: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        oficina: '',
        num_mercado_nvo: '',
        descripcion: '',
        categoria: '',
        cuenta_ingreso: '',
        cuenta_energia: '',
        id_zona: '',
        tipo_emision: 'M',
        usuario_id: 1 // Simulación, reemplazar por usuario logueado
      },
      reporteUrl: ''
    };
  },
  mounted() {
    this.fetchMercados();
  },
  methods: {
    fetchMercados() {
      this.$axios.post('/api/execute', {
        action: 'getCatalogoMercados',
        params: {}
      }).then(res => {
        if (res.data.success) {
          this.mercados = res.data.data;
        }
      });
    },
    createMercado() {
      this.$axios.post('/api/execute', {
        action: 'createCatalogoMercado',
        params: this.form
      }).then(res => {
        if (res.data.success) {
          this.fetchMercados();
          this.closeForm();
        }
      });
    },
    editMercado(mercado) {
      this.form = { ...mercado };
      this.showEditForm = true;
      this.showCreateForm = false;
    },
    updateMercado() {
      this.$axios.post('/api/execute', {
        action: 'updateCatalogoMercado',
        params: this.form
      }).then(res => {
        if (res.data.success) {
          this.fetchMercados();
          this.closeForm();
        }
      });
    },
    deleteMercado(mercado) {
      if (confirm('¿Está seguro de eliminar este mercado?')) {
        this.$axios.post('/api/execute', {
          action: 'deleteCatalogoMercado',
          params: {
            oficina: mercado.oficina,
            num_mercado_nvo: mercado.num_mercado_nvo
          }
        }).then(res => {
          if (res.data.success) {
            this.fetchMercados();
          }
        });
      }
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = {
        oficina: '',
        num_mercado_nvo: '',
        descripcion: '',
        categoria: '',
        cuenta_ingreso: '',
        cuenta_energia: '',
        id_zona: '',
        tipo_emision: 'M',
        usuario_id: 1
      };
    },
    generarReporte() {
      this.$axios.post('/api/execute', {
        action: 'getCatalogoMercadosReporte',
        params: {}
      }).then(res => {
        if (res.data.success && res.data.data && res.data.data.pdf_url) {
          this.reporteUrl = res.data.data.pdf_url;
        } else {
          alert('No se pudo generar el reporte.');
        }
      });
    }
  }
};
</script>

<style scoped>
.catalogo-mercados-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 500px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.33);
}
</style>
