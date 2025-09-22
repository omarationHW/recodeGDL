<template>
  <div class="cve-cuota-mntto-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Claves de Cuota</li>
      </ol>
    </nav>
    <h2>Mantenimiento de Claves para la Cuota</h2>
    <div v-if="!editing">
      <button class="btn btn-primary mb-2" @click="startCreate">Nueva Clave de Cuota</button>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Clave Cuota</th>
            <th>Descripción</th>
            <th style="width: 160px;">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in items" :key="item.clave_cuota">
            <td>{{ item.clave_cuota }}</td>
            <td>{{ item.descripcion }}</td>
            <td>
              <button class="btn btn-sm btn-info" @click="startEdit(item)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="deleteItem(item)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="items.length === 0">
            <td colspan="3" class="text-center">No hay registros</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-else>
      <form @submit.prevent="save">
        <div class="form-group">
          <label for="clave_cuota">Clave Cuota</label>
          <input type="number" min="1" max="5000" class="form-control" id="clave_cuota" v-model.number="form.clave_cuota" :disabled="editMode === 'edit'">
        </div>
        <div class="form-group">
          <label for="descripcion">Descripción</label>
          <input type="text" class="form-control" id="descripcion" v-model="form.descripcion" maxlength="60" style="text-transform:uppercase">
        </div>
        <div class="form-group mt-3">
          <button type="submit" class="btn btn-success">Guardar</button>
          <button type="button" class="btn btn-secondary ml-2" @click="cancel">Cancelar</button>
        </div>
      </form>
    </div>
    <div v-if="message" class="alert mt-3" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'CveCuotaMnttoPage',
  data() {
    return {
      items: [],
      editing: false,
      editMode: 'create', // 'create' or 'edit'
      form: {
        clave_cuota: '',
        descripcion: ''
      },
      message: '',
      success: true
    };
  },
  created() {
    this.fetchItems();
  },
  methods: {
    async fetchItems() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list_cve_cuota' })
      });
      const data = await res.json();
      if (data.success) {
        this.items = data.data;
      } else {
        this.message = data.message;
        this.success = false;
      }
    },
    startCreate() {
      this.editing = true;
      this.editMode = 'create';
      this.form = { clave_cuota: '', descripcion: '' };
      this.message = '';
    },
    startEdit(item) {
      this.editing = true;
      this.editMode = 'edit';
      this.form = { clave_cuota: item.clave_cuota, descripcion: item.descripcion };
      this.message = '';
    },
    async save() {
      if (!this.form.descripcion) {
        this.message = 'La descripción no puede ser nula';
        this.success = false;
        return;
      }
      if (this.editMode === 'create') {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'create_cve_cuota', params: this.form })
        });
        const data = await res.json();
        this.message = data.message;
        this.success = data.success;
        if (data.success) {
          this.editing = false;
          this.fetchItems();
        }
      } else {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'update_cve_cuota', params: this.form })
        });
        const data = await res.json();
        this.message = data.message;
        this.success = data.success;
        if (data.success) {
          this.editing = false;
          this.fetchItems();
        }
      }
    },
    async deleteItem(item) {
      if (!confirm('¿Está seguro de eliminar la clave de cuota ' + item.clave_cuota + '?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'delete_cve_cuota', params: { clave_cuota: item.clave_cuota } })
      });
      const data = await res.json();
      this.message = data.message;
      this.success = data.success;
      if (data.success) {
        this.fetchItems();
      }
    },
    cancel() {
      this.editing = false;
      this.message = '';
    }
  }
};
</script>

<style scoped>
.cve-cuota-mntto-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
