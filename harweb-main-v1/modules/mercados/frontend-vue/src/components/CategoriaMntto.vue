<template>
  <div class="categoria-mntto-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Mantenimiento de Categorías</li>
      </ol>
    </nav>
    <h2>Mantenimiento de Categorías</h2>
    <div class="card mb-3">
      <div class="card-header">Agregar / Modificar Categoría</div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row">
            <div class="col-md-2">
              <label for="categoria">Categoría</label>
              <input type="number" v-model.number="form.categoria" id="categoria" class="form-control" min="1" max="12" :disabled="formMode==='edit'" required />
            </div>
            <div class="col-md-6">
              <label for="descripcion">Descripción</label>
              <input type="text" v-model="form.descripcion" id="descripcion" class="form-control" maxlength="30" required style="text-transform:uppercase" />
            </div>
            <div class="col-md-4 d-flex align-items-end">
              <button type="submit" class="btn btn-primary mr-2">{{ formMode==='edit' ? 'Actualizar' : 'Agregar' }}</button>
              <button type="button" class="btn btn-secondary" @click="resetForm">Cancelar</button>
            </div>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
        <div v-if="success" class="alert alert-success mt-2">{{ success }}</div>
      </div>
    </div>
    <div class="card">
      <div class="card-header">Listado de Categorías</div>
      <div class="card-body p-0">
        <table class="table table-striped mb-0">
          <thead>
            <tr>
              <th>Categoría</th>
              <th>Descripción</th>
              <th style="width:120px">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="cat in categorias" :key="cat.categoria">
              <td>{{ cat.categoria }}</td>
              <td>{{ cat.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-info mr-1" @click="editCategoria(cat)">Editar</button>
                <button class="btn btn-sm btn-danger" @click="deleteCategoria(cat)">Eliminar</button>
              </td>
            </tr>
            <tr v-if="categorias.length===0">
              <td colspan="3" class="text-center">No hay categorías registradas.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CategoriaMnttoPage',
  data() {
    return {
      categorias: [],
      form: {
        categoria: '',
        descripcion: ''
      },
      formMode: 'add', // 'add' | 'edit'
      error: '',
      success: ''
    }
  },
  mounted() {
    this.loadCategorias();
  },
  methods: {
    async loadCategorias() {
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', { action: 'categoria.list' });
        if (res.data.success) {
          this.categorias = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar categorías';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      if (!this.form.categoria || !this.form.descripcion) {
        this.error = 'Todos los campos son obligatorios';
        return;
      }
      let action = this.formMode === 'edit' ? 'categoria.update' : 'categoria.create';
      try {
        const res = await this.$axios.post('/api/execute', {
          action,
          data: {
            categoria: this.form.categoria,
            descripcion: this.form.descripcion
          }
        });
        if (res.data.success) {
          this.success = this.formMode === 'edit' ? 'Categoría actualizada correctamente' : 'Categoría agregada correctamente';
          this.resetForm();
          this.loadCategorias();
        } else {
          this.error = res.data.message || 'Error en la operación';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    editCategoria(cat) {
      this.form.categoria = cat.categoria;
      this.form.descripcion = cat.descripcion;
      this.formMode = 'edit';
      this.error = '';
      this.success = '';
    },
    async deleteCategoria(cat) {
      if (!confirm('¿Está seguro de eliminar la categoría ' + cat.categoria + '?')) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'categoria.delete',
          data: { categoria: cat.categoria }
        });
        if (res.data.success) {
          this.success = 'Categoría eliminada correctamente';
          this.loadCategorias();
        } else {
          this.error = res.data.message || 'Error al eliminar';
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    resetForm() {
      this.form = { categoria: '', descripcion: '' };
      this.formMode = 'add';
      this.error = '';
      this.success = '';
    }
  }
}
</script>

<style scoped>
.categoria-mntto-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 0;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.card {
  margin-bottom: 1.5rem;
}
</style>
