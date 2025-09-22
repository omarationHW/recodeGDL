<template>
  <div class="page-container">
    <h1>Catálogo de Tipos de Aseo</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Tipos de Aseo</li>
      </ol>
    </nav>
    <div class="actions mb-3">
      <button class="btn btn-success" @click="openForm('create')">Alta</button>
      <button class="btn btn-secondary" :disabled="!selectedRow" @click="openForm('update')">Editar</button>
      <button class="btn btn-danger" :disabled="!selectedRow" @click="openForm('delete')">Eliminar</button>
      <button class="btn btn-outline-primary float-end" @click="fetchData">Refrescar</button>
    </div>
    <table class="table table-striped table-hover">
      <thead>
        <tr>
          <th>Control</th>
          <th>Tipo</th>
          <th>Descripción</th>
          <th>Cta. Aplicación</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in tiposAseo" :key="row.ctrol_aseo" :class="{selected: selectedRow && selectedRow.ctrol_aseo === row.ctrol_aseo}" @click="selectRow(row)">
          <td>{{ row.ctrol_aseo }}</td>
          <td>{{ row.tipo_aseo }}</td>
          <td>{{ row.descripcion }}</td>
          <td>{{ row.cta_aplicacion }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="showForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3 v-if="formMode==='create'">Alta de Tipo de Aseo</h3>
          <h3 v-else-if="formMode==='update'">Editar Tipo de Aseo</h3>
          <h3 v-else-if="formMode==='delete'">Eliminar Tipo de Aseo</h3>
          <form @submit.prevent="submitForm">
            <div class="mb-2">
              <label>Tipo de Aseo</label>
              <input v-model="form.tipo_aseo" :disabled="formMode!=='create'" maxlength="1" required class="form-control" />
            </div>
            <div class="mb-2">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="80" required class="form-control" />
            </div>
            <div class="mb-2">
              <label>Cta. Aplicación</label>
              <input v-model.number="form.cta_aplicacion" type="number" required class="form-control" />
            </div>
            <div class="modal-footer">
              <button v-if="formMode==='create'" class="btn btn-success" type="submit">Guardar</button>
              <button v-else-if="formMode==='update'" class="btn btn-primary" type="submit">Actualizar</button>
              <button v-else-if="formMode==='delete'" class="btn btn-danger" type="submit">Eliminar</button>
              <button class="btn btn-secondary" type="button" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="message" class="alert" :class="{'alert-success': messageType==='success', 'alert-danger': messageType==='error'}">
      {{ message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'TiposAseoPage',
  data() {
    return {
      tiposAseo: [],
      selectedRow: null,
      showForm: false,
      formMode: 'create', // create|update|delete
      form: {
        ctrol_aseo: null,
        tipo_aseo: '',
        descripcion: '',
        cta_aplicacion: ''
      },
      message: '',
      messageType: 'success',
      loading: false
    };
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.selectedRow = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'tipos_aseo.list'
        });
        if (res.data.status === 'success') {
          this.tiposAseo = res.data.data || [];
        } else {
          this.message = res.data.message || 'Error al cargar datos';
          this.messageType = 'error';
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
        this.messageType = 'error';
      }
      this.loading = false;
    },
    selectRow(row) {
      this.selectedRow = row;
    },
    openForm(mode) {
      this.formMode = mode;
      if (mode === 'create') {
        this.form = { ctrol_aseo: null, tipo_aseo: '', descripcion: '', cta_aplicacion: '' };
      } else if (this.selectedRow) {
        this.form = { ...this.selectedRow };
      }
      this.showForm = true;
      this.message = '';
    },
    closeForm() {
      this.showForm = false;
      this.message = '';
    },
    async submitForm() {
      let action = '';
      let params = {};
      if (this.formMode === 'create') {
        action = 'tipos_aseo.create';
        params = {
          tipo_aseo: this.form.tipo_aseo,
          descripcion: this.form.descripcion,
          cta_aplicacion: this.form.cta_aplicacion,
          usuario: 1 // TODO: obtener usuario real
        };
      } else if (this.formMode === 'update') {
        action = 'tipos_aseo.update';
        params = {
          ctrol_aseo: this.form.ctrol_aseo,
          tipo_aseo: this.form.tipo_aseo,
          descripcion: this.form.descripcion,
          cta_aplicacion: this.form.cta_aplicacion,
          usuario: 1
        };
      } else if (this.formMode === 'delete') {
        action = 'tipos_aseo.delete';
        params = {
          ctrol_aseo: this.form.ctrol_aseo,
          usuario: 1
        };
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action,
          payload: params
        });
        if (res.data.status === 'success') {
          this.message = 'Operación exitosa';
          this.messageType = 'success';
          this.closeForm();
          this.fetchData();
        } else {
          this.message = res.data.message || 'Error en la operación';
          this.messageType = 'error';
        }
      } catch (error) {
        this.message = 'Error de conexión: ' + error.message;
        this.messageType = 'error';
      }
    }
  }
};
</script>

<style scoped>
.page-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.selected {
  background: #e0f7fa;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 400px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
  padding: 2rem;
}
.modal-footer {
  margin-top: 1rem;
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}
.alert {
  margin-top: 1rem;
}
</style>
