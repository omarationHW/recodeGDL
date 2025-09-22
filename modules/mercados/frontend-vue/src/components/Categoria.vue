<template>
  <div class="categoria-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Categorías</li>
      </ol>
    </nav>
    <h2>Categorías</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateModal = true">Agregar Categoría</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Categoría</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="cat in categorias" :key="cat.categoria">
          <td>{{ cat.categoria }}</td>
          <td>{{ cat.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editCategoria(cat)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteCategoria(cat.categoria)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Crear/Editar -->
    <div v-if="showCreateModal || showEditModal" class="modal-backdrop">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">{{ showEditModal ? 'Editar' : 'Agregar' }} Categoría</h5>
            <button type="button" class="close" @click="closeModal">&times;</button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="showEditModal ? updateCategoria() : createCategoria()">
              <div class="form-group">
                <label for="categoria">Categoría</label>
                <input type="number" v-model.number="form.categoria" :disabled="showEditModal" class="form-control" required />
              </div>
              <div class="form-group">
                <label for="descripcion">Descripción</label>
                <input type="text" v-model="form.descripcion" maxlength="30" class="form-control" required />
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
                <button type="submit" class="btn btn-primary">Guardar</button>
              </div>
            </form>
          </div>
        </div>
      </div>
    </div>

    <!-- Mensaje -->
    <div v-if="message" class="alert alert-info mt-3">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'CategoriaPage',
  data() {
    return {
      categorias: [],
      showCreateModal: false,
      showEditModal: false,
      form: {
        categoria: '',
        descripcion: ''
      },
      message: ''
    };
  },
  mounted() {
    this.fetchCategorias();
  },
  methods: {
    fetchCategorias() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'categoria.list' } })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.categorias = res.eResponse.data;
          } else {
            this.message = res.eResponse.message;
          }
        });
    },
    createCategoria() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'categoria.create',
            params: {
              categoria: this.form.categoria,
              descripcion: this.form.descripcion
            }
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.message = 'Categoría agregada correctamente';
            this.closeModal();
            this.fetchCategorias();
          } else {
            this.message = res.eResponse.message;
          }
        });
    },
    editCategoria(cat) {
      this.form = { ...cat };
      this.showEditModal = true;
    },
    updateCategoria() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'categoria.update',
            params: {
              categoria: this.form.categoria,
              descripcion: this.form.descripcion
            }
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.message = 'Categoría actualizada correctamente';
            this.closeModal();
            this.fetchCategorias();
          } else {
            this.message = res.eResponse.message;
          }
        });
    },
    deleteCategoria(categoria) {
      if (!confirm('¿Está seguro de eliminar la categoría?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'categoria.delete',
            params: { categoria }
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.message = 'Categoría eliminada correctamente';
            this.fetchCategorias();
          } else {
            this.message = res.eResponse.message;
          }
        });
    },
    closeModal() {
      this.showCreateModal = false;
      this.showEditModal = false;
      this.form = { categoria: '', descripcion: '' };
    }
  }
};
</script>

<style scoped>
.categoria-page {
  max-width: 800px;
  margin: 0 auto;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-dialog {
  background: #fff;
  border-radius: 4px;
  min-width: 350px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>
