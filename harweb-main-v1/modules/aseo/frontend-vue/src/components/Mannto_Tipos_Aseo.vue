<template>
  <div class="page-mannto-tipos-aseo">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Catálogo Tipos de Aseo</li>
      </ol>
    </nav>
    <h2>Catálogo de Tipos de Aseo</h2>
    <div class="actions mb-3">
      <button class="btn btn-primary" @click="showForm('create')">Nuevo Tipo de Aseo</button>
    </div>
    <table class="table table-bordered table-sm">
      <thead>
        <tr>
          <th>Control</th>
          <th>Tipo</th>
          <th>Descripción</th>
          <th>Cta. Aplicación</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in tiposAseo" :key="item.ctrol_aseo">
          <td>{{ item.ctrol_aseo }}</td>
          <td>{{ item.tipo_aseo }}</td>
          <td>{{ item.descripcion }}</td>
          <td>{{ item.cta_aplicacion }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="showForm('edit', item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="confirmDelete(item)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="tiposAseo.length === 0">
          <td colspan="5" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>

    <!-- Formulario Modal -->
    <div v-if="formVisible" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3 v-if="formMode==='create'">Alta de Tipo de Aseo</h3>
          <h3 v-else-if="formMode==='edit'">Edición de Tipo de Aseo</h3>
          <form @submit.prevent="submitForm">
            <div class="form-group">
              <label>Tipo de Aseo</label>
              <input v-model="form.tipo_aseo" :readonly="formMode==='edit'" maxlength="1" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input v-model="form.descripcion" maxlength="80" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Cta. Aplicación</label>
              <input v-model.number="form.cta_aplicacion" type="number" min="1" max="999999" class="form-control" required @blur="validateCtaAplicacion" />
              <small v-if="ctaAplicacionError" class="text-danger">Cuenta de aplicación no existe</small>
            </div>
            <div class="form-group text-right">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- Fin Modal -->
  </div>
</template>

<script>
export default {
  name: 'ManntoTiposAseo',
  data() {
    return {
      tiposAseo: [],
      formVisible: false,
      formMode: 'create',
      form: {
        tipo_aseo: '',
        descripcion: '',
        cta_aplicacion: ''
      },
      ctaAplicacionError: false
    };
  },
  mounted() {
    this.loadTiposAseo();
  },
  methods: {
    async loadTiposAseo() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list' })
      });
      const json = await res.json();
      if (json.success) {
        this.tiposAseo = json.data;
      } else {
        alert(json.message || 'Error al cargar datos');
      }
    },
    showForm(mode, item = null) {
      this.formMode = mode;
      this.ctaAplicacionError = false;
      if (mode === 'create') {
        this.form = { tipo_aseo: '', descripcion: '', cta_aplicacion: '' };
      } else if (mode === 'edit' && item) {
        this.form = {
          tipo_aseo: item.tipo_aseo,
          descripcion: item.descripcion,
          cta_aplicacion: item.cta_aplicacion
        };
      }
      this.formVisible = true;
    },
    closeForm() {
      this.formVisible = false;
    },
    async submitForm() {
      if (!this.form.tipo_aseo || !this.form.descripcion || !this.form.cta_aplicacion) {
        alert('Todos los campos son obligatorios');
        return;
      }
      if (this.ctaAplicacionError) {
        alert('Cuenta de aplicación no válida');
        return;
      }
      const action = this.formMode === 'create' ? 'create' : 'update';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, data: this.form })
      });
      const json = await res.json();
      if (json.success) {
        this.loadTiposAseo();
        this.closeForm();
      } else {
        alert(json.message || 'Error al guardar');
      }
    },
    async confirmDelete(item) {
      if (!confirm('¿Está seguro de eliminar este tipo de aseo?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete', data: { tipo_aseo: item.tipo_aseo } })
      });
      const json = await res.json();
      if (json.success) {
        this.loadTiposAseo();
      } else {
        alert(json.message || 'No se pudo eliminar');
      }
    },
    async validateCtaAplicacion() {
      if (!this.form.cta_aplicacion) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'validate_cta_aplicacion', data: { cta_aplicacion: this.form.cta_aplicacion } })
      });
      const json = await res.json();
      this.ctaAplicacionError = !json.success;
    }
  }
};
</script>

<style scoped>
.page-mannto-tipos-aseo {
  max-width: 800px;
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
