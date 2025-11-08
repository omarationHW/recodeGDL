<template>
  <div class="page-mannto-zonas">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Catálogo de Zonas</li>
      </ol>
    </nav>
    <h2>Catálogo de Zonas</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showForm('create')">Nueva Zona</button>
    </div>
    <table class="table table-bordered table-sm">
      <thead>
        <tr>
          <th>Control</th>
          <th>Zona</th>
          <th>Sub-Zona</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="zona in zonas" :key="zona.ctrol_zona">
          <td>{{ zona.ctrol_zona }}</td>
          <td>{{ zona.zona }}</td>
          <td>{{ zona.sub_zona }}</td>
          <td>{{ zona.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="showForm('edit', zona)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteZona(zona)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="formVisible" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h4 v-if="formMode==='create'">Alta de Zona</h4>
          <h4 v-else-if="formMode==='edit'">Edición de Zona</h4>
          <form @submit.prevent="submitForm">
            <div class="mb-2">
              <label>Zona</label>
              <input type="number" v-model.number="form.zona" :disabled="formMode==='edit'" class="form-control" required />
            </div>
            <div class="mb-2">
              <label>Sub-Zona</label>
              <input type="number" v-model.number="form.sub_zona" :disabled="formMode==='edit'" class="form-control" required />
            </div>
            <div class="mb-2">
              <label>Descripción</label>
              <input type="text" v-model="form.descripcion" class="form-control" maxlength="80" required />
            </div>
            <div class="mb-2" v-if="formMode==='edit'">
              <label>Control</label>
              <input type="number" v-model.number="form.ctrol_zona" class="form-control" disabled />
            </div>
            <div class="d-flex justify-content-end">
              <button type="submit" class="btn btn-success me-2">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
            <div v-if="formError" class="alert alert-danger mt-2">{{ formError }}</div>
          </form>
        </div>
      </div>
    </div>

    <div v-if="deleteConfirm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h5>¿Está seguro de eliminar la zona?</h5>
          <div class="mb-2">Zona: {{ deleteTarget.zona }} - Sub-Zona: {{ deleteTarget.sub_zona }}</div>
          <div class="d-flex justify-content-end">
            <button class="btn btn-danger me-2" @click="confirmDelete">Eliminar</button>
            <button class="btn btn-secondary" @click="deleteConfirm=false">Cancelar</button>
          </div>
          <div v-if="deleteError" class="alert alert-danger mt-2">{{ deleteError }}</div>
        </div>
      </div>
    </div>

    <div v-if="message" class="alert alert-info mt-3">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ManntoZonasPage',
  data() {
    return {
      zonas: [],
      formVisible: false,
      formMode: 'create',
      form: {
        zona: '',
        sub_zona: '',
        descripcion: '',
        ctrol_zona: null
      },
      formError: '',
      deleteConfirm: false,
      deleteTarget: null,
      deleteError: '',
      message: ''
    };
  },
  created() {
    this.loadZonas();
  },
  methods: {
    async loadZonas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'ZONAS_LIST' })
      });
      const data = await res.json();
      if (data.success) {
        this.zonas = data.data;
      } else {
        this.message = data.message || 'Error al cargar zonas';
      }
    },
    showForm(mode, zona = null) {
      this.formMode = mode;
      this.formError = '';
      if (mode === 'create') {
        this.form = { zona: '', sub_zona: '', descripcion: '', ctrol_zona: null };
      } else if (mode === 'edit' && zona) {
        this.form = { ...zona };
      }
      this.formVisible = true;
    },
    closeForm() {
      this.formVisible = false;
      this.formError = '';
    },
    async submitForm() {
      this.formError = '';
      let action = this.formMode === 'create' ? 'ZONAS_CREATE' : 'ZONAS_UPDATE';
      let payload = {
        zona: this.form.zona,
        sub_zona: this.form.sub_zona,
        descripcion: this.form.descripcion
      };
      if (this.formMode === 'edit') {
        payload.ctrol_zona = this.form.ctrol_zona;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, payload })
      });
      const data = await res.json();
      if (data.success) {
        this.message = this.formMode === 'create' ? 'Zona creada correctamente' : 'Zona actualizada correctamente';
        this.formVisible = false;
        this.loadZonas();
      } else {
        this.formError = data.message || 'Error en el formulario';
      }
    },
    deleteZona(zona) {
      this.deleteTarget = zona;
      this.deleteError = '';
      this.deleteConfirm = true;
    },
    async confirmDelete() {
      this.deleteError = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'ZONAS_DELETE', payload: { ctrol_zona: this.deleteTarget.ctrol_zona } })
      });
      const data = await res.json();
      if (data.success) {
        this.message = 'Zona eliminada correctamente';
        this.deleteConfirm = false;
        this.loadZonas();
      } else {
        this.deleteError = data.message || 'No se pudo eliminar la zona';
      }
    }
  }
};
</script>

<style scoped>
.page-mannto-zonas {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 100%;
  max-width: 400px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>
